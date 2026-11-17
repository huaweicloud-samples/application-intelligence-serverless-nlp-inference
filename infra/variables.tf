variable "region" {
  description = "华为云区域"
  type        = string
  default     = "cn-north-4"
}

variable "project" {
  description = "项目名称"
  type        = string
  default     = "ml-monitoring"
}

variable "model_endpoint" {
  description = "ModelArts推理端点"
  type        = string
  default     = ""
}
