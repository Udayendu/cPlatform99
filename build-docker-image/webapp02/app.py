from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello ():
  return 'Open a new tab and enter /welcome/name for URL'

@app.route('/welcome/<name>')
def Welcome_name(name):
  return "Welcome {}!".format(name)

if __name__ == '__main__':
  app.run(host='0.0.0.0', port=8443)
