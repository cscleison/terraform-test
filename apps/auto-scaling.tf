resource "aws_appautoscaling_target" "ecs" {
  min_capacity       = 1
  max_capacity       = 5
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}


resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_cp" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.ecs_cp.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_cp.name
  }
}

resource "aws_ecs_capacity_provider" "ecs_cp" {
  name = "${var.project_name}-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn
    managed_scaling {
      target_capacity           = 100
      instance_warmup_period    = 30
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 10
      status                    = "ENABLED"
    }
  }
}


resource "aws_launch_template" "ecs_launch_template" {
  name          = "${var.project_name}-lt"
  image_id      = "ami-089950bc622d39ed8"
  instance_type = "t2.micro"
  # vpc_security_group_ids = [aws_security_group.ecs_sg.id]
  # key_name               = var.ssh_key_name

  # iam_instance_profile {
  #   name = aws_iam_instance_profile.ecs_iam_ip.name
  # }
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                = "${var.project_name}-asg"
  max_size            = 2
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  health_check_type   = "EC2"

  instance_refresh {
    strategy = "Rolling"
  }

  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }
}

