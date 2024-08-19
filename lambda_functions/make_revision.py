import boto3
import os
import zipfile

s3 = boto3.client('s3')

def lambda_handler(event, context):
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']

    print(f'Bucket name is {bucket_name}.')
    print(f'Trigger file name is {key}.')

    tmp_revision_path = '/tmp/revision'
    os.makedirs(tmp_revision_path, exist_ok=True)

    dist_assets_path = 'dist/assets/'
    dist_index_path = 'dist/index.html'
    appspec_path = 'appspec.yml'
    scripts_path = 'scripts/'

    file_names_to_zip = [appspec_path, dist_index_path]

    response = s3.list_objects_v2(Bucket=bucket_name, Prefix=dist_assets_path)
    for obj in response['Contents']:
        tmp_key_name = obj['Key']
        file_names_to_zip.append(tmp_key_name)

    response = s3.list_objects_v2(Bucket=bucket_name, Prefix=scripts_path)
    for obj in response['Contents']:
        tmp_key_name = obj['Key']
        file_names_to_zip.append(tmp_key_name)

    print('==========================')
    print('file names to zip is following')
    for file_name in file_names_to_zip:
        print(f'{file_name}')

    print('==========================')

    for file_name in file_names_to_zip:
        local_file_path = os.path.join(tmp_revision_path, file_name)
        os.makedirs(os.path.dirname(local_file_path), exist_ok=True)
        s3.download_file(bucket_name, file_name, local_file_path)


    zip_path = '/tmp/revision.zip'

    with zipfile.ZipFile(zip_path, 'w') as zipf:
        for file_name in file_names_to_zip:
            downloaded_file_path = f'/tmp/revision/{file_name}'
            zipf.write(downloaded_file_path, arcname=file_name)

    s3.upload_file(zip_path, bucket_name, 'revision.zip')