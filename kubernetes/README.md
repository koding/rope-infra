# Kubernetes

Kubernetes folder holds the charts for services installations.

It uses [helm](https://github.com/kubernetes/helm/blob/master/README.md) for template rendering and deployment management.

## Helm Tool

You can find how to install helm [here](https://github.com/kubernetes/helm/blob/master/README.md#install)
If you don't afraid to live on the edges you can use the single line installer

```sh
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
```

Installation, Upgrades, Downgrades:

Please check how to do the respective operations with:

```sh
helm --help
```

## Charts

### Count

Count chart deploys both "counter" and "compactor" workers. Please see the Values.yaml file for the configuration parameters.

Installation and Upgrades:

```sh
helm upgrade counter ./count --install
helm upgrade compactor ./count --install
```

### Home

Home chart deploys [rope-home](github.com/koding/rope-home). Please see the Values.yaml file for the configuration parameters.

Installation and Upgrades:

```sh
helm upgrade home ./home --install
```

### Keel

Keel chart handles the auto update of the deployments. Please see the Values.yaml file for the configuration parameters.

Installation and Upgrades:

```sh
helm upgrade home ./home --install
```

### MongoDB

mongodb chart deploys [mongodb](https://www.mongodb.com/). Please see the Values.yaml file for the configuration parameters.

Installation and Upgrades:

```sh
helm upgrade mongodb ./mongodb --install
```

After deploying you can connect to your cluster with the following command,

```sh
kubectl run mongodb-mongodb-client --rm --tty -i --image bitnami/mongodb --command -- mongo --host mongodb-mongodb -p minda
# kubectl run {{ template "mongodb.fullname" . }}-client --rm --tty -i --image bitnami/mongodb --command -- mongo --host {{ template "mongodb.fullname" . }} {{- if .Values.mongodbRootPassword }} -p {{ .Values.mongodbRootPassword }}
```

After connecting to your mongo, you can create a user with the following command.

```sh
use <your db name>
db.createUser(
   {
     user: "rope_admin",
     pwd: "minda",
     roles: [ "readWrite", "dbAdmin" ]
   }
)
```

### Redis

redis chart installs a redis server.

```sh
helm upgrade redis ./redis --install
```

```sh
kubectl run name-redis-client --rm --tty -i --image bitnami/redis:3.2.9-r2 -- bash
```

## Chart Version Upgrades

### keel

helm fetch kubernetes-charts/keel --untar --destination ./kubernetes/keel
helm fetch kubernetes-charts/kube-state-metrics --untar --destination ./kubernetes/kube-state-metrics
helm fetch kubernetes-charts/mongodb --untar --destination ./kubernetes/mongodb
helm fetch kubernetes-charts/prometheus --untar --destination ./kubernetes/prometheus
helm fetch kubernetes-charts/redis --untar --destination ./kubernetes/redis
helm fetch kubernetes-charts/spotify-docker-gc --untar --destination ./kubernetes/spotify-docker-gc
