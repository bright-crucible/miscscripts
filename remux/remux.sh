#!/usr/bin/bash
set -e
echo "This script is broken. Try remux2.sh" >&2
exit 0
MUX=`find . -name '*.mkv'`
#NUM1="1:"
#NUM2="2:"
NUM1="0:"
NUM2="1:"
FPS=""
declare -r VID="video"
declare -r AUD="audio"
declare -r AC3=".ac3"
declare -r WAV=".wav"
declare -r AVC1=".h264"
declare -r AAC=".aac"
FLAG="1"
AACFLAG="0"

# Determine the FPS of the video
for i in $( mkvinfo "$MUX" |\
            grep "Default duration:" |\
            gawk '{print $6}' |\
            cut -b 1 --complement ); do
    case $i in
        "23.976")
            FPS="$i"
            ;;
        "29.970")
            FPS="$i"
            ;;
        "25.000")
            FPS="$i"
            ;;
        *)
           ;;
    esac
done

#echo $FPS

if [ -z "$FPS" ] ; then
    echo "Could not determine FPS. Exiting." 1>&2
    exit 1
fi

# Setup which track is which
for i in $( mkvinfo "$MUX" |\
            grep "Track number:\|Track type:\|Codec ID:" |\
            gawk '{print $5}' ); do
    if [ $FLAG == "1" ] ; then
        if [ $i == $VID ] ; then
            NUM1="$NUM1$VID"
        fi
        if [ $i == $AUD ] ; then
            NUM1="$NUM1$AUD"
        fi
        if [ $i == "V_MPEG4/ISO/AVC" ] ; then
            NUM1="$NUM1$AVC1"
            echo "if $NUM1 $NUM1$AVC1"
        fi
        if [ $i == "A_AC3" ] ; then
            NUM1="$NUM1$AC3"
            echo "if $NUM1 $NUM1$AC3"
        fi
        if [ $i == "A_AAC" ] ; then
            AACFLAG="1"
            NUM1="$NUM1$AAC"
        fi
        if [ $i == "2" ] ; then
            FLAG="2"
        fi
        if [ $i == "3" ] ; then
            echo "Third track not supported." 1>&2
            exit 1
        fi
     else
        if [ $i == $VID ] ; then
            NUM2="$NUM2$VID"
        fi
        if [ $i == $AUD ] ; then
            NUM2="$NUM2$AUD"
        fi
        if [ $i == "V_MPEG4/ISO/AVC" ] ; then
            NUM2="$NUM2$AVC1"
            echo "if2 $NUM2 $NUM2$AVC1"
        fi
        if [ $i == "A_AC3" ] ; then
            NUM2="$NUM2$AC3"
            echo "if2 $NUM2 $NUM2$AC3"
        fi
        if [ $i == "A_AAC" ] ; then
            AACFLAG="1"
            NUM2="$NUM2$AAC"
        fi
        if [ $i == "3" ] ; then
            echo "Third track not supported." 1>&2
            exit 1
        fi
    fi
done

echo $NUM1
echo $NUM2
echo "$MUX $NUM1 $NUM2"
mkvextract tracks "$MUX" $NUM1 $NUM2

if [ $AACFLAG == "1" ] ; then
   MP4Box -add "$VID$AVC1" -add "$AUD$AAC" -fps $FPS temp.mp4
#   mp4info temp.mp4
   rm "$VID$AVC1" "$AUD$AAC"
else 
   ffmpeg -i "$AUD$AC3" -ac 2 "$AUD$WAV"
   neroAacEnc -lc -q .9 -if "$AUD$WAV" -of "$AUD$AAC"
   MP4Box -add "$VID$AVC1" -add "$AUD$AAC" -fps $FPS temp.mp4
#   mp4info temp.mp4
   rm "$VID$AVC1" "$AUD$WAV" "$AUD$AAC" "$AUD$AC3"
fi

MUX=${MUX%???}
MUX=${MUX}"mp4"
mv temp.mp4 "$MUX"
mp4info "$MUX"
