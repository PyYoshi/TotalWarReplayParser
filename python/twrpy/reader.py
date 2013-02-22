#!/usr/bin/env python
# -*- coding: utf-8 -*-

import struct

class BinaryReader:
    # http://www.python.jp/doc/2.7/library/struct.html

    _TYPES = {
        'int8' : struct.Struct('<b'),
        'uint8' : struct.Struct('<B'),
        'int16' : struct.Struct('<h'),
        'uint16' : struct.Struct('<H'),
        'int32' : struct.Struct('<i'),
        'uint32' : struct.Struct('<I'),
        'int64' : struct.Struct('<q'),
        'uint64' : struct.Struct('<Q'),
        'float' : struct.Struct('<f'),
        'float32' : struct.Struct('<f'),
        'single' : struct.Struct('<f'),
        'float64' : struct.Struct('<d'),
        'double' : struct.Struct('<d'),
        'char8' : struct.Struct('<c'),
        'char16' : struct.Struct('<s'),
        'pad' : struct.Struct('<x'),
        'bool' : struct.Struct('<?'),
        }

    _FORMATS = {
        'int8' : 'b',
        'uint8' : 'B',
        'int16' : 'h',
        'uint16' : 'H',
        'int32' : 'i',
        'uint32' : 'I',
        'int64' : 'q',
        'uint64' : 'Q',
        'float' : 'f',
        'float32' : 'f',
        'single' : 'f',
        'float64' : 'd',
        'double' : 'd',
        'char8' : 'c',
        'char16' : 's',
        'pad' : 'x',
        'bool' : '?',
        }

    def __init__(self, fp):
        self.stream = fp.read()
        self.index = 0
        self.size = len(self.stream)

    def read(self,type, next=False):
        t = self._TYPES[type]
        value = t.unpack_from(self.stream,self.index)[0]
        self.index += t.size
        if next:
            self.next(t.size)
        return value

    def reads(self,type, next=False):
        # return multiple-values
        t = self._TYPES[type]
        values = t.unpack_from(self.stream,self.index)
        self.index += t.size
        if next:
            self.next(t.size)
        return values

    def next(self, count):
        return self.stream[self.index:self.index+count]

    def read_bool_value(self):
        t = self._TYPES['bool']
        value = t.unpack_from(self.stream,self.index)[0]
        self.index += t.size
        self.next(t.size)
        return value

    def read_int8_value(self):
        t = self._TYPES['int8']
        value = t.unpack_from(self.stream, self.index)[0]
        self.index += t.size
        self.next(t.size)
        return value

    def read_int16_value(self):
        t = self._TYPES['int16']
        value = t.unpack_from(self.stream,self.index)[0]
        self.index += t.size
        self.next(t.size)
        return value

    def read_int32_value(self):
        t = self._TYPES['int32']
        value = t.unpack_from(self.stream,self.index)[0]
        self.index += t.size
        self.next(t.size)
        return value

    def read_int64_value(self):
        t = self._TYPES['int64']
        value = t.unpack_from(self.stream,self.index)[0]
        self.index += t.size
        self.next(t.size)
        return value

    def read_uint8_value(self):
        t = self._TYPES['uint8']
        value = t.unpack_from(self.stream,self.index)[0]
        self.index += t.size
        self.next(t.size)
        return value

    def read_uint16_value(self):
        t = self._TYPES['uint16']
        value = t.unpack_from(self.stream,self.index)[0]
        self.index += t.size
        self.next(t.size)
        return value

    def read_uint32_value(self):
        t = self._TYPES['uint32']
        value = t.unpack_from(self.stream,self.index)[0]
        self.index += t.size
        self.next(t.size)
        return value

    def read_uint64_value(self):
        t = self._TYPES['uint64']
        value = t.unpack_from(self.stream,self.index)[0]
        self.index += t.size
        self.next(t.size)
        return value

    def read_float32_value(self):
        t = self._TYPES['float32']
        value = t.unpack_from(self.stream,self.index)[0]
        self.index += t.size
        self.next(t.size)
        return value

    def read_float64_value(self):
        t = self._TYPES['float64']
        value = t.unpack_from(self.stream,self.index)[0]
        self.index += t.size
        self.next(t.size)
        return value

    def read_char8_value(self):
        t = self._TYPES['char8']
        value = t.unpack_from(self.stream,self.index)[0]
        self.index += t.size
        self.next(t.size)
        return value

    def read_char16_value(self):
        t = self._TYPES['char16']
        value = t.unpack_from(self.stream,self.index)[0]
        self.index += t.size
        self.next(t.size)
        return value

    def read_pad_value(self):
        t = self._TYPES['pad']
        value = t.unpack_from(self.stream,self.index)[0]
        self.index += t.size
        self.next(t.size)
        return value

    def read_ca_unicode_value(self):
        """
        uint16 count
        char16[count] codepoints
        """
        t = self._TYPES['uint16']
        string_length = t.unpack_from(self.stream,self.index)[0]
        self.index += t.size
        self.next(t.size)
        value = unicode()
        for i in range(string_length):
            value += unichr(self.read_uint16_value())
        return value

    def read_ca_ascii_value(self):
        """
        uint16 count
        char8[count] characters
        """
        t = self._TYPES['uint16']
        string_length = t.unpack_from(self.stream,self.index)[0]
        self.index += t.size
        self.next(t.size)
        value = ''
        for i in range(string_length):
            value += self.read_char8_value()
        return value

    def read_int24_value(self):
        """
        uintvar is a variable length encoding for unsigned integers
        int24be
        max 5bytes
        """
        value = self.read_int8_value()
        sigh = (value & 0x80) != 0
        value = value & 0x7f
        for i in range(2):
            value = (value << 8) + self.read_int8_value()
        if sigh:
            value = (-1 * value)
        return value

    def read_uint24_value(self):
        value = 0
        for i in range(2):
            value = (value << 8) + self.read_int8_value()
        return

