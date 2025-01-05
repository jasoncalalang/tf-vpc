# Fetch existing SSH keys
data "ibm_is_ssh_keys" "existing_keys" {}

# Create an SSH Key in IBM Cloud if it does not exist
resource "ibm_is_ssh_key" "orbix_key" {
  count      = length([for key in data.ibm_is_ssh_keys.existing_keys.keys : key.name if key.name == "orbix-vsi-ssh"]) == 0 ? 1 : 0
  name       = "orbix-vsi-ssh"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0mSLU9Vdy7Dc29yLPL+CDOtLDN4wTdaxbmod7jOZcn7hW8H6z9xHTFba7vJZY/06mhHmexCe6hS8WSUjmGEIU7pqhiL4fRg+JoRL26T23LQS1VM3iKy8pfOM5eSaTL66VlWZFnkyHJH4rpWrjguRgZOAwt4+/v7hE/YiK6Bl9U3XbCTJ5XGsjxtnt3VZLhtr5OBiv1zjMa8dURI3iUZQ8T1e7/AxvyvY28TUfLaCvWoPFgzkA2d44TKj+ZArLikW6ZQgY9PXrt6jl1GhU03w+vIYEr2w8yNPuVSe8KsRd9szAiCWFEPQgV/i8hjz4DwuO44D5g9bf48Re1BZO2dFb0CzwigtFgkUV4GO5jNKVmqlqBygtww2XxP0L02U6S8J4ShsSV1jllsFYVX6vbM3MhK4P8EqsUuWKrqBBApr/YBIZLjTyTnorHv9X1G+YW6flLsV31LDB+5wkBmL782UzypPACnQMcegnhqMJb8wgM3cLHGRmmvtU8D7MGLNuuDGgCiOiNQx6oOs7wDeSpzcVZFuY5oPTEZRtzcRYCp8/dSrBjVurUC/NebQFDzdFSUMQnLgZ2EWDL9srL6QnJVtTzTr65qT5wLm9CWEoaLGuH41yNVeBWWsBEaLZ2fhPqqUArg0jb6KFh/Izpm7IZmZmb9PZRQ5ZKfmtO7NcEZXXAQ=="
}

# Use a null resource to conditionally create the SSH key
resource "null_resource" "create_ssh_key" {
  count = length([for key in data.ibm_is_ssh_keys.existing_keys.keys : key.name if key.name == "orbix-vsi-ssh"]) == 0 ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'SSH key created'"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}
