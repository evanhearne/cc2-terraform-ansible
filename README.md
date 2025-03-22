# cc2-terraform-ansible

This repository is for Cloud Computing 2's Terraform Ansible assignment. It contains:

+ Terraform Configuration of AWS Infrastructure (VPC + EC2)
+ Ansible Playbooks to set up Apache + HAProxy.
+ Ansible Inventory to store AWS Information (EC2). 

The aim of this assignment is to combine Terraform and Ansible to provision a load balancing environment using HAProxy and Apache on the AWS platform. 

It does this through Ansible roles, Ansible Vault, Ansible Playbooks, Ansible Inventory, Terraform variables and Terraform configuration. 

## How to run

1. Ensure you have your AWS credentials saved at `~/.aws/credentials` . You can either provide the credentials from AWS Learner Lab, or create a user with `AdministratorAccess` role in AWS IAM, and then generate a key to use as your credentials. See [here](https://repost.aws/knowledge-center/create-access-key) for more details.

2. In `ansible` directory ensure you have a `vockey.pem` file (you can get this through AWS Learner Lab, or generate a key to this name using AWS IAM and save it there). See [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html#having-ec2-create-your-key-pair) for more details .

3. Ensure you have [python](https://www.python.org/downloads/), [pipx](https://pipx.pypa.io/stable/installation/#installing-pipx), [aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions) , [ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#pipx-install), and [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform) installed locally. 

4. From `terraform/` directory create a `variables.tf` file with these variables defined (you can customise if you wish):
    ```hcl
    variable "aws_region" {
    description = "AWS region"
    default     = "us-east-1"
    }

    variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    default     = "10.0.0.0/16"
    }

    variable "public_subnet_cidr" {
    description = "CIDR block for the public subnet"
    default     = "10.0.1.0/24"
    }

    variable "private_subnet_cidr" {
    description = "CIDR block for the private subnet"
    default     = "10.0.2.0/24"
    }

    variable "availability_zone" {
    description = "Availability zone for subnets"
    default     = "us-east-1a"
    }

    variable "key_name" {
    description = "SSH key pair name"
    default     = "vockey"
    }

    variable "instance_type" {
    description = "EC2 instance type"
    default     = "t2.micro"
    }
    ```

5. Run the following from `terraform/` directory:
    ```bash
    terraform init && terraform apply --auto-approve
    ```
    Ensure this runs successfully.

6. Create a vault file from `ansible/` directory by running `ansible-vault create inventory/group_vars/all/vault.yml` . Enter a password and add the following information to the file"
    ```yaml
    ansible_user: ubuntu
    ansible_ssh_private_key_file: vockey.pem
    ```

7. Run the following from `ansible/` directory:
    ```bash
    eval $(ssh-agent)
    ssh-add "<Your Root Directory>/cc2-terraform-ansible/ansible/vockey.pem"
    ssh -A -J ubuntu@<HA_PROXY_EC2_PUBLIC_IP> ubuntu@<APACHE_EC2_1_PRIVATE_IP>
    ```
    Confirm yes twice then type `exit` followed by the Return key. Then run:
    ```bash
    ssh -A -J ubuntu@<HA_PROXY_EC2_PUBLIC_IP> ubuntu@<APACHE_EC2_2_PRIVATE_IP>
    ```
    Confirm yes then type `exit` followed by the Return key. Then run:
    ```bash
    ansible-playbook -i inventory/aws_ec2.yml playbook.yml --ask-vault-pass
    ```
    Enter your password followed by the Return key. Ensure the plays run to completion. 

These steps provision VPC and Compute infrastructure via Terraform, and provision HAProxy and Apache via Ansible . 

You should now be able to navigate to `http://<YOUR_HAPROXY_EC2_PUBLIC_IP>:80` and view the private IP addresses of each Apache instance via HAProxy's Round Robin configuration of the Apache instances. 

## How to tear down
To tear down, from `terraform/` directory run `terraform destroy --auto-approve` . 
