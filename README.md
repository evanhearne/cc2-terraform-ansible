# cc2-terraform-ansible

This repository is for Cloud Computing 2's Terraform Ansible assignment. It contains:

+ Terraform Configuration of AWS Infrastructure (VPC + EC2)
+ Ansible Playbooks to set up Apache + HAProxy.
+ Ansible Inventory to store AWS Information (EC2). 

The aim of this assignment is to combine Terraform and Ansible to provision a load balancing environment using HAProxy and Apache on the AWS platform. 

Currently, it does this through Ansible roles, Ansible Playbooks, Ansible Inventory, and Terraform configuration. 

However, it also needs to utilise either Hashicorp or Ansible Vault to store variables pertaining to the AWS configuration. This will be done at a later stage...

## How to run

1. Ensure you have your AWS credentials saved at `~/.aws/credentials` . You can either provide the credentials from AWS Learner Lab, or create a user with `AdministratorAccess` role in AWS IAM, and then generate a key to use as your credentials. See [here](https://repost.aws/knowledge-center/create-access-key) for more details.

2. In `ansible` directory ensure you have a `vockey.pem` file (you can get this through AWS Learner Lab, or generate a key to this name using AWS IAM and save it there). See [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html#having-ec2-create-your-key-pair) for more details .

3. Ensure you have [python](https://www.python.org/downloads/), [pipx](https://pipx.pypa.io/stable/installation/#installing-pipx), [aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions) , [ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#pipx-install), and [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform) installed locally. 

4. Run the following from `terraform/` directory:
    ```bash
    terraform init && terraform apply --auto-approve
    ```
    Ensure this runs successfully.

5. Run the following from `ansible/` directory:
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
    ansible-playbook -i inventory/aws_ec2.yml playbook.yml
    ```
    Ensure the plays run to completion. 

These steps provision VPC and Compute infrastructure via Terraform, and provision HAProxy and Apache via Ansible . 

You should now be able to navigate to `http://<YOUR_HAPROXY_EC2_PUBLIC_IP>:80` and view the private IP addresses of each Apache instance via HAProxy's Round Robin configuration of the Apache instances. 
