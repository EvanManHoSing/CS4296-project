from flask import Flask, request, jsonify, g
from huggingface_hub import InferenceClient
import os
import time
import logging
from pythonjsonlogger import jsonlogger
from datetime import datetime

app = Flask(__name__)

# Setting up the logger
logger = logging.getLogger()
logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter("{message}{asctime}{method}", style="{")
logHandler.setFormatter(formatter)

logger.addHandler(logHandler)
logger.setLevel(logging.INFO)
logging.getLogger("werkzeug").disabled = True

# Get the directory where backend.py is located
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
TOKEN_PATH = os.path.join(BASE_DIR, "token.txt")

# Load Hugging Face API token from token.txt
try:
    with open(TOKEN_PATH, "r") as file:
        API_TOKEN = file.read().strip()
except FileNotFoundError:
    API_TOKEN = None

client = InferenceClient(api_key=API_TOKEN)


def log_client(prompt):
    logger.info(
        {"message": "Client Request", "method": request.method, "prompt": prompt}
    )


# Mark the start time for each request
@app.before_request
def mark_start():
    g.start = time.time()


# Log the response


def log_response(response):
    end = time.time()
    duration = round(end - g.start, 5)
    content_text = ""

    # In case the response is too long
    if len(response) > 50:
        content_text = response[:30] + "..."
    else:
        content_text = response

    logger.info(
        {
            "message": "API Response",
            "duration": duration,
            "method": request.method,
            "response": content_text,
        }
    )
    return duration


@app.route("/generate", methods=["POST"])
def generate_response():
    if not API_TOKEN:
        return jsonify({"error": "token.txt not found"}), 500

    data = request.get_json()
    if not data or "prompt" not in data:
        return jsonify({"error": "No prompt provided or invalid JSON"}), 400

    prompt = data["prompt"]
    if not prompt:
        return jsonify({"error": "Prompt is empty"}), 400

    log_client(prompt)

    try:
        completion = client.chat.completions.create(
            model="mistralai/Mixtral-8x7B-Instruct-v0.1",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=100,
            temperature=0.7,
        )
        response = completion.choices[0].message.content

        duration = log_response(response)

        return jsonify({"response": response, "duration": duration}), 200
    except Exception as e:
        app.logger.error(f"Error calling Hugging Face API: {str(e)}")
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
