class ReplayData
  codec: null
  header: null
  footer: null
  nodes: null

  constructor:(stream)->
    reader = new ReplayDataReader(stream)
    @header = ReplayDataCoreCodec.readHeader(reader)
    switch @header.format
      when ReplayDataFormats.ABCE
        @codec = new ReplayDataAbceCodec(reader, @header)
      when ReplayDataFormats.ABCF
        @codec = new ReplayDataAbcfCodec(reader, @header)
      when ReplayDataFormats.ABCA
        @codec = new ReplayDataAbcaCodec(reader, @header)
      else
        throw new NotSupportedFileException()
    _l(@codec)
    _l(@codec.getNodes())

