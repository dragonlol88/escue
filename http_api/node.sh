#! /bin/bash


_nodes()
{
  curl -XGET "http://${host}/_nodes/_all"
  echo "Http to get node information"
}