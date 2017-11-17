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

```sh
helm upgrade --install rope ./env
```

Notes:

* namespace is not required for this command
* one time command per project

### Grafana

Grafana chart is the "grafana" dashboarding system. Please see the Values.yaml file for the configuration parameters.

Installation and Upgrades:

```sh
helm upgrade --install graf ./grafana
```

Notes:

* namespace is not required for this command
* one time command per project

### Keel

Keel chart handles the auto update of the deployments. Please see the Values.yaml file for the configuration parameters.

Installation and Upgrades:

```sh
helm upgrade --install --namespace <namespace> keel ./keel
```

Notes:

* namespace should be a system namespace
* one time command per project

### Nginx Ingress

Nginx Ingress chart handles the auto routing/discovery for the backend services. Given the services and Ingress pairs, this ingress controller creates *a* load balancer and routes all the traffice from that endpoint into the internal ingresses. Please see the Values.yaml file for the configuration parameters.

Installation and Upgrades:

```sh
helm upgrade --install --namespace nginx-ingress nginx-ingress ./nginx-ingress
```

Notes:

* namespace should be nginx-ingress namespace
* one time command per project

### Prometheus

Prometheus is the cloud native monitoring and metrics system where most the kubernetes related projects has built-in support for it. Please see the Values.yaml file for the configuration parameters.

Installation and Upgrades:

```sh
helm upgrade --install prom ./prometheus
```

Notes:

* one time command per project

### Docker GC

Spotify docker GC chart removes the unused images from the system, basically handles the GC. Please see the Values.yaml file for the configuration parameters.

Installation and Upgrades:

```sh
helm upgrade --install docker-gc ./spotify-docker-gc
```

Notes:

* one time command per project

### Count

Count chart deploys both "counter" and "compactor" workers. Please see the Values.yaml file for the configuration parameters.

Installation and Upgrades:

```sh
helm upgrade --install --namespace <namespace> counter ./count
helm upgrade --install --namespace <namespace> compactor ./count
```

Notes:

* namespace is *required* for this command
* required per separate environments

### Home

Home chart deploys [home](github.com/ropelive/home). Please see the Values.yaml file for the configuration parameters.

Installation and Upgrades:

```sh
helm upgrade --install --namespace <namespace> home ./home
```

Notes:

* namespace is *required* for this command
* required per separate environments

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

Notes:

* namespace is *required* for this command
* required per separate environments

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

Notes:

* namespace is *required* for this command
* required per separate environments

## Chart Version Upgrades

Please note that the Values.yaml files might have been changed to satisfy our needs. Merge the changes according to new requirements and push accordingly.

```sh
helm fetch stable/keel --untar --destination ./kubernetes/keel
helm fetch stable/mongodb --untar --destination ./kubernetes/mongodb
helm fetch stable/prometheus --untar --destination ./kubernetes/prometheus
helm fetch stable/redis --untar --destination ./kubernetes/redis
helm fetch stable/spotify-docker-gc --untar --destination ./kubernetes/spotify-docker-gc
helm fetch stable/nginx-ingress --untar --destination ./kubernetes/nginx-ingress
```

## Steps for deployment

### Multi env installations

```sh
helm init

export ENV_PREFIX="rope"
export ENV_SUFFIX="stage" # for production change env suffix to prod
export NAMESPACE=$ENV_PREFIX-$ENV_SUFFIX

export MONGODBUSERNAME="rope_admin"
export MONGODBPASSWORD="minda"
export MONGODBDATABASE="rope"
export MONGODB_URL="mongodb://$MONGODBUSERNAME:$MONGODBPASSWORD@$ENV_SUFFIX-mongodb-mongodb:27017/$MONGODBDATABASE"
export REDIS_URL="$ENV_SUFFIX-redis-redis:6379"

# service components
helm upgrade --install --namespace $NAMESPACE                                                                                                                      $ENV_SUFFIX-redis ./redis
helm upgrade --install --namespace $NAMESPACE --set mongodbUsername=$MONGODBUSERNAME --set mongodbPassword=$MONGODBPASSWORD --set mongodbDatabase=$MONGODBDATABASE $ENV_SUFFIX-mongodb ./mongodb
# accounting components
helm upgrade --install --namespace $NAMESPACE --set appName=counter   --set mongodbURL=$MONGODB_URL --set redisURL=$REDIS_URL                                      $ENV_SUFFIX-counter ./count
helm upgrade --install --namespace $NAMESPACE --set appName=compactor --set mongodbURL=$MONGODB_URL --set redisURL=$REDIS_URL                                      $ENV_SUFFIX-compactor ./count
# rope components
helm upgrade --install --namespace $NAMESPACE                         --set mongodbURL=$MONGODB_URL                                                                $ENV_SUFFIX-home ./home
helm upgrade --install --namespace $NAMESPACE                                                       --set redisURL="redis://$REDIS_URL"                            $ENV_SUFFIX-twine ./twine
helm upgrade --install --namespace $NAMESPACE                                                                                                                      $ENV_SUFFIX-server ./server
helm upgrade --install --namespace $NAMESPACE                                                                                                                      $ENV_SUFFIX-rest ./rest
# routing components
helm upgrade --install --namespace $NAMESPACE --set envName=$ENV_SUFFIX                                                                                            $ENV_SUFFIX-routing  ./routing
```

### Single installations per deployment

```sh
helm upgrade --install                            $ENV_PREFIX    ./env
helm upgrade --install                            keel           ./keel
helm upgrade --install                            prom           ./prometheus
helm upgrade --install                            graf           ./grafana
helm upgrade --install                            docker-gc      ./spotify-docker-gc
helm upgrade --install --namespace  nginx-ingress nginx-ingress  ./nginx-ingress
```