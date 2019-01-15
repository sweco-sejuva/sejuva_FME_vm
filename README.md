# AWS
AWS Configuration Scripts
The files in this repository are used to create virtual machines for FME training courses.
The virtual machines are Amazon AWS EC2 machines.
The webpage used for requesting the virtual machines is a static page hosted on AWS S3.

## Overview
1. (optional) Configure a floating license server to license FME Desktop. The other option is to have the students request an evaluation license when they start FME Desktop.
1. Configure an image that has everything you need installed. If you are happy creating student virtual machines manually, this is the only required step.
1. (optional) Set up an installation of FME Server to allow students to request a virtual machine

There are four files in the repository that need to be edited, and two workspaces that need to be edited and published to FME Server. The four files you will eventually edit are:
1. InitialConfiguration.bat
1. /js/parameters.js
1. /templates/emailtemplate.txt
1. /template/rdptempate.txt (optional)

## Fork this Repository to your own account

### Create License Server machine for FME Desktop (if desired)
Use Linux t3.nano in same VPC as training machines
Use private IP address when licensing FME. That way machines outside the VPC cannot obtain a license.
[Detailed instructions here](https://knowledge.safe.com/articles/82230/create-fme-license-server.html)

## Create image for virtual machine
InitialConfiguration.bat is used to setup the image for the virtual machine.
Edit the content of InitialConfiguration.bat so that OnstartConfigurationURL points to your own OnstartConfigurationURL.bat file.
Create a t3.large Windows instance, and then edit and run the following from the commandline:
`powershell -Command "Invoke-WebRequest https://raw.githubusercontent.com/rjcragg/AWS/master/InitialConfiguration.bat -OutFile InitialConfiguration.bat" && InitialConfiguration.bat password fmelicenseip fmeserverserial`
* Edit the `https://raw.githubusercontent.com/.../InitialConfiguration.bat` path to point to your GitHub repository
* Replace `password` with the desired login password for the virtual machine
* Replace `fmelicenseip` with the FME license server IP address


OnstartConfiguration.bat is run by the Task Scheduler on the virtual machines every time the virtual machine starts (or restarts). This allows you to perform additional configuration steps at startup.

## Create workspace for launching virtual machines

## Create FME Server machine or use FME Cloud
The machine used for training could possibly do this. Turn off auto-shutdown.

## Create website for launching virtual machines
1. Create S3 bucket
1. Edit GitClone2S3.fmw so that it contains your AWS web connection, and publish to FME Server or FME Cloud.
1. Add webhook in GitHub repository run GitHub2S3.fmw

### GitHub Webhook
1. Navigate to your GitHub repository
1. Click on the `Settings` tab
1. Click on `Webhooks`
1. Click `Add webhook`
1. Payload URL is `https://<server name>/fmerest/v3/transformations/submit/<repository name>/GitHub2S3.fmw?GitHubZipUrl=<GitHub ZIP download URL>&S3_BUCKET_NAME=<S3 Bucket name>&fmetoken=<token>`  
`https://demos-safe-software.fmecloud.com/fmerest/v3/transformations/submit/FMETraining/GitClone2S3.fmw?GITUSER=<git user name>&GITREPOSITORY=<repository name>&GITBRANCH=<git branch>&S3_BUCKET_NAME=<S3 Bucket>&S3_OBJECT_KEY=<folder in bucket>&fmetoken=<fme token>`
1. Content type is `application/json`
  

## Set Calendar Reminders
If you are not using a permanent license for FME Server, you'll have to re-license it on occasion. The FME Server token will also have to be refreshed.
