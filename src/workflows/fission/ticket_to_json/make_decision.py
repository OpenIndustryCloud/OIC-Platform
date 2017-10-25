import json
from flask import request, jsonify

def main():
    input = request.json
    risk = input['risk']
    if risk > 70:
        status = 'denied'
    else:
        status = 'accepted'

    msg = {'id':input['id'], 'risk': risk, 'status': status}
    # return json.dumps(msg)
    return jsonify(msg)
