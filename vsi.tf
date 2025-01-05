resource ibm_is_volume home-vol {
  name      = "home-vol-123"
  profile   = "general-purpose"    # or "5iops-tier", "10iops-tier", etc.
  capacity  = 10                   # in GB
  zone      = "jp-tok-1"        # adjust to match your region/zone
}

resource ibm_is_instance test-vsi {
  name    = var.vsi_name
  profile = "bx2-2x8"
  image   = "r022-d5e7a447-981e-4ffe-906e-1ff648690bf9"
  zone    = "jp-tok-1"
  vpc     = ibm_is_vpc.vpc[0].id
  depends_on = [ ibm_is_ssh_key.orbix_key, ibm_is_volume.home-vol ]
  
  # Attach primary network interface
  primary_network_interface {
    subnet = ibm_is_subnet.subnet_a.id
  }

  # Add SSH key
  keys = [
    ibm_is_ssh_key.orbix_key.id
  ]

  user_data = <<-EOT
#cloud-config
package_update: true
packages:
  - ansible-core
runcmd:
  - [ "/bin/bash", "-c", "set -e && dnf update -y && dnf install git ansible-core -y" ]
  - [ "/bin/bash", "-c", "DEVICE=/dev/vdd; MOUNT_POINT=/home; if [ -b $DEVICE ]; then \
        mkdir -p $MOUNT_POINT; \
        if ! blkid $DEVICE; then mkfs.xfs $DEVICE; fi; \
        BACKUP_DIR=/tmp/home_backup; mkdir -p $BACKUP_DIR; rsync -a $MOUNT_POINT/ $BACKUP_DIR/; \
        mount $DEVICE $MOUNT_POINT; \
        UUID=$(blkid -s UUID -o value $DEVICE); \
        echo \"UUID=$UUID $MOUNT_POINT xfs defaults 0 0\" >> /etc/fstab; fi" ]
  - [ "/bin/bash", "-c", "git clone https://github.com/jasoncalalang/ansible.git" ]
EOT
}

resource ibm_is_instance_volume_attachment vol-home-attach {
  instance = ibm_is_instance.test-vsi.id
  volume   = ibm_is_volume.home-vol.id

  # Setting this to true means the volume will be deleted
  # when you delete the VSI.
  delete_volume_on_instance_delete = true
}

resource "ibm_is_virtual_network_interface" "is-vni-vsi" {
  allow_ip_spoofing = true
  auto_delete = false
  enable_infrastructure_nat = true
  name = "test-vni"
  subnet = ibm_is_subnet.subnet_a.id
}

resource "ibm_is_instance_network_interface_floating_ip" "vni-test" {
  instance          = ibm_is_instance.test-vsi.id
  network_interface = ibm_is_instance.test-vsi.primary_network_interface[0].id
  floating_ip       = ibm_is_floating_ip.fip1.id
}