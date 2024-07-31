import boto3
import mysql.connector
from mysql.connector import Error
import random
import string
import subprocess

# Function to generate a random password
def generate_random_password(length=12):
    characters = string.ascii_letters + string.digits + string.punctuation
    return ''.join(random.choice(characters) for i in range(length))

# Function to connect to the RDS instance
def connect_to_rds(host, user, password, database):
    try:
        connection = mysql.connector.connect(
            host=host,
            user=user,
            password=password,
            database=database
        )
        if connection.is_connected():
            print("Connected to RDS instance")
            return connection
    except Error as e:
        print(f"Error connecting to RDS: {e}")
        return None

# Function to update RDS credentials
def update_rds_credentials(db_instance_identifier, new_master_password):
    rds_client = boto3.client('rds')
    try:
        response = rds_client.modify_db_instance(
            DBInstanceIdentifier=db_instance_identifier,
            MasterUserPassword=new_master_password,
            ApplyImmediately=True
        )
        print("Updated RDS credentials")
    except Exception as e:
        print(f"Error updating RDS credentials: {e}")

# Function to update AWS Secrets Manager
def update_secrets_manager(secret_name, new_password):
    secrets_client = boto3.client('secretsmanager')
    try:
        response = secrets_client.put_secret_value(
            SecretId=secret_name,
            SecretString=new_password
        )
        print("Updated Secrets Manager with new credentials")
    except Exception as e:
        print(f"Error updating Secrets Manager: {e}")

# Function to apply new credentials to Kubernetes secrets
def update_kubernetes_secret(secret_name, new_password):
    try:
        # Create a temporary YAML file for the secret
        yaml_content = f"""
apiVersion: v1
kind: Secret
metadata:
  name: {secret_name}
type: Opaque
data:
  password: {new_password.encode('utf-8').hex()}
"""
        with open('/tmp/temp-secret.yaml', 'w') as file:
            file.write(yaml_content)

        # Apply the new secret to Kubernetes
        subprocess.run(["kubectl", "apply", "-f", "/tmp/temp-secret.yaml"], check=True)
        print("Updated Kubernetes secret with new credentials")
    except Exception as e:
        print(f"Error updating Kubernetes secret: {e}")

# Main script logic
def main():
    # Configuration
    db_instance_identifier = 'your-rds-instance-id'
    db_host = 'your-rds-endpoint'
    db_user = 'current-username'
    db_password = 'current-password'
    db_name = 'your-database-name'
    secret_name = 'your-k8s-secret-name'
    aws_secret_name = 'your-aws-secret-name'

    # Generate new password
    new_password = generate_random_password()
    print(f"New password: {new_password}")

    # Connect to RDS and verify connection
    connection = connect_to_rds(db_host, db_user, db_password, db_name)
    if connection:
        connection.close()

    # Update RDS instance with new credentials
    update_rds_credentials(db_instance_identifier, new_password)

    # Update AWS Secrets Manager with new credentials
    update_secrets_manager(aws_secret_name, new_password)

    # Update Kubernetes secret with new credentials
    update_kubernetes_secret(secret_name, new_password)

if __name__ == "__main__":
    main()
