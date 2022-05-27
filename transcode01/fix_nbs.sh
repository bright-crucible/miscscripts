#!/bin/bash
#https://fileformats.fandom.com/wiki/SubStation_Alpha
#ASS uses \h to indicate a non-breaking space
#The conversion to SRT just places the \h which means \h to SRT
sub="$1"
if [ ! -f "$sub" ]
then
echo "Subtitles $sub not found" >&2
exit 1
fi
sed -i 's/\\h/ /g' "$sub"
