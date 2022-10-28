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
    sudo docker stop apisix-standalone || true
    sudo docker rm apisix-standalone || true
}

trap clean_up EXIT

sudo docker run --name apisix-standalone \
    -v $PWD/test/case2/apisix/config.yaml:/usr/local/apisix/conf/config.yaml \
    -v $PWD/test/case2/apisix/apisix.yaml:/usr/local/apisix/conf/apisix.yaml \
    -p 9080:9080 \
    --network=host \
    -d apache/apisix:dev

sleep 3

rm -rf $PWD/test/case2/apisix/result || true
mkdir $PWD/test/case2/apisix/result

for i in {1..10}; do \
    wrk -c100 -t4 -d10 -R99999 -U http://127.0.0.1:9080/hello > $PWD/test/case2/apisix/result/$i.log 2>&1
done