# Unit-IV Web Application Design and Development: Web technologies, web interfaces to databases, digital signatures and digital certificates, performance issues, XML in Databases. 

import psycopg2
from flask import Flask, jsonify
import xml.etree.ElementTree as ET
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding, rsa

app = Flask(__name__)

# --- Database connection config ---
conn_params = {
    'host': 'localhost',
    'database': 'yourdb',
    'user': 'youruser',
    'password': 'yourpass'
}

# --- Setup DB schema and insert XML data ---
def setup_database():
    conn = psycopg2.connect(**conn_params)
    cur = conn.cursor()
    
    # Create Products table with XML column
    cur.execute("""
    CREATE TABLE IF NOT EXISTS Products (
        ProductID SERIAL PRIMARY KEY,
        Name VARCHAR(100),
        Details XML
    )
    """)
    
    # Insert sample data if empty
    cur.execute("SELECT COUNT(*) FROM Products")
    count = cur.fetchone()[0]
    if count == 0:
        cur.execute("""
        INSERT INTO Products (Name, Details) VALUES
        ('Laptop', 
        '<?xml version="1.0"?><product><brand>XYZ</brand><specs><cpu>Intel i7</cpu><ram>16GB</ram><storage>512GB SSD</storage></specs></product>'),
        ('Smartphone',
        '<?xml version="1.0"?><product><brand>ABC</brand><specs><cpu>Snapdragon 888</cpu><ram>8GB</ram><storage>256GB</storage></specs></product>')
        """)
    
    conn.commit()
    cur.close()
    conn.close()

# --- REST API endpoint to fetch products ---
@app.route('/products', methods=['GET'])
def get_products():
    conn = psycopg2.connect(**conn_params)
    cur = conn.cursor()
    cur.execute("SELECT ProductID, Name, Details FROM Products")
    rows = cur.fetchall()
    products = []
    for pid, name, details_xml in rows:
        # Parse XML details to extract specs
        root = ET.fromstring(details_xml)
        specs = root.find('specs')
        cpu = specs.find('cpu').text
        ram = specs.find('ram').text
        storage = specs.find('storage').text
        products.append({
            'ProductID': pid,
            'Name': name,
            'CPU': cpu,
            'RAM': ram,
            'Storage': storage
        })
    cur.close()
    conn.close()
    return jsonify(products)

# --- Digital Signature generation and verification ---
def digital_signature_demo():
    print("\n--- Digital Signature Demo ---")
    # Generate keys
    private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    public_key = private_key.public_key()

    message = b"Important transaction data"

    # Sign message
    signature = private_key.sign(
        message,
        padding.PSS(mgf=padding.MGF1(hashes.SHA256()), salt_length=padding.PSS.MAX_LENGTH),
        hashes.SHA256()
    )
    print("Message signed.")

    # Verify signature
    try:
        public_key.verify(
            signature,
            message,
            padding.PSS(mgf=padding.MGF1(hashes.SHA256()), salt_length=padding.PSS.MAX_LENGTH),
            hashes.SHA256()
        )
        print("Signature verified successfully!")
    except Exception as e:
        print("Signature verification failed:", e)

# --- Performance tips ---
performance_tips = """
Performance Considerations:
1. Use connection pooling for database connections.
2. Cache frequent queries/results.
3. Optimize SQL with indexes and analyze query plans.
4. Use pagination for large datasets.
5. Handle requests asynchronously if possible.
6. Index XML paths if DB supports it.
7. Secure APIs with authentication and encryption.
"""

if __name__ == '__main__':
    print("Setting up database...")
    setup_database()
    print("Database setup complete.")
    
    digital_signature_demo()
    
    print(performance_tips)
    
    print("Starting Flask server at http://127.0.0.1:5000/products")
    app.run(debug=True)
