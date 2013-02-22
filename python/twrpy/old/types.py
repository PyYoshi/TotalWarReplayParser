#!/usr/bin/env python
# -*- coding: utf-8 -*-


class TypeCodes:
    # http://t-a-w.blogspot.jp/2012/03/esf-empire-total-war-object.html

    INVALID = 0x00

    # Value 1:16(Decimal number)
    BOOL = 0x01
    INT8 = 0x02
    INT16 = 0x03
    INT32 = 0x04
    INT64 = 0x05
    UINT8 = 0x06
    UINT16 = 0x07
    UINT32 = 0x08
    UINT64 = 0x09
    FLOAT32 = 0x0a
    FLOAT64 = 0x0b
    COORDINATES2D = 0x0c
    COORDINATES3D = 0x0d
    UTF16 = 0x0e # ca_unicode
    ASCII = 0x0f # ca_ascii
    ANGLE = 0x10

    # Array 65:80(Decimal number)
    BOOL_ARRAY = 0x41
    INT8_ARRAY = 0x42
    INT16_ARRAY = 0x43
    INT32_ARRAY = 0x44
    INT64_ARRAY = 0x45
    UINT8_ARRAY = 0x46
    UINT16_ARRAY = 0x47
    UINT32_ARRAY = 0x48
    UINT64_ARRAY = 0x49
    FLOAT32_ARRAY = 0x4a
    FLOAT64_ARRAY = 0x4b
    COORDINATES2D_ARRAY = 0x4c
    COORDINATES3D_ARRAY = 0x4d
    UTF16_ARRAY = 0x4e # ca_unicode
    ASCII_ARRAY = 0x4f # ca_ascii
    ANGLE_ARRAY = 0x50

    # Value 18:29(Decimal number)
    BOOL_TRUE = 0x12
    BOOL_FALSE = 0x13
    UINT32_ZERO = 0x14
    UINT32_ONE = 0x15
    UINT32_BYTE = 0x16
    UINT32_SHORT = 0x17
    UINT32_24BIT = 0x18
    INT32_ZERO = 0x19
    INT32_BYTE = 0x1a
    INT32_SHORT = 0x1b
    INT32_24BIT = 0x1c
    FLOAT32_ZERO = 0x1d

    #  128:129(Decimal number)
    RECODE = 0x80
    RECODE_ARRAY = 0x81

    # 82:93(Decimal number)
    BOOL_TRUE_ARRAY = 0x52 # makes no sense
    BOOL_FALSE_ARRAY = 0x53 # makes no sense
    UINT_ZERO_ARRAY = 0x54 # makes no sense
    UINT_ONE_ARRAY = 0x55 # makes no sense
    UINT32_BYTE_ARRAY = 0x56
    UINT32_SHORT_ARRAY = 0x57
    UINT32_24BIT_ARRAY = 0x58
    INT32_ZERO_ARRAY = 0x59 # makes no sense
    INT32_BYTE_ARRAY = 0x5a
    INT32_SHORT_ARRAY = 0x5b
    INT32_24BIT_ARRAY = 0x5c
    FLOAT32_ZERO_ARRAY = 0x5d # makes no sense