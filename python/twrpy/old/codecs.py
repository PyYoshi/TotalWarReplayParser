#!/usr/bin/env python
# -*- coding: utf-8 -*-

from twrpy.old.errors import UnknownReplayFileError


class BaseCodec:
    # http://t-a-w.blogspot.jp/2012/03/esf-empire-total-war-object.html

    BLOCK_BIT = hex(0)
    CODEC_NAME = 'BASE'
    HEADER = None
    FOOTER = None

    def __init__(self,):
        pass


class CaCodec(BaseCodec):
    CODEC_NAME = 'ABCA'
    pass


class CeCodec(BaseCodec):
    CODEC_NAME = 'ABCE'
    pass


class CfCodec(BaseCodec):
    CODEC_NAME = 'ABCF'
    pass


class MeCodec(BaseCodec):
    pass


class RoCodec(BaseCodec):
    pass


def get_codec(reader):
    reader.index = 0
    codec_type = reader.read('uint32', next=True)
    filename = reader.filename
    if codec_type == 0xabca: # abca
        #raise UnknownReplayFileError(filename)
        codec = CaCodec()
    elif codec_type == 0xabce: # abce
        codec = CeCodec()
    elif codec_type == 0xabcf: # abcf
        codec = CfCodec()
    elif codec_type == 0x0906: # 0906
        raise UnknownReplayFileError(filename)
        #codec = MeCodec()
    elif codec_type == 0x0704: # 0704
        raise UnknownReplayFileError(filename)
        #codec = RoCodec()
    else:
        raise UnknownReplayFileError(filename)
    reader.index = 0
    return codec



