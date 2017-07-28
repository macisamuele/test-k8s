#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ${DIR}

docker build -t hackapp/gitlab-runner:v9.4.1 gitlab-runner 

cd -
