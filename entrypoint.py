import os
import logging
from flask import Flask, request, send_from_directory, abort

# ---------------------------
# Flask App + Logging Setup
# ---------------------------

app = Flask(__name__)

logging.basicConfig(
    level=logging.DEBUG,                 # log everything
    format='[%(asctime)s] %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

# ---------------------------
# Storage directory
# ---------------------------

MEDIA_DIR = "/home/lcarmina/DEV/scripts/live_dash_ll/storage/"
os.makedirs(MEDIA_DIR, exist_ok=True)

# ---------------------------
# Log every incoming request
# ---------------------------

@app.before_request
def log_request():
    logger.debug(f"Incoming request: {request.method} {request.url}")
    logger.debug(f"Headers: {dict(request.headers)}")

    if request.method == "POST":
        logger.debug(f"POST content length: {request.content_length}")
        logger.debug("POST request body received (binary not printed).")

# ---------------------------
# Handle chunked file upload and DELETE
# ---------------------------
@app.route('/cmaf/syna/live/<path:filename>', methods=['GET', 'POST', 'DELETE'])
def handle_file(filename):
    file_path = os.path.join(MEDIA_DIR, filename)
    os.makedirs(os.path.dirname(file_path), exist_ok=True)

    if request.method == "GET":
        return send_from_directory(MEDIA_DIR, filename)

    elif request.method == "POST":
        # Read the raw POST body (works for chunked uploads)
        with open(file_path, 'wb') as f:
            chunk_size = 1024 * 1024  # 1MB
            while True:
                chunk = request.stream.read(chunk_size)
                if not chunk:
                    break
                f.write(chunk)

        logger.debug(f"File successfully saved: {file_path}")
        return f"File {filename} uploaded successfully!", 200

    elif request.method == "DELETE":
        if os.path.exists(file_path):
            os.remove(file_path)
            logger.debug(f"File deleted successfully: {file_path}")
            return f"File {filename} deleted successfully!", 200
        else:
            abort(404, f"File {filename} not found")


# ---------------------------
# Root route
# ---------------------------

@app.route('/')
def index():
    return "DASH Entry Point Server with Logging is running!"

# ---------------------------
# Start server
# ---------------------------
if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8080, debug=False, threaded=True)
