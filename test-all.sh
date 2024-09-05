#!/usr/bin/env bash
set -e

DEVICES=(
  vivoactive3
  vivoactive5
  vivoactive_hr
  fenix5
  fenix6
  fenix7
  venu2
  instinct2
  fr965
)

for d in ${DEVICES[@]}; do
  make test DEVICE=${d}
  make start DEVICE=${d}
done
