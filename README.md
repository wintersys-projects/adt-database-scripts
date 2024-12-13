##### [MAIN REPOSITORY](https://github.com/wintersys-projects/adt-build-machine-scripts)

##### This repository is the code which implements the database functions of the Agile Deployment Toolkit

Machines built from this repository will support three different databases. MariaDB, MySQL or Postgres for MariaDB and Postgres you can set which version you want to install in the ${BUILD_HOME}/builddescriptors/buildstyles.dat file on the build machine.

It is expected that during development you will build by installing one of these databases but when you want to "go live" you will use this machine to proxy the backup and installation processes to a DBaaS database hosted by your cloudhost provider. This DBaaS database will be man enough to cope with production workloads. If you look in the documetation provider with the build machine repository you will find information about how to deploy to a DBaaS solution rather than the custom installed version of your database of choice. 

This script will download your application database either from your git provider or your datastore depending on how you have kept things configured. 

In effect if you use the default install you are deploying a "user managed" database if you make a DBaaS install then you are using a managed database where you shouldn't need to take care of much. To be clear then the recommendation is to only use the user managed database for development and to deploy to a DBaaS database when you want to go to production.

As far as your websevers are concerned, they won't even see "this" machine they will connect directly to your DBaaS machine and as such each of your webservers will need to be granted access to the DBaaS service because it should have fifirewall like restrictions as to which ip addresses can connect to it. "This" machine (the machine deployed and built from this repository) will run installations and backups against the DBaaS machine and that is why you need to have one of these machines in your architecture (I could have modified the webservers to provide backup and installation services in the case of a DBaaS deployment but I felt that that broke the clear delination of the design so I kept it this way even though it means you have to have a machine running which essentially isn't doing much other than backups and installation and is bypassed by the application usage straight to the DBaaS instance. 

The firewalling is kept as strict as I can make it

