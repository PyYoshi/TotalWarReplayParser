#!/usr/bin/env python
# -*- coding: utf-8 -*-

from twrpy.types import TypeCodes

##################################################################

class BaseNode:
    type_code = None
    def __init__(self, reader, codec):
        self.reader = reader
        self.codec = codec
        self.index = 0

    def get_value(self):
        raise NotImplementedError


class BoolNode(BaseNode):
    type_code = TypeCodes.BOOL
    def get_value(self):
        value = self.reader.read_uint8_value()
        if value == TypeCodes.BOOL_TRUE:
            return True
        elif value == TypeCodes.BOOL_FALSE:
            return False
        elif value == 0x00:
            return False
        elif value == 0x01:
            return True
        else:
            raise


class Int8Node(BaseNode):
    type_code = TypeCodes.INT8
    def get_value(self):
        return self.reader.read_int8_value()


class UInt8Node(BaseNode):
    type_code = TypeCodes.UINT8
    def get_value(self):
        return self.reader.read_uint8_value()


class Int16Node(BaseNode):
    type_code = TypeCodes.INT16
    def get_value(self):
        return self.reader.read_int16_value()


class UInt16Node(BaseNode):
    type_code = TypeCodes.UINT16
    def get_value(self):
        return self.reader.read_uint16_value()


class Int32Node(BaseNode):
    type_code = TypeCodes.INT32
    def get_value(self):
        return self.reader.read_int32_value()


class UInt32Node(BaseNode):
    type_code = TypeCodes.UINT32
    def get_value(self):
        return self.reader.read_uint32_value()


class Int64Node(BaseNode):
    type_code = TypeCodes.INT64
    def get_value(self):
        return self.reader.read_int64_value()


class UInt64Node(BaseNode):
    type_code = TypeCodes.UINT64
    def get_value(self):
        return self.reader.read_uint64_value()


class Float32Node(BaseNode):
    type_code = TypeCodes.FLOAT32
    def get_value(self):
        return self.reader.read_float32_value()


class Float64Node(BaseNode):
    type_code = TypeCodes.FLOAT64
    def get_value(self):
        return self.reader.read_fleat64_value()


class Coordinates2DNode(BaseNode):
    type_code = TypeCodes.COORDINATES2D
    def get_value(self):
        value_x = self.reader.read_float32_value()
        value_y = self.reader.read_float32_value()
        return (value_x,value_y)


class Coordinates3DNode(BaseNode):
    type_code = TypeCodes.COORDINATES3D

    def get_value(self):
        value_x = self.reader.read_float32_value()
        value_y = self.reader.read_float32_value()
        value_z = self.reader.read_float32_value()
        return (value_x,value_y,value_z)


class Utf16Node(BaseNode):
    type_code = TypeCodes.UTF16
    def get_value(self):
        if self.codec.CODEC_NAME in ['ABCA', 'ABCF']:
            value_index = self.reader.read_uint32_value()
            return self.codec.FOOTER['ex_values'][value_index]
        else:
            return self.reader.read_ca_unicode_value()


class AsciiNode(BaseNode):
    type_code = TypeCodes.ASCII
    def get_value(self):
        if self.codec.CODEC_NAME in ['ABCA', 'ABCF']:
            value_index = self.reader.read_uint32_value()
            return self.codec.FOOTER['ex_values'][value_index]
        else:
            return self.reader.read_ca_ascii_value()


class AngleNode(BaseNode):
    type_code = TypeCodes.ANGLE
    def get_value(self):
        return self.reader.read_uint16_value()


##################################################################


class BaseArrayNode(BaseNode):
    """
    In ABCD/ABCE/ABCF
        uint8 node-type-code (40..5f)
        uint32 offset of first byte after end of array (this is a weird way of encoding size)
        element 0
        element 1
        ...
    In ABCA
        uint8 node-type-code (40..5f)
        uintvar number of bytes in the array
        element 0
        element 1
        ...
    """
    type_code = None
    def __init__(self,reader,codec):
        self.reader = reader
        self.codec = codec
        self.offset = self.get_offset()
        BaseNode.__init__(self,reader,codec)

    def get_type_code(self):
        return self.reader.read_uint8_value()

    def get_offset(self):
        if self.codec.CODEC_NAME == 'ABCA':
            pass
        else:
            return self.reader.read_uint32_value()

    def get_values(self):
        values = []
        while True:
            if self.reader.index >= self.offset:
                break
            else:
                value = self.get_value()
                values.append(value)
        return values


class BoolArrayNode(BoolNode, BaseArrayNode):
    type_code = TypeCodes.BOOL_ARRAY
    def __init__(self,reader,codec):
        BaseArrayNode.__init__(self,reader,codec)


class Int8ArrayNode(Int8Node, BaseArrayNode):
    type_code = TypeCodes.INT8_ARRAY
    def __init__(self,reader,codec):
        BaseArrayNode.__init__(self,reader,codec)


class UInt8ArrayNode(UInt8Node,BaseArrayNode):
    type_code = TypeCodes.UINT8_ARRAY
    def __init__(self,reader,codec):
        BaseArrayNode.__init__(self,reader,codec)


class Int16ArrayNode(Int16Node,BaseArrayNode):
    type_code = TypeCodes.INT16_ARRAY
    def __init__(self,reader,codec):
        BaseArrayNode.__init__(self,reader,codec)


class UInt16ArrayNode(UInt16Node,BaseArrayNode):
    type_code = TypeCodes.UINT16_ARRAY
    def __init__(self,reader,codec):
        BaseArrayNode.__init__(self,reader,codec)


class Int32ArrayNode(Int32Node,BaseArrayNode):
    type_code = TypeCodes.INT32_ARRAY
    def __init__(self,reader,codec):
        BaseArrayNode.__init__(self,reader,codec)


class UInt32ArrayNode(UInt32Node,BaseArrayNode):
    type_code = TypeCodes.UINT32_ARRAY
    def __init__(self,reader,codec):
        BaseArrayNode.__init__(self,reader,codec)


class Int64ArrayNode(Int64Node,BaseArrayNode):
    type_code = TypeCodes.INT64_ARRAY
    def __init__(self,reader,codec):
        BaseArrayNode.__init__(self,reader,codec)


class UInt64ArrayNode(UInt64Node,BaseArrayNode):
    type_code = TypeCodes.UINT64_ARRAY
    def __init__(self,reader,codec):
        BaseArrayNode.__init__(self,reader,codec)


class Float32ArrayNode(Float32Node,BaseArrayNode):
    type_code = TypeCodes.FLOAT32_ARRAY
    def __init__(self,reader,codec):
        BaseArrayNode.__init__(self,reader,codec)


class Float64ArrayNode(Float64Node,BaseArrayNode):
    type_code = TypeCodes.FLOAT64_ARRAY
    def __init__(self,reader,codec):
        BaseArrayNode.__init__(self,reader,codec)


class Coordinates2DArrayNode(Coordinates2DNode,BaseArrayNode):
    type_code = TypeCodes.COORDINATES2D_ARRAY
    def __init__(self,reader,codec):
        BaseArrayNode.__init__(self,reader,codec)


class Coordinates3DArrayNode(Coordinates3DNode, BaseArrayNode):
    type_code = TypeCodes.COORDINATES3D_ARRAY
    def __init__(self,reader,codec):
        BaseArrayNode.__init__(self,reader,codec)


class Utf16ArrayNode(Utf16Node,BaseArrayNode):
    type_code = TypeCodes.UTF16_ARRAY
    def __init__(self,reader,codec):
        BaseArrayNode.__init__(self,reader,codec)


class AsciiArrayNode(AsciiNode,BaseArrayNode):
    type_code = TypeCodes.ASCII_ARRAY
    def __init__(self,reader,codec):
        BaseArrayNode.__init__(self,reader,codec)


class AngleArrayNode(AngleNode,BaseArrayNode):
    type_code = TypeCodes.ANGLE_ARRAY
    def __init__(self,reader,codec):
        BaseArrayNode.__init__(self,reader,codec)


##################################################################

class RecordNode:
    type_code = TypeCodes.RECODE

    def __init__(self, reader, codec, parser, is_parent=False):
        """
        Record Node Structure:
            uint16 tag name - it's index to table of tags in the footer. index
            uint8 version - version number - starts with 0, updated every time object format changes
            uint32 offset of first byte after end of record
        """
        self.reader = reader
        self.codec = codec
        self.parser = parser
        self.tag_name_index = self.get_tag_name_index()
        self.version = self.get_version()
        self.children = []
        self.values = []
        self.offset = self.get_offset()
        self.nodes = self.get_nodes()

    def get_tag_name_index(self):
        return self.reader.read_uint16_value()

    def get_version(self):
        return self.reader.read_uint8_value()

    def get_read_size(self):
        cvalue = self.reader.read_uint8_value()
        result = 0
        while (cvalue & 0x80) != 0:
            result = (result << 7) * (cvalue & 0x7f)
            cvalue = self.reader.read_uint8_value()
        return (result << 7) + (cvalue & 0x7f)

    def get_offset(self):
        if self.codec.CODEC_NAME in ["ABCE","ABCF"]:
            result = self.reader.read_uint32_value()
        elif self.codec.CODEC_NAME == 'ABCA':
            result = self.get_read_size() + self.reader.index
        else:
            raise
        return result

    def get_nodes(self):
        while True:
            if self.reader.index >= self.offset:
                break
            else:
                cvalue = self.reader.read_uint8_value()
                result = self.parser.decode(self.reader,self.codec,cvalue)
                if cvalue in [TypeCodes.RECODE, TypeCodes.RECODE_ARRAY]:
                    self.children.append(result)
                else:
                    self.values.append(result)


class RecordArrayNode:
    type_code = TypeCodes.RECODE_ARRAY

    def __init__(self,reader,codec, parser):
        """
        uint16 tag name - it's index to table of tags in the footer
        uint8 version - version number
        uint32 offset of first byte after end of array
        uint32 number of elements
        uint32 offset of first byte after end of record #0
        contents of record 0
        uint32 offset of first byte after end of record #1
        contents of record 1
        ...
        """
        self.reader = reader
        self.codec = codec
        self.parser = parser
        self.tag_name_index = self.get_tag_name_index()
        self.version = self.get_version()
        self.offset = self.get_offset()
        self.elements_length = self.get_elements_length()
        self.values = self.get_values()

    def get_tag_name_index(self):
        return self.reader.read_uint16_value()

    def get_version(self):
        return self.reader.read_uint8_value()

    def get_offset(self):
        return self.reader.read_uint32_value()

    def get_elements_length(self):
        return self.reader.read_uint32_value()

    def get_values(self):
        values = []
        while True:
            if self.reader.index >= self.offset:
                break
            else:
                element_offset = self.reader.read_uint32_value()
                child_node = ChildNode()
                while True:
                    if self.reader.index >= element_offset:
                        break
                    else:
                        cvalue = self.reader.read_uint8_value()
                        result = self.parser.decode(self.reader,self.codec,cvalue)

                        if cvalue in [RecordNode,RecordArrayNode]:
                            child_node.children.append(result)
                        else:
                            child_node.values.append(result)
                values.append(child_node)
        return values


class ChildNode:
    def __init__(self):
        self.children = []
        self.values = []

