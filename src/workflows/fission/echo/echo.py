from flask import request, jsonify


def main():
    input = request.json
    return jsonify(input)
