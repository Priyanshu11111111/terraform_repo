variable "ec2_instanse_type" {
    default = "t2.micro"
    type = string
  
}

variable "ec2_root_storage_size" {
    default = 15
    type = number
  
}

variable "ec2_ami_id" {
    default =  #give default ami id
    type = string
  
}