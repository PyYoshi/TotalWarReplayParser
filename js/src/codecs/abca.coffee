###

###
class ReplayDataAbcaCodec extends ReplayDataCoreCodec
  constructor:(reader, header)->
    super(reader, header)
  readFooter: ()->
    @reader.setPosition(@header.footerStartOffset)
    # uint16 number of tag types
    tagsLength = @reader.readUint16()
    tags = []
    for i in range(tagsLength)
      tags.push(@reader.readCaAscii())
    exTagsLength = @reader.readUint16()
    skipBlock = @reader.readUint16()
    exTags = {}
    for i in range(exTagsLength)
      value = @reader.readCaUnicode()
      index = @reader.readUint32()
      exTags[index] = value
    return new ReplayDataFooter(tags, exTags)
  readValueNode: (typeCode)->
    switch typeCode
      when ReplayTypeCodes.BOOL
        result = @reader.readUint8()
        switch result
          when ReplayTypeCodes.BOOL_TRUE
            return true
          when ReplayTypeCodes.BOOL_FALSE
            return false
          when 0x00
            return false
          when 0x01
            return true
          else
            throw new NotSupportedNodeTypeException('0x'+result.toString(16))
      when ReplayTypeCodes.INT8
        return @reader.readInt8()
      when ReplayTypeCodes.INT16
        return @reader.readInt16()
      when ReplayTypeCodes.INT32
        return @reader.readInt32()
      when ReplayTypeCodes.INT64
      # FIXME: Int64はJavaScriptでは実装されていない
        @reader.setPosition(@reader.getPosition()+8)
        return null
      when ReplayTypeCodes.UINT8
        return @reader.readUint8()
      when ReplayTypeCodes.UINT16
        return @reader.readUint16()
      when ReplayTypeCodes.UINT32
        return @reader.readUint32()
      when ReplayTypeCodes.UINT64
      # FIXME: UInt64はJavaScriptでは実装されていない
        @reader.setPosition(@reader.getPosition()+8)
        return null
      when ReplayTypeCodes.FLOAT32
        return @reader.readFloat32()
      when ReplayTypeCodes.FLOAT64
        return @reader.readFloat64()
      when ReplayTypeCodes.COORDINATES2D
        return [@reader.readFloat32(), @reader.readFloat32()]
      when ReplayTypeCodes.COORDINATES3D
        return [@reader.readFloat32(), @reader.readFloat32(), @reader.readFloat32()]
      when ReplayTypeCodes.UTF16
        valueIndex = @reader.readUint32()
        return @footer.getExTagName(valueIndex)
      when ReplayTypeCodes.ASCII
        valueIndex = @reader.readUint32()
        return @footer.getExTagName(valueIndex)
      when ReplayTypeCodes.ANGLE
        return @reader.readUint16()
      when ReplayTypeCodes.INVALID
        return null
      else
        throw new NotSupportedNodeTypeException('0x'+typeCode.toString(16))
  readOptimizedValueNode: (typeCode)->
    switch typeCode
      when ReplayTypeCodes.BOOL_TRUE
        return true
      when ReplayTypeCodes.BOOL_FALSE
        return false
      when ReplayTypeCodes.INT32_ZERO
        return 0
      when ReplayTypeCodes.INT32_BYTE
        return @reader.readInt8()
      when ReplayTypeCodes.INT32_SHORT
        return @reader.readInt16()
      when ReplayTypeCodes.INT32_24BIT
        return @reader.readInt24()
      when ReplayTypeCodes.UINT32_ZERO
        return 0
      when ReplayTypeCodes.UINT32_BYTE
        return @reader.readUint8()
      when ReplayTypeCodes.UINT32_SHORT
        return @reader.readUint16()
      when ReplayTypeCodes.UINT32_24BIT
        return @reader.readUint24()
      when ReplayTypeCodes.UINT32_ONE
        return 1
      when ReplayTypeCodes.FLOAT32_ZERO
        return 0.0
      else
        throw new NotSupportedNodeTypeException('0x'+typeCode.toString(16))

  readArrayNode: (typeCode)->
    arrayNodeEndOffset = @reader.readUintVar()
    results = []
    switch typeCode
      when ReplayTypeCodes.BOOL_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          result = @reader.readUint8()
          switch result
            when ReplayTypeCodes.BOOL_TRUE
              results.push(true)
            when ReplayTypeCodes.BOOL_FALSE
              results.push(false)
            when 0x00
              results.push(false)
            when 0x01
              results.push(true)
            else
              throw new NotSupportedNodeTypeException('0x'+result.toString(16))
        return results
      when ReplayTypeCodes.INT8_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          results.push(@reader.readInt8())
        return results
      when ReplayTypeCodes.INT16_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          results.push(@reader.readInt16())
        return results
      when ReplayTypeCodes.INT32_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          results.push(@reader.readInt32())
        return results
      when ReplayTypeCodes.INT64_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          # FIXME: Int64はJavaScriptでは実装されていない
          @reader.setPosition(@reader.getPosition()+8)
          results.push(null)
        return results
      when ReplayTypeCodes.UINT8_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          results.push(@reader.readUint8())
        return results
      when ReplayTypeCodes.UINT16_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          results.push(@reader.readUint16())
        return results
      when ReplayTypeCodes.UINT32_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          results.push(@reader.readUint32())
        return results
      when ReplayTypeCodes.UINT64_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          # FIXME: UInt64はJavaScriptでは実装されていない
          @reader.setPosition(@reader.getPosition()+8)
          results.push(null)
        return results
      when ReplayTypeCodes.FLOAT32_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          results.push(@reader.readFloat32())
        return results
      when ReplayTypeCodes.FLOAT64_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          results.push(@reader.readFloat64())
        return results
      when ReplayTypeCodes.COORDINATES2D_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          results.push([@reader.readFloat32(),@reader.readFloat32()])
        return results
      when ReplayTypeCodes.COORDINATES3D_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          results.push([@reader.readFloat32(), @reader.readFloat32(), @reader.readFloat32()])
        return results
      when ReplayTypeCodes.UTF16_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          valueIndex = @reader.readUint32()
          results.push(@footer.getExTagName(valueIndex))
        return results
      when ReplayTypeCodes.ASCII_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          valueIndex = @reader.readUint32()
          results.push(@footer.getExTagName(valueIndex))
        return results
      when ReplayTypeCodes.ANGLE_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          results.push(@reader.readUint16())
        return results
      else
        throw new NotSupportedNodeTypeException('0x'+typeCode.toString(16))
  readOptimizedArrayNode: (typeCode)->
    results = []
    switch typeCode
      when ReplayTypeCodes.INT32_BYTE_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          results.push(@reader.readInt8())
        return results
      when ReplayTypeCodes.INT32_SHORT_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          results.push(@reader.readInt16())
        return results
      when ReplayTypeCodes.INT32_24BIT_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          results.push(@reader.readInt24())
        return results
      when ReplayTypeCodes.UINT32_BYTE_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          results.push(@reader.readUint8())
        return results
      when ReplayTypeCodes.UINT32_SHORT_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          results.push(@reader.readUint16())
        return results
      when ReplayTypeCodes.UINT32_24BIT_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          results.push(@reader.readUint24())
        return results
      else
        throw new NotSupportedNodeTypeException('0x'+typeCode.toString(16))
  readRecordNode: ()->
    first = @reader.getPosition()-1 == @header.nodesStartOffset
    if first
      tagNameIndex = @reader.readUint16()
    else
      tagNameIndex = @reader.readUint8()
    tagName = @footer.getTagName(tagNameIndex)
    _g(['--TAG_INDEX--',tagNameIndex,'--TAG_NAME--',tagName,'--Position--','0x'+@reader.getPosition().toString(16)])
    # uint8 version - version number - starts with 0, updated every time object format changes
    if first
      version = @reader.readUint8()
    else
      version = (ReplayTypeCodes.RECORD & 31) >> 1
    # uintvar size of data within record in bytes
    nodeEndOffset = @reader.readUintVar()
    values = {}
    i=0
    # noinspection CoffeeScriptInfiniteLoop
    while true
      if @reader.getPosition() >= nodeEndOffset then break
      code = @reader.readUint8()
      result = @decodeNode(code)
      if isObject(result)
        keys = Object.getOwnPropertyNames(result)
        for key in keys
          values[key] = result[key]
      else
        values[i] = result
        i++
    obj = {}
    obj[tagName] = values
    return obj
  readRecordArrayNode: ()->
    # uint16 tag name - it's index to table of tags in the footer
    tagNameIndex = @reader.readUint16()
    tagName = @footer.getTagName(tagNameIndex)
    # uint8 version - version number
    version = @reader.readUint8()
    # uint32 offset of first byte after end of array
    nodeEndOffset = @reader.readUintVar()
    # uint32 number of elements
    elementLength = @reader.readUintVar()
    values = []
    # noinspection CoffeeScriptInfiniteLoop
    while true
      if @reader.getPosition() >= nodeEndOffset then break
      elementEndOffset = @reader.readUintVar()
      # noinspection CoffeeScriptInfiniteLoop
      while true
        if @reader.getPosition() >= elementEndOffset then break
        code = @reader.readUint8()
        values.push(@decodeNode(code))
    obj = {}
    obj[tagName] = values
    return obj

  ###

  ###
  decodeNode: (typeCode)->
    ReplayDataReader.checkReaderType(@reader, 'decodeNode()')
    if isNumber(typeCode) == false then throw new TypeError('This typeCode is not Number')
    recordBit = typeCode & ReplayTypeCodes.RECORD
    #if recordBit == 0 || @reader.getPosition()-1 == @header.nodesStartOffset

    if typeCode < ReplayTypeCodes.BOOL_TRUE
      v = @readValueNode(typeCode)
      _g(['--VALUE_NODE--',v,'--Position--','0x'+@reader.getPosition().toString(16)],_l)
    else if typeCode < ReplayTypeCodes.BOOL_ARRAY
      v = @readOptimizedValueNode(typeCode)
      _g(['--OPTIMIZED_VALUE_NODE--',v,'--Position--','0x'+@reader.getPosition().toString(16)],_l)
    else if typeCode < ReplayTypeCodes.BOOL_TRUE_ARRAY
      v = @readArrayNode(typeCode)
      _g(['--ARRAY_NODE--',v,'--Position--','0x'+@reader.getPosition().toString(16)],_l)
    else if typeCode < ReplayTypeCodes.RECORD
      v = @readOptimizedArrayNode(typeCode)
      _g(['--OPTIMIZED_ARRAY_NODE--',v,'--Position--','0x'+@reader.getPosition().toString(16)],_l)
    else if typeCode == ReplayTypeCodes.RECORD
      v = @readRecordNode()
      _g(['--RECORD_NODE--',v,'--Position--','0x'+@reader.getPosition().toString(16)], _l)
    else if typeCode == ReplayTypeCodes.RECORD_ARRAY
      v = @readRecordArrayNode()
      _g(['--RECORD_ARRAY_NODE--',v,'--Position--','0x'+@reader.getPosition().toString(16)], _l)
    else
      throw new NotSupportedNodeTypeException('0x'+typeCode.toString(16))
    return v
  parseGameTitle: (gameTitle)->
    result = gameTitle.match(/^([a-z|A-Z|\d]*)\:TotalWar\(([0-9|\.]*)\)\(.*Build\(([0-9]*)\).*\)\sChangelist\(([0-9]*)\)$/)
    return new ReplayDataGameTitle(result[1], result[2], Number(result[3]), Number(result[4]))
  parse: ()->
    return