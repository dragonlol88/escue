#! /bin/bash

BASE_URL=''

_set_url()
{
  # $1: Host, $2: Index $3: Rest url
  BASE_URL=http://$1/$2/$3
}

_curling()
{
  METHOD=$1; shift
  # setting base url
  _set_url $1 $2 $3

  # request http to elasticsearch
  curl "$1 $BASE_URL" | python -m json.tool
}



_close()
{
  HOST=$1
  INDEX=$2
  REST_URL='_close'
  METHOD="XPOST"

  # curling to elasticsearch
  _curling $METHOD $HOST $INDEX $REST_URL
}

_open()
{

  HOST=$1
  INDEX=$2
  REST_URL='_open'
  METHOD="XPOST"

  # curling to elasticsearch
  _curling $METHOD $HOST $INDEX $REST_URL

}
