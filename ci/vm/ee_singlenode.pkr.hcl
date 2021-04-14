variable "primehub_version" {
  type = string
  default = "${env("PRIMEHUB_VERSION")}"
}

variable "ami_name" {
  type = string
  default = "${env("CUSTOM_AMI_NAME")}"
}
variable "region" {
  type    = string
  default = "ap-northeast-1"
}

source "amazon-ebs" "eesinglenode" {
  ami_name      = "${var.ami_name}"
  instance_type = "c4.2xlarge"
  ssh_pty = true
  region        = "${var.region}"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-bionic-18.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 40
    volume_type = "gp2"
    delete_on_termination = true
  }
  ssh_username = "ubuntu"
}

# a build block invokes sources and runs provisioning steps on them.
build {
  sources = ["source.amazon-ebs.eesinglenode"]

  provisioner "shell" {
    expect_disconnect = true
    script = "./server_setup.sh"
  }
  provisioner "file" {
    destination = "/home/ubuntu/"
    source      = "./install_primehub.sh"
  }
  provisioner "shell" {
    inline = ["./install_primehub.sh ${var.primehub_version}"]
  }
  provisioner "shell" {
    expect_disconnect = true
    script = "./clean_up.sh"
  }
}

