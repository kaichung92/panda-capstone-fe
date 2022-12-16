#!/bin/sh


# ------------------------------------------------------------------
# [Author] Noel Lim
#          Use this file as a driver to orchestrate run and build repository.
# ------------------------------------------------------------------


USAGE () {
    echo "Please specify argument."
}

if [ $# == 0 ]
then
    USAGE
    exit 1;
fi


check_docker_exists () {
    if ! command -v docker &> /dev/null
    then
        echo "FAIL: Docker could not be found."
        exit 1;
    elif ! docker stats --no-stream &> /dev/null
    then
        echo "FAIL: Docker daemon/engine is not running."
        exit 1;
    else
        echo "Docker found."
    fi
}

check_docker_exists


build_app () {

    echo "[build_app]"
    commit_hash=$(git log -1 --format="%H")
    ymds=$(date +%Y%m%d%s)
    image_name="vms-frontend-build-${commit_hash}-${ymds}"
    echo "[development] building container ${image_name}"
    docker build -f Dockerfile.build -t ${image_name} .

    if [[ "$(docker images -q ${image_name} 2> /dev/null)" == "" ]]
    then
        echo "FAIL: [development] Image ${image_name} not found"
        exit 1;        
    else
        echo "[development] Image ${image_name} found"
        echo "[development] Running image ${image_name}"
        docker run -it -v "$(pwd):/app" -e DEVELOPMENT_PORT="${DEVELOPMENT_PORT}" --rm -p "${DEVELOPMENT_PORT}":"${DEVELOPMENT_PORT}"/tcp ${image_name}
    fi
    exit 0;

}

case "${1}" in
    build)
    build_app
    ;;
esac