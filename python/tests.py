#!/usr/bin/env python
# -*- coding: utf-8 -*-

from twrpy.old.codecs import get_codec
from twrpy.old.reader import BinaryReader
from twrpy.old.parser import Parser

#reader = BinaryReader(file('../testdata/empire.replay','rb')) # ceab # http://www.japantotalwar.com/replaydb/profile.cgi?_v=1301919407&tpl=view
#reader = BinaryReader(file('../testdata/medieval.rpy','rb')) # 0609 # http://www.japantotalwar.com/replaydb/profile.cgi?_v=1275669862&tpl=view
#reader = BinaryReader(file('../testdata/napoleon.replay','rb')) # ceab # http://www.japantotalwar.com/replaydb/profile.cgi?_v=1298821338&tpl=view
#reader = BinaryReader(file('../testdata/rome.rpy','rb')) # http://www.japantotalwar.com/replaydb/profile.cgi?_v=1275669862&tpl=view
#reader = BinaryReader(file('../testdata/shogun2.replay','rb')) # cfab # http://www.japantotalwar.com/replaydb/profile.cgi?_v=1329562428&tpl=view
reader = BinaryReader(file('../testdata/shogun2_ex.replay','rb')) # caab # http://www.japantotalwar.com/replaydb/profile.cgi?_v=1341328952&tpl=view

codec = get_codec(reader)
parser = Parser(reader,codec)
nodes = parser.nodes
for tag in parser.footer['tags']:
    print tag
print len(parser.footer['tags'])
for val in parser.footer['ex_values'].items():
    print val
del codec
del parser


#print dumps(nodes)