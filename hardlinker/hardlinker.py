#!/usr/bin/env python3
#Originally envisioned for Minecraft Overviewer but disk savings were poor
import os
import sys
import glob
import re
import hashlib
from pprint import pprint

if __name__ == '__main__':
    idx = 0
    hashes = {}
    for dirpath, dirnames, filenames in os.walk('render-alt'):
        idx = idx + 1
        #print(dirpath)
        #print(dirnames)
        #print(filenames)
        for png in glob.glob(dirpath + '*.png'):
            with open(png, 'rb') as f:
                md5 = hashlib.md5(f.read()).digest()
            stats = os.stat(png)
            #print('file is {0}'.format(png))
            if md5 in hashes:
                #some check that the files really are the same?
                exists = os.stat(hashes[md5])
                if exists.st_ino != stats.st_ino:
                    print(idx)
                    os.unlink(png)
                    print('unlink  {0}'.format(png))
                    os.link(hashes[md5], png)
                    print('link to {0}'.format(hashes[md5]))
                    os.utime(png, (stats.st_atime, stats.st_mtime))
                    print('')
            else:
                hashes[md5] = png
        #if idx > 3000:
        #    break
