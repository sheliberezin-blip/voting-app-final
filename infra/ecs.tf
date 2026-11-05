resource "aws_ecs_cluster" "main" {
  name = "${local.name}-cluster"

  tags = {
    Name = "${local.name}-cluster"
  }
}

module "vote" {
  source = "./modules/service"

  name                = "${local.name}-vote"
  cluster_id          = aws_ecs_cluster.main.id
  image               = "${data.aws_ecr_repository.vote.repository_url}:${var.image_tag}"
  subnet_ids          = [for s in aws_subnet.public : s.id]
  security_group_ids  = [aws_security_group.ecs.id]
  execution_role_arn  = aws_iam_role.ecs_execution.arn
  container_port      = 80
  target_group_arn    = aws_lb_target_group.vote.arn
  desired_count        = var.env == "prod" ? 2 : 1

  environment = {
    REDIS_HOST     = aws_elasticache_cluster.main.cache_nodes[0].address
    OPTION_A       = var.option_a
    OPTION_B       = var.option_b
    ALLOWED_ORIGIN = "*"
  }

  depends_on = [aws_lb_listener.vote]
}

module "result" {
  source = "./modules/service"

  name                = "${local.name}-result"
  cluster_id          = aws_ecs_cluster.main.id
  image               = "${data.aws_ecr_repository.result.repository_url}:${var.image_tag}"
  subnet_ids          = [for s in aws_subnet.public : s.id]
  security_group_ids  = [aws_security_group.ecs.id]
  execution_role_arn  = aws_iam_role.ecs_execution.arn
  container_port      = 80
  target_group_arn    = aws_lb_target_group.result.arn
  desired_count        = var.env == "prod" ? 2 : 1

  environment = {
    DB_HOST        = aws_db_instance.main.address
    DB_PORT        = tostring(aws_db_instance.main.port)
    DB_USER        = aws_db_instance.main.username
    DB_NAME        = aws_db_instance.main.db_name
    DB_SSL         = "true"
    ALLOWED_ORIGIN = "*"
  }

  secrets = {
    DB_PASSWORD = aws_secretsmanager_secret.db_password.arn
  }

  depends_on = [aws_lb_listener.result]
}

module "worker" {
  source = "./modules/service"

  name                = "${local.name}-worker"
  cluster_id          = aws_ecs_cluster.main.id
  image               = "${data.aws_ecr_repository.worker.repository_url}:${var.image_tag}"
  subnet_ids          = [for s in aws_subnet.public : s.id]
  security_group_ids  = [aws_security_group.ecs.id]
  execution_role_arn  = aws_iam_role.ecs_execution.arn
  desired_count        = var.env == "prod" ? 2 : 1

  environment = {
    REDIS_HOST = aws_elasticache_cluster.main.cache_nodes[0].address
    DB_HOST    = aws_db_instance.main.address
    DB_PORT    = tostring(aws_db_instance.main.port)
    DB_USER    = aws_db_instance.main.username
    DB_NAME    = aws_db_instance.main.db_name
    DB_SSL     = "true"
  }

  secrets = {
    DB_PASSWORD = aws_secretsmanager_secret.db_password.arn
  }
}