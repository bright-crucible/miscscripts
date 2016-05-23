#!/usr/bin/env bash
SNAP_COUNT=20
DIR_BASENAME=backup
BACKUP_DIR=/home/whomever/test
SNAP_OLDEST=$(($SNAP_COUNT + 1))
SNAP_NEWEST=01
SNAP_SECOND=`printf %02d $(($SNAP_NEWEST + 1))`
OLDEST_DIR=$BACKUP_DIR/$DIR_BASENAME$SNAP_OLDEST
BACKUP_NEWEST=$BACKUP_DIR/$DIR_BASENAME$SNAP_NEWEST
BACKUP_SECOND=$BACKUP_DIR/$DIR_BASENAME$SNAP_SECOND

if ! [ -d $BACKUP_NEWEST ]; then
    echo "Initial backup contents $BACKUP_NEWEST not found" >&2
    exit 1
fi
if [ -d $OLDEST_DIR ]; then
    echo "remove $OLDEST_DIR"
    rmdir "$OLDEST_DIR"
fi
for i in `seq $SNAP_COUNT -1 $SNAP_NEWEST`; do
    j=$(($i + 1))
    newer=`printf %02d $i`
    older=`printf %02d $j`
    backup_newer=$BACKUP_DIR/$DIR_BASENAME$newer
    backup_older=$BACKUP_DIR/$DIR_BASENAME$older
    if [ -d "$backup_newer" ]; then
        echo "move $backup_newer $backup_older"
        mv "$backup_newer" "$backup_older"
    fi
done

echo "cp -al $BACKUP_SECOND $BACKUP_NEWEST"
cp -al "$BACKUP_SECOND" "$BACKUP_NEWEST"
echo "rsync whatever $BACKUP_NEWEST/"
