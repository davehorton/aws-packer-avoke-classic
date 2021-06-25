# jambonz-feature-server

A [packer](https://www.packer.io/) template to build an AMI for the Avoke call recording application (the "classic" version, which uses Freeswitch and listens for DTMF via tones).  The base linux distro is Debian 10 (buster).

## Installing 

```
$  packer build -color=false template.json
```

### variables
There are many variables that can be specified on the `packer build` command line; however defaults (which are shown below) are appropriate for building an "all in one" jambonz server, so you generally should not need to specify values.

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
