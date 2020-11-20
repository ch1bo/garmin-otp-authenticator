#!/bin/bash

# Requires Inkscape and ImageMagick

VIVOACTIVE3_SIZE="40x33"
VIVOACTIVE3_RESIZE="33x33"
VIVOACTIVE4_RESIZE="35x35"
VIVOACTIVE4_SIZE="$VIVOACTIVE4_RESIZE"
FENIX5S_RESIZE="36x36"
FENIX5S_SIZE="$FENIX5S_RESIZE"
FENIX6_RESIZE="40x40"
FENIX6_SIZE="$FENIX6_RESIZE"
VIVOACTIVE_HR_RESIZE="33x33"
VIVOACTIVE_HR_SIZE="$VIVOACTIVE_HR_RESIZE"

# SVG to PNG
inkscape -w 720 -o padlock.png padlock.svg
convert padlock.png -strip padlock.png
convert padlock.png -gravity center -background none -extent "1440x720" -strip hero.png

# Vivoactive 3
convert padlock.png +dither -brightness-contrast 20x20 -remap rgb222_colortable.gif -resize "$VIVOACTIVE3_RESIZE" -gravity center -background none -extent "$VIVOACTIVE3_SIZE" \( +clone -channel A -morphology EdgeOut Diamond +channel +level-colors black \) -compose DstOver -composite -remap rgb222_colortable.gif -strip ../resources-vivoactive3/icon.png

# Vivoactive 4
convert padlock.png +dither -brightness-contrast 20x20 -remap rgb222_colortable.gif -resize "$VIVOACTIVE4_RESIZE" -gravity center -background none -extent "$VIVOACTIVE4_SIZE" \( +clone -channel A -morphology EdgeOut Diamond +channel +level-colors black \) -compose DstOver -composite -remap rgb222_colortable.gif -strip ../resources-vivoactive4/icon.png

#convert padlock.png +dither -brightness-contrast 20x20 -remap rgb222_colortable.gif -resize "$VIVOACTIVE_HR_RESIZE" -gravity center -background none -extent "$VIVOACTIVE_HR_SIZE" \( +clone -channel A -morphology EdgeOut Diamond +channel +level-colors black \) -compose DstOver -composite -remap rgb222_colortable.gif ../resources-vivoactive_hr/icon.png
# convert padlock.png +dither -brightness-contrast 20x20 -remap rgb222_colortable.gif -resize "$FENIX6_RESIZE" -gravity center -background none -extent "$FENIX6_SIZE" \( +clone -channel A -morphology EdgeOut Diamond +channel +level-colors black \) -compose DstOver -composite -remap rgb222_colortable.gif ../resources-fenix6/icon.png

# Fenix 5s
convert padlock.png +dither -brightness-contrast 20x20 -remap rgb222_colortable.gif -resize "$FENIX5S_RESIZE" -gravity center -background none -extent "$FENIX5S_SIZE" \( +clone -channel A -morphology EdgeOut Diamond +channel +level-colors black \) -compose DstOver -composite -remap rgb222_colortable.gif -strip ../resources-fenix5s/icon.png

# Defaults
convert padlock.png +dither -brightness-contrast 20x20 -remap rgb222_colortable.gif -resize "40x40" \( +clone -channel A -morphology EdgeOut Diamond +channel +level-colors black \) -compose DstOver -composite -remap rgb222_colortable.gif -strip ../resources/icon.png
cp ../resources/icon.png ../resources/icon-40x40.png
convert padlock.png +dither -brightness-contrast 20x20 -remap rgb222_colortable.gif -resize "30x30" \( +clone -channel A -morphology EdgeOut Diamond +channel +level-colors black \) -compose DstOver -composite -remap rgb222_colortable.gif -strip ../resources-round-218x218/icon.png
convert padlock.png +dither -brightness-contrast 20x20 -remap rgb222_colortable.gif -resize "60x60" \( +clone -channel A -morphology EdgeOut Diamond +channel +level-colors black \) -compose DstOver -composite -remap rgb222_colortable.gif -strip ../resources-round-390x390/icon.png

