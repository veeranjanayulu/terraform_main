provider "aws" {
    region = "ca-central-1"
  
}

resource "aws_vpc" "private" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
        tags = {
      Name ="private-vpc"
    }
  
}