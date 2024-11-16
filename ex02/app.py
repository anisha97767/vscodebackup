from flask import Flask
from redis import Redis
from redis.exceptions import RedisError  # Import RedisError
import os
import socket
 
# Connect to Redis
redis = Redis(host="redis", port=6379)
 
app = Flask(__name__)
 
@app.route("/")
def hello():
    try:
        visits = redis.incr("counter")  # Increment the visit counter in Redis
    except RedisError:
        visits = "<i>cannot connect to Redis, counter disabled</i>"
 
    # HTML template with placeholders for name and hostname
    html = "<h3>Hello {name}!</h3>" \
           "<b>Hostname:</b> {hostname}<br/>" \
           "<b>Visits:</b> {visits}<br/>"  # Added visit count in the response
 
    # Return the formatted HTML with name and hostname from environment variables
    return html.format(
        name=os.getenv("NAME", "world"),
        hostname=socket.gethostname(),
        visits=visits  # Pass visit count into the template
    )
 
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5001, debug=True)