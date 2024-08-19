import boto3
import os
import zipfile

s3 = boto3.client('s3')

def lambda_handler(event, context):
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']

    print(f'Bucket name is {bucket_name}.')
    print(f'Key name is {key}.')

    if not key.endswith('.py'):
        print(f'{key} is not .py file. So We are stopping function.')
        return

    download_dir = '/tmp'
    base_name = os.path.basename(key)
    os.makedirs(download_dir, exist_ok=True)

    download_path = os.path.join(download_dir, base_name)
    print(f'download_path is {download_path}.')

    s3.download_file(bucket_name, key, download_path)
    print(f'Downloaded {bucket_name}/{key} to {download_path}.')

    zip_path = f'/tmp/{os.path.splitext(base_name)[0]}.zip'
    print(f'zip_path is {zip_path}.')

    with zipfile.ZipFile(zip_path, 'w') as zipf:
        zipf.write(download_path, arcname=base_name)
        print(f'Zipped file to {zip_path}')

    zip_key = f'{os.path.splitext(key)[0]}.zip'
    print(f'zip_key is {zip_key}')
    s3.upload_file(zip_path, bucket_name, zip_key)
  
    print(f"Uploaded {zip_key} to {bucket_name}")
