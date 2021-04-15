#!/bin/bash

# Install dependencies

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install packer --yes

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

cd ci/vm
export CUSTOM_AMI_NAME=PrimeHub-${CIRCLE_TAG}
export PRIMEHUB_VERSION=${CIRCLE_TAG}
packer build ee_singlenode.pkr.hcl

AMI_ID=$(aws ec2 describe-images --owners self --filters "Name=name,Values=${CUSTOM_AMI_NAME}" | grep ImageId | cut -f4 -d'"')

aws ec2 export-image --image-id ${AMI_ID} --disk-image-format VMDK --s3-export-location S3Bucket=primehub-ee-trial-vm,S3Prefix=${PRIMEHUB_VERSION}/
