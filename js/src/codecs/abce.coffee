###

###
class ReplayDataAbceCodec extends ReplayDataCoreCodec
  constructor:(reader=null, header=null, footer=null)->
    super(reader, header, footer)
  readFooter: ()->
    @reader.setPosition(@header.footerStartOffset)
    # uint16 number of tag types
    tagsLength = @reader.readUint16()
    tags = []
    for i in range(tagsLength)
      value = @reader.readCaAscii()
      tags.push(value)
    return new ReplayDataFooter(tags)
  parseGameTitle: (gameTitle)->
    result = gameTitle.match(/^([a-z|A-Z|\d]*)\:\sTotal\sWar\s([0-9|\.]*)\s\(.*Build\s([0-9]*).*\)\sChangelist\:\s([0-9]*)$/)
    return new ReplayDataGameTitle(result[1], result[2], Number(result[3]), Number(result[4]))
  parse: ()->

    return
