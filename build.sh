#!/bin/bash

shopt -s extdebug
shopt -s inherit_errexit
set -e

. build-scripts/loader-extended.bash

loader_addpath build-scripts/

# shellcheck source=build-scripts/libmain.sh
include libmain.sh
# shellcheck source=build-scripts/libbuild.sh
include libbuild.sh
# shellcheck source=build-scripts/libdefer.sh
include libdefer.sh
# shellcheck source=build-scripts/liblog.sh
include liblog.sh

function main() {
  local stage="${1-all}"

  libmain_init seqpipe-gpf-containers sgc
  libmain_init_build_env gpf gpfjs
  libmain_save_build_env_on_exit
  libbuild_init "$stage" registry.seqpipe.org

  defer_ret build_run_ctx_reset_all_persistent
  defer_err build_run_ctx_reset_all_persistent
  defer_err build_run_ctx_reset

  build_stage "Cleanup"
  {
    build_run_ctx_init "container" "ubuntu:18.04"
    defer_ret build_run_ctx_reset
    build_run rm -rf \
      ./seqpipe-gpfjs/gpfjs/node_modules \
      ./seqpipe-gpfjs/gpfjs/package-lock.json \
      ./seqpipe-gpfjs/gpfjs/dist \
      ./seqpipe-gpfjs/gpfjs-dist-*.tar.gz \
      ./seqpipe-gpf-full/gpfjs-dist-*.tar.gz
  }

  local gpf_commit
  gpf_commit=$(e gpf_git_describe)

  local gpfjs_commit
  gpfjs_commit=$(e gpfjs_git_describe)

  build_stage "Build seqpipe-builder"
  {
    build_docker_image_create "seqpipe-builder" "seqpipe-builder" "seqpipe-builder/Dockerfile"
  }

  build_stage "Build seqpipe-http"
  {
    build_docker_image_create "seqpipe-http" "seqpipe-http" "seqpipe-http/Dockerfile"
  }

  build_stage "Preparing gpf and gpfjs sources"
  {
    build_run_ctx_init "local"
    defer_ret build_run_ctx_reset

    build_run pushd .

    build_run cd seqpipe-gpf
    build_run [ ! -d gpf ] && build_run git clone git@github.com:iossifovlab/gpf.git

    build_run cd gpf
    build_run git clean --force
    build_run git checkout .
    build_run git pull || true
    build_run git checkout "$gpf_commit"
    build_run git pull || true

    build_run popd

    build_run pushd .

    build_run cd seqpipe-gpfjs
    build_run [ ! -d gpfjs ] && build_run git clone git@github.com:iossifovlab/gpfjs.git

    build_run cd gpfjs
    build_run git clean --force
    build_run git checkout .
    build_run git pull  || true
    build_run git checkout "$gpfjs_commit"
    build_run git pull  || true

    build_run popd
  }

  build_stage "Build seqpipe-gpf"
  {
    build_docker_image_create "seqpipe-gpf" "seqpipe-gpf" "seqpipe-gpf/Dockerfile"
  }

  local seqpipe_node_base_image_ref
  seqpipe_node_base_image_ref=$(e docker_img_seqpipe_node_base)
  build_stage "Build seqpipe-gpfjs"
  {
    build_run_ctx_init "container" "$seqpipe_node_base_image_ref"
    defer_ret build_run_ctx_reset

    build_run cd seqpipe-gpfjs/gpfjs

    build_run npm install
    build_run rm -rf dist
    build_run ng build --prod --aot --configuration 'default' --base-href '/gpf_prefix/' --deploy-url '/gpf_prefix/'
    build_run python ppindex.py

    build_run cd dist/gpfjs
    build_run tar zcvf /wd/seqpipe-gpfjs/gpfjs-dist-default-"${gpfjs_commit}".tar.gz .
    build_run cp /wd/seqpipe-gpfjs/gpfjs-dist-default-"${gpfjs_commit}".tar.gz /wd/seqpipe-gpf-full/
    build_run cd -
  }

  build_stage "Build gpf-full"
  {
    build_run_ctx_init "local"
    defer_ret build_run_ctx_reset

    build_run cd seqpipe-gpf-full

    local docker_repo
    docker_repo=$(ee docker_repo)

    local seqpipe_gpf_image_ref
    seqpipe_gpf_image_ref=$(e docker_img_seqpipe_gpf)

    # shellcheck disable=SC2016
    build_run bash -c  "sed Dockerfile > Dockerfile.build \
      -e '1 s|:REGISTRY:/seqpipe-gpf:latest|'${seqpipe_gpf_image_ref}'|g' \
      -e 's/^ARG VERSION_TAG//' \
      -e 's/\${VERSION_TAG}/'${gpfjs_commit}'/'"

    build_docker_image_create "seqpipe-gpf-full" "seqpipe-gpf-full" ./seqpipe-gpf-full/Dockerfile.build
  }
}

main "$@"
