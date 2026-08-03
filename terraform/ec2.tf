
resource "aws_security_group" "flask_app_sg" {
    name        = "flask-app-sg"
    description = "Security group for Flask app"

    ingress {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Flask App"
        from_port   = 5000
        to_port     = 5000
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_instance" "flask_app_instance" {
    ami           = "ami-01a00762f46d584a1" 
    instance_type = "t3.micro"
    key_name      = "Terraform_keyPair" 
    subnet_id     = data.aws_subnets.default.ids[0]

    vpc_security_group_ids = [aws_security_group.flask_app_sg.id]

    user_data = <<-EOF
                #!/bin/bash
                apt-get update -y
                apt-get install -y docker.io
                systemctl start docker
                systemctl enable docker
                usermod -aG docker ubuntu
                EOF

    tags = {
        Name = "FlaskAppInstance"
    }
}

output "flask_app_instance_public_ip" {
    value = aws_instance.flask_app_instance.public_ip
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}