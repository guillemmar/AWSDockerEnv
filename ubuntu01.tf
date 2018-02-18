resource "aws_eip" "IP_Ubuntu01" {
  instance 			= "${aws_instance.Ubuntu01.id}"
  
  depends_on = ["aws_key_pair.AdmKey"]
}

resource "aws_instance" "Ubuntu01" {
  ami           	= "ami-1b791862"
  instance_type 	= "t2.micro"
  key_name				= "AdmKey"
  security_groups	= [
        "WebPorts",
        "AdmPorts",
  ]
	tags {
        Name = "Ubuntu01"
  }

  provisioner "remote-exec" {
    inline				= [
    	"sudo useradd -m -c \"ec2-user\" ec2-user -s /bin/bash",
    	"sudo mkdir /home/ec2-user/.ssh",
    ]
    connection {
			type = "ssh"
			user = "ubuntu"
			private_key = "${file("${path.module}/keys/id_rsa.")}"
  	}
  }

	provisioner "file" {
  	source				= "keys/id_rsa."
  	destination		= "/tmp/id_rsa"
  	connection {
			type = "ssh"
			user = "ubuntu"
			private_key = "${file("${path.module}/keys/id_rsa.")}"
  	}
  }
  
  provisioner "file" {
  	source				= "keys/id_rsa.pub"
  	destination		= "/tmp/id_rsa.pub"
  	connection {
			type = "ssh"
			user = "ubuntu"
			private_key = "${file("${path.module}/keys/id_rsa.")}"
  	}
  }

  provisioner "file" {
  	source				= "files/simple-web-server.zip"
  	destination		= "/tmp/simple-web-server.zip"
  	connection {
			type = "ssh"
			user = "ubuntu"
			private_key = "${file("${path.module}/keys/id_rsa.")}"
  	}
  }

  provisioner "remote-exec" {
    inline				= [
    	"sudo chown ubuntu:ubuntu /home/ec2-user/.ssh -R",
    	"sudo mv /tmp/id_rsa /home/ec2-user/.ssh/",
    	"sudo mv /tmp/id_rsa.pub /home/ec2-user/.ssh/",
    	"sudo cat /home/ec2-user/.ssh/id_rsa.pub > /home/ec2-user/.ssh/authorized_keys",
    	"sudo chmod 600 /home/ec2-user/.ssh/*",
    	"sudo chown ec2-user:ec2-user /home/ec2-user/.ssh/authorized_keys",
    	"sudo chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa.",
    	"sudo chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa.pub",
    	"sudo chown ec2-user:ec2-user /home/ec2-user/.ssh/",
    	"sudo chmod 700 /home/ec2-user/.ssh",
    	"echo \"ec2-user ALL=(ALL) NOPASSWD:ALL\" >> /tmp/91-ec2-user",
    	"sudo mv /tmp/91-ec2-user /etc/sudoers.d/91-ec2-user",
    	"sudo chmod 440 /etc/sudoers.d/91-ec2-user",
    	"sudo chown root:root /etc/sudoers.d/91-ec2-user",
    	"sudo apt-get install python unzip -y",
    	"unzip /tmp/simple-web-server.zip",
    	"sudo mv ~/simple-web-server/ /home/ec2-user/",
    	"sudo chown ec2-user:ec2-user /home/ec2-user/simple-web-server/ -R",
    	"rm -rf /tmp/simple-web-server.zip",
    	"sudo reboot",
    ]
    connection {
			type = "ssh"
			user = "ubuntu"
			private_key = "${file("${path.module}/keys/id_rsa.")}"
  	}
  }
  
  depends_on = ["aws_security_group.WebPorts"]
}
