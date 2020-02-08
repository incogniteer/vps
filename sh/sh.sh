#!/usr/bin/env bash

# check the default sh interpreter
# sh is linked to dash in debian/ubuntu
readlink -f $(which sh)
