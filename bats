#! /bin/bash

echo "Test ElaStic ResCUE(ESCUE) Project"
echo "Test all testing files from tests/*_test.sh"

bats ./tests/*_test.sh
