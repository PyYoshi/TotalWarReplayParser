#!/usr/bin/env python
# -*- coding: utf-8 -*-

from twrpy.errors import UnknownReplayFileError


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
    if codec_type == 43978: # abca
        raise UnknownReplayFileError(filename)
        #codec = CaCodec()
    elif codec_type == 43982: # abce
        codec = CeCodec()
    elif codec_type == 43983: # abcf
        codec = CfCodec()
    elif codec_type == 264454: # 0906
        raise UnknownReplayFileError(filename)
        #codec = MeCodec()
    elif codec_type == 263940: # 0704
        raise UnknownReplayFileError(filename)
        #codec = RoCodec()
    else:
        raise UnknownReplayFileError(filename)
    reader.index = 0
    return codec



