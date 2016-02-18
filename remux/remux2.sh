#!/usr/bin/bash
set -e

PROGNAME=`basename $0`
ARGV=("$@")

function usage() {
    echo "$PROGNAME -h                                  "\
        "print this help message"
    echo "$PROGNAME content1.mkv ... contentN.mkv       "\
        "remux content"
}

while getopts ":h" opt; do
    case $opt in
        h)
            usage
            exit 0
        ;;
        \?)
            usage
            exit 1
        ;;
    esac
done

TempFile[0]="audio.ac3"
TempFile[1]="audio.wav"
TempFile[2]="audio.aac"
TempFile[3]="video.h264"
TempFile[4]="audio.dts"

for file in 0 1 2 3 4; do
    if [ -a ${TempFile[$file]} ]; then
        echo "Temporary file ${TempFile[$file]} present. Aborting" >&2
        exit 1
    fi
done
for (( i = $OPTIND - 1 ; i < $#; i++ ))
do
    declare -a TYPES
    declare -a TRACKS
    declare -a CODECS
    FPS=""
    THING=${ARGV[$i]}
    TARGET="`basename --suffix=mkv $THING`mp4"
    if [ -a $TARGET ]; then
        echo "Target file $TARGET already exists" >&2
        continue
    fi
    echo "$i $THING"
    #what I should do here is create an associative array where the
    #keys are the types and the values are the track numbers
    TYPES=(`mkvinfo $THING | grep "Track type:" | gawk '{print $5}'`)
    CODECS=(`mkvinfo $THING | grep "Codec ID:" | gawk '{print $5}'`)
    TRACKS=(`mkvinfo $THING | grep -Po '(?<=mkvextract:\s)\w+'`)
    #hack way of determining the FPS for the final remuxing
    #can explode if an audio track appears before the video with
    #one of the following FPS values
    #Actually the keys should be the track # and the values are the types
    FPS=""
    for j in $(mkvinfo $THING | grep "Default duration:" |\
            gawk '{print $6}' |\
            cut -b 1 --complement); do
        case $j in
            "23.976")
                FPS=$j
            ;;
            "29.970")
                FPS=$j
            ;;
            "25.000")
                FPS=$j
            ;;
            *)
            ;;
        esac
    done
    if [ -z $FPS ]; then
        echo "Could not determine FPS" >&2
        continue
    fi
    j=0
    for value in ${TYPES[@]}; do
        echo "j is $j"
        if [ $value == "video" ]; then
            mkvextract tracks $THING ${TRACKS[$j]}:video.h264
        fi
        if [ $value == "audio" ]; then
            if [ ${CODECS[$j]} == "A_AC3" ]; then
                mkvextract tracks $THING ${TRACKS[$j]}:audio.ac3
                ffmpeg -i audio.ac3 -ac 2 audio.wav
                neroAacEnc -lc -q .9 -if audio.wav -of audio.aac
            elif [ ${CODECS[$j]} == "A_AAC" ]; then
                mkvextract tracks $THING ${TRACKS[$j]}:audio.aac
            elif [ ${CODECS[$j]} == "A_DTS" ]; then
                mkvextract tracks $THING ${TRACKS[$j]}:audio.dts
                ffmpeg -i audio.dts -ac 2 audio.wav
                neroAacEnc -lc -q .9 -if audio.wav -of audio.aac
            else
                echo "Unable to handle audio codec ${CODECS[$j]}" >&2
            fi
        fi
        j=`dc -e "$j 1 + p"`
    done
    MP4Box -add video.h264 -add audio.aac -fps $FPS $TARGET
    rm video.h264 audio.*
    mp4info $TARGET
done

#echo ""
#echo "FPS is $FPS"
#echo ${TYPES[@]}
#echo ${#TYPES[@]}
