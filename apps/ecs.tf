resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.project_name
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "${var.project_name}-log-group"
}

resource "aws_ecs_task_definition" "task_definition" {
family = var.project_name
  container_definitions = jsonencode(
    [{
      "name" : "site",
      "image" : "${var.ecr_image}",
      "cpu" : 0,
      "essential" : true,
      "networkMode" : "awsvpc",
      "portMappings" : [
        {
          "containerPort" : 80,
          "hostPort" : 80,
          "protocol" : "tcp"
        }
      ],
      "privileged" : false,
      "readonlyRootFilesystem" : false,
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "${aws_cloudwatch_log_group.log_group.name}",
          "awslogs-region" : "${var.region}",
          "awslogs-stream-prefix" : "site"
        }
      }
  }])
  # execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  memory                   = 1024
  cpu                      = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
}

resource "aws_ecs_service" "ecs_service" {
  name            = var.project_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = var.desired_count

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_cp.name
    weight            = 100
    base              = 0
  }

  network_configuration {
    subnets         = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
    security_groups = [aws_security_group.ecs_tasks.id, aws_security_group.alb.id]
    # assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.alb_target_group.arn
    container_name   = "site"
    container_port   = 80
  }

  depends_on = [aws_alb_listener.alb_listener]
}
