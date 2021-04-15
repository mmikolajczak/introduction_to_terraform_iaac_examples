import base64
from datetime import datetime, timezone
import os
import random

import boto3


CATS_PHOTOS_BUCKET = os.environ['CATS_PHOTOS_BUCKET']
MAX_PHOTO_ID = int(os.environ['MAX_PHOTO_ID'])
SAMPLING_STATISTICS_TABLE_NAME = os.environ['SAMPLING_STATISTICS_TABLE_NAME']

s3_client = boto3.client('s3')
dynamodb_resource = boto3.resource('dynamodb')
sampling_statistics_table = dynamodb_resource.Table(SAMPLING_STATISTICS_TABLE_NAME)


def get_current_utc_timestamp() -> str:
    return datetime.now(timezone.utc).astimezone().isoformat()


def lambda_handler(event, context) -> dict:
    photo_id = random.randint(0, MAX_PHOTO_ID)
    sampling_statistics_table.put_item(Item={'photo_id': photo_id, 'request_timestamp': get_current_utc_timestamp()})

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
