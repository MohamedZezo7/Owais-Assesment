import json
import datetime
import os
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

BACKUP_DIR = '/backups'  
S3_BUCKET_NAME = 's3-bucket-name'  
S3_BACKUP_PATH = 'backups/'  


s3_client = boto3.client('s3')

def backup_application_data():
    """Simulate backing up application data and upload it to S3."""
    timestamp = datetime.datetime.now().strftime('%Y%m%d%H%M%S')
    backup_file = f"{BACKUP_DIR}/backup_{timestamp}.json"
    print(f"Backing up application data to {backup_file}...")
    
    
    data = {
        'timestamp': timestamp,
        'data': 'Sample backup data'
    }
    os.makedirs(BACKUP_DIR, exist_ok=True)
    with open(backup_file, 'w') as f:
        json.dump(data, f)
    
    print(f"Backup completed successfully: {backup_file}")
    upload_to_s3(backup_file, f"{S3_BACKUP_PATH}backup_{timestamp}.json")

def upload_to_s3(file_path, s3_key):
    """Upload a file to an S3 bucket."""
    try:
        s3_client.upload_file(file_path, S3_BUCKET_NAME, s3_key)
        print(f"File uploaded to S3: s3://{S3_BUCKET_NAME}/{s3_key}")
    except FileNotFoundError:
        print(f"The file {file_path} was not found.")
    except NoCredentialsError:
        print("Credentials not available.")
    except PartialCredentialsError:
        print("Incomplete credentials provided.")
    except Exception as e:
        print(f"Failed to upload file to S3: {e}")

if __name__ == "__main__":
    backup_application_data()
