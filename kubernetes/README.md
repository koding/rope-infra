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
helm upgrade --install rope ./env
```

### Count

Count chart deploys both "counter" and "compactor" workers. Please see the Values.yaml file for the configuration parameters.

Installation and Upgrades:

```sh
helm upgrade --install --namespace <namespace> counter ./count
helm upgrade --install --namespace <namespace> compactor ./count
```

### Home

Home chart deploys [rope-home](github.com/koding/rope-home). Please see the Values.yaml file for the configuration parameters.

Installation and Upgrades:

```sh
helm upgrade --install --namespace <namespace> home ./home
```

### Keel

Keel chart handles the auto update of the deployments. Please see the Values.yaml file for the configuration parameters.

Installation and Upgrades:

```sh
helm upgrade --install --namespace <namespace> keel ./keel
```

### kube-state-metrics

kube-state-metrics chart handles the exposure of state metrics of the cluster.

Installation and Upgrades:

```sh
helm upgrade --install --namespace <namespace> kube-state-metrics ./kube-state-metrics
```

### MongoDB

mongodb chart deploys [mongodb](https://www.mongodb.com/). Please see the Values.yaml file for the configuration parameters.

Installation and Upgrades:

note: Do not forget to add namespace as a prefix, mongodb uses PVC and PVCs are not namepsaced.

```sh
helm upgrade --install --namespace <namespace> <namespace>-mongodb ./mongodb
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
helm upgrade --install --namespace <namespace> <namespace>-redis ./redis
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

## Steps for deployment

```sh
helm upgrade --install rope ./env

export ENV_PREFIX="rope"
export ENV_SUFFIX="stage"
export NAMESPACE=$ENV_PREFIX-$ENV_SUFFIX

helm upgrade --install --namespace $NAMESPACE $ENV_SUFFIX-redis ./redis
helm upgrade --install --namespace $NAMESPACE $ENV_SUFFIX-mongodb ./mongodb
# create mongo user
# update values in the charts for mongo user name and password

export MONGODB_URL="mongodb://rope_admin:minda@stage-mongodb-mongodb:27017/rope"
export REDIS_URL="stage-redis-redis:6379"

helm upgrade --install --namespace $NAMESPACE --set appName=counter   --set mongodbURL=$MONGODB_URL --set redisURL=$REDIS_URL $ENV_SUFFIX-counter ./count
helm upgrade --install --namespace $NAMESPACE --set appName=compactor --set mongodbURL=$MONGODB_URL --set redisURL=$REDIS_URL $ENV_SUFFIX-compactor ./count
helm upgrade --install --namespace $NAMESPACE                         --set mongodbURL=$MONGODB_URL                           $ENV_SUFFIX-home ./home
helm upgrade --install --namespace $NAMESPACE                                                       --set redisURL=$REDIS_URL $ENV_SUFFIX-twine ./twine

```