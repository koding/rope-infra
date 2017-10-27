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

### Env

Env chart prepares the environments for the whole system. It creates staging and production namespaces respectively

note: namespace is not required for this command

```sh
helm upgrade rope ./env  --install
```

### Count

Count chart deploys both "counter" and "compactor" workers. Please see the Values.yaml file for the configuration parameters.

Installation and Upgrades:

```sh
helm upgrade counter ./count --install --namespace <namespace>
helm upgrade compactor ./count --install --namespace <namespace>
```

### Home

Home chart deploys [rope-home](github.com/koding/rope-home). Please see the Values.yaml file for the configuration parameters.

Installation and Upgrades:

```sh
helm upgrade home ./home --install --namespace <namespace>
```

### Keel

Keel chart handles the auto update of the deployments. Please see the Values.yaml file for the configuration parameters.

Installation and Upgrades:

```sh
helm upgrade keel ./keel --install --namespace <namespace>
```

### MongoDB

mongodb chart deploys [mongodb](https://www.mongodb.com/). Please see the Values.yaml file for the configuration parameters.

Installation and Upgrades:

note: Do not forget to add namespace as a prefix, mongodb uses PVC and PVCs are not namepsaced.

```sh
helm upgrade <namespace>-mongodb ./mongodb --install --namespace <namespace>
```

After deploying you can connect to your cluster with the following command,

```sh
kubectl run --namespace <namespace> mongodb-mongodb-client --rm --tty -i --image bitnami/mongodb --command -- mongo --host mongodb-mongodb -p minda
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

Installation and Upgrades:

note: Do not forget to add namespace as a prefix, mongodb uses PVC and PVCs are not namepsaced.

```sh
helm upgrade <namespace>-redis ./redis --install --namespace <namespace>
```

```sh
kubectl run --namespace <namespace> name-redis-client --rm --tty -i --image bitnami/redis:3.2.9-r2 -- bash
```

## Chart Version Upgrades

### keel

helm fetch kubernetes-charts/keel --untar --destination ./kubernetes/keel
helm fetch kubernetes-charts/kube-state-metrics --untar --destination ./kubernetes/kube-state-metrics
helm fetch kubernetes-charts/mongodb --untar --destination ./kubernetes/mongodb
helm fetch kubernetes-charts/prometheus --untar --destination ./kubernetes/prometheus
helm fetch kubernetes-charts/redis --untar --destination ./kubernetes/redis
helm fetch kubernetes-charts/spotify-docker-gc --untar --destination ./kubernetes/spotify-docker-gc
