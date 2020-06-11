provider "aws" {
  region = "ap-south-1"
  profile = "myvishesh"
}


resource "aws_instance" "web" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name = "mykey1111.pem"
  security_groups = [ "launch-wizard-2" ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/user/Desktop/cloud/mykey1111.pem")
    host     = aws_instance.web.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install php  -y",
      "sudo yum install httpd -y"
      "sudo yum install git -y"
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
    ]
  }

  tags = {
    Name = "lwos1"
  }

}


resource "aws_ebs_volume" "esb1" {
  availability_zone = aws_instance.web.availability_zone
  size              = 1
  tags = {
    Name = "lwebs"
  }
}


resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.esb1.id}"
  instance_id = "${aws_instance.web.id}"
  force_detach = true
}


output "myos_ip" {
  value = aws_instance.web.public_ip
}


resource "null_resource" "nulllocal2"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.web.public_ip} > publicip.txt"
  	}
}



resource "null_resource" "nullremote3"  {

depends_on = [
    aws_volume_attachment.ebs_att,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/user/Desktop/cloud/mykey1111.pem")
    host     = aws_instance.web.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/visheshgargavi/hybrid-task1.git /var/www/html/"
    ]
  }
}



resource "null_resource" "nulllocal1"  {


depends_on = [
    null_resource.nullremote3,
  ]

	provisioner "local-exec" {
	    command = "chrome  ${aws_instance.web.public_ip}"
  	}
}


