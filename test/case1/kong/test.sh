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

clean_up() {
    sudo docker stop kong-dbless || true
    sudo docker rm kong-dbless || true
}

trap clean_up EXIT

sudo docker run -d --name kong-dbless \
    --network=host \
    -v $PWD/test/case1/kong/declarative/kong.yaml:/kong/declarative/kong.yaml \
    -e "KONG_DATABASE=off" \
    -e "KONG_DECLARATIVE_CONFIG=/kong/declarative/kong.yaml" \
    -e "KONG_PROXY_ACCESS_LOG=off" \
    -e "KONG_NGINX_WORKER_PROCESSES=1" \
    -e "KONG_LOG_LEVEL=warn" \
    -p 8000:8000 \
    kong:3.0.0-ubuntu

sleep 3

rm -rf $PWD/test/case1/kong/result || true
mkdir $PWD/test/case1/kong/result

for i in {1..3}; do \
    wrk -c100 -t4 -d10 -R26000 -U http://127.0.0.1:8000/hello > $PWD/test/case1/kong/result/$i.log 2>&1
done
