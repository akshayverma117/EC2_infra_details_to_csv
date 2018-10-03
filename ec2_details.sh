#!/usr/bin/python
import boto3
import collections
import csv
import smtplib

# EC2 connection beginning
ec = boto3.client('ec2')
# S3 connection beginning
s3 = boto3.resource('s3')

filepath = '/home/ubuntu/tmp/' + "ec2_details" + '.csv'
csv_file = open(filepath, 'w+')
print(filepath)
region = 'REGION_NAME'
ec2con = boto3.client('ec2', region_name=region)

reservations = ec2con.describe_instances().get(
    'Reservations', []
)
instances = sum(
    [
        [i for i in r['Instances']]
        for r in reservations
    ], [])
instanceslist = len(instances)
if instanceslist > 0:
    csv_file.write("%s,%s,%s,%s,%s\n" % ('', '', '','',''))
    csv_file.write("%s,%s\n" % ('EC2 INSTANCE', region))
    csv_file.write(
        "%s,%s,%s,%s,%s\n" % (
            'InstanceName','InstanceId', 'PrivateIp', 'PublicIp','Environment'))
    csv_file.flush()

for instance in instances:
    state = instance['State']['Name']
    if state == 'running':
        instanceid = ''
        privateip = ''
        publicip = ''
        instancename = ''
        env = ''
        instanceid = instance['InstanceId']
        privateip = instance['PrivateIpAddress']
        try:
            publicip = instance['PublicIpAddress']
        except Exception as e:
            print('Some Instances do not have a public Ip')
        tag = instance['Tags']
        for k in tag:
            if k['Key'] == 'Name':
                instancename = k['Value']
            if k['Key'] == 'Environment':
                env =k['Value']

        csv_file.write(
            "%s,%s,%s,%s,%s\n" % (
                instancename, instanceid, privateip, publicip, env))
        csv_file.flush()
bucket = 'S3_BUCKET_NAME'
s3.Bucket(bucket).upload_file(filepath, 'infra-details/ec2/ec2_details.csv')

