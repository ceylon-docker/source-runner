#!/bin/bash

set -e

if [[ $# -lt 1 ]]; then
    echo "Usage: docker run ceylon/source-runner [-q] <repo-module-url> [<module>]"
    echo ""
    echo "The <repo-module-url> argument can either be:"
    echo " - a GitHub repository name, eg: \"ceylon/ceylon.formatter\""
    echo " - a GitHub repository URL, eg: \"https://github.com/ceylon/ceylon.formatter\""
    echo " - a URL to a ZIP file, eg: \"https://github.com/ceylon/ceylon.formatter/archive/master.zip\""
    echo " - a Ceylon module on the Herd that has a source artifact, eg: \"ceylon.formatter/1.2.1\""
    echo ""
    echo "The runner will try to figure out which module to run, but if it can't or if you want"
    echo "to override the choice it makes you can specify its name as the <module> argument."
    echo ""
    echo "Use the option -q option to suppress output from the runner itself."
    exit
fi

if [[ $1 == "-q" ]]; then
    ECHO=:
    shift 1
else
    ECHO=echo
fi

REPO=$1
if [[ $# -lt 2 ]]; then
    MODULE=
    ARGS=
else
    MODULE=$2
    shift 2
    ARGS="$@"
fi

VERSION=master

if ! [[ -d modules ]]; then
    $ECHO "Getting code..."
    if [[ ${REPO} =~ ^[-a-zA-Z0-1]+(\.[-a-zA-Z0-1]+)+\/.*$ ]]; then
        ceylon src ${REPO} >/dev/null
    else
        if ! ( [[ ${REPO} == http://* ]] || [[ ${REPO} == https://* ]] ); then
            REPO="https://github.com/${REPO}"
        fi

        URL=${REPO}
        if ! [[ ${URL} == *.zip ]]; then
            URL=${URL}/archive/${VERSION}.zip
        fi

        curl -sSL -o ${VERSION}.zip "${URL}" >/dev/null

        unzip -q ${VERSION}.zip

        DIR=$(find . -maxdepth 1 -type d -name '[a-zA-Z0-3]*' -printf '%f\n')
        if [[ -d ${DIR}/source ]]; then
            cd ${DIR}
        elif ! [[ -d source ]]; then
            mkdir source
            mv ${DIR} source/
        fi
    fi

    $ECHO "Compiling..."
    if [[ $ECHO == ":" ]]; then
        ceylon compile -W \* &>/dev/null
    else
        ceylon compile -W --progress \*
    fi
fi

if [[ ${MODULE} == "" ]]; then
    MODULES=$(find modules -name '*.car' -printf "%P\n" | sed -r 's/^(.*)\/([^\/]*)\/[^\/]*/\1$\2/' | tr "/$" "./")
    MODULE=${MODULES[0]}
fi

# See if the config file defines the module to run for the JVM.
javamodule=$(ceylon config get runtool.java.module)

# See if the config file defines the module to run for JavaScript.
jsmodule=$(ceylon config get runtool.js.module)

# We first checked "runtool.java.module" and if that didn't exist
# we try "runtool.module" and finally we default to "$MODULE"
if [[ -z "$javamodule" && -z "$jsmodule" ]]; then
	javamodule=$(ceylon config get runtool.module)
	if [[ -z "$javamodule" ]]; then
		javamodule=$MODULE
	fi
fi

# Now depending on the modules we found we either execute them
# with the JVM or the JS backend (or both). The --sysrep argument
# can be used because the `assemble` script already copied all
# dependencies including the system modules. It's needed because
# ceylon.io doesn't allow opening of read-only files
$ECHO "Starting..."
$ECHO ""
[[ ! -z "$javamodule" ]] && exec ceylon run $javamodule ${ARGS}
[[ ! -z "$jsmodule" ]] && exec ceylon run-js $jsmodule ${ARGS}

