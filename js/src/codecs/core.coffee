###

###
class ReplayDataCoreCodec
  reader: null
  header: null
  footer: null
  nodes: null
  constructor:(reader=null, header=null, footer=null)->
    ReplayDataReader.checkReaderType(reader, 'constructor')
    @reader = reader
    if header != null
      ReplayDataHeader.checkHeaderType(header)
      @header = header
    else
      @header = ReplayDataCoreCodec.readHeader(@reader)
    if footer != null
      ReplayDataFooter.checkFooterType(footer)
      @footer = footer
    else
      @footer = @readFooter()
  ###
    ReplayFileのヘッダーを取得する関数。
    @return {ReplayDataHeader}
  ###
  @readHeader: (reader=null)->
    ReplayDataReader.checkReaderType(reader)
    if reader.getPosition() != 0 then reader.setPosition(0)
    format = reader.readUint32()
    if format not in [ReplayDataFormats.ABCE, ReplayDataFormats.ABCF, ReplayDataFormats.ABCA] then throw new NotSupportedFileException()
    skipBlock = reader.readUint32()
    timestamp = new Date()
    timestamp.setTime(reader.readUint32()*1000)
    footerStartOffset = reader.readUint32()
    return new ReplayDataHeader(format, timestamp, reader.getPosition(), footerStartOffset)
  ###

  ###
  readFooter: ()->
    throw new NotImplementedException(ReplayDataCoreCodec.name + '.readFooter()')
    return
  ###

  ###
  readCount: ()->
    return @reader.readUint32()
  ###

  ###
  readSize: ()->
    return @readCount() - @reader.getPosition()
  ###

  ###
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
        _w('Int64はJavaScriptでは実装されていない')
        return 0
      when ReplayTypeCodes.UINT8
        return @reader.readUint8()
      when ReplayTypeCodes.UINT16
        return @reader.readUint16()
      when ReplayTypeCodes.UINT32
        return @reader.readUint32()
      when ReplayTypeCodes.UINT64
      # FIXME: UInt64はJavaScriptでは実装されていない
        @reader.setPosition(@reader.getPosition()+8)
        _w('UInt64はJavaScriptでは実装されていない')
        return 0
      when ReplayTypeCodes.FLOAT32
        return @reader.readFloat32()
      when ReplayTypeCodes.FLOAT64
        return @reader.readFloat64()
      when ReplayTypeCodes.COORDINATES2D
        return [@reader.readFloat32(), @reader.readFloat32()]
      when ReplayTypeCodes.COORDINATES3D
        return [@reader.readFloat32(), @reader.readFloat32(), @reader.readFloat32()]
      when ReplayTypeCodes.UTF16
        return @reader.readCaUnicode()
      when ReplayTypeCodes.ASCII
        return @reader.readCaAscii()
      when ReplayTypeCodes.ANGLE
        return @reader.readUint16()
      when ReplayTypeCodes.INVALID
        return null
      else
        throw new NotSupportedNodeTypeException('0x'+typeCode.toString(16))
  ###

  ###
  readArrayNode: (typeCode)->
    arrayNodeEndOffset = @readCount()
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
          results.push(@reader.readCaUnicode())
        return results
      when ReplayTypeCodes.ASCII_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          results.push(@reader.readCaAscii())
        return results
      when ReplayTypeCodes.ANGLE_ARRAY
        while true
          if @reader.getPosition() >= arrayNodeEndOffset then break
          results.push(@reader.readUint16())
        return results
      else
        throw new NotSupportedNodeTypeException('0x'+typeCode.toString(16))
  ###

  ###
  readRecordNode: (typeCode)->
    tagNameIndex = @reader.readUint16()
    tagName = @footer.getTagName(tagNameIndex)
    version = @reader.readUint8()
    targetOffset = @readSize() + @reader.getPosition()
    values = {}
    i = 0
    # noinspection CoffeeScriptInfiniteLoop
    while @reader.getPosition() < targetOffset
      code = @reader.readUint8()
      result = @decodeNode(code)
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

  ###

  ###
  readRecordArrayNode: (typeCode)->
    tagNameIndex = @reader.readUint16()
    tagName = @footer.getTagName(tagNameIndex)
    version = @reader.readUint8()
    nodeEndOffset = @readSize()
    elementLength = @readCount()
    values = []
    # noinspection CoffeeScriptInfiniteLoop
    for i in range(elementLength)
      elementEndOffset = @reader.readUint32()
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
    if typeCode < ReplayTypeCodes.BOOL_ARRAY
      v = @readValueNode(typeCode)
      #_g(['--VALUE_NODE--',v,'--Position--','0x'+@reader.getPosition().toString(16)],_l)
    else if typeCode < ReplayTypeCodes.RECORD
      v = @readArrayNode(typeCode)
      #_g(['--ARRAY_NODE--',v,'--Position--','0x'+@reader.getPosition().toString(16)],_l)
    else if typeCode == ReplayTypeCodes.RECORD
      v = @readRecordNode(typeCode)
      #_g(['--RECORD_NODE--',v,'--Position--','0x'+@reader.getPosition().toString(16)], _l)
    else if typeCode == ReplayTypeCodes.RECORD_ARRAY
      v = @readRecordArrayNode(typeCode)
      #_g(['--RECORD_ARRAY_NODE--',v,'--Position--','0x'+@reader.getPosition().toString(16)], _l)
    else
      throw new NotSupportedNodeTypeException('0x'+typeCode.toString(16))
    return v
  ###

  ###
  parseGameTitle: (gameTitle)->
    throw new NotImplementedException(ReplayDataCoreCodec.name + '.parseGameTitle()')
    return
  ###

  ###
  getNodes: ()->
    @reader.setPosition(@header.nodesStartOffset)
    @nodes = []
    #noinspection CoffeeScriptInfiniteLoop
    while @reader.getPosition() < (@header.footerStartOffset)
      code = @reader.readUint8()
      result = @decodeNode(code)
      @nodes.push(result)
    return @nodes
  ###

  ###
  parse: ()->
    throw new NotImplementedException(ReplayDataCoreCodec.name + '.parse()')
    return