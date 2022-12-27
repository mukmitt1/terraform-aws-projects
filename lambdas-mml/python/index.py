from datetime import datetime
import json
import os
import boto3
import logging

from random import randrange

import random

import time


dynamodb = boto3.resource('dynamodb')
step_functions = boto3.client('stepfunctions')


def lambda_handler(event, context):

    print('AAAAAAAAAAAAAAAAAAAAAAA')
    print('Context Test:',context)
    print("PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP:", event)

    # Write message to DynamoDB
    table = dynamodb.Table('temp_table')


   #Insert data in temp table
    response1 = table.put_item(
        Item={
            'executionId': event['TaskToken'],
            'Timestamp': datetime.now().isoformat(),
            'payload' : json.dumps(event),
            'function_name': context.function_name,
            'function_version': context.function_version
        }
    )

    # use for testing only. Even number, consider exception. Odd number -  system is working as expected
    x = random.randint(1, 6)

    # in case even number, no need to stop the process and consider lambda program failure
    if x % 2 == 0:
        print("Response failure!")
        return 'error'
    else:
        print("Response is successful!")
        response1 = table.delete_item(
            Key={
                'executionId': event['TaskToken']
            }
        )
        response = step_functions.send_task_success(
            taskToken=event['TaskToken'],
            output="\"success\""
    )
