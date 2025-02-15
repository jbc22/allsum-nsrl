from flask import Flask, jsonify, request
import sqlite3
import os

app = Flask(__name__)

DB_PATH = '/mnt/data/RDS_2024.03.1_modern/RDS_2024.03.1_modern.db'


def query_db(query, args=(), one=False):
    try:
        with sqlite3.connect(DB_PATH) as conn:
            conn.row_factory = sqlite3.Row
            cur = conn.execute(query, args)
            results = cur.fetchall()
            cur.close()
            return (results[0] if results else None) if one else [dict(row) for row in results]
    except sqlite3.Error as e:
        return {"error": str(e)}


@app.route('/')
def home():
    return "Flask App Connected to RDS Database"


@app.route('/applications', methods=['GET'])
def get_applications():
    """Retrieve all applications"""
    apps = query_db("SELECT * FROM APPLICATION")
    return jsonify(apps)


@app.route('/files', methods=['GET'])
def get_files():
    """Retrieve files with optional filter for package_id"""
    package_id = request.args.get('package_id')
    if package_id:
        query = "SELECT * FROM FILE WHERE package_id = ?"
        files = query_db(query, (package_id,))
    else:
        files = query_db("SELECT * FROM FILE")
    return jsonify(files)


@app.route('/os', methods=['GET'])
def get_operating_systems():
    """Retrieve all operating systems"""
    os_info = query_db("SELECT * FROM OS")
    return jsonify(os_info)


@app.route('/manufacturers', methods=['GET'])
def get_manufacturers():
    """Retrieve all manufacturers"""
    manufacturers = query_db("SELECT * FROM MFG")
    return jsonify(manufacturers)


@app.route('/packages', methods=['GET'])
def get_packages():
    """Retrieve packages with optional filtering by OS or manufacturer"""
    os_id = request.args.get('os_id')
    mfg_id = request.args.get('mfg_id')

    query = "SELECT * FROM PKG"
    params = []

    if os_id:
        query
