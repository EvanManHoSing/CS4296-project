import json
import os
from huggingface_hub import InferenceClient

# Get API token from environment variable
API_TOKEN = os.getenv("HF_API_TOKEN")

# Initialize InferenceClient
client = InferenceClient(api_key=API_TOKEN)


def lambda_handler(event, context):
    if not API_TOKEN:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "API token not available"}),
            "headers": {"Content-Type": "application/json"},
        }

    try:
        body = json.loads(event["body"])
        prompt = body.get("prompt", "")
        if not prompt:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "No prompt provided"}),
                "headers": {"Content-Type": "application/json"},
            }

        completion = client.chat.completions.create(
            model="mistralai/Mixtral-8x7B-Instruct-v0.1",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=100,
            temperature=0.7,
        )
        response = completion.choices[0].message.content

        return {
            "statusCode": 200,
            "body": json.dumps({"response": response}),
            "headers": {"Content-Type": "application/json"},
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)}),
            "headers": {"Content-Type": "application/json"},
        }
