# step1 provide
provider "aws" {
    region = "<enter your region >"
  
}

#step2 key pair
resource "aws_key_pair" "aws_key" {
    key_name = "terra-key-ec2"
    public_key = file("terra-key-ec2.pub")
 
}

#step3 vpc 
resource "aws_default_vpc" "default" {
  
}

#step3.2 security g
resource "aws_security_group" "my_security_group" {
    name = "automate_sg"
    description = "this will add a TF generated SG "
    vpc_id = aws_default_vpc.default.id  #interpolation
     

     #inbound rule
     ingress  {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description= "ingress rule for ssh"
     }

     ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description= "ingress rule for http"
     }

     ingress {
        from_port = 8000
        to_port = 8000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description= "ingress rule for flax app"
     }

     #egress outbound rule
     egress  {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks= ["0.0.0.0/0"]
        description= "all access open outbound"
     }

    tags = {
        name="automate_sg"
    }
  
}

#step4 ec2 instance

resource "aws_instance" "my_instance" {
    #count = 2
    key_name = aws_key_pair.aws_key.key_name
    security_groups = [aws_security_group.my_security_group.name]
    instance_type= var.ec2_instanse_type
    ami = var.ec2_ami_id #give ami id from aws
    user_data = file("install_nginx.sh")  #user_data allow you to run shell script when instance are creating in this case we are install an run nginx in ec2 instance 

    root_block_device {
      volume_size = var.ec2_ami_id
      volume_type = "gp3"
    }

    tags={
        name="  give name for tag"
    }
}