###

###
class ReplayDataCoreCodec
  reader: null
  header: null
  footer: null
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
    # uint32 format number
    format = reader.readUint32()
    if format not in [ReplayDataFormats.ABCE, ReplayDataFormats.ABCF, ReplayDataFormats.ABCA] then throw new NotSupportedFileException()
    # uint32 4bytes, always zero
    skipBlock = reader.readUint32()
    # unit32 4bytes, look like Unix timestamp
    timestamp = new Date()
    timestamp.setTime(reader.readUint32()*1000)
    # uint32 offset where footer starts
    footerStartOffset = reader.readUint32()
    return new ReplayDataHeader(format, timestamp, reader.getPosition(), footerStartOffset)

  ###

  ###
  readFooter: ()->
    throw new NotImplementedException(ReplayDataCoreCodec.name + '.readFooter()')
    return

  ###

  ###
  readValueNode: (typeCode)->
    throw new NotImplementedException(ReplayDataCoreCodec.name + '.readValueNode()')
    return

  ###

  ###
  readArrayNode: (typeCode)->
    throw new NotImplementedException(ReplayDataCoreCodec.name + '.readArrayNode()')
    return

  ###

  ###
  readRecordNode: ()->
    # uint16 tag name - it's index to table of tags in the footer. index
    tagNameIndex = @reader.readUint16()
    tagName = @footer.getTagName(tagNameIndex)
    # uint8 version - version number - starts with 0, updated every time object format changes
    version = @reader.readUint8()
    # uint32 offset of first byte after end of record
    nodeEndOffset = @reader.readUint32()
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

  ###

  ###
  readRecordArrayNode: ()->
    # uint16 tag name - it's index to table of tags in the footer
    tagNameIndex = @reader.readUint16()
    tagName = @footer.getTagName(tagNameIndex)
    # uint8 version - version number
    version = @reader.readUint8()
    # uint32 offset of first byte after end of array
    nodeEndOffset = @reader.readUint32()
    # uint32 number of elements
    elementLength = @reader.readUint32()
    values = []
    # noinspection CoffeeScriptInfiniteLoop
    while true
      if @reader.getPosition() >= nodeEndOffset then break
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
    #recordBit = typeCode & ReplayTypeCodes.RECORD
    if typeCode < ReplayTypeCodes.BOOL_ARRAY
      v = @readValueNode(typeCode)
      _g(['--VALUE_NODE--',v,'--Position--','0x'+@reader.getPosition().toString(16)],_l)
    else if typeCode < ReplayTypeCodes.RECORD
      v = @readArrayNode(typeCode)
      _g(['--ARRAY_NODE--',v,'--Position--','0x'+@reader.getPosition().toString(16)],_l)
    else if typeCode == ReplayTypeCodes.RECORD
      v = @readRecordNode()
      _g(['--RECORD_NODE--',v,'--Position--','0x'+@reader.getPosition().toString(16)], _l)
    else if typeCode == ReplayTypeCodes.RECORD_ARRAY
      v = @readRecordArrayNode()
      _g(['--RECORD_ARRAY_NODE--',v,'--Position--','0x'+@reader.getPosition().toString(16)], _l)
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
    nodes = []
    #noinspection CoffeeScriptInfiniteLoop
    while true
      if @reader.getPosition() >= (@header.footerStartOffset-1) then break
      code = @reader.readUint8()
      result = @decodeNode(code)
      nodes.push(result)
    return nodes

  ###

  ###
  parse: ()->
    throw new NotImplementedException(ReplayDataCoreCodec.name + '.parse()')
    return