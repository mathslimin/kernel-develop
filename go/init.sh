#!/bin/bash

basedir="$(cd -P "$(dirname "$0")" && pwd)"
rm -f host_key*
ssh-keygen -f "${basedir}/host_key" -P ""
