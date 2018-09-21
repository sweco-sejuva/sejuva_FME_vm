# AWS
AWS Configuration Scripts
The files in this repository are used to create virtual machines for FME training courses.
The virtual machines are Amazon AWS EC2 machines.
The webpage used for requesting the virtual machines in a static page hosted on AWS S3.


## Fork this Repository to your own account

## Create image for virtual machine

### Create License Server machine for FME Desktop (if desired)
Use Linux t3.nano in same VPC as training machines
Use private IP address when licensing FME. That way machines outside the VPC cannot obtain a license.

## Create workspace for launching virtual machines

## Create FME Server machine or use FME Cloud
The machine used for training could possibly do this. Turn off auto-shutdown.

## Create website for launching virtual machines
1. Create S3 bucket
1. Use FME Server to sync GitHub files into S3 bucket. Maybe use FME Server to create config.js file for token etc.
1. Add GitHub webhook to run GitHub2S3.fmw

### GitHub Webhook
1. Navigate to your GitHub repository
1. Click on the `Settings` tab
1. Click on `Webhooks`
1. Click `Add webhook`
1. Payload URL is `https://<server name>/fmerest/v3/transformations/submit/<repository name>/GitHub2S3.fmw?fmetoken=<token>`/n
https://www.urlencoder.org/
1. Content type is `application/json`
  
  

## Set Calendar Reminders
If you are not using a permanent license for FME Server, you'll have to re-license it on occasion. The FME Server token will also have to be refreshed.
