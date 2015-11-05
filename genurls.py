#!/usr/bin/env python
from __future__ import print_function
from __future__ import division
import re
import urllib2
import urlparse
from bs4 import BeautifulSoup
from pprint import pprint

locations = set(['CA', 'MX', 'US'])
protos = set(['http', 'ftp'])
protosre = '|'.join(['^' + i + '://' for i in protos])
links = set()
paths = ['releases/23/Workstation/i386/iso/Fedora-Workstation-netinst-i386-23.iso',
      'releases/23/Workstation/i386/iso/Fedora-Live-Workstation-i686-23-10.iso',
      'releases/23/Workstation/x86_64/iso/Fedora-Live-Workstation-x86_64-23-10.iso',
      'releases/23/Workstation/x86_64/iso/Fedora-Workstation-netinst-x86_64-23.iso']
url = 'https://admin.fedoraproject.org/mirrormanager/mirrors/Fedora/23'
req = urllib2.Request(url)
u = urllib2.urlopen(req)
soup = BeautifulSoup(u, 'html.parser')

for trs in soup.find_all('tr'):
    #print(trs.td.text)
    if trs.td.text not in locations and len(locations) > 0:
        continue
    for link in trs.find_all('a'):
        if not re.search('epel', link.get('href')):
            if link.text in protos:
                if re.search(protosre, link.get('href')):
                    for path in paths:
                        links.add(urlparse.urljoin(link.get('href') + '/', path))

shell = ['#!/usr/bin/bash']
wget = '''echo "%s"
wget -O /dev/null '%s'\n'''
for link in links:
    shell.append(wget % (link, link))
print('\n'.join(shell))
