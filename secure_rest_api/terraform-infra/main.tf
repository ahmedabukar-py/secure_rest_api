provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3"{
    bucket = "cyber94-ahmed-calculator-bucket"
    key = "tfstate/calculator/terraform.tfstate"
    region = "eu-west-1"
    dynamodb_table = "cyber94_calculator_ahmed_dynamodb_table_lock"
    encrypt = true
  }
}


resource "aws_vpc" "cyber94_ahmed_cal_vpc_tf" {
    cidr_block = "10.202.0.0/16"

    tags = {
      Name = "cyber94_ahmed_cal_vpc"
    }
}

resource "aws_internet_gateway" "cyber94_ahmed_cal_ig_tf" {    # Creating Internet Gateway
    vpc_id =  aws_vpc.cyber94_ahmed_cal_vpc_tf.id
    tags = {
      Name = "cyber94_ahmed_cal_ig"
      }             # vpc_id will be generated after we create VPC
 }

resource "aws_route_table" "cyber94_ahmed_cal_rt_tf" {    # Creating RT for Private Subnet
    vpc_id = aws_vpc.cyber94_ahmed_cal_vpc_tf.id

    route{
      cidr_block = "0.0.0.0/0"             # Traffic from Private Subnet reaches Internet via NAT Gateway
      gateway_id = aws_internet_gateway.cyber94_ahmed_cal_ig_tf.id
    }

    tags = {
      Name = "cyber94_ahmed_cal_rt"
    }

  }
# AWS App subnet
resource "aws_subnet" "cyber94_ahmed_app_subnet_tf" {
  vpc_id = aws_vpc.cyber94_ahmed_cal_vpc_tf.id
  cidr_block = "10.202.1.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "cyber94_ahmed_app_subnet"
  }
}
# AWS db subnet
resource "aws_subnet" "cyber94_ahmed_db_subnet_tf" {
  vpc_id = aws_vpc.cyber94_ahmed_cal_vpc_tf.id
  cidr_block = "10.202.2.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "cyber94_ahmed_db_subnet"
  }
}
resource "aws_subnet" "cyber94_ahmed_bastion_subnet_tf" {
  vpc_id = aws_vpc.cyber94_ahmed_cal_vpc_tf.id
  cidr_block = "10.202.3.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "cyber94_ahmed_db_subnet"
  }
}

resource "aws_route_table_association" "cyber94_ahmed_app_rt_assoc_tf" {    # Creating RT for Private Subnet
   subnet_id = aws_subnet.cyber94_ahmed_app_subnet_tf.id
   route_table_id = aws_route_table.cyber94_ahmed_cal_rt_tf.id

 }

resource "aws_route_table_association" "cyber94_ahmed_db_rt_assoc_tf" {    # Creating RT for Private Subnet
    subnet_id = aws_subnet.cyber94_ahmed_db_subnet_tf.id
    route_table_id = aws_route_table.cyber94_ahmed_cal_rt_tf.id

  }

resource "aws_route_table_association" "cyber94_ahmed_bastion_rt_assoc_tf" {    # Creating RT for Private Subnet
     subnet_id = aws_subnet.cyber94_ahmed_bastion_subnet_tf.id
     route_table_id = aws_route_table.cyber94_ahmed_cal_rt_tf.id

   }


resource "aws_network_acl" "cyber94_ahmed_app_nacl_tf" {
    vpc_id = aws_vpc.cyber94_ahmed_cal_vpc_tf.id

    egress {
        protocol   = "tcp"
        rule_no    = 1000
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 3306
        to_port    = 3306
      }

    egress {
        protocol   = "tcp"
        rule_no    = 2000
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 80
        to_port    = 80
      }

    egress {
        protocol   = "tcp"
        rule_no    = 3000
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 443
        to_port    = 443
      }

    egress {
        protocol   = "tcp"
        rule_no    = 4000
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 1024
        to_port    = 65535
      }

    ingress {
        protocol   = "tcp"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 5000
        to_port    = 5000
      }

    ingress {
        protocol   = "tcp"
        rule_no    = 200
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 22
        to_port    = 22
      }

    ingress {
        protocol   = "tcp"
        rule_no    = 300
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 1024
        to_port    = 65535
      }


     subnet_ids = [aws_subnet.cyber94_ahmed_app_subnet_tf.id]

     tags = {
       Name = "cyber94_ahmed_app_nacl"
     }
   }

