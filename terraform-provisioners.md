
There are 3 different types of provisioner in Terraform
1. file provisioner
2. local-exec provisioner
3. remote-exec provisoner 

## Why do we need Terraform provisioner
- When we have a script or a web server html file, 
- To run that script or software in an Ec2 instance when the terraform creates the aws_instance resource
- To accomplish these tasks, Terraform provisioners are used
- These are mostly used for Ansible playbook to configure once the infra is created
- Copy some foles to a target machine
- In an `IDP` the developers uses these provisioner to test their applications

## What was the problem provisioner is solving
2. Without provisioner, there used to be two step process.
    - 1st: create the infra using terraform resource
    - 2nd: manually configure the server and deploy any application or scripts
    - There were Lack of automation
    - Chances of human error were high 
    - Time consuming and complex

## How provisioner solves the above problem
- **Automation**: It automates the post-provisioning tasks, ensuring consistency and reducing manual intervention.
- **Integration**: They integrate configuration management and infrastructure provisioning, simplifying the deployment process.
- **Consistency**: By running scripts or commands as part of the Terraform plan, we can ensure that all resources are configured consistently.

## What is Terraform provisioner 
- Terraform provisioners are useful for automating post-provisioning tasks and integrating infrastructure and configuration management. 

## Example to understand the Terraform provisioner

- **Local-exec Provisioner:**
- Executes a command on the machine running Terraform.

```
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo ${aws_instance.example.public_ip} > ip_address.txt"
  }
}
```

- **Remote-exec Provisioner:**
- Executes commands on the target resource via SSH or WinRM.
- Need to create the public key using the resource `aws_key_pair { key_name = "partho-key" public_key= file("~/.ssh/id_rsa.pub") }`
- generate the rsa key on your local laptop - `keygen -t rsa`

```
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  provisioner "remote-exec" {ed
    // This block helps to connect with the instance that was just creat
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host     = self.public_ip
    }

    // This block helps to execute the commands that is needed to be executed
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
    ]
  }
}

```

* *Note*
- Here, the `connection` is used, which is used to connect to the instance once its created
- the `self` is used instead of aws_instance.example, because the provisioner block is within the aws_instance block {}


## Example time
- I have an HTML file, which I want to be copied into my Ec2 instance once its created using tf

```
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  # File provisioner to copy the index.html file to the instance
  provisioner "file" {
    source      = "index.html"
    destination = "/home/ubuntu/index.html"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host     = self.public_ip
    }
  }

  # Remote-exec provisioner to install Nginx and move the index.html file
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host     = self.public_ip
    }

    inline = [
      # Update package list and install Nginx
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      
      # Move the copied index.html file to the Nginx directory
      "sudo mv /home/ubuntu/index.html /var/www/html/index.html",
      "sudo chown www-data:www-data /var/www/html/index.html",
      "sudo chmod 644 /var/www/html/index.html"
    ]
  }
}

```

## COmcept
- Provsioner is not only run during resource creation (`terraform apply`)
- But, it can be used during resource deletion/destruction as well (`terraform destroy`)
- It is mostly used During destruction for some clean up tasks, backup and copy the log files etc

### Understanding `when` Argument
- The provisioner block has an optional when argument that controls when the provisioner runs:

    - `create`: Runs the provisioner during resource creation (default).
    - `destroy`: Runs the provisioner during resource destruction.
    - `create_before_destroy`: Runs the provisioner during resource creation before the resource is destroyed.


- `when = "create" `
- `when = "destroy"`
```

resource "aws_instance" "example" {
  ami           = "ami-12345678" # Update with a valid AMI ID
  instance_type = "t2.micro"

  # Provisioner to run during creation
  provisioner "remote-exec" {
    when    = "create"
    script  = "scripts/setup.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }

  # Provisioner to run during destruction
  provisioner "remote-exec" {
    when    = "destroy"
    inline  = [
      "echo 'Performing cleanup tasks...'",
      "rm -rf /tmp/*",
      "echo 'Instance is being destroyed.' | mail -s 'Instance Termination' admin@example.com"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }
}
```