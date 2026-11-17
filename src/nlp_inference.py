"""
NLP推理函数 - FunctionGraph
调用ModelArts推理端点进行问答
"""
import json
import os
import requests

MODEL_ENDPOINT = os.environ.get('MODEL_ENDPOINT', '')
OBS_BUCKET = os.environ.get('OBS_BUCKET', '')

def handler(event, context):
    try:
        # 解析请求
        body = json.loads(event.get('body', '{}'))
        question = body.get('question', '')
        context_text = body.get('context', '')
        
        if not question or not context_text:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'question and context are required'})
            }
        
        # 调用ModelArts推理端点
        if MODEL_ENDPOINT:
            response = requests.post(
                f'{MODEL_ENDPOINT}/predict',
                json={'text': f'Q: {question}\nA: {context_text}'},
                timeout=30
            )
            answer = response.json().get('answer', 'No answer generated')
        else:
            answer = f"Question: {question}\nContext: {context_text}"
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'question': question,
                'answer': answer
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
