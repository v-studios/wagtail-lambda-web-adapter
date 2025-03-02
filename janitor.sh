#!/usr/bin/env bash -x
# TODO all these hard wired values should be gotten from CloudFormation.

export AWS_STORAGE_BUCKET_NAME=wagtail-dev-s3media-12vbehqv6osgh

export DATABASE_URL=postgres://wagtail:ChangeMe@wagtaillambda.cluster-caoirfmotyxq.eu-west-3.rds.amazonaws.com:5432/wagtaillambda
export WAGTAIL_JANITOR=yup

export IMG=150806394439.dkr.ecr.eu-west-3.amazonaws.com/serverless-wagtail-dev
export TAG=wagtaillambda
export IMGTAG=${IMG}:${TAG}

docker run --rm -it \
       -e AWS_STORAGE_BUCKET_NAME \
       -e DATABASE_URL \
       -e WAGTAIL_JANITOR \
       -e AWS_PROFILE \
       -v ${HOME}/.aws/credentials:/root/.aws/credentials \
       $IMGTAG bash
