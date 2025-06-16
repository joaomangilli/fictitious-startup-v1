packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.7"
      source  = "github.com/hashicorp/amazon"
    }
  }

  required_plugins {
    amazon-ami-management = {
      version = ">= 1.6.1"
      source = "github.com/wata727/amazon-ami-management"
    }
  }
}

variable "version" {}

source "amazon-ebs" "amazon-linux" {
  ami_name                    = "fictitious-startup-${var.version}"
  instance_type               = "t2.micro"
  region                      = "us-east-2"
  ssh_username                = "ubuntu"
  vpc_id                      = "vpc-030768e9484d41a45"
  subnet_id                   = "subnet-0e86a7685879c89d3"
  associate_public_ip_address = true

  source_ami_filter {
    filters = {
      name = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server*"
      root-device-type = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }

  tags = {
    Amazon_AMI_Management_Identifier = "fictitious-startup"
  }
}

build {
  sources = [
    "source.amazon-ebs.amazon-linux"
  ]

  provisioner "file" {
    source = "./"
    destination = "/tmp"
  }

  provisioner "shell" {
    inline = [
      "cp -r /tmp /opt/app",
    ]
  }

  provisioner "shell" {
    script = "setup.sh"
  }

  post-processor "amazon-ami-management" {
    regions       = ["us-east-2"]
    identifier    = "fictitious-startup"
    keep_releases = 2
  }
}
