# 部署指南

## 前置条件

- 华为云账号
- 已开通：OBS、FunctionGraph、APIG、IAM
- ModelArts已部署PyTorch推理端点
- Terraform >= 1.0

## 快速开始

> 部署前先运行 `bash scripts/build-nlp-package.sh` 生成函数代码包（该 zip 为构建产物，不入库）。

```bash
# 1. 配置凭证
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"

# 2. 初始化
cd infra
terraform init

# 3. 验证
terraform validate

# 4. 部署
terraform apply
```

## 分步部署

### 1. 部署OBS桶

```bash
terraform apply -target=huaweicloud_obs_bucket.inference_logs
terraform apply -target=huaweicloud_obs_bucket.model_cache
```

### 2. 部署FunctionGraph函数

```bash
terraform apply -target=huaweicloud_fgs_function.nlp_inference
```

### 3. 部署APIG

```bash
terraform apply -target=huaweicloud_apig_api.nlp_qa
terraform apply -target=huaweicloud_apig_api_publishment.nlp_qa
```

## 验证

```bash
# 测试API
curl -X POST https://<api-endpoint>/nlp-qa \
  -H "Content-Type: application/json" \
  -d '{"question": "What is your name?", "context": "My name is Test."}'
```

## 清理

```bash
terraform destroy
```
