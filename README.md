# rope-infra

[![CircleCI](https://circleci.com/gh/koding/rope-infra/tree/master.svg?style=svg&circle-token=1e8d2ffb37bddb5ad2085d46700fe7263e9a419c)](https://circleci.com/gh/koding/rope-infra/tree/master)

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