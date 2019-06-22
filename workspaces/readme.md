#These are the workspaces required to automate VM creation

| Workspace                 | Purpose   |
|---                        |---        |
| CreateFMEServer.fmw       | Creates the FME Server that will host VMCreator.fmw|
| CreateLicenseServer.fmw   | Creates the FlexNet floating license server for FME Desktop|
| CreateVPC.fmw             | Creates the VPC and security groups used by all the various virtual machines|
| InitialMachineCreator.fmw | Creates the training machine template|
| QuickSetup.fmw            | Runs CreateVPC, CreateLicenseServer and InitialMachineCreator|
| VMCreator.fmw             | Creates the student's virtual machines |
