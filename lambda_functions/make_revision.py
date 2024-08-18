import boto3
import os
import zipfile

s3 = boto3.client('s3')

def lambda_handler(event, context):
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']

    print(f'Bucket name is {bucket_name}.')
    print(f'Key name is {key}.')

    download_dir = '/tmp/revision'
    os.makedirs(download_dir, exist_ok=True)

    dist_assets_path = 'dist/assets'
    dist_index_path = 'dist/index.html'

    s3.download_file(bucket_name, dist_assets_path, '/tmp/revision/assets')
    s3.download_file(bucket_name, dist_index_path, '/tmp/revision/index.html')

    zip_path = '/tmp/revision.zip'
    print(f'zip_path is {zip_path}.')
