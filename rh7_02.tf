resource "aws_eip" "IP_RedHat02" {
  instance 			= "${aws_instance.RedHat02.id}"
  
  depends_on = ["aws_eip.IP_Ubuntu01"]
}

resource "aws_instance" "RedHat02" {
  ami           	= "ami-c90195b0"
  instance_type 	= "t2.micro"
  key_name				= "AdmKey"
  security_groups	= [
        "WebPorts",
        "AdmPorts",
  ]
	tags {
        Name = "RedHat02"
  }

  provisioner "file" {
  	source				= "keys/id_rsa."
  	destination		= "/tmp/id_rsa"
  	connection {
			type = "ssh"
			user = "ec2-user"
			private_key = "${file("${path.module}/keys/id_rsa.")}"
  	}
  }
  
  provisioner "file" {
  	source				= "keys/id_rsa.pub"
  	destination		= "/tmp/id_rsa.pub"
  	connection {
			type = "ssh"
			user = "ec2-user"
			private_key = "${file("${path.module}/keys/id_rsa.")}"
  	}
  }

  provisioner "remote-exec" {
    inline				= [
    	"sudo mv /tmp/id_rsa /home/ec2-user/.ssh/",
    	"sudo mv /tmp/id_rsa.pub /home/ec2-user/.ssh/",
    	"sudo cat /home/ec2-user/.ssh/id_rsa.pub > /home/ec2-user/.ssh/authorized_keys",
    	"sudo chmod 600 /home/ec2-user/.ssh/*",
    	"sudo rpm -ivh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
    	"sudo yum install vim wget git whois fail2ban fail2ban-systemd unzip -y",
    	"sudo yum update -y selinux-policy*",
    	"sudo systemctl enable fail2ban.service"
    ]
    connection {
			type = "ssh"
			user = "ec2-user"
			private_key = "${file("${path.module}/keys/id_rsa.")}"
  	}
  }
  
  provisioner "file" {
  	source				= "fail2ban/sshd.local"
  	destination		= "/tmp/sshd.local"
  	connection {
			type = "ssh"
			user = "ec2-user"
			private_key = "${file("${path.module}/keys/id_rsa.")}"
  	}
  }
  
  provisioner "file" {
  	source				= "files/simple-web-server.zip"
  	destination		= "~/simple-web-server.zip"
  	connection {
			type = "ssh"
			user = "ec2-user"
			private_key = "${file("${path.module}/keys/id_rsa.")}"
  	}
  }

  provisioner "remote-exec" {
    inline				= [
    	"sudo mv /tmp/sshd.local /etc/fail2ban/jail.d/sshd.local",
    	"sudo chown root:root /etc/fail2ban/jail.d/sshd.local",
    	"sudo systemctl start fail2ban.service",
    	"unzip ~/simple-web-server.zip",
    	"rm -rf ~/simple-web-server.zip",
    	"sudo reboot",
    ]
    connection {
			type = "ssh"
			user = "ec2-user"
			private_key = "${file("${path.module}/keys/id_rsa.")}"
  	}
  }
  
  depends_on = ["aws_eip.IP_Ubuntu01"]
}
