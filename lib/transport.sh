#! /bin/bash

Transport()
{
  
  
  http_trasport()
  {
    # $1=method
    # $2=url
    # $3=params
    # $4=data
    # $5=headers
    # Options(timeout)
    echo "Transport HTTP request using curl" > http_request

  }
  
  scp_file_transport()
  {
    echo "Transport file using scp protocol" > scp_file_transfer
  }

  echo "HTTP Transport"
}

