#!/bin/bash

set -e

# Define all the versions that should be generated
VERSIONS=(1.3.0 1.2.2 1.2.1 1.2.0 1.1.0 1.0.0)

# Define the "latest" version
LATEST=1.3.0

# Define which JRE versions to generate for
JRES=(7 8)

# Define the default JRE
DEFAULT_JRE=8

PUSH=0
for arg in "$@"; do
    case "$arg" in
        --help)
            echo "Usage: $0 [--help] [--push]"
            echo ""
            echo "   --help   : shows this help text"
            echo "   --push   : pushes each branch and its tags to Git"
            echo ""
            exit
            ;;
        --push)
            PUSH=1
            ;;
    esac
done

function error() {
    MSG=$1
    [[ ! -z $MSG ]] && echo $MSG
    exit 1
}

function build_branch() {
    VERSION=$1
    [[ -z $VERSION ]] && error "Missing 'version' parameter for build_branch()"
    FROM=$2
    [[ -z $FROM ]] && error "Missing 'from' parameter for build_branch()"
    BRANCH=$3
    [[ -z $BRANCH ]] && error "Missing 'branch' parameter for build_branch()"
    shift 3
    TAGS=("$@")

    echo "Building branch $BRANCH with tags ${TAGS[@]} ..."
    rm -rf /tmp/docker-ceylon-build-templates
    cp -a templates /tmp/docker-ceylon-build-templates
    sed -i "s/@@FROM@@/$FROM/g" /tmp/docker-ceylon-build-templates/Dockerfile
    sed -i "s/@@VERSION@@/$VERSION/g" /tmp/docker-ceylon-build-templates/Dockerfile
    git checkout --quiet $(git show-ref --verify --quiet refs/heads/$BRANCH || echo '-b') $BRANCH
    rm -rf build.sh templates LICENSE README.md
    cp -a /tmp/docker-ceylon-build-templates/. .
    rm -rf /tmp/docker-ceylon-build-templates
    git add .
    git commit -q -m "Updated Dockerfile for $VERSION" || true
    [[ $PUSH -eq 1 ]] && git push -u origin $BRANCH
    for t in ${TAGS[@]}; do
        git tag -f $t
        [[ $PUSH -eq 1 ]] && git push --force origin $t
    done
    git checkout -q master
}

function build_jres() {
    VERSION=$1
    [[ -z $VERSION ]] && error "Missing 'version' parameter for build_jres()"
    FROM_TEMPLATE=$2
    [[ -z $FROM_TEMPLATE ]] && error "Missing 'from_template' parameter for build_jres()"
    JRE_TEMPLATE=$3
    [[ -z $JRE_TEMPLATE ]] && error "Missing 'jre_template' parameter for build_jres()"

    for t in ${JRES[@]}; do
        FROM=${FROM_TEMPLATE/@/$t}
        JRE=${JRE_TEMPLATE/@/$t}
        TAGS=()
        if [[ "$t" == "$DEFAULT_JRE" ]]; then
            TAGS+=("$VERSION")
            if [[ "$VERSION" == "$LATEST" ]]; then
                TAGS+=("latest")
            fi
        fi
        NAME="$VERSION-$JRE"
        build_branch $VERSION $FROM $NAME "${TAGS[@]}"
    done
}

function build() {
    VERSION=$1
    [[ -z $VERSION ]] && error "Missing 'version' parameter for build()"

    echo "Building version $VERSION ..."

    build_jres $VERSION "ceylon\/ceylon:${VERSION}-jre@-redhat" "jre@"
}

for v in ${VERSIONS[@]}; do
    build $v
done

