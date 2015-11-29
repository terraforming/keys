# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name = "terraform_example"
  description = "Used in the terraform"

  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# HTTP access from anywhere
  ingress {
    from_port = 3389
    to_port = 3389
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# HTTP access from anywhere
  ingress {
    from_port = 5985
    to_port = 5985
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# resource "aws_instance" "windows1" {
#   # The connection block tells our provisioner how to
#   # communicate with the resource (instance)
  

#   connection {
#     type = "winrm"
#     # The default username for our AMI
#     user = "Administrator"

#     password = "${var.admin_password}"
#   }

#   instance_type = "t2.micro"

#   # Lookup the correct AMI based on the region
#   # we specified
#   # ami = "${lookup(var.aws_amis, var.aws_region)}"
#   ami = "ami-5cfdeb3d"

#   # The name of our SSH keypair you've created and downloaded
#   # from the AWS console.
#   #
#   # https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#KeyPairs:
#   #
#   key_name = "${var.key_name}"

#   # Our Security group to allow HTTP and SSH access
#   security_groups = ["${aws_security_group.default.name}"]

  
#  user_data = <<EOF
# <script>
#   winrm quickconfig -q & winrm set winrm/config/winrs @{MaxMemoryPerShellMB="300"} & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"}
# </script>
# <powershell>
#   netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
#   $admin = [adsi]("WinNT://./administrator, user")
#   $admin.psbase.invoke("SetPassword", "${var.admin_password}")
# </powershell>
# EOF
#   provisioner "local-exec" {
#     command =  "sleep 7m"

#   }
#   # We run a remote provisioner on the instance after creating it.
#   # In this case, we just install nginx and start it. By default,
#   # this should be on port 80
#   provisioner "remote-exec" {
#     inline = [
#       "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))",
#       "choco install -y  git",
#       "choco install -y chefdk",

#        "git clone https://github.com/terraforming/keys.git",
#        "cd keys",
#       # "mkdir /home/ubuntu/.chef",
#       # "cp otaykalo.pem /home/ubuntu/.chef/",
      

#       # "cp nowhere-validator.pem /home/ubuntu/.chef/",
       
#       # "cp webui_priv.pem /home/ubuntu/.chef/",
#       # "cp worker-private.pem /home/ubuntu/.chef/",
#       # "mkdir /home/ubuntu/.chef/trusted_certs/",
       
#       # "cp ${aws_instance.chef-server.private_dns}.crt /home/ubuntu/.chef/trusted_certs/",
#       # "mkdir /home/ubuntu/chef_repo",

#       # "touch /home/ubuntu/.chef/knife.rb",
#       # "knife configure -s https://${aws_instance.chef-server.private_dns}:443 -u otaykalo --validation-client-name nowhere-validator --validation-key /home/ubuntu/.chef/nowhere-validator.pem -y -r /home/ubuntu/chef_repo -c /home/ubuntu/.chef/knife.rb",
#       # "knife ssl check"

#       ]
#   }




# provisioner "local-exec" {
#         command = "echo ${aws_instance.windows1.public_ip} > worker.txt"
#     }
# }


resource "aws_instance" "chef-server" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ubuntu"

    # The path to your keyfile
    key_file = "${var.key_path}"
  }

  instance_type = "t2.medium"

  # Lookup the correct AMI based on the region
  # we specified
  # ami = "${lookup(var.aws_amis, var.aws_region)}"
  ami = "ami-5189a661"

  # The name of our SSH keypair you've created and downloaded
  # from the AWS console.
  #
  # https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#KeyPairs:
  #
  key_name = "${var.key_name}"

  # Our Security group to allow HTTP and SSH access
  security_groups = ["${aws_security_group.default.name}"]

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
  provisioner "remote-exec" {
    inline = [

      "wget https://packagecloud.io/chef/stable/packages/ubuntu/trusty/chef-server-core_12.2.0-1_amd64.deb/download",
      "sudo dpkg -i download",
      "sudo chef-server-ctl reconfigure",

      "sudo chef-server-ctl user-create otaykalo oleg taykalo oleg.taykalo@gmail.com abcd123 --filename /home/ubuntu/otaykalo.pem",

       "sudo chef-server-ctl org-create nowhereland 'nowhereLand inc.' --association_user otaykalo --filename /home/ubuntu/nowhere-validator.pem",

 #      "sudo chef-server-ctl install opscode-manage",
  
   #  "sudo chef-server-ctl reconfigure",
 #      "sudo opscode-manage-ctl reconfigure",

  #     "sudo chef-server-ctl install opscode-reporting",
   #    "sudo chef-server-ctl reconfigure",
    #   "sudo opscode-reporting-ctl reconfigure",
       "sudo chef-server-ctl status",
       "sudo apt-get install git -y",
       "git clone https://github.com/terraforming/keys.git",
       "cd keys",
       "cp ~/otaykalo.pem .",
       "cp ~/nowhere-validator.pem .",
       
       "sudo cp /etc/opscode/webui_priv.pem /home/ubuntu/keys/",
       "sudo cp /etc/opscode/worker-private.pem /home/ubuntu/keys/",
       "sudo chmod 640 *.pem",
         
        
       "sudo cp /var/opt/opscode/nginx/ca/${aws_instance.chef-server.private_dns}.crt /home/ubuntu/keys/${aws_instance.chef-server.private_dns}.crt",
       "sudo chmod 666 /home/ubuntu/keys/${aws_instance.chef-server.private_dns}.crt",
       "git add .",
       "git config --global user.name 'terraform bot'", 
       "git config --global user.email 'terraform@terraform.com'",
       "git commit -m 'abc'",
       "git push --repo https://terraforming:1qaz2wsx@github.com/terraforming/keys.git"
       ]
  }
provisioner "local-exec" {
        command = "echo ${aws_instance.chef-server.public_ip} > file.txt"
    }
}
resource "aws_instance" "chef-worker" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ubuntu"

    # The path to your keyfile
    key_file = "${var.key_path}"
  }

  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  # ami = "${lookup(var.aws_amis, var.aws_region)}"
  ami = "ami-5189a661"

  # The name of our SSH keypair you've created and downloaded
  # from the AWS console.
  #
  # https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#KeyPairs:
  #
  key_name = "${var.key_name}"

  # Our Security group to allow HTTP and SSH access
  security_groups = ["${aws_security_group.default.name}"]

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
  provisioner "remote-exec" {
    inline = [

      "wget https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/10.04/x86_64/chef_12.5.1-1_amd64.deb",
      "sudo dpkg -i chef_12.5.1-1_amd64.deb",
      
       "sudo apt-get install git -y",
       "git clone https://github.com/terraforming/keys.git",
       "cd keys",
       "mkdir /home/ubuntu/.chef",
       "cp otaykalo.pem /home/ubuntu/.chef/",
       "cp nowhere-validator.pem /home/ubuntu/.chef/",
       
       "cp webui_priv.pem /home/ubuntu/.chef/",
       "cp worker-private.pem /home/ubuntu/.chef/",
       "mkdir /home/ubuntu/.chef/trusted_certs/",
       "cp ${aws_instance.chef-server.private_dns}.crt /home/ubuntu/.chef/trusted_certs/",
       "mkdir /home/ubuntu/chef_repo",

       "touch /home/ubuntu/.chef/knife.rb",
       "knife configure -s https://${aws_instance.chef-server.private_dns}:443 -u otaykalo --validation-client-name nowhere-validator --validation-key /home/ubuntu/.chef/nowhere-validator.pem -y -r /home/ubuntu/chef_repo -c /home/ubuntu/.chef/knife.rb",
       "knife ssl check"

      ]
  }




provisioner "local-exec" {
        command = "echo ${aws_instance.chef-worker.public_ip} > worker.txt"
    }
}

#   ami-5cfdeb3d windows
