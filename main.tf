provider "aws" {
    region = "ap-south-1"
}


# variable subnet_cidr_block {}
# variable vpc_cidr_block {} 
# variable avail_zone {}
# variable env_prefix {}
# variable my_ip {}
# variable instance_type {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

module "myapp-subnet" {
    source = "./modules/subnet"
    subnet_cidr_block = var.subnet_cidr_block
    vpc_cidr_block = var.vpc_cidr_block
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.myapp-vpc.id
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}

module "myapp-server" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.myapp-vpc.id
    my_ip = var.my_ip
    env_prefix = var.env_prefix
    image_name = var.image_name
    public_key_location = var.public_key_location
    instance_type = var.instance_type
    subnet_id = module.myapp-subnet.subnet.id
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
}

# resource "aws_subnet" "myapp-subnet-1" {
#     vpc_id = aws_vpc.myapp-vpc.id
#     cidr_block = var.subnet_cidr_block
#     availability_zone = var.avail_zone
#     tags = {
#         Name: "${var.env_prefix}-subnet-1"
#     }
# }

# resource "aws_route_table" "myapp-route-table" {
#     vpc_id = aws_vpc.myapp-vpc.id

#     route {
#          cidr_block = "0.0.0.0/0"
#          gateway_id = aws_internet_gateway.myapp-igw.id
#     }
#     tags = {
#         Name: "${var.env_prefix}-rtb"
#     }
# }

# resource "aws_internet_gateway" "myapp-igw" {
#     vpc_id=aws_vpc.myapp-vpc.id
#     tags = {
#         Name: "${var.env_prefix}-igw"
#     }
# }

# resource "aws_route_table_association" "a-rtb-subnet" {
#     subnet_id = aws_subnet.myapp-subnet-1.id
#     route_table_id = aws_route_table.myapp-route-table.id
# }

# resource "aws_default_route_table" "main-rtb" {
#     default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
#     tags = {
#           Name: "${var.env_prefix}-main-rtb"
#       }
# }

# resource "aws_security_group" "myapp-sg" {
#     name = "myapp-sg"
#     vpc_id = aws_vpc.myapp-vpc.id

#     ingress { //ingress for incoming or inbound
#         from_port = 22
#         to_port = 22
#         protocol = "tcp"
#         cidr_blocks = [var.my_ip]
#     }

#     ingress { 
#         from_port = 8080
#         to_port = 8080
#         protocol = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#     }

#     egress { // for outgoing or outbounddd
#         from_port = 0
#         to_port = 0
#         protocol = "-1"
#         cidr_blocks = ["0.0.0.0/0"]
#         prefix_list_ids = [] 
#     }

#     tags = {
#         Name: "${var.env_prefix}-sg"
#     }
# }

#  resource "aws_default_route_table" "main-rtb" {
#     default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
#     tags = {
#           Name: "${var.env_prefix}-main-rtb"
#       }
# }

resource "aws_default_security_group" "default-sg" {
    vpc_id = aws_vpc.myapp-vpc.id

    ingress { //ingress for incoming or inbound
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }

    ingress { 
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress { // for outgoing or outbounddd
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = [] 
    }

    tags = {
        Name: "${var.env_prefix}-default-sg"
    }
}
 
# data "aws_ami" "latest-amazon-linux-image" {
#     most_recent = true
#     owners = ["amazon"]
#     filter {
#         name = "name"
#         values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#     }
#     filter {
#         name = "virtualization-type"
#         values = ["hvm"]
#     }
# }

# resource "aws_key_pair" "ssh-key" {
#     key_name = "server-key"
#     public_key = 
# }

resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type
    subnet_id = module.myapp-subnet.subnet.id
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    availability_zone = var.avail_zone   

    associate_public_ip_address = true
    key_name = "CDAC1"

    tags = {
        Name = "${var.env_prefix}-server"
    }
}