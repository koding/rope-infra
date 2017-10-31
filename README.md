# rope-infra

Infra for rope systems.


## Kubernetes

Kubernetes folder holds the helm charts for the whoe system

## Monitoring

TODO

## Logging

Logs are collected by the stackdriver of google cloud.

you can find / filter the logs on [https://console.cloud.google.com/logs/](https://console.cloud.google.com/logs/)

For prod logs [click here](https://console.cloud.google.com/logs/viewer?project=kodingdev-vms&organizationId=151663178488&minLogLevel=0&expandAll=false&resource=container%2Fcluster_name%2Frope%2Fnamespace_id%2Frope-prod)

For stage logs [click here](https://console.cloud.google.com/logs/viewer?project=kodingdev-vms&organizationId=151663178488&minLogLevel=0&expandAll=false&resource=container%2Fcluster_name%2Frope%2Fnamespace_id%2Frope-stage)