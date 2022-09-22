#!/usr/bin/env bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -ex

command_exists() {
    command -v "$@" > /dev/null 2>&1
}

install_docker() {
    sudo apt-get update
    sudo apt-get install \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    sudo mkdir -p /etc/apt/keyrings
    sudo rm /etc/apt/keyrings/docker.gpg || true
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce=5:20.10.18~3-0~debian-buster docker-ce-cli=5:20.10.18~3-0~debian-buster containerd.io docker-compose-plugin
}

install_openresty() {
    sudo apt-get -y install --no-install-recommends wget gnupg ca-certificates
    wget -O - https://openresty.org/package/pubkey.gpg | sudo apt-key add -
    codename=`grep -Po 'VERSION="[0-9]+ \(\K[^)]+' /etc/os-release`
    echo "deb http://openresty.org/package/debian $codename openresty" \ | sudo tee /etc/apt/sources.list.d/openresty.list
    sudo apt-get update
    sudo apt-get -y install openresty
}

start_openresty() {
    ulimit -n 65535
    ulimit -n -S
    ulimit -n -H
    openresty -p ~/apisix-benchmark/deploy/openresty -c ~/apisix-benchmark/deploy/openresty/conf/nginx.conf
}


deploy_apisix() {
    if ! command_exists docker; then
        install_docker
    fi
    sudo docker pull apache/apisix:dev
}


deploy_kong() {
    if ! command_exists docker; then
        install_docker
    fi
    sudo docker pull kong:3.0.0-ubuntu
}


deploy_openresty() {
    if ! command_exists openresty; then
        install_openresty
    fi
    start_openresty
}


deploy_wrk() {
    cd ~
    mkdir workbench && true

    cd workbench

    sudo rm -rf wrk2 && true

    sudo apt-get update
    sudo apt-get install -y build-essential libssl-dev git zlib1g-dev
    sudo git clone https://github.com/giltene/wrk2.git
    cd wrk2
    sudo make -j8
    # move the executable to somewhere in your PATH
    sudo rm /usr/local/bin/wrk && true
    sudo cp wrk /usr/local/bin
}


case_opt=$1
shift

case ${case_opt} in
deploy_apisix)
    deploy_apisix
    ;;
deploy_kong)
    deploy_kong
    ;;
deploy_openresty)
    deploy_openresty
    ;;
deploy_wrk)
    deploy_wrk
    ;;
esac
