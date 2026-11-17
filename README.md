# application-intelligence-serverless-nlp-inference

![License](https://img.shields.io/badge/license-MIT--0-blue.svg)
![Huawei Cloud](https://img.shields.io/badge/%E5%8D%8E%E4%B8%BA%E4%BA%91-%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5-ff4d00.svg)

> A serverless ML inference service based on Huawei Cloud FunctionGraph + ModelArts, providing real-time NLP Q&A and model performance monitoring capabilities.

> [中文](README.cn.md)

---

## Overview

This project provides a **real-time NLP Question & Answer service** and **model performance monitoring solution** on Huawei Cloud.

### Core Features

1. **Real-time NLP Q&A Inference**
   - Question answering service based on HuggingFace PyTorch models
   - Uses Extractive QA algorithm to extract answers from given context
   - OpenAI-compatible API interface format

2. **Model Performance Monitoring**
   - Automatically records every inference request input (question + context)
   - Automatically records model prediction results (extracted answers)
   - Persists to OBS bucket for downstream analysis

3. **Serverless Architecture**
   - Fully managed FunctionGraph functions, no server management required
   - Pay per actual use, no resources held when idle

---

## Architecture

```
User Request
    │
    ▼
┌─────────────────────────────────────────────────────┐
│                    APIG Gateway                    │
│              POST /nlp-qa                        │
└────────────────────────┬────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│              FunctionGraph Function                │
│         Python 3.9 + transformers              │
└────────────────────────┬────────────────────────────┘
                         │
            ┌────────────┴────────────┐
            ▼                         ▼
┌─────────────────────┐    ┌─────────────────────┐
│    OBS Log Bucket   │    │   ModelArts        │
│  inference_logs/   │    │   Inference        │
│  - input.json      │    │   Endpoint         │
│  - output.json     │    │   (PyTorch)        │
└─────────────────────┘    └─────────────────────┘
```

---

## Key Features

- **Serverless Architecture**: Uses FunctionGraph, pay per actual invocation, no server provisioning
- **OpenAI-Compatible Interface**: API format aligned with OpenAI for easy integration
- **Log Persistence**: Inference logs (input + output) automatically written to OBS for model analysis
- **Extractive QA**: Precisely extracts answers from context, supports long-text Q&A scenarios

---

## Use Cases

### 1. Intelligent Customer Service Q&A
- **Scenario**: Internal knowledge base Q&A, automated product FAQ responses
- **Input**: User question + relevant documentation/knowledge base content
- **Output**: Accurate answer extracted from documents

### 2. Document Intelligent Analysis
- **Scenario**: Contract review, legal query, technical documentation Q&A
- **Input**: Document content to analyze + specific question
- **Output**: Relevant passages located and extracted from documents

### 3. Model Performance Monitoring & Analysis
- **Scenario**: Post-deployment ML model effect monitoring, anomaly detection
- **Function**: Records every inference input/output, supports post-hoc model performance analysis

---

## API Usage Examples

### Request Format

```json
{
  "question": "What is my name?",
  "context": "My name is Clara and I live in Berkeley. I am a software engineer."
}
```

### Response Format

```json
{
  "answer": "Clara",
  "score": 0.95,
  "start": 11,
  "end": 16
}
```

### cURL Example

```bash
curl -X POST https://<api-endpoint>/nlp-qa \
  -H "Content-Type: application/json" \
  -d '{"question": "What is my name?", "context": "My name is Clara and I live in Berkeley."}'
```

### Python Example

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

## Prerequisites

> Run `bash scripts/build-nlp-package.sh` to build the function package before deployment.

- Huawei Cloud account (real-name authentication required)
- Services enabled: OBS, FunctionGraph, APIG, IAM
- ModelArts deployed with PyTorch inference endpoint (preset or custom model)

---

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/huaweicloud-samples/application-intelligence-serverless-nlp-inference.git
cd application-intelligence-serverless-nlp-inference
```

### 2. Configure Credentials

```bash
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"
export HW_REGION_NAME="cn-north-4"
```

### 3. Initialize Terraform

```bash
cd infra
terraform init
```

### 4. Validate Configuration

```bash
terraform validate
```

### 5. Deploy

```bash
terraform apply
```

### 6. Test

```bash
# Get API endpoint
API_ENDPOINT=$(terraform output -raw api_endpoint)

# Test Q&A
curl -X POST "${API_ENDPOINT}/nlp-qa" \
  -H "Content-Type: application/json" \
  -d '{"question": "What is the capital of France?", "context": "France is a country in Europe. Its capital is Paris."}'
```

---

## Viewing Logs

Inference logs are stored in the OBS bucket under `inference_logs/`:

```bash
# Using OBS Browser+ or the obsutil CLI tool
obsutil ls obs://<bucket-name>/inference_logs/
```

Log Format:

**input.json** (Inference Input):
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "question": "What is the capital of France?",
  "context": "France is a country in Europe. Its capital is Paris."
}
```

**output.json** (Inference Output):
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "answer": "Paris",
  "score": 0.98,
  "model": "distilbert-base-uncased-distilled-squad"
}
```

---

## Cleanup

```bash
terraform destroy
```

---

## License

MIT No Attribution - See [LICENSE](LICENSE) file for details
