#!/usr/bin/env python2.7
'''Grabs and parses HTML page for Motorola SB6120 and then stores values
in a user specified file'''
from __future__ import print_function
from pprint import pprint
from collections import namedtuple
import re
import urllib2
import BeautifulSoup
import sys
import time

url = 'http://192.168.100.1/cmSignalData.htm'
plfilename = '/home/paladin/python/modem/powerlevels.csv'
snrfilename = '/home/paladin/python/modem/snr.csv'
t_struct = time.localtime()
#timestr = str(t_struct.tm_year) + '-' + \
#          str(t_struct.tm_mon).zfill(2) + '-' + \
#          str(t_struct.tm_mday).zfill(2) + ' ' + \
#          str(t_struct.tm_hour).zfill(2) + ':' + \
#          str(t_struct.tm_min).zfill(2)

timestr = str(t_struct.tm_mon) + '/' + \
          str(t_struct.tm_mday).zfill(2) + '/' + \
          str(t_struct.tm_year) + ' ' + \
          str(t_struct.tm_hour).zfill(2) + ':' + \
          str(t_struct.tm_min).zfill(2) + ':' + \
          str(t_struct.tm_sec).zfill(2)

if __name__ == '__main__':
    'By the Old Gods and the New'

    try:
        req = urllib2.Request(url)
        u = urllib2.urlopen(req)
    except:
        with open(plfilename, 'a') as levelfile:
            #levelfile.write(str(time.mktime(time.gmtime())) + ',' * 25 + '\n')
            levelfile.write(timestr + ',' * 25 + '\n')
        with open(snrfilename, 'a') as snrfile:
            snrfile.write(timestr + ',' * 12 + '\n')
        sys.exit(0)

        
    #u = urllib2.urlopen(url)
    #print(u.getcode())
        
    #with urllib.urlopen(url) as u:
    soup = BeautifulSoup.BeautifulSoup(u)
    #print(soup.prettify())
    allrows = soup.findAll('tr')

    userrows = [t for t in allrows if t.findAll(text=re.compile('Channel ID'))]
    channeldata = userrows[0].findAll('td')[1].getString()
    downChannelIDs = []
    for channel in userrows[0].findAll('td')[1:]:
        downChannelIDs.append(channel.getText().rstrip('&nbsp;'))
    upChannelIDs = []
    for channel in userrows[1].findAll('td')[1:]:
        upChannelIDs.append(channel.getText().rstrip('&nbsp;'))
    #print(','.join(upChannelIDs))
    #print(','.join(downChannelIDs))

    userrows = [t for t in allrows if t.findAll(text=re.compile('Power Level'))]
    downPowerLevel = userrows[0].findAll('td')
    dlevels = []
    for level in downPowerLevel[2:]:
        dlevels.append(level.getText().rstrip(u' dBmV\n&nbsp;'))
        #levels.append(level.getText())
    #print(','.join(dlevels))
    upPowerLevel = userrows[2].findAll('td')
    ulevels = []
    for level in upPowerLevel[1:]:
        ulevels.append(level.getText().rstrip(u' dBmV\n&nbsp;'))
    #print(','.join(ulevels))
    
    userrows = [t for t in allrows if t.findAll(text=re.compile('Signal to Noise Ratio'))]
    snrlevel = userrows[0].findAll('td')
    snr = []
    for sig in snrlevel[1:]:
        snr.append(sig.getText().rstrip(u' dB&nbsp;'))
    #print(','.join(snr))

    #print('down chan', downChannelIDs)
    #print('down level', dlevels)
    #print('up chan', upChannelIDs)
    #print('up level', ulevels)
    #print('snr', snr)
    Downstream = namedtuple('Downstream', ['chanID', 'power'])
    Upstream = namedtuple('Upstream', ['chanID', 'power'])
    SNR = namedtuple('SNR', ['chanID', 'snr'])
    ds = []
    dsnr = []
    us = []
    for i in xrange(len(downChannelIDs)):
        l = Downstream(int(downChannelIDs[i]), int(dlevels[i]))
        ds.append(l)
        l = SNR(int(downChannelIDs[i]), int(snr[i]))
        dsnr.append(l)

    for i in xrange(len(upChannelIDs)):
        l = Upstream(int(upChannelIDs[i]), int(ulevels[i]))
        us.append(l)

    #pprint(sorted(ds))
    #pprint(sorted(dsnr))
    #pprint(sorted(us))

    plstr = ''
    snrstr = ''

    commacount = 1
    for i in xrange(len(sorted(ds))):
        #print(',' * (sorted(ds)[i].chanID - commacount), end='')
        #print(sorted(ds)[i].power, end='')
        plstr = plstr + ',' * (sorted(ds)[i].chanID - commacount)
        plstr = plstr + str(sorted(ds)[i].power)
        commacount = sorted(ds)[i].chanID
    for i in xrange(len(sorted(us))):
        #print(',' * (sorted(us)[i].chanID - commacount), end='')
        #print(sorted(us)[i].power, end='')
        plstr = plstr + ',' * (sorted(us)[i].chanID - commacount)
        plstr = plstr + str(sorted(us)[i].power)
        commacount = sorted(us)[i].chanID

    #print(str(time.mktime(time.gmtime())) + ',' + plstr)
    plstr = timestr + ',' + plstr
    plstr = plstr + '\n'

    commacount = 1
    for i in xrange(len(sorted(dsnr))):
        #print(',' * (sorted(dsnr)[i].chanID - commacount), end='')
        #print(sorted(dsnr)[i].snr, end='')
        snrstr = snrstr + ',' * (sorted(dsnr)[i].chanID - commacount)
        snrstr = snrstr + str(sorted(dsnr)[i].snr)
        commacount = sorted(dsnr)[i].chanID

    #print(str(time.mktime(time.gmtime())) + ',' + snrstr)
    #snrstr = str(time.mktime(time.gmtime())) + ',' + snrstr
    snrstr = timestr + ',' + snrstr
    snrstr = snrstr + '\n'

    with open(plfilename, 'a') as levelfile:
        levelfile.write(plstr)
    with open(snrfilename, 'a') as snrfile:
        snrfile.write(snrstr)
