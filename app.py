from flask import Flask, jsonify
app = Flask(__name__)

@app.get("/")
def home():
    return "Hello from CodeDeploy + Flask!!!!!"

@app.get("/health")
def health():
    return jsonify(status="ok")