resource "aws_network_acl" "cyber94_ahmed_bastion_nacl_tf" {
  vpc_id = aws_vpc.cyber94_ahmed_cal_vpc_tf.id

  egress {
        protocol   = "tcp"
        rule_no    = 1000
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 22
        to_port    = 22
      }

    egress {
        protocol   = "tcp"
        rule_no    = 2000
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 1024
        to_port    = 65535
      }

    ingress {
        protocol   = "tcp"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 22
        to_port    = 22
      }

    ingress {
        protocol   = "tcp"
        rule_no    = 200
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 1024
        to_port    = 65535
      }

      subnet_ids = [aws_subnet.cyber94_ahmed_bastion_subnet_tf.id]

        tags = {
          Name = "cyber94_ahmed_bastion_nacl"
        }
      }

resource "aws_network_acl" "cyber94_ahmed_db_nacl_tf" {
  vpc_id = aws_vpc.cyber94_ahmed_cal_vpc_tf.id
  egress {
       protocol   = "tcp"
       rule_no    = 1000
       action     = "allow"
       cidr_block = "0.0.0.0/0"
       from_port  = 1024
       to_port    = 65535
     }

   ingress {
       protocol   = "tcp"
       rule_no    = 100
       action     = "allow"
       cidr_block = "0.0.0.0/0"
       from_port  = 22
       to_port    = 22
     }

   ingress {
       protocol   = "tcp"
       rule_no    = 200
       action     = "allow"
       cidr_block = "0.0.0.0/0"
       from_port  = 3306
       to_port    = 3306
     }
  subnet_ids = [aws_subnet.cyber94_ahmed_db_subnet_tf.id]

  tags = {
      Name = "cyber94_ahmed_db_nacl"
    }
}

resource "aws_security_group" "cyber94_ahmed_app_sg_tf" {
 name = "cyber94_ahmed_app_sg"
 description = "Allow web inbound traffic"
 vpc_id = aws_vpc.cyber94_ahmed_cal_vpc_tf.id

 ingress {
     description = "SSH"
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
     description = "5000"
     from_port   = 5000
     to_port     = 5000
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
     description = "MySQL"
     from_port   = 3306
     to_port     = 3306
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
     description = "HTTPS"
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
     description = "HTTP"
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

 tags = {
   Name = "cyber94_ahmed_app_sg"
 }
}

resource "aws_security_group" "cyber94_ahmed_bastion_sg_tf" {
 name = "cyber94_ahmed_bastion_sg"
 description = "Allow web inbound traffic"
 vpc_id = aws_vpc.cyber94_ahmed_cal_vpc_tf.id

 ingress {
     description = "SSH"
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
     description = "HTTPS"
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
     description = "HTTP"
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
     description = "SSH"
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
     Name = "cyber94_ahmed_bastion_sg"
   }
 }

resource "aws_security_group" "cyber94_ahmed_db_sg_tf" {
  name = "cyber94_ahmed_db_sg"
  description = "Allow web inbound traffic"
  vpc_id = aws_vpc.cyber94_ahmed_cal_vpc_tf.id

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      Name = "cyber94_ahmed_db_sg"
    }
}

resource "aws_instance" "cyber94_test_ahmed_server_app_tf"{
  ami = "ami-0943382e114f188e8"
  instance_type = "t2.micro"
  key_name = "cyber94-aabdirahman"
  vpc_security_group_ids = [aws_security_group.cyber94_ahmed_app_sg_tf.id]
  subnet_id = aws_subnet.cyber94_ahmed_app_subnet_tf.id
  associate_public_ip_address = true

  tags = {
    Name = "cyber94_ahmed_app_server"
  }

  lifecycle {
    create_before_destroy = true
  }
  provisioner "local-exec" {
    working_dir ="../ansible"
    command = "ansible-playbook -i ${self.public_ip}, -u ubuntu provisioner.yml"
  }
}

resource "aws_instance" "cyber94_test_ahmed_server_bastion_tf"{
  ami = "ami-0943382e114f188e8"
  instance_type = "t2.micro"
  key_name = "cyber94-aabdirahman"
  vpc_security_group_ids = [aws_security_group.cyber94_ahmed_bastion_sg_tf.id]
  subnet_id = aws_subnet.cyber94_ahmed_bastion_subnet_tf.id
  associate_public_ip_address = true

  tags = {

    Name = "cyber94_ahmed_bastion_server"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "cyber94_test_ahmed_server_db_tf"{
  ami = "ami-0943382e114f188e8"
  instance_type = "t2.micro"
  key_name = "cyber94-aabdirahman"
  vpc_security_group_ids = [aws_security_group.cyber94_ahmed_db_sg_tf.id]
  subnet_id = aws_subnet.cyber94_ahmed_db_subnet_tf.id
  associate_public_ip_address = true

  tags = {

    Name = "cyber94_ahmed_db_server"
  }

  lifecycle {
    create_before_destroy = true
  }


}
