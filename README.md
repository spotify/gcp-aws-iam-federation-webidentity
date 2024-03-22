[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](https://commons.wikimedia.org/wiki/Template:MIT)

# Cross cloud IAM permission setup

## Description
This repository sets up identity federation between GCP -> AWS.

The components include setting up a service account in a GCP project and IAM role in an AWS account.

Then a trust policy is applied on the IAM role in AWS to allow the service account in GCP to assume that role using the [AssumeRoleWithWebIdentity](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html) feature.

## Terraform:
This sections explains how to setup your Terraform environment to create the needed resources.
### Install Terraform:
https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started
### Instantiate: 
```bash
$ terraform init
```    

## Authenticate to GCP
```bash
$ gcloud auth application-default login
```

## Authenticate to AWS
Follow the instructions here to authenticate to the desired project in AWS: https://awscli.amazonaws.com/v2/documentation/api/latest/reference/configure/sso.html
E.g.

```bash
$ aws configure sso
SSO session name (Recommended): SOME_NAME
SSO start URL [None]: YOUR_AWS_START_URL
SSO region [None]: REGION
SSO registration scopes [sso:account:access]: 
```
STS credentials are then stored in ~/.aws/cli

## Add permissions (Unless assinged to IAM principle):
Add the following permissions to your gcloud principle in your GCP project.
```  	
Project IAM Admin				
Service Account Admin
```
## Enable billing acccount(Unless active):
### Check your CPU limitations based on the resources you want to create:
  https://cloud.google.com/billing/docs/how-to/modify-project

## Create resources via Terraform:
```bash
$ terraform plan
$ terraform apply -lock=true -auto-approve
```

## Verify that you can assume the AWS role using AssumeRoleWithWebIdentity
The documentation for how AssumeRoleWithWebIdentity works can be found here:
https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html

In order to assume the AWS role using the GCP service account you can either use the aws cli, see below:

### Use AWS CLI STS - with assume-role-with-web-identity
This can be done by using the following command:

```bash
$ aws sts assume-role-with-web-identity \
    --role-arn YOUR_AWS_ROLE_ARN \
    --role-session-name YOUR_AWS_SESSION_NAME_THAT_YOU_DECIDE \
    --web-identity-token $(gcloud auth print-identity-token --impersonate-service-account=YOUR_GCP_SA_EMAIL --audiences=THE_OAUD_AUDIENCE_YOU_SET_IN_TERRAFORM --include-email)
```

### Use AWS STS via CURL
AWS STS CLI uses HTTP request as a base to authenticate.
Looking at the docs here: https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html#:~:text=usage%20of%20AssumeRoleWithWebIdentity.-,Sample%20Request,-https%3A/

We can craft a curl request using the required headers and data in the request body.
This can look like:

```bash
$ curl -v \
      --header "Content-Type: application/x-www-form-urlencoded" \
        --data "Action=AssumeRoleWithWebIdentity" \
        --data "Version=2011-06-15" \
        --data "DurationSeconds=3600" \
        --data "RoleSessionName=YOUR_AWS_SESSION_NAME_THAT_YOU_DECIDE" \
        --data "RoleArn=AWS_ROLE_ARN_HERE" \
        --data "WebIdentityToken="$(gcloud auth print-identity-token --impersonate-service-account=GCP_SA_EMAIL_HERE --audiences=THE_OAUD_AUDIENCE_YOU_SET_IN_TERRAFORM --include-email) \
      POST https://sts.amazonaws.com
```

## LICENSE
This project is licensed under the terms of the MIT license framework.

## Maintenance
This repository is maintained by Marcus Hallberg.

Contact information is: 
- Email: mhallberg@spotify.com or marcus.oj.hallberg@gmail.com
- [LinkedIn](https://www.linkedin.com/in/hallbergmarcus/)