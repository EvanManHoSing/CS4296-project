import os
import json
from huggingface_hub import InferenceClient

API_TOKEN = os.environ.get("HF_API_TOKEN")
client = InferenceClient(api_key=API_TOKEN)


def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))
        prompt = body.get("prompt")
        if not prompt:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Prompt is required."}),
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
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)}),
        }
