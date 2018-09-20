# AWS
AWS Configuration Scripts

## Create image for virtual machine

### Create License Server machine for FME Desktop (if desired)
Use Linux t3.nano in same VPC as training machines
Use private IP address when licensing FME. That way machines outside the VPC cannot obtain a license.

## Step 2. Create workspace for launching virtual machines

## Create FME Server machine or use FME Cloud
The machine used for training could possibly do this. Turn off auto-shutdown.

## Step 3. Create website for launching virtual machines
Create S3 bucket
Use FME Server to sync GitHub files into S3 bucket. Maybe use FME Server to create config.js file for token etc.

## Set Calendar Reminders
If you are not using a permanent license for FME Server, you'll have to re-license it on occasion. The FME Server token will also have to be refreshed.
