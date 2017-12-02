#!/bin/bash

#  make relative paths work.
pushd "$(dirname "$0")"

function git-tag() {
	repo=$1
	repo_dir=$(get-repo-path "$repo")
	pushd "$repo_dir"
	git stash save
	git fetch
	git pull --rebase
	VERSION=$(git for-each-ref refs/tags --sort=-taggerdate --format='%(refname:short)' --count=1)
	echo "Latest version tag:" "$VERSION"

	# split into array
	VERSION_BITS=(${VERSION//./ })

	#get number parts and increase last one by 1
	VNUM1=${VERSION_BITS[0]:-0}
	VNUM2=${VERSION_BITS[1]:-0}
	VNUM3=${VERSION_BITS[2]:-0}
	VNUM3=$((VNUM3 + 1))

	#create new tag
	NEW_TAG="$VNUM1.$VNUM2.$VNUM3"

	echo "Updating $VERSION to $NEW_TAG"

	echo "Tagging with" "$NEW_TAG"
	git tag -f "$NEW_TAG"
	git push origin "$NEW_TAG"
	git stash pop
	popd
}

repos=(home infra server rest count twine)

function validate-repo-name() {
	repo=$1
	case "${repos[@]}" in *"$repo"*) ;;
	*)
		echo "Error: Repo not found: $repo"
		echo "Available Repos:" "${repos[@]}"
		exit 1
		;;
	esac
}

function get-rope-path() {
	ROPE_PATH=${ROPE_PATH:-"$(dirname "$0")"/..}
	echo "$ROPE_PATH"
}

function get-repo-path() {
	repo=$1
	rope_path=$(get-rope-path)
	REPO_DIR=${REPO_DIR:-$rope_path/$repo}
	echo "$REPO_DIR"
}

function validate-repo-path() {
	repo=$1
	repo_dir=$(get-repo-path "$repo")
	if [ -d "$repo_dir" ]; then
		echo "$repo_dir exists"
	else
		echo "Error: $repo_dir does not exist"
		echo "Cloning $repo to $repo_dir"
		git clone git@github.com:ropelive/"$repo".git "$repo_dir"
	fi
}

function validate-image-tags() {
	failed="false"
	for i in "${repos[@]}"; do
		if [ $i != "infra" ]; then
			version=$(./yaml-parser.sh ./kubernetes/"$i"/values.yaml image_tag)
			tag=$(curl --silent "https://hub.docker.com/v2/repositories/ropelive/"$i"/tags/?page_size=1" | jq -r '.results|.[]|.name')
			echo "repo: $i $version $tag"
			if [[ "$version" != "$tag" ]]; then
				failed="true"
				echo "Error: version mismatch: current version in values: $version and dockerhub tag: $tag are not same for $i"
			fi
		fi
	done
	[[ "$failed" == "false" ]] || exit 1
}

if [ "$1" == "upgrade" ]; then
	shift

	validate-repo-name "$1"
	validate-repo-path "$1"
	git-tag "$1"

elif [ "$1" == "helm" ]; then
	validate-image-tags

	shift
	./kubernetes/helm.sh "$@"

elif [ "$1" == "validate-image-tags" ]; then
	validate-image-tags
else
	echo "Error: usage yaml-parser.sh <filename?> <key?>"
fi
