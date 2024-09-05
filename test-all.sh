#!/usr/bin/env bash
set -e

# A few interesting devices to test
DEVICES=(
  fenix847mm # ciq 5.x, amoled, touch, buttons, round
  fenix8solar51mm # bigger, mip, solar
  venu3 # touch only
  instinct2 # octagon, sub-display
  fenix6 # ciq 3.x, mip, buttons only
  vivoactive4 # ciq 3.x
  vivoactive_hr # ciq 2.x, square
)

for d in ${DEVICES[@]}; do
  make test DEVICE=${d}
  make start DEVICE=${d}
done
