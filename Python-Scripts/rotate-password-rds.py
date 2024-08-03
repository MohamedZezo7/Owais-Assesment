import subprocess

MYSQL_USER = 'root'
MYSQL_PASSWORD = 'current_password'
MYSQL_DATABASE = 'mydatabase'
MONGO_USER = 'admin'
MONGO_PASSWORD = 'current_password'
MONGO_DATABASE = 'nodejs_api'

def rotate_mysql_credentials():
    """Rotate MySQL credentials."""
    new_mysql_password = 'new_password'
    print(f"Rotating MySQL credentials for user '{MYSQL_USER}'...")
    
    subprocess.run([
        'mysql', '-u', MYSQL_USER, '-p' + MYSQL_PASSWORD,
        '-e', f"ALTER USER '{MYSQL_USER}'@'localhost' IDENTIFIED BY '{new_mysql_password}';"
    ])
    print(f"MySQL password updated successfully.")

def rotate_mongodb_credentials():
    """Rotate MongoDB credentials."""
    new_mongo_password = 'new_password'
    print(f"Rotating MongoDB credentials for user '{MONGO_USER}'...")
    
    subprocess.run([
        'mongo', '--eval', f"""
            use admin;
            db.changeUserPassword('{MONGO_USER}', '{new_mongo_password}');
            use {MONGO_DATABASE};
            db.createUser({{
                user: '{MONGO_USER}',
                pwd: '{new_mongo_password}',
                roles: ['readWrite']
            }});
        """
    ])
    print(f"MongoDB password updated successfully.")

if __name__ == "__main__":
    rotate_mysql_credentials()
    rotate_mongodb_credentials()
