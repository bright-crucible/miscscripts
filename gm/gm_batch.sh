#!/usr/bin/bash
#Used to create background images for Outrun 2019
#Kept for reference
for file in *.png
do 
    outfile=1080p/$file
    echo composite -filter Point -resize 1920x -geometry +0+620 $file ../template.png $outfile
done | gm batch -echo on -feedback on -
