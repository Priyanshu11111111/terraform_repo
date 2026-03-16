output "ec2_public_ip" {
    value = aws_instance.my_instance.public_ip # this is for the single output one instance
    # value = aws_instance.my_instance[*].public_ip  , for multiple output
  
}

output "ec2_public_DNS" {
    value = aws_instance.my_instance.public_dns # this is for the single output one instance
  # but if you created two or more instance using  (count = 2)  then you have to add * in output.tf 
  #  ex = (value = aws_instance.my_instance[*].public_dns)
}

output "ec2_private_ip" {
  value = aws_instance.my_instance.private_ip # this is for the single output one instance
  #  value = aws_instance.my_instance[*].private_ip

}