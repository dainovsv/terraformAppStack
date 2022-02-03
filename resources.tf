resource "aws_autoscaling_group" "SimpleZFSAutoSaclingGroup" {
  #availability_zones        = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  capacity_rebalance        = "false"
  default_cooldown          = "300"
  desired_capacity          = "1"
  force_delete              = "false"
  health_check_grace_period = "300"
  health_check_type         = "EC2"

  launch_template {
    #id      = "lt-02c49d0562d1e0649"
    name    = "ZFSSimpleAppTemplate"
    version = "$Default"
  }

  max_instance_lifetime   = "0"
  max_size                = "1"
  metrics_granularity     = "1Minute"
  min_size                = "1"
  name                    = "SimpleZFSAutoSaclingGroup"
  protect_from_scale_in   = "false"
  service_linked_role_arn = "arn:aws:iam::135727629848:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
  #target_group_arns         = ["arn:aws:elasticloadbalancing:eu-west-2:135727629848:targetgroup/SimpleZFSAutoSaclingGroup-1/1acf0b00b99ad043"]
  vpc_zone_identifier       = ["${data.terraform_remote_state.local.outputs.aws_subnet_SUBNET2_id}", "${data.terraform_remote_state.local.outputs.aws_subnet_SUBNET1_id}", "${data.terraform_remote_state.local.outputs.aws_subnet_SUBNET3_id}"]
  wait_for_capacity_timeout = "10m"
}


resource "aws_db_subnet_group" "RDS_SUBNET_GROUP" {
  description = "Created from the RDS Management Console"
  name        = "default-vpc-03200b6b"
  subnet_ids  = ["${data.terraform_remote_state.local.outputs.aws_subnet_SUBNET2_id}", "${data.terraform_remote_state.local.outputs.aws_subnet_SUBNET3_id}", "${data.terraform_remote_state.local.outputs.aws_subnet_SUBNET1_id}"]
}



resource "aws_instance" "ZFS_WEB_SERVER" {
  ami                         = var.image_id
  associate_public_ip_address = "true"
  availability_zone           = "eu-west-2a"

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  cpu_core_count       = "1"
  cpu_threads_per_core = "1"

  credit_specification {
    cpu_credits = "standard"
  }

  disable_api_termination = "false"
  ebs_optimized           = "false"

  enclave_options {
    enabled = "false"
  }

  get_password_data                    = "false"
  hibernation                          = "false"
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t2.small"
  ipv6_address_count                   = "0"
  key_name                             = "zfs"

  launch_template {
    #id   = "lt-02c49d0562d1e0649"
    name = "ZFSSimpleAppTemplate"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = "1"
    http_tokens                 = "optional"
    instance_metadata_tags      = "disabled"
  }

  monitoring = "false"
  private_ip = "172.31.22.43"

  root_block_device {
    delete_on_termination = "true"
    encrypted             = "false"
    volume_size           = "30"
    volume_type           = "gp2"
  }

  security_groups        = ["launch-wizard-2"]
  source_dest_check      = "true"
  subnet_id              = data.terraform_remote_state.local.outputs.aws_subnet_SUBNET1_id
  tenancy                = "default"
  vpc_security_group_ids = ["${data.terraform_remote_state.local.outputs.aws_security_group_LAUCH_WIZARD_ZFS_id}"]
}

resource "aws_internet_gateway" "IGW_ZFS" {
  vpc_id = data.terraform_remote_state.local.outputs.aws_vpc_VPC_ZFS_id
}

resource "aws_launch_template" "ZFSSimpleAppTemplate" {
  default_version         = "1"
  disable_api_termination = "false"
  image_id                = var.image_id
  instance_type           = "t2.small"
  key_name                = "zfs"
  name                    = "ZFSSimpleAppTemplate"
  vpc_security_group_ids  = ["sg-022db4c5d1be35080"]
}

resource "aws_lb" "ALB_ZFS" {
  desync_mitigation_mode     = "defensive"
  drop_invalid_header_fields = "false"
  enable_deletion_protection = "false"
  enable_http2               = "true"
  enable_waf_fail_open       = "false"
  idle_timeout               = "60"
  internal                   = "false"
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  name                       = "SimpleZFSAutoSaclingGroup-1"
  security_groups            = ["${data.terraform_remote_state.local.outputs.aws_security_group_LAUCH_WIZARD_ZFS_id}"]

  subnet_mapping {
    subnet_id = "subnet-5e770e24"
  }

  subnet_mapping {
    subnet_id = "subnet-6634b82a"
  }

  subnet_mapping {
    subnet_id = "subnet-baefd2d3"
  }

  subnets = ["${data.terraform_remote_state.local.outputs.aws_subnet_SUBNET2_id}", "${data.terraform_remote_state.local.outputs.aws_subnet_SUBNET1_id}", "${data.terraform_remote_state.local.outputs.aws_subnet_SUBNET3_id}"]
}

resource "aws_lb_listener" "ALB_ZFS_LISTENER" {
  default_action {
    #target_group_arn = "arn:aws:elasticloadbalancing:eu-west-2:135727629848:targetgroup/SimpleZFSAutoSaclingGroup-1/1acf0b00b99ad043"
    type = "forward"
  }

  load_balancer_arn = data.terraform_remote_state.local.outputs.aws_lb_ALB_ZFS_id
  port              = "80"
  protocol          = "HTTP"
}

resource "aws_lb_target_group" "ALB_ZFS_TARGET_GROUP" {
  deregistration_delay = "300"

  health_check {
    enabled             = "true"
    healthy_threshold   = "5"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    timeout             = "5"
    unhealthy_threshold = "5"
  }

  load_balancing_algorithm_type = "round_robin"
  name                          = "SimpleZFSAutoSaclingGroup-1"
  port                          = "80"
  protocol                      = "HTTP"
  protocol_version              = "HTTP1"
  slow_start                    = "0"

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }

  target_type = "instance"
  vpc_id      = "vpc-03200b6b"
}

#resource "aws_lb_target_group_attachment" "ALB_ZFS_TARGET_GROUP_ATTACHMENT" {
# target_group_arn = "arn:aws:elasticloadbalancing:eu-west-2:135727629848:targetgroup/SimpleZFSAutoSaclingGroup-1/1acf0b00b99ad043"
#  target_id        = "i-06fd78260f33107f5"
#}

resource "aws_main_route_table_association" "VPC_ZFS" {
  route_table_id = data.terraform_remote_state.local.outputs.aws_route_table_ROUTE_TABLE_ZFS_id
  vpc_id         = data.terraform_remote_state.local.outputs.aws_vpc_VPC_ZFS_id
}

resource "aws_network_acl" "ZFS_ACL" {
  egress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "0"
    icmp_code  = "0"
    icmp_type  = "0"
    protocol   = "-1"
    rule_no    = "100"
    to_port    = "0"
  }

  ingress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "0"
    icmp_code  = "0"
    icmp_type  = "0"
    protocol   = "-1"
    rule_no    = "100"
    to_port    = "0"
  }

  subnet_ids = ["${data.terraform_remote_state.local.outputs.aws_subnet_SUBNET2_id}", "${data.terraform_remote_state.local.outputs.aws_subnet_SUBNET3_id}", "${data.terraform_remote_state.local.outputs.aws_subnet_SUBNET1_id}"]
  vpc_id     = data.terraform_remote_state.local.outputs.aws_vpc_VPC_ZFS_id
}

resource "aws_network_interface" "ALB_ENI_1" {
  description = "ELB app/SimpleZFSAutoSaclingGroup-1/3f1c9137a6b527fa"
  #interface_type     = "interface"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "172.31.11.50"
  security_groups    = ["sg-022db4c5d1be35080"]
  source_dest_check  = "true"
  subnet_id          = data.terraform_remote_state.local.outputs.aws_subnet_SUBNET1_id
}

resource "aws_network_interface" "RED_ENI" {
  description = "RDSNetworkInterface"
  #interface_type     = "interface"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "172.31.46.43"
  security_groups    = ["sg-2da0c051"]
  source_dest_check  = "true"
  subnet_id          = data.terraform_remote_state.local.outputs.aws_subnet_SUBNET1_id
}

resource "aws_network_interface" "ALB_ENI_2" {
  attachment {
    device_index = "0"
    instance     = "i-06fd78260f33107f5"
  }

  #interface_type     = "interface"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "172.31.22.43"
  private_ip_list    = ["172.31.22.43"]
  security_groups    = ["sg-022db4c5d1be35080"]
  source_dest_check  = "true"
  subnet_id          = data.terraform_remote_state.local.outputs.aws_subnet_SUBNET2_id
}

resource "aws_network_interface" "ALB_ENI_3" {
  description = "ELB app/SimpleZFSAutoSaclingGroup-1/3f1c9137a6b527fa"
  #interface_type     = "interface"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "172.31.28.119"
  security_groups    = ["sg-022db4c5d1be35080"]
  source_dest_check  = "true"
  subnet_id          = data.terraform_remote_state.local.outputs.aws_subnet_SUBNET3_id
}


resource "aws_route_table" "ROUTE_TABLE_ZFS" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-0615c76e"
  }

  vpc_id = data.terraform_remote_state.local.outputs.aws_vpc_VPC_ZFS_id
}


resource "aws_security_group" "LAUCH_WIZARD_ZFS" {
  description = "launch-wizard-2 created 2022-02-02T10:46:08.456+00:00"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "3389"
    protocol    = "tcp"
    self        = "false"
    to_port     = "3389"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "443"
    protocol    = "tcp"
    self        = "false"
    to_port     = "443"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "80"
    protocol    = "tcp"
    self        = "false"
    to_port     = "80"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "8172"
    protocol    = "tcp"
    self        = "false"
    to_port     = "8172"
  }

  name   = "launch-wizard-2"
  vpc_id = data.terraform_remote_state.local.outputs.aws_vpc_VPC_ZFS_id
}


resource "aws_subnet" "SUBNET1" {
  assign_ipv6_address_on_creation                = "false"
  cidr_block                                     = "172.31.16.0/20"
  enable_dns64                                   = "false"
  enable_resource_name_dns_a_record_on_launch    = "false"
  enable_resource_name_dns_aaaa_record_on_launch = "false"
  ipv6_native                                    = "false"
  #map_customer_owned_ip_on_launch                = "false"
  map_public_ip_on_launch             = "true"
  private_dns_hostname_type_on_launch = "ip-name"
  vpc_id                              = data.terraform_remote_state.local.outputs.aws_vpc_VPC_ZFS_id
}

resource "aws_subnet" "SUBNET2" {
  assign_ipv6_address_on_creation                = "false"
  cidr_block                                     = "172.31.32.0/20"
  enable_dns64                                   = "false"
  enable_resource_name_dns_a_record_on_launch    = "false"
  enable_resource_name_dns_aaaa_record_on_launch = "false"
  ipv6_native                                    = "false"
  #map_customer_owned_ip_on_launch                = "false"
  map_public_ip_on_launch             = "true"
  private_dns_hostname_type_on_launch = "ip-name"
  vpc_id                              = data.terraform_remote_state.local.outputs.aws_vpc_VPC_ZFS_id
}

resource "aws_subnet" "SUBNET3" {
  assign_ipv6_address_on_creation                = "false"
  cidr_block                                     = "172.31.0.0/20"
  enable_dns64                                   = "false"
  enable_resource_name_dns_a_record_on_launch    = "false"
  enable_resource_name_dns_aaaa_record_on_launch = "false"
  ipv6_native                                    = "false"
  #map_customer_owned_ip_on_launch                = "false"
  map_public_ip_on_launch             = "true"
  private_dns_hostname_type_on_launch = "ip-name"
  vpc_id                              = data.terraform_remote_state.local.outputs.aws_vpc_VPC_ZFS_id
}

resource "aws_vpc" "VPC_ZFS" {
  assign_generated_ipv6_cidr_block = "false"
  cidr_block                       = "172.31.0.0/16"
  enable_classiclink               = "false"
  enable_classiclink_dns_support   = "false"
  enable_dns_hostnames             = "true"
  enable_dns_support               = "true"
  instance_tenancy                 = "default"
  #ipv6_netmask_length              = "0"
}
