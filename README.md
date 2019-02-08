# FME Training Virtual Machines and Automation
The files in this repository are used to create virtual machines for FME training courses, and to allow students to request virtual machines on-demand.
The virtual machines are Amazon AWS EC2 machines.
The webpage used for requesting the virtual machines is a static page hosted on AWS S3.

## Prerequisites
A basic understanding of GitHub, Amazon AWS, FME Desktop, and FME Server is required.
An installation of GitHub Desktop and FME Desktop.

Be aware that you'll probably have to request an Instance Limit increase for the EC2 instances. The default limit is 20 machines. At Safe Software, we have a limit of 500.

Also be aware that the default VPC limit is 5. If you currently have 5 VPCs in your desired region, you will have to request an increase in the VPC limit.

![EC2 Service Increase](/images/EC2Limits.png)

## Overview
1. Fork this Repository to your own account
1. Install and update AWSCredentialSupplier.fmx
1. Create and configure S3 Bucket
1. Edit settings.json
1. Edit and run GitClone2S3.fmw in FME Desktop to mirror GitHub to S3
1. Run CreateVPC.fmw in FME Desktop
1. Run CreateLicenseServer.fmw in FME Desktop to create license server
1. Use FME Cloud or Run CreateFMEServer.fmw in FME Desktop to create FME Server installation
1. Run InitialMachineCreator.fmw in FME Desktop to create instance to use as AMI
1. Create and tag AMI
1. Publish VMCreator.fmw and GitClone2S3.fmw with AWSCredentialSupplier.fmx to FME Server/Cloud
1. Configure GitHub webhook to run GitClone2s3.fmw


There are two files in the repository that need to be edited, and two workspaces that need to be edited and published to FME Server. The two files you will eventually edit are:
1. InitialConfiguration.bat
1. settings.json

# Steps
## Fork this Repository to your own account
Click Fork.
Once forked into your own account, click Settings.
Change the repository name if desired.


### Create License Server machine for FME Desktop (if desired)
1. Edit and run CreateLicenseServer.fmw
1. Open LicenseServerInfo.txt and follow instructions to obtain license file safe.lic
1. Stop the license server virtual machine, and edit the User Data to so that `wget https://licensing.safe.com/licenses/fme/float/` contains the entire path listed in the email from Codes.


### FME Server
1. Run CreateFMEServer.fmw
1. Go to the public IP address
1. Activate FME Server
1. Change the admin Password
1. Create FMETraining repository
1. Create a new user that only has read and run permissions for the FMETraining repository


## Create image for virtual machine
InitialConfiguration.bat is used to setup the image for the virtual machine.
Edit the content of InitialConfiguration.bat so that OnstartConfigurationURL points to your own OnstartConfigurationURL.bat file.
Create a t3.large Windows instance, and then edit and run the following from the commandline:
`powershell -Command "Invoke-WebRequest https://raw.githubusercontent.com/rjcragg/AWS/master/InitialConfiguration.bat -OutFile InitialConfiguration.bat" && InitialConfiguration.bat password fmelicenseip fmeserverserial`
* Edit the `https://raw.githubusercontent.com/.../InitialConfiguration.bat` path to point to your GitHub repository
* Replace `password` with the desired login password for the virtual machine
* Replace `fmelicenseip` with the FME license server IP address

OnstartConfiguration.bat is run by the Task Scheduler on the virtual machines every time the virtual machine starts (or restarts). This allows you to perform additional configuration steps at startup.

Once the machine is configured, create an image (AMI) and add a tag called Course. The course is the name of the image (like training, or certification). This tag is used by the VMCreator.fmw file to launch virtual machines on demand.  

## Create FME Server machine or use FME Cloud for launching virtual machines
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
1. Payload URL is `https://<server name>/fmejobsubmitter/<repository name>/GitHub2S3.fmw?GITUSER=<git user name>&GITREPOSITORY=<repository name>&GITBRANCH=<git branch>&S3_BUCKET_NAME=<S3 Bucket>&S3_OBJECT_KEY=<folder in bucket>&opt_showresult=true`
1. Content type is `application/json`

## Create workspace for launching virtual machines
1. Edit /workspaces/VMCreator.fmw. The 2 private parameters and the Web Connection for email must be configured.
1. Publish to FME Server or FME Cloud.
1. Create a new user with only Read and Run permissions for the FME Server repository that contains VMCreator.fmw
1. Create a token with the new user.

## Edit /js/parameters.js
The configuration for the webpage and VMCreator.fmw is done in parameters.js

## Creating additional courses
Fork the current GitHub branch, and give it a name that matches the Course tag on the AMI.

## Set Calendar Reminders
If you are not using a permanent license for FME Server, you'll have to re-license it on occasion. The FME Server token will also have to be refreshed.
