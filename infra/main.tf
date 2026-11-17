# Terraform配置 - 华为云无服务器ML监控

terraform {
  required_version = ">= 1.0"
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = "1.96.0"
    }
  }
}

provider "huaweicloud" {
  region = var.region
}

# OBS桶 - 存储推理日志
resource "huaweicloud_obs_bucket" "inference_logs" {
  bucket = "inference-logs-${var.project}"
  acl    = "private"
}

# FunctionGraph函数 - NLP推理
resource "huaweicloud_fgs_function" "nlp_inference" {
  name        = "nlp-inference"
  runtime     = "Python3.9"
  handler     = "nlp_inference.handler"
  memory_size = 1024
  timeout     = 60

  app = "default"

  func_code = filebase64("${path.module}/../../src/nlp_inference.zip")

  environment {
    variables = {
      MODEL_ENDPOINT = var.model_endpoint
      OBS_BUCKET     = huaweicloud_obs_bucket.inference_logs.bucket
    }
  }
}

# APIG实例
resource "huaweicloud_apig_instance" "main" {
  name              = "nlp-qa-apig"
  flavor            = "BASIC"
  vpc_id            = huaweicloud_vpc.main.id
  subnet_id         = huaweicloud_vpc_subnet.main.id
  available_zones   = ["cn-north-4a", "cn-north-4b"]
  security_group_id = huaweicloud_networking_secgroup.default.id
}

# APIG API
resource "huaweicloud_apig_api" "nlp_qa" {
  name         = "nlp-qa"
  gateway_id   = huaweicloud_apig_instance.main.id
  path         = "/nlp-qa"
  method       = "POST"
  function_urn = huaweicloud_fgs_function.nlp_inference.urn
}

resource "huaweicloud_apig_api_publishment" "nlp_qa" {
  api_id = huaweicloud_apig_api.nlp_qa.id
  env_id = "release"
}

# VPC
resource "huaweicloud_vpc" "main" {
  name = "nlp-qa-vpc"
  cidr = "10.0.0.0/16"
}

# 子网
resource "huaweicloud_vpc_subnet" "main" {
  name       = "nlp-qa-subnet"
  vpc_id     = huaweicloud_vpc.main.id
  cidr       = "10.0.1.0/24"
  gateway_ip = "10.0.1.1"
}

# 安全组
resource "huaweicloud_networking_secgroup" "default" {
  name        = "nlp-qa-sg"
  description = "Security group for NLP QA API"
}

resource "huaweicloud_networking_secgroup_rule" "ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = huaweicloud_networking_secgroup.default.id
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
}

# 输出
output "api_endpoint" {
  value = "https://${huaweicloud_apig_instance.main.endpoint}/nlp-qa"
}
