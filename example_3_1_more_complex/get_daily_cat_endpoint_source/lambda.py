import base64
import os
import random

import boto3


CATS_PHOTOS_BUCKET = os.environ['CATS_PHOTOS_BUCKET']
MAX_PHOTO_ID = int(os.environ['MAX_PHOTO_ID'])

s3_client = boto3.client('s3')


def lambda_handler(event, context) -> dict:
    photo_id = random.randint(0, MAX_PHOTO_ID)

    response = s3_client.get_object(
        Bucket=CATS_PHOTOS_BUCKET,
        Key=f'{photo_id}.png',
    )
    image = response['Body'].read()
    return {
        'headers': {'Content-Type': 'image/png'},
        'statusCode': 200,
        'body': base64.b64encode(image).decode('utf-8'),
        'isBase64Encoded': True
    }
