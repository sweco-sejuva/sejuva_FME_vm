# AWS
AWS Configuration Scripts
The files in this repository are used to create virtual machines for FME training courses.
The virtual machines are Amazon AWS EC2 machines.
The webpage used for requesting the virtual machines in a static page hosted on AWS S3.


## Fork this Repository to your own account

## Create image for virtual machine
InitialConfiguration.bat is used to setup the image for the virtual machine.
Create a t3.large Windows instance, and then edit and run the following from the commandline:
`powershell -Command "Invoke-WebRequest https://raw.githubusercontent.com/rjcragg/AWS/master/InitialConfiguration.bat -OutFile InitialConfiguration.bat" && InitialConfiguration.bat password fmelicenseip fmeserverserial`
* Edit the `https://raw.githubusercontent.com/.../InitialConfiguration.bat` path to point to your GitHub repository
* Replace `password` with the desired login password for the virtual machine
* Replace `fmelicenseip` with the FME license server IP address


OnstartConfiguration.bat is run by the Task Scheduler on the virtual machines every time the virtual machine starts (or restarts). This allows you to perform additional configuration steps at startup.



### Create License Server machine for FME Desktop (if desired)
Use Linux t3.nano in same VPC as training machines
Use private IP address when licensing FME. That way machines outside the VPC cannot obtain a license.
[Detailed instructions here](https://knowledge.safe.com/articles/82230/create-fme-license-server.html)

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
1. Payload URL is `https://<server name>/fmerest/v3/transformations/submit/<repository name>/GitHub2S3.fmw?GitHubZipUrl=<GitHub ZIP download URL>&S3_BUCKET_NAME=<S3 Bucket name>&fmetoken=<token>`  
Make sure that the value for GitHubZip URL is encoded properly. Use the link below.  
https://www.urlencoder.org/
1. Content type is `application/json`
  
  

## Set Calendar Reminders
If you are not using a permanent license for FME Server, you'll have to re-license it on occasion. The FME Server token will also have to be refreshed.
