import flask
app = flask.Flask(__name__)

@app.route("/")
def index():
    ip_address = flask.request.remote_addr
    return "Requester IP: {} ".format(ip_address)


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8443)
