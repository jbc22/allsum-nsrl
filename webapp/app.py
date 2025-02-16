from flask import Flask, jsonify, request, render_template, redirect, url_for
import sqlite3
import os

app = Flask(__name__)

DB_PATH = '/mnt/data/RDS_2024.03.1_modern/RDS_2024.03.1_modern.db'
USER_DB_PATH = '/mnt/data/users.db'


def query_db(query, args=(), one=False, db_path=DB_PATH):
    try:
        with sqlite3.connect(db_path) as conn:
            conn.row_factory = sqlite3.Row
            cur = conn.execute(query, args)
            results = cur.fetchall()
            cur.close()
            return (results[0] if results else None) if one else [dict(row) for row in results]
    except sqlite3.Error as e:
        return {"error": str(e)}


def execute_db(query, args=(), db_path=DB_PATH):
    try:
        with sqlite3.connect(db_path) as conn:
            cur = conn.execute(query, args)
            conn.commit()
            cur.close()
    except sqlite3.Error as e:
        return {"error": str(e)}


@app.route('/', methods=['GET', 'POST'])
def home():
    """Search the database for a term"""
    if request.method == 'POST':
        term = request.form['term']
        query = """
        SELECT * FROM FILE WHERE 
        name LIKE ? OR 
        description LIKE ? OR 
        path LIKE ?
        """
        search_term = f"%{term}%"
        results = query_db(query, (search_term, search_term, search_term))
        return render_template('search_results.html', results=results, term=term)
    return render_template('search.html')


@app.route('/api-docs')
def api_docs():
    """Render the API documentation"""
    return render_template('api_docs.html')


@app.route('/signup', methods=['GET', 'POST'])
def signup():
    """Sign up a new user"""
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        # You should hash the password before storing it in the database
        query = "INSERT INTO users (username, password) VALUES (?, ?)"
        execute_db(query, (username, password), db_path=USER_DB_PATH)
        return render_template('signup.html', success=True)
    return render_template('signup.html')


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
        query += " WHERE os_id = ?"
        params.append(os_id)
    if mfg_id:
        query += " AND mfg_id = ?" if os_id else " WHERE mfg_id = ?"
        params.append(mfg_id)

    packages = query_db(query, params)
    return jsonify(packages)


if __name__ == '__main__':
    # Create the users table if it doesn't exist
    execute_db("""
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
    )
    """, db_path=USER_DB_PATH)
    app.run(host='0.0.0.0', port=5001)