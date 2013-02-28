###

  @param stream
###
class ReplayDataReader
  ds: null
  constructor:(stream)->
    @ds = new DataStream(stream)
  endianness: {
  little: DataStream.LITTLE_ENDIAN
  big: DataStream.BIG_ENDIAN
  }
  # 現在のリーダ位置を返す
  getPosition: ()->
    return @ds.position
  # リーダ位置をセットする
  setPosition: (position)->
    @ds.position = position
  # Reads an 8-bit int from the DataStream.
  readInt8:()->
    return @ds.readInt8()
  # Reads an 8-bit unsigned int from the DataStream.
  readUint8: ()->
    return @ds.readUint8()
  # Reads a 16-bit int from the DataStream with the desired endianness.
  readInt16: (endian=@endianness.little)->
    return @ds.readInt16(endian)
  # Reads a 16-bit unsigned int from the DataStream with the desired endianness.
  readUint16: (endian=@endianness.little)->
    return @ds.readUint16(endian)
  # Reads a 32-bit int from the DataStream with the desired endianness.
  readInt32: (endian=@endianness.little)->
    return @ds.readInt32(endian)
  # Reads a 32-bit unsigned int from the DataStream with the desired endianness.
  readUint32: (endian=@endianness.little)->
    return @ds.readUint32(endian)
  # Reads a 32-bit float from the DataStream with the desired endianness.
  readFloat32:(endian=@endianness.little)->
    return @ds.readFloat32(endian)
  # Reads a 64-bit float from the DataStream with the desired endianness.
  readFloat64:(endian=@endianness.little)->
    return @ds.readFloat64(endian)
  # 8bit読み込んで文字列1つ返す関数。8bit分読み進めます。
  readChar8: ()->
    cp = @readUint8()
    return String.fromCharCode(cp)
  # 16bit読み込んで文字列1つ返す関数。 16bit分読み進めます。
  readChar16: (endian=@endianness.little)->
    cp = @readUint16(endian)
    return String.fromCharCode(cp)
  # 特定の範囲まで読み込んで文字列を返す関数。 Ascii文字列を読み込むため8bitずつ処理する。
  readCaAscii: ()->
    count = @readUint16(@endianness.little)
    result = ''
    for i in range(count)
      result += @readChar8(@endianness.little)
    return result
  # 特定の範囲まで読み込んで文字列を返す関数。 UTF-16文字列を読み込むため16bitづつ処理する。
  readCaUnicode: ()->
    count = @readUint16(@endianness.little)
    result = ''
    for i in range(count)
      result += @readChar16(@endianness.little)
    return result
  # 可変長な範囲を読み込み、数値として返す関数。
  readUintVar:()->
    code = @readUint8()
    result = 0
    while ((code & 0x80) != 0)
      result = (result << 7) + (code & 0x7f)
      code = @readUint8()
    return ((result << 7) + (code & 0x7f))
  # Int24分のデータを読み込み数値を返す関数。24bit分読み進めます。
  readInt24:()->
    value = @readUint8()
    sign = (value & 0x80) != 0
    value = value & 0x7f
    for i in range(2)
      value = (value << 8) + @readUint8()
    if(sign)
      value = -value
    return value
  # Uint24分のデータを読み込み数値を返す関数。 24bit分読み進めます。
  readUint24:()->
    value = 0
    for i in range(2)
      value = (value << 8) + @readUint8()
    return value
  #
  @checkReaderType: (reader, methodName='This method')->
    if DEBUG == false then return
    if reader == null
      throw new TypeError(methodName + ' takes 1 or some arguments')
    if reader instanceof ReplayDataReader == false
      throw new TypeError('This reader object is not ' + ReplayDataReader.name)
    return