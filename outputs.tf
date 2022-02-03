output "aws_autoscaling_group_SimpleZFSAutoSaclingGroup_id" {
  value = aws_autoscaling_group.SimpleZFSAutoSaclingGroup.id
}

output "aws_instance_ZFS_WEB_SERVER_id" {
  value = aws_instance.ZFS_WEB_SERVER.id
}

output "aws_internet_gateway_IGW_ZFS_id" {
  value = aws_internet_gateway.IGW_ZFS.id
}

output "aws_launch_template_ZFSSimpleAppTemplate_id" {
  value = aws_launch_template.ZFSSimpleAppTemplate.id
}

output "aws_lb_listener_ALB_ZFS_LISTENER_id" {
  value = aws_lb_listener.ALB_ZFS_LISTENER.id
}

#output "aws_lb_target_group_attachment_tfer--arn-003A-aws-003A-elasticloadbalancing-003A-eu-002D-west-002D-2-003A-135727629848-003A-targetgroup-002F-ALB_ZFS-002F-1acf0b00b99ad043-002D-20220202233643256800000001_id" {
# value = "${aws_lb_target_group_attachment.tfer--arn-003A-aws-003A-elasticloadbalancing-003A-eu-002D-west-002D-2-003A-135727629848-003A-targetgroup-002F-ALB_ZFS-002F-1acf0b00b99ad043-002D-20220202233643256800000001.id}"
#}

output "aws_lb_target_group_ALB_ZFS_TARGET_GROUP_id" {
  value = aws_lb_target_group.ALB_ZFS_TARGET_GROUP.id
}

output "aws_lb_ALB_ZFS_id" {
  value = aws_lb.ALB_ZFS.id
}

output "aws_main_route_table_association_VPC_ZFS_id" {
  value = aws_main_route_table_association.VPC_ZFS.id
}

output "aws_network_acl_ZFS_ACL_id" {
  value = aws_network_acl.ZFS_ACL.id
}

output "aws_network_interface_ALB_ENI_1_id" {
  value = aws_network_interface.ALB_ENI_1.id
}

output "aws_network_interface_RED_ENI_id" {
  value = aws_network_interface.RED_ENI.id
}

output "aws_network_interface_ALB_ENI_2_id" {
  value = aws_network_interface.ALB_ENI_2.id
}

output "aws_network_interface_ALB_ENI_3_id" {
  value = aws_network_interface.ALB_ENI_3.id
}

output "aws_route_table_ROUTE_TABLE_ZFS_id" {
  value = aws_route_table.ROUTE_TABLE_ZFS.id
}


#utput "aws_security_group_tfer--default_sg-002D-2da0c051_id" {
#  value = "${aws_security_group.tfer--default_sg-002D-2da0c051.id}"
#}

output "aws_security_group_LAUCH_WIZARD_ZFS_id" {
  value = aws_security_group.LAUCH_WIZARD_ZFS.id
}


output "aws_subnet_SUBNET1_id" {
  value = aws_subnet.SUBNET1.id
}

output "aws_subnet_SUBNET2_id" {
  value = aws_subnet.SUBNET2.id
}

output "aws_subnet_SUBNET3_id" {
  value = aws_subnet.SUBNET3.id
}

output "aws_vpc_VPC_ZFS_id" {
  value = aws_vpc.VPC_ZFS.id
}
