class ReplayData
  codec: null
  header: null
  @parsed_data = null
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
    @codec.getNodes()
    #_g(['---------------- CODEC ----------------', @codec])
    @parsed_data = @codec.parse()
    #_g(['---- PARSED DATA ----', parsed_data])

