#!/usr/bin/env bash

check() {
  TARGET=${1}
  if [ -d "${TARGET}" ]; then
    if grep --recursive -Iie "\\btodo\\b" ${TARGET}
      then
        echo "There are remaining items TODO in ${TARGET}"
        exit 1;
      else
        echo "${TARGET} OK"
    fi
  else
    echo "${TARGET} directory not found, skipping"
  fi
}

# Check the specified directories
check scripts
check scenes
check global
check models
check tests
