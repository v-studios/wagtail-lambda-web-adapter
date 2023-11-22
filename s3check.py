#!/usr/bin/env python
import os
import boto3

bucketname = os.environ["AWS_STORAGE_BUCKET_NAME"]
s3c = boto3.client('s3')


def handler(event, context):
    print("Handling it")
    res = s3c.list_objects_v2(Bucket=bucketname)
    http_code = res['ResponseMetadata']['HTTPStatusCode']
    print (f"{http_code=}")
    if http_code == 200:
        contents = res['Contents']
        if contents:
            print(f"{contents[:1]=}")
        else:
            print(f"Access ok but no contents yet")


if __name__ == "__main__":
    print("Invoking handler")
    handler(None, None)
