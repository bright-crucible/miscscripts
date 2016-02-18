#!/bin/bash

set -e

cdparanoia -vsQ
cdparanoia -B

j=001
for i in *.wav ; do
#for i in *.flac; do
    echo $i
#    b=`basename "$i" .wav`
#    lame --alt-preset standard "$i" "$b.mp3"
    trackfile=`printf "track%03d.ogg\n" "$j"`
    oggenc -q 6.0 "$i" -o "$trackfile"
    j=$(($j + 1))
done

rm *.wav
