from flask import Flask, request, jsonify
from huggingface_hub import InferenceClient
import os

app = Flask(__name__)

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

    try:
        completion = client.chat.completions.create(
            model="mistralai/Mixtral-8x7B-Instruct-v0.1",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=100,
            temperature=0.7,
        )
        response = completion.choices[0].message.content
        return jsonify({"response": response})
    except Exception as e:
        app.logger.error(f"Error calling Hugging Face API: {str(e)}")
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
