# Linux Runner

Using summerwind/actions-runner-dind as base

## Building

``` bash
export DOCKER_BUILDKIT=1; docker buildx build -t IMAGE_NAME:IMAGE_VERSION --no-cache -f DOCKERFILE .
```

## Ansible runner
### packages
- ansible-core
- docker
- docker-buildx
- git
- jq
- openssl
- gh (github cli)
- pip
- p7zip


## Yarn runner
### packages
- docker-buildx
- git
- jq
- openssl
- zstd
- gh (github cli)
- yarn
- pip
- p7zip