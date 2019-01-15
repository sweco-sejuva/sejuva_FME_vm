var repository, workspace, form, server, token;
repository = "FMETraining";  //This is the FME Server repository
workspace = "VMCreator.fmw"; //This is the workspace that creates the virtual machines
server = "https://demos-safe-software.fmecloud.com";  //This is the URL of your FME Server or FME Cloud
token ="b42f5405ae92f30024974cd3943d5d2a2bcf0443";     //security token for the user that runs the workspace.

var region_name = "us-east-1";
var EC2Type = "t3";
var EC2Size = "large";
var CourseType = "training";   //matches the tag on the AMI
var AccountEmail = "train@safe.com";
var EmergencyEmail = "ryan.cragg@safe.com";
var CRMEmail = "emailtosalesforce@3bxfu520n23ghfjugzh0uta0y.in.salesforce.com";
var S3ROOT = "https://s3.amazonaws.com/fmekc/test/";   //This is the combination of s3 bucket name and folder name
