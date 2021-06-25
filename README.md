# jambonz-feature-server

A [packer](https://www.packer.io/) template to build an AMI for the Avoke call recording application (the "classic" version, which uses Freeswitch and listens for DTMF via tones).  The base linux distro is Debian 10 (buster).

## Installing 
change into the project directory, and then:
```
$  packer build -color=false template.json
```
Of course, you will need packer installed on your laptop along with the AWS CLI.

### variables
There are a few optional variables that can be specified on the `packer build` command line; these are shown below along with their default values.

```
"region": "us-east-1"
```
The region to create the AMI in

```
"ami_description": "Avoke recording server (classic)"
```
AMI description.

```
"instance_type": "t2.xlarge"
```
EC2 Instance type to use when building the AMI.

```
"drachtio_version": "v0.8.10"
```
drachtio tag or branch to build
