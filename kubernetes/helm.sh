#!/bin/bash

# Validate that this file is called from the parent bash script.
PARENT_COMMAND="$(ps -o args= $PPID)"
should_contain_str="infra/rope.sh helm"
if [[ "$PARENT_COMMAND" != *$should_contain_str* ]]; then
	echo 'This file should not be called directly, use "rope.sh helm" instead'
	exit 1
fi

#  make relative paths work.
pushd "$(dirname "$0")"

function set-env-vars() {
	export ENV_PREFIX=${ENV_PREFIX:-"rope"}
	export ENV_SUFFIX=${ENV_SUFFIX:-"stage"} # for production change env suffix to prod
	export NAMESPACE=${NAMESPACE:-$ENV_PREFIX-$ENV_SUFFIX}
	export BASE_DOMAIN=${BASE_DOMAIN:-"p.rope.live"}
	export ROUTING_DEPLOY_NAME=${ROUTING_DEPLOY_NAME:-$ENV_SUFFIX-${BASE_DOMAIN//./-}-routing}

	export MONGODBUSERNAME=${MONGODBUSERNAME:-"rope_admin"}
	export MONGODBPASSWORD=${MONGODBPASSWORD:-"minda"}
	export MONGODBDATABASE=${MONGODBDATABASE:-"rope"}
	export MONGODB_URL=${MONGODB_URL:-"mongodb://$MONGODBUSERNAME:$MONGODBPASSWORD@$ENV_SUFFIX-mongodb-mongodb:27017/$MONGODBDATABASE"}
	export REDIS_URL=${REDIS_URL:-"$ENV_SUFFIX-redis-redis:6379"}
}

function upgrade-templates() {
	set-env-vars
	helm upgrade --install --namespace $NAMESPACE $ENV_SUFFIX-redis ./redis
	helm upgrade --install --namespace $NAMESPACE --set mongodbUsername=$MONGODBUSERNAME --set mongodbPassword=$MONGODBPASSWORD --set mongodbDatabase=$MONGODBDATABASE $ENV_SUFFIX-mongodb ./mongodb
	# accounting components
	helm upgrade --install --namespace $NAMESPACE --set appName=counter --set mongodbURL=$MONGODB_URL --set redisURL=$REDIS_URL $ENV_SUFFIX-counter ./count
	helm upgrade --install --namespace $NAMESPACE --set appName=compactor --set mongodbURL=$MONGODB_URL --set redisURL=$REDIS_URL $ENV_SUFFIX-compactor ./count
	# rope components
	helm upgrade --install --namespace $NAMESPACE --set envName=$ENV_SUFFIX --set baseDomain=$BASE_DOMAIN --set mongodbURL=$MONGODB_URL $ENV_SUFFIX-home ./home
	helm upgrade --install --namespace $NAMESPACE --set redisURL="redis://$REDIS_URL" $ENV_SUFFIX-twine ./twine
	helm upgrade --install --namespace $NAMESPACE $ENV_SUFFIX-server ./server
	helm upgrade --install --namespace $NAMESPACE $ENV_SUFFIX-rest ./rest
	# routing components
	helm upgrade --install --namespace $NAMESPACE --set envName=$ENV_SUFFIX $ENV_SUFFIX-routing ./routing
	helm upgrade --install --namespace $NAMESPACE --set envName=$ENV_SUFFIX --set baseDomain=$BASE_DOMAIN $ROUTING_DEPLOY_NAME ./routing
}

function init() {
	set-env-vars
	helm init
	helm upgrade --install $ENV_PREFIX ./env
	helm upgrade --install keel ./keel
	helm upgrade --install prom ./prometheus
	helm upgrade --install graf ./grafana
	helm upgrade --install docker-gc ./spotify-docker-gc
	helm upgrade --install --namespace nginx-ingress nginx-ingress ./nginx-ingress
	helm upgrade --install --namespace routing kube-lego ./kube-lego
}

if [ "$1" == "init" ]; then
	init
elif [ "$1" == "upgrade-templates-prod" ]; then
	export ENV_SUFFIX="prod"
	upgrade-templates
elif [ "$1" == "upgrade-templates-stage" ]; then
	export ENV_SUFFIX="stage"
	upgrade-templates
else
	upgrade-templates
fi
