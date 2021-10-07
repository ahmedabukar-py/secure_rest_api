
from flask import Flask, make_response, request, render_template
from random import random
import datetime
import jwt

SECRET_KEY = "C7E2F9D46E92DCF2234D18BEF8C6D"
flask_app = Flask(__name__)

def verify_token(token):
    if token:
        decoded_token = jwt.decode(token, SECRET_KEY, "HS256")
        print(decoded_token)
        # Check whther the information in decoded_token is correct or not

        return True # if the information is correct, otherwise return False
    else:
        return False

@flask_app.route('/')
def index_page():
    print(request.cookies)
    isUserLoggedIn = False
    if 'token' in request.cookies:
        isUserLoggedIn = verify_token(request.cookies['token'])

    if isUserLoggedIn:
        return "Welcome back to the website"
    else:
        user_id = random()
        print(f"User ID: {user_id}")
        resp = make_response("This is the index page of a Secure REST API")
        resp.set_cookie('user_id', str(user_id))
        return resp

@flask_app.route('/calculate')
def calculator():
    return render_template("calculator.html")

@flask_app.route('/proceed')
def proceed():
    return render_template("proceed.html")

@flask_app.route('/login')
def login_page():
    return render_template('login.html')
#       <form action="/send" method="POST">

@flask_app.route('/send', methods = ['POST'])
def send():
    if request.method == "POST":
        num1 = request.form['num1']
        num2 = request.form['num2']
        operation = request.form["operation"]

    if operation == "add":
        sum = float(num1) + float(num2)
        return render_template("calculator.html", sum=sum)
    elif operation == "subtraction":
        sum = float(num1) - float(num2)
        return render_template("calculator.html", sum=sum)
    elif operation == "multiply":
        sum = float(num1) * float(num2)
        return render_template("calculator.html", sum=sum)
    elif operation == "divide":
        sum = float(num1) / float(num2)
        return render_template("calculator.html", sum=sum)
    else:
        return render_template("calculator.html")


def create_token(username, password):
    validity = datetime.datetime.utcnow() + datetime.timedelta(days=15)
    token = jwt.encode({'user_id': 123154, 'username': username, 'expiry': str(validity)}, SECRET_KEY, "HS256")
    return token

@flask_app.route('/authenticate', methods = ['POST'])
def authenticate_users():
    data = request.form
    username = data['username']
    password =  ['password']


    # check whether the username and password are correct
    user_token = create_token(username, password)

    resp = make_response("Logged In Successflly")
    #resp.set_cookie("loggedIn", "True")
    resp.set_cookie('token', user_token)
    return resp

if __name__ == "__main__":
    print("This is a Secure REST API Server")
    flask_app.run(host = "0.0.0.0", debug = True, ssl_context=('cert/cert.pem', 'cert/key.pem'))
