#!/usr/bin/env bash
ret=0
if [ -f /tmp/tc ]; then
echo "Transcode in progress, exiting" >&2
exit 1
fi
for i in *.ts
do
orig=$(readlink "$i")
dest=$(dirname "$orig")
mkv=$(basename "$i" .ts).mkv
ass=$(basename "$i" .ts).ass
srt=$(basename "$i" .ts).srt
if ! [ -f "$mkv" ]; then
echo "$i does not have mkv" >&2
ret=1
else
#echo "$i has mkv, copy and delete"
mv "$mkv" "$dest/"
rm "$i"
rm "$orig"
mv "$ass" "$srt" subs/
fi

done
exit $ret
