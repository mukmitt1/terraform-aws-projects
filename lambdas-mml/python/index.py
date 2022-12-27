from datetime import datetime
import json
import os
import boto3
import logging

from random import randrange

import random

import time


dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):

    print('AAAAAAAAAAAAAAAAAAAAAAA')
    print(context)

    # Write message to DynamoDB
    table = dynamodb.Table('order')

#    print("sssssssssssssssssss:", event['TaskToken'])
    print("PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP:", event)
    print("QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ:", context)

    response1 = table.put_item(
        Item={
            'executionId': event['TaskToken'],
            'Timestamp': datetime.now().isoformat(),
            'payload' : json.dumps(event),
            'function_name': context.function_name,
            'function_version': context.function_version
        }
    )

    x = random.randint(1, 6)

    if x % 2 == 0:
        print("Response is failure!")
        return 'error'
    else:
        print("Response is successful!")
        response1 = table.delete_item(
            Key={
                'executionId': event['TaskToken']
            }
        )
