#! /bin/bash

load test_helper.sh

setup()
{
  source ./lib/transport.sh
  Transport
  rm -rf testing && mkdir testing
  cd testing

}

teardown() {
  cd ..
  rm -rf testing
}


@test "Test Http Request" {

  http_trasport
  [ -e "./http_request" ]
  [ "$(head -n 1 http_request)" = "Transport HTTP request using curl" ]

}

@test "Test scp File Transport" {
  scp_file_transport
  [ -e "./scp_file_transfer" ]
  [ "$(head -n 1 scp_file_transfer)" = "Transport file using scp protocol" ]


}
