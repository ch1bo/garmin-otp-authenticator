#!/usr/bin/env bash
set -e

# A few interesting devices to test
DEVICES=(
  fenix847mm # ciq 5.x, amoled, touch, buttons, round
  fenix8solar51mm # bigger, mip, solar
  fenix6spro # ciq 3.4, smaller, mip, buttons only
  vivoactive4 # ciq 3.x, touch, less buttons
  venu3 # touch, less buttons
  venusq2m # rectangular
  instinct2 # octagon, sub-display
)

for d in ${DEVICES[@]}; do
  make test DEVICE=${d}
  make start DEVICE=${d}
done
