##### [MAIN REPOSITORY](https://github.com/wintersys-projects/adt-build-machine-scripts)

##### This repository is the code which implements the database functions of the Agile Deployment Toolkit

Machines built from this repository will support three different databases. MariaDB, MySQL or Postgres. 
You can set which specific version you want to install in the ${BUILD_HOME}/builddescriptors/buildstyles.dat file on the build machine.

It is expected that during development you will build by installing one of these databases but when you want to "go live" you will use this machine to proxy the backup and installation processes to a DBaaS database hosted by your cloudhost provider. This DBaaS database will be "man enough" to cope with production workloads. 

This script will download your application database either from your git provider (if you are deploying from a baseline) or your datastore (if you are deploying from a temporal backup). 

In effect if you use the default install you are deploying a "self managed" database if you make a DBaaS install then you are using a managed database where you shouldn't need to take care of much. To be clear then the recommendation is to only use the self managed database for development and to deploy to a DBaaS database when you want to go to production.

As far as your websevers are concerned when you are using a managed DBaaS database, they won't even "see" this machine they will connect directly to your DBaaS machine. "This" machine (the machine deployed and built from this repository) will run installations and backups against the DBaaS machine and that is why you need to have one of these machine types in your architecture (I could have modified the webservers to provide backup and installation services in the case of a DBaaS deployment but I felt that that broke the clear delination of the design so I kept it this way even though it means you have to have a machine running which essentially isn't doing much other than backups and installation and is bypassed by the application usage straight to the DBaaS instance. 

The firewalling is kept as strict as I can make it but you are free to loosen it up if you need to.

--------------------------------

The Direcrtory Structure of the webserver is as follow:

**${HOME}/application**  
Scripts related to the application that is being deployed into the database this will consist of an sql or psql compatible database dump file

**${HOME}/cron**  
Scripts related to the functioning of the crontab configuration

**${HOME}/installscripts**  
Scripts related to the installtion of the software that is needed for a database machine to operate

**${HOME}/providerscripts**  
Scripts related to 3rd party services

**${HOME}/runtime**  
A directory that is used at runtime to hold information about the state/deployment of the current database

**${HOME}/security**  
Scripts related to the security of the database

**${HOME}/utilities**  
Utility scripts that help with the functioning of the database

