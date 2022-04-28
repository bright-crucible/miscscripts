#!/usr/bin/env bash
if [ -f /tmp/tc ]; then
echo "Transcode in progress" >&2
exit 1
fi
while IFS= read -r line
do
#echo "$line"
b=`basename "$line"`
#echo "$b"
ln -s "$line" "$b"
done < <(find ~/plex/usenet/ -name '*.ts')
