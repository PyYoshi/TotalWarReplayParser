###

###
class ReplayDataAbcaCodec extends ReplayDataAbcfCodec
  BLOCK_BIT: 0x40
  LONG_INFO: 0x20
  RECORD_BIT: 0x80
  OTHER_RECORD_BIT: 0xa0
  constructor:(reader=null, header=null, footer=null)->
    super(reader, header, footer)
  readSize: ()->
    return @reader.readUintVar()
  readCount: ()->
    return @readSize()
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
    arrayNodeEndOffset = @readSize() + @reader.getPosition()
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
          _w('Int64はJavaScriptでは実装されていない')
          results.push(0)
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
          _w('UInt64はJavaScriptでは実装されていない')
          results.push(0)
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
    arrayNodeEndOffset = @readCount()
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
  readRecordNode: (code)->
    if (@reader.getPosition() == @header.nodesStartOffset+1) || ((code & @LONG_INFO) != 0)
      tagNameIndex = @reader.readUint16()
      version = @reader.readUint8()
    else
      version = (code & 31 >> 1)
      tagNameIndex = (code & 1) << 8
      tagNameIndex += @reader.readUint8()
    tagName = @footer.getTagName(tagNameIndex)
    targetOffset = @readSize() + @reader.getPosition()
    values = {}
    i = 0
    while @reader.getPosition() < targetOffset
      typeCode = @reader.readUint8()
      result = @decodeNode(typeCode)
      if !isArray(result) and isObject(result)
        keys = Object.getOwnPropertyNames(result)
        for key in keys
          values[key] = result[key]
      else
        values[i] = result
        i++
    obj = {}
    obj[tagName] = values
    return obj
  readRecordArrayNode: (code)->
    if (@reader.getPosition() == @header.nodesStartOffset+1) || ((code & @LONG_INFO) != 0)
      tagNameIndex = @reader.readUint16()
      version = @reader.readUint8()
    else
      version = (code & 31 >> 1)
      tagNameIndex = (code & 1) << 8
      tagNameIndex += @reader.readUint8()
    tagName = @footer.getTagName(tagNameIndex)
    size = @readSize()
    itemCount = @readCount()
    values = []
    for i in range(itemCount)
      targetOffset = @readSize() + @reader.getPosition()
      while @reader.getPosition() < targetOffset
        code = @reader.readUint8()
        values.push(@decodeNode(code))
    obj = {}
    obj[tagName] = values
    return obj
  decodeNode: (typeCode)->
    recordBit = (typeCode & @RECORD_BIT)
    if recordBit == 0 || @reader.getPosition() == @header.nodesStartOffset
      if typeCode < ReplayTypeCodes.BOOL_TRUE
        # Value Node
        result = @readValueNode(typeCode)
        #_g(['--VALUE_NODE--',result,'--Position--','0x'+@reader.getPosition().toString(16)],_l)
      else if typeCode < ReplayTypeCodes.BOOL_ARRAY
        # Optimized Value Node
        result = @readOptimizedValueNode(typeCode)
        #_g(['--OPTIMIZED_VALUE_NODE--',result,'--Position--','0x'+@reader.getPosition().toString(16)],_l)
      else if typeCode < ReplayTypeCodes.BOOL_TRUE_ARRAY
        # Array Node
        # TODO: ABCAでのreadArrayNodeの処理がおかしい
        result = @readArrayNode(typeCode)
        #_g(['--ARRAY_NODE--',result,'--Position--','0x'+@reader.getPosition().toString(16)],_l)
      else if typeCode < ReplayTypeCodes.RECORD
        # Optimized Array Node
        result = @readOptimizedArrayNode(typeCode)
        #_g(['--OPTIMIZED_ARRAY_NODE--',result,'--Position--','0x'+@reader.getPosition().toString(16)],_l)
      else if typeCode == ReplayTypeCodes.RECORD or typeCode == @OTHER_RECORD_BIT
        result = @readRecordNode(typeCode)
        #_g(['--RECORD_NODE--',result,'--Position--','0x'+@reader.getPosition().toString(16)], _l)
      else if typeCode == ReplayTypeCodes.RECORD_ARRAY
        result = @readRecordArrayNode(typeCode)
        #_g(['--RECORD_ARRAY_NODE--',result,'--Position--','0x'+@reader.getPosition().toString(16)], _l)
      else
        throw new NotSupportedNodeTypeException('0x'+typeCode.toString(16))
    else
      blockBit = (typeCode & @BLOCK_BIT) != 0
      if blockBit then result = @readRecordArrayNode(typeCode) else result = @readRecordNode(typeCode)
    return result
  parseGameTitle: (gameTitle)->
    result = gameTitle.match(/^Total\sWar\:\s([a-z|A-Z|\d|\s]*)\s\(([a-z|A-Z|\d|\.]*)\)\(.*Build\(([0-9|\*]*)\).*Changelist\(([0-9|\*]*)\)$/)
    return new ReplayDataGameTitle(result[1].replace(' ', ''), result[2], result[3], Number(result[4]))
