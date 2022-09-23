# apisix-banchmark

This repository is used to store scripts and configurations related to APISIX performance testing.

## Deploy

### Attack

```shell
./deploy/deploy.sh deploy_wrk
```

### APISIX

```shell
./deploy/deploy.sh deploy_apisix
```

### upstream

```shell
./deploy/deploy.sh deploy_openresty
```

## Test

Run `test.sh` under different case dir, such as:

```shell
./test/case1/apisix/test.sh
```

## Results

Results are stored in `result` dir, such as: `./test/case1/apisix/result`

## TODO

1. Optimize deployment and testing for multiple scenarios, such as attack and APISIX deployment on different servers.
2. Extracting fixed parameters as command parameters.
3. Supports reading wrk2 test results and generating graphs.
