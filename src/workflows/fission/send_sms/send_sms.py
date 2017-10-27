import json
from twilio.rest import Client
from flask import request, jsonify

# Your Account SID from twilio.com/console
account_sid = "foo"
# Your Auth Token from twilio.com/console
auth_token  = "bar"

# Creating a global client
client = Client(account_sid, auth_token)

def main():
    input = request.json

    msg = ''.join(['Your request ',input['id'],' was ', input['status'], '.'])

    message = client.messages.create(
        to="+33616702389", 
        from_="+33756799844",
        body=msg)

    output = {'id':input['id'], 'risk': input['risk'], 'status': input['status'], 'sid': message.sid}

    # return json.dumps(output)
    return jsonify(output)
    
