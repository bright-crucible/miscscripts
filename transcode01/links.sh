#!/usr/bin/env bash
while IFS= read -r line
do
#echo "$line"
b=`basename "$line"`
#echo "$b"
ln -s "$line" "$b"
done < <(find ~/plex/usenet/ -name '*.ts')
