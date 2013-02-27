###

###
class ReplayDataAbcfCodec extends ReplayDataCoreCodec
  constructor:(reader=null, header=null, footer=null)->
    super(reader, header, footer)
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
        _w('Int64はJavaScriptでは実装されていない')
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
        _w('UInt64はJavaScriptでは実装されていない')
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
          _w('UInt64はJavaScriptでは実装されていない')
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
  parseGameTitle: (gameTitle)->
    result = gameTitle.match(/^([a-z|A-Z|\d]*)\:TotalWar\(([0-9|\.]*)\)\(.*Build\(([0-9]*)\).*\)\sChangelist\(([0-9]*)\)$/)
    return new ReplayDataGameTitle(result[1], result[2], Number(result[3]), Number(result[4]))
  parse: ()->
    return
