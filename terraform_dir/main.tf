provider "aws" {
  region = "us-east-1"

}

resource "aws_instance" "amazon-linux2" {
  ami = "ami-05fa00d4c63e32376"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name = aws_key_pair.generated-key.id
  user_data = <<-EOF
      #!/bin/bash
      yum -y install python3
      EOF 


}

resource "aws_security_group" "sg" {
  name = "redhat-sg"
  ingress {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_key_pair" "generated-key" {
  public_key = file("/home/unix/.ssh/id_rsa.pub")

}

data  "template_file" "ansible_hosts" {
  template = file("templates/hosts.tlp")
  
  vars = {
    server = "${aws_instance.amazon-linux2.public_ip}"
    remote_user = "ec2-user"
  }
}

resource "null_resource" "ansible_hosts_file" {
  triggers = {
    template_rendered = "${data.template_file.ansible_hosts.rendered}"
  }
  provisioner "local-exec" {
    command = "echo '${data.template_file.ansible_hosts.rendered}' > ../ansible/hosts;echo '${data.template_file.ansible_hosts.rendered}' > ~/inventory/hosts"
    
    
  }
}