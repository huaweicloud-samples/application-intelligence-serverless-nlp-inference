# application-intelligence-serverless-nlp-inference

![License](https://img.shields.io/badge/license-MIT--0-blue.svg)
![Huawei Cloud](https://img.shields.io/badge/%E5%8D%8E%E4%B8%BA%E4%BA%91-%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5-ff4d00.svg)

> 基于华为云 FunctionGraph + ModelArts 的无服务器ML推理服务，提供实时NLP问答与模型性能监控能力。

> [English](README.md)

---

## 简介

本项目提供基于华为云的**实时NLP问答服务**与**模型性能监控解决方案**。

### 核心功能

1. **实时NLP问答推理**
   - 基于 HuggingFace PyTorch 模型的问答服务
   - 使用抽取式问答（Extractive QA）算法，从给定文本上下文中提取答案
   - 支持 OpenAI 兼容的 API 接口格式

2. **模型性能监控**
   - 自动记录每一次推理请求的输入（question + context）
   - 自动记录模型预测结果（提取的答案）
   - 持久化存储到 OBS 桶，便于后续分析

3. **无服务器架构**
   - 完全托管的 FunctionGraph 函数，无需管理服务器
   - 按实际调用量付费，空闲时不占用资源

---

## 架构

```
用户请求
    │
    ▼
┌─────────────────────────────────────────────────────┐
│                    APIG 网关                       │
│              POST /nlp-qa                        │
└────────────────────────┬────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│              FunctionGraph 函数                    │
│         Python 3.9 + transformers              │
└────────────────────────┬────────────────────────────┘
                         │
            ┌────────────┴────────────┐
            ▼                         ▼
┌─────────────────────┐    ┌─────────────────────┐
│    OBS 日志桶       │    │   ModelArts        │
│  inference_logs/   │    │   推理端点         │
│  - input.json      │    │   (PyTorch)        │
│  - output.json     │    │                    │
└─────────────────────┘    └─────────────────────┘
```

---

## 核心特点

- **无服务器架构**: 使用FunctionGraph，按实际调用量付费，无需预置服务器
- **OpenAI兼容接口**: API格式与OpenAI保持一致，便于对接和集成
- **日志持久化**: 推理日志（输入+输出）自动写入OBS，便于模型性能分析
- **抽取式问答**: 从上下文中精确提取答案，支持长文本问答场景

---

## 使用案例

### 1. 智能客服问答
- **场景**: 企业内部知识库问答、产品FAQ自动问答
- **输入**: 用户问题 + 相关文档/知识库内容
- **输出**: 从文档中提取的准确答案

### 2. 文档智能解析
- **场景**: 合同审查、法条查询、技术文档问答
- **输入**: 待解析的文档内容 + 具体问题
- **输出**: 从文档中定位并提取的相关段落

### 3. 模型性能监控与分析
- **场景**: ML模型上线后的效果监控、异常检测
- **功能**: 记录每一次推理的输入输出，支持事后分析模型表现

---

## API 使用示例

### 请求格式

```json
{
  "question": "What is my name?",
  "context": "My name is Clara and I live in Berkeley. I am a software engineer."
}
```

### 响应格式

```json
{
  "answer": "Clara",
  "score": 0.95,
  "start": 11,
  "end": 16
}
```

### cURL 示例

```bash
curl -X POST https://<api-endpoint>/nlp-qa \
  -H "Content-Type: application/json" \
  -d '{"question": "What is my name?", "context": "My name is Clara and I live in Berkeley."}'
```

### Python 示例

```python
import requests

url = "https://<api-endpoint>/nlp-qa"
payload = {
    "question": "What is machine learning?",
    "context": "Machine learning is a subset of artificial intelligence that enables systems to learn from data."
}

response = requests.post(url, json=payload)
print(response.json())
```

---

## 前置条件

> 部署前先运行 `bash scripts/build-nlp-package.sh` 生成函数代码包。

- 华为云账号（需完成实名认证）
- 已开通服务：OBS、FunctionGraph、APIG、IAM
- ModelArts 已部署 PyTorch 推理端点（预置模型或自定义模型）

---

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/huaweicloud-samples/application-intelligence-serverless-nlp-inference.git
cd application-intelligence-serverless-nlp-inference
```

### 2. 配置凭证

```bash
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"
export HW_REGION_NAME="cn-north-4"
```

### 3. 初始化 Terraform

```bash
cd infra
terraform init
```

### 4. 验证配置

```bash
terraform validate
```

### 5. 部署

```bash
terraform apply
```

### 6. 测试

```bash
# 获取 API 地址
API_ENDPOINT=$(terraform output -raw api_endpoint)

# 测试问答
curl -X POST "${API_ENDPOINT}/nlp-qa" \
  -H "Content-Type: application/json" \
  -d '{"question": "What is the capital of France?", "context": "France is a country in Europe. Its capital is Paris."}'
```

---

## 查看日志

推理日志存储在 OBS 桶的 `inference_logs/` 目录下：

```bash
# 使用 OBS Browser+ 或 obsutil 命令行工具
obsutil ls obs://<bucket-name>/inference_logs/
```

日志格式：

**input.json** (推理输入):
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "question": "What is the capital of France?",
  "context": "France is a country in Europe. Its capital is Paris."
}
```

**output.json** (推理输出):
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "answer": "Paris",
  "score": 0.98,
  "model": "distilbert-base-uncased-distilled-squad"
}
```

---

## 清理资源

```bash
terraform destroy
```

---

## 许可证

MIT No Attribution - 详见 [LICENSE](LICENSE) 文件
