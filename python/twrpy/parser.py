#!/usr/bin/env python
# -*- coding: utf-8 -*-

import datetime

from twrpy.types import TypeCodes
from twrpy.nodes import BaseNode, RecordNode, BoolNode, Int8Node, Int16Node, Int32Node, Int64Node,\
    UInt8Node, UInt16Node, UInt32Node, UInt64Node, Float32Node, Float64Node,\
    Coordinates2DNode, Coordinates3DNode, Utf16Node, AsciiNode, AngleNode,\
    BaseArrayNode, RecordArrayNode, BoolArrayNode, Int8ArrayNode, Int16ArrayNode, Int32ArrayNode, Int64ArrayNode,\
    UInt8ArrayNode, UInt16ArrayNode, UInt32ArrayNode, UInt64ArrayNode, Float32ArrayNode, Float64ArrayNode,\
    Coordinates2DArrayNode, Coordinates3DArrayNode, Utf16ArrayNode, AsciiArrayNode, AngleArrayNode

class Parser:
    def __init__(self, reader,codec):
        self.reader = reader
        self.codec = codec
        self.header = self.get_header(self.reader)
        self.footer = self.get_footer(self.reader,self.header)
        self.codec.HEADER = self.header
        self.codec.FOOTER = self.footer
        self.nodes = self.get_nodes()

    @classmethod
    def get_header(cls,reader):
        """
        Header
            uint32 - magic number (0xABCD, 0xABCE, 0xABCF, 0xABCA)
            uint32 - 4 bytes, always zeros - not present in ABCD format
            uint32 - 4 bytes, look like Unix timestamp - not present in ABCD format
            uint32 - offset where footer starts
        """
        reader.index = 0
        # get magic_number
        magic_number = reader.read_uint32_value()

        if magic_number in [43978,43982,43983]:
            # get zero_padding
            zero_padding = reader.read_uint32_value()

            # get timestamp
            timestamp = reader.read_uint32_value()

            nodes_size = reader.read_uint32_value()

            header = {
                'magic_number': magic_number,
                'datetime': datetime.datetime.fromtimestamp(timestamp),
                'header_index': (0,reader.index-1), # (start,end)
                'nodes_index': (reader.index, nodes_size-1), # (start,end)
            }
        else:
            # get zero_padding
            zero_padding = reader.read_uint32_value()

            # get timestamp
            invalid_timestamp = reader.read_uint32_value()

            nodes_size = reader.read_uint32_value()

            header = {
                'magic_number': magic_number,
                'datetime': None,
                'header_index': (0,reader.index-1),
                'nodes_index': (reader.index, nodes_size-1),
                }
        reader.index = 0
        return header

    @classmethod
    def get_footer(cls,reader,header):
        """
        Footer:
            uint16 number of tag types
            ca_ascii name of tag 0
            ca_ascii name of tag 1
            ...
            if ABCA, ABCF:
                uint16 size of Unicode string lookup table
                uint16 make no sense
                ca_unicode string A
                uint32 index of string A
                ...

        """
        reader.index = header['nodes_index'][1] + 1
        tags_length = reader.read_uint16_value()
        tags = []
        for i in range(tags_length):
            if reader.index >= reader.size:
                break
            else:
                tags.append(reader.read_ca_ascii_value())
        footer = {
            'tags':tags
        }
        if header['magic_number'] in [43978,43983]: # abca, abcf
            ustring_size = reader.read_uint16_value()
            invalid = reader.read_uint16_value() # skip 4bytes
            ex_values = {}
            for i in range(ustring_size):
                ex_values[reader.read_uint32_value()] = reader.read_ca_unicode_value()
            footer['ex_values'] = ex_values

        reader.index = 0
        return footer

    def get_tag_name(self,index):
        return self.footer['tags'][index]

    @classmethod
    def decode(cls,reader,codec,type_code):
        if type_code < TypeCodes.BOOL_ARRAY:
            result = cls.read_value_node(reader,codec,type_code)
        elif type_code < TypeCodes.RECODE:
            result = cls.read_array_node(reader,codec,type_code)
        elif type_code == TypeCodes.RECODE:
            result = cls.read_recode_node(reader,codec,)
        elif type_code == TypeCodes.RECODE_ARRAY:
            result = cls.read_recode_array_node(reader,codec,)
        else:
            raise Exception('TypeCode: %s \tIndex: %s' % (hex(type_code),hex(reader.index-1)))

        return result

    @classmethod
    def read_value_node(cls,reader,codec,code):
        if code == TypeCodes.BOOL:
            return BoolNode(reader, codec).get_value()
        elif code == TypeCodes.INT8:
            return Int8Node(reader, codec).get_value()
        elif code == TypeCodes.INT16:
            return Int16Node(reader, codec).get_value()
        elif code == TypeCodes.INT32:
            return Int32Node(reader, codec).get_value()
        elif code == TypeCodes.INT64:
            return Int64Node(reader, codec).get_value()
        elif code == TypeCodes.UINT8:
            return UInt8Node(reader, codec).get_value()
        elif code == TypeCodes.UINT16:
            return UInt16Node(reader, codec).get_value()
        elif code == TypeCodes.UINT32:
            return UInt32Node(reader, codec).get_value()
        elif code == TypeCodes.UINT64:
            return UInt64Node(reader, codec).get_value()
        elif code == TypeCodes.FLOAT32:
            return Float32Node(reader, codec).get_value()
        elif code == TypeCodes.FLOAT64:
            return Float64Node(reader, codec).get_value()
        elif code == TypeCodes.COORDINATES2D:
            return Coordinates2DNode(reader, codec).get_value()
        elif code == TypeCodes.COORDINATES3D:
            return Coordinates3DNode(reader, codec).get_value()
        elif code == TypeCodes.UTF16:
            return Utf16Node(reader, codec).get_value()
        elif code == TypeCodes.ASCII:
            return AsciiNode(reader, codec).get_value()
        elif code == TypeCodes.ANGLE:
            return AngleNode(reader, codec).get_value()
        elif code == TypeCodes.INVALID:
            return BaseNode
        else:
            raise

    @classmethod
    def read_array_node(cls,reader,codec,code):
        if code == TypeCodes.BOOL_ARRAY:
            return BoolArrayNode(reader, codec).get_values()
        elif code == TypeCodes.INT8_ARRAY:
            return Int8ArrayNode(reader, codec).get_values()
        elif code == TypeCodes.INT16_ARRAY:
            return Int16ArrayNode(reader, codec).get_values()
        elif code == TypeCodes.INT32_ARRAY:
            return Int32ArrayNode(reader, codec).get_values()
        elif code == TypeCodes.INT64_ARRAY:
            return Int64ArrayNode(reader, codec).get_values()
        elif code == TypeCodes.UINT8_ARRAY:
            return UInt8ArrayNode(reader, codec).get_values()
        elif code == TypeCodes.UINT16_ARRAY:
            return UInt16ArrayNode(reader, codec).get_values()
        elif code == TypeCodes.UINT32_ARRAY:
            return UInt32ArrayNode(reader, codec).get_values()
        elif code == TypeCodes.UINT64_ARRAY:
            return UInt64ArrayNode(reader, codec).get_values()
        elif code == TypeCodes.FLOAT32_ARRAY:
            return Float32ArrayNode(reader, codec).get_values()
        elif code == TypeCodes.FLOAT64_ARRAY:
            return Float64ArrayNode(reader, codec).get_values()
        elif code == TypeCodes.COORDINATES2D_ARRAY:
            return Coordinates2DArrayNode(reader, codec).get_values()
        elif code == TypeCodes.COORDINATES3D_ARRAY:
            return Coordinates3DArrayNode(reader, codec).get_values()
        elif code == TypeCodes.UTF16_ARRAY:
            return Utf16ArrayNode(reader, codec).get_values()
        elif code == TypeCodes.ASCII_ARRAY:
            return AsciiArrayNode(reader, codec).get_values()
        elif code == TypeCodes.ANGLE_ARRAY:
            return AngleArrayNode(reader, codec).get_values()
        else:
            raise

    @classmethod
    def read_recode_node(cls,reader,codec,):
        return RecordNode(reader, codec,cls)

    @classmethod
    def read_recode_array_node(cls,reader,codec):
        return RecordArrayNode(reader,codec,cls)

    def get_nodes(self):
        nodes_index = self.header['nodes_index']
        self.reader.index = nodes_index[0]
        nodes = []
        while True:
            if self.reader.index >= nodes_index[1]:
                break
            else:
                cvalue = self.reader.read_uint8_value()
                result = self.decode(self.reader,self.codec,cvalue)
                nodes.append(result)
        return nodes

    def parse(self,model=None):
        pass



