# Docker env. build script

## Description:

This repository contains all scripts needed to deploy an environment for docker on [AWS](https://aws.amazon.com) using [Terraform](https://www.terraform.io/). 

The environment is composed by 3 VM's:

- RedHat01: 

This VM has [ansible](https://www.ansible.com/) installed and contains ansible role files and playbook for deploy and configure docker on RedHat02 and Ubuntu01 VM's. The ansible role also deploys a docker container called "simple-web-server" wich is a simple web server listening on port 80 that outputs some client information.

In the home user directory there are two bash scripts:
 - lstusr.sh: lists all system users and if they're logged in
 - ports.sh: lists all processes that listen on a TCP port and the port number.

- RedHat02: This VM has docker installed and runs the container simple-web-server.

- Ubuntu01: This VM has docker installed and runs the container simple-web-server.

## File list:

- directory "fail2ban": 

Contains the file "sshd.local" in order to configure fail2ban on RedHat VM's

- directory "keys": 

Contains "id-rsa" and "id_rsa.pub" files. Those are the public and private key for the 3 VM's. I provide these two files in order to fully automate the process but, due to the critical nature of a key pair, I strongly recomend that you generate your own key pair. An easy way to do that is with [Open-ssh](https://www.openssh.com/).

- directory "files": 

Contains "ansible.cfg" (ansible configuration file for "RedHat01"), "simple-web-server.zip" (contains the files needed to deploy the docker container for the aplication "simple-web-server") and "ansible.zip" (contains ansilbe role files, ansible playbooks and bash scripts lstuser.sh and ports.sh).

- root directory:

Contains terraform scripts for environment creation on AWS.

key.tf: AWS key pair
provider.tf: access_key, secret_key and region values of your AWS account.
secgrp.tf: AWS security groups for the VM's
rh7_01.tf: "RedHat01" VM definition and post-install scripts
rh7_02.tf: "RedHat02" VM definition and post-install scripts
ubuntu01.tf: "Ubuntu01" VM definition and post-install scripts

## Usage:

1- Install Terraform and make sure you have Terraform install dir on your PATH.

2- Clone or download this repository on your computer.

3- Edit "provider.tf" and write your AWS access_key, secret_key and region values.

4- From your local directory run "terraform init" command to initialize the project and then run "terraform apply".

The whole process takes about 8 mins to complete. Then you will have 3 VM's on your AWS account (instances) accessible via ssh using user "ec2-user" (no password) and the private key on "keys" directory. "RedHat02" and "Ubuntu01" machines will be also accessible via HTTP.
