#!/usr/bin/env bash
#https://stackoverflow.com/questions/3169910/can-ffmpeg-extract-closed-caption-data
#https://www.reddit.com/r/PleX/comments/hyisuz/how_can_i_update_the_audio_language_from_unknown/
if [ -f /tmp/tc ]; then
echo "Transcode in progress" >&2
exit 1
else
touch /tmp/tc
fi
for i in *.ts;
do
new="`basename "$i" .ts`.mkv"
sub="`basename "$i" .ts`.ass"
sub2="`basename "$i" .ts`.srt"

#constants
crf=26
preset=slow

#For some reason, if a filename has a ', then it movie=... won't work
echo "$i" | grep \'
badname=$?
if [ $badname -eq 0 ]; then
ln -s "$i" temp.ts
bad=temp.ts
else
bad="$i"
fi
nice -n19 ffmpeg -f lavfi -i "movie=$bad[out+subcc]" -map 0:1 "$sub"
#nice -n19 ffmpeg -f lavfi -i "movie=$bad[out+subcc]" -map 0:1 "$sub2"
nice -n19 ffmpeg -i "$sub" "$sub2"
nice -n19 ./fix_nbs.sh "$sub2"
if [ $badname -eq 0 ]; then
rm temp.ts
fi

mediainfo "$i" | egrep "Scan type\s+: Interlaced"
retVal=$?
if [ $retVal -eq 1 ]; then
#echo "not interlaced:"
#echo "$i"
#8bit:
#nice -n19 ffmpeg -i "$i" -i "$sub2" -i "$sub" -c:v libx265 -crf ${crf} -preset ${preset} -map 0 -c:a copy -map 1 -map 2 -c:s copy -metadata:s:s language=eng "$new"
#10bit:
#nice -n19 ffmpeg -i "$i" -i "$sub2" -i "$sub" -pix_fmt yuv420p10le -c:v libx265 -crf ${crf} -preset ${preset} -map 0 -c:a copy -map 1 -map 2 -c:s copy -metadata:s:s language=eng "$new"
nice -n19 \
    ffmpeg \
        -i "$i" \
        -i "$sub2" \
        -i "$sub" \
        -pix_fmt yuv420p10le \
        -map 0:v:0 \
        -map 0:a:0 \
        -map 1 \
        -map 2 \
        -c:v:0 libx265 -crf ${crf} -preset ${preset} \
        -c:a:0 copy \
        -c:s:0 copy \
        -c:s:1 copy \
        -metadata:s:s language=eng \
        "$new"
else
#echo "interlaced"
#echo "$i"
#8bit:
#nice -n19 ffmpeg -i "$i" -i "$sub2" -i "$sub" -vf yadif -c:v libx265 -crf ${crf} -preset ${preset} -map 0 -c:a copy -map 1 -map 2 -c:s copy -metadata:s:s language=eng "$new"
#10bit:
#nice -n19 ffmpeg -i "$i" -i "$sub2" -i "$sub" -vf yadif -pix_fmt yuv420p10le -c:v libx265 -crf ${crf} -preset ${preset} -map 0 -c:a copy -map 1 -map 2 -c:s copy -metadata:s:s language=eng "$new"
nice -n 19 \
    ffmpeg \
        -i "$i" \
        -i "$sub2" \
        -i "$sub" \
        -vf yadif \
        -pix_fmt yuv420p10le \
        -map 0:v:0 \
        -map 0:a:0 \
        -map 1 \
        -map 2 \
        -c:v:0 libx265 -crf ${crf} -preset ${preset}
        -c:a:0 copy \
        -c:s:0 copy \
        -c:s:1 copy \
        -metadata:s:s language=eng \
        "$new"
fi
done
rm /tmp/tc
