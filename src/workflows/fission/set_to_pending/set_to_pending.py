import json
import random
from flask import request, jsonify

def main():
    input = request.json
    risk = random.randint(1,100)
    status = 'pending'
    msg = {'id':input['id'],'status': status, 'risk': risk}
    # return json.dumps(msg)
    return jsonify(msg)