resource "aws_eip" "IP_RedHat01" {
  instance 			= "${aws_instance.RedHat01.id}"
}

resource "aws_instance" "RedHat01" {
  ami           	= "ami-c90195b0"
  instance_type 	= "t2.micro"
  key_name				= "AdmKey"
  security_groups	= [
        "AdmPorts",
  ]
	tags {
        Name = "RedHat01"
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
    	"sudo yum install java-1.8.0-openjdk vim wget git whois fail2ban fail2ban-systemd ansible unzip -y",
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

  provisioner "remote-exec" {
    inline				= [
    	"sudo mv /tmp/sshd.local /etc/fail2ban/jail.d/sshd.local",
    	"sudo chown root:root /etc/fail2ban/jail.d/sshd.local",
    	"sudo systemctl start fail2ban.service",
    ]
    connection {
			type = "ssh"
			user = "ec2-user"
			private_key = "${file("${path.module}/keys/id_rsa.")}"
  	}
  }
  
  provisioner "file" {
  	source				= "files/ansible.zip"
  	destination		= "/home/ec2-user/ansible.zip"
  	connection {
			type = "ssh"
			user = "ec2-user"
			private_key = "${file("${path.module}/keys/id_rsa.")}"
  	}
  }

  provisioner "file" {
  	source				= "files/ansible.cfg"
  	destination		= "/tmp/ansible.cfg"
  	connection {
			type = "ssh"
			user = "ec2-user"
			private_key = "${file("${path.module}/keys/id_rsa.")}"
  	}
  }

  provisioner "remote-exec" {
    inline				= [
    	"sudo mv /etc/ansible/ansible.cfg /etc/ansible/ansible.orig",
    	"sudo mv /tmp/ansible.cfg /etc/ansible/ansible.cfg",
    	"unzip /home/ec2-user/ansible.zip",
    	"rm -rf ansible.zip",
    	"echo \"[RedHat]\" >> ~/hosts",
    	"echo \"${aws_eip.IP_RedHat02.public_ip}\" >> ~/hosts",
    	"echo \"[Ubuntu]\" >> ~/hosts",
    	"echo \"${aws_eip.IP_Ubuntu01.public_ip}\" >> ~/hosts",
    	"sudo mv /etc/ansible/hosts /etc/ansible/hosts.orig",
    	"sudo mv ~/hosts /etc/ansible/hosts",
    	"sudo chmod 644 /etc/ansible/hosts",
    	"sudo chown root:root /etc/ansible/hosts",
    	"sudo chmod +x /home/ec2-user/lstusr.sh /home/ec2-user/ports.sh",
    	"ansible-playbook addHosts.yml",
    	"ansible-playbook basic_config.yml",
    	"sudo reboot",
    ]
    connection {
			type = "ssh"
			user = "ec2-user"
			private_key = "${file("${path.module}/keys/id_rsa.")}"
  	}
  }
  depends_on = ["aws_eip.IP_RedHat02"]
}
