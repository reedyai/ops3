#print the ip for nmap and other uses
output "aws_instance_public_ip" {
  value = aws_instance.mc_server.public_ip
}  