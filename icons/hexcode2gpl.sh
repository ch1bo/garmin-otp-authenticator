#!/bin/bash

for f in *.txt ; do
  (
  echo "GIMP Palette
Name: $(basename "$f" .txt)
#"

  for i in `cat "$f" | sed 's/[[:space:]]\+/\n/g' | sed 's/^0x//g'` ; do
    printf "%3d %3d %3d\n" 0x${i:0:2} 0x${i:2:2} 0x${i:4:2}
  done
  ) > "$(basename "$f" .txt).gpl"
done

