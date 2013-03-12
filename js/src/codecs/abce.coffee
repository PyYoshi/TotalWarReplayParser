###

###
class ReplayDataAbceCodec extends ReplayDataCoreCodec
  constructor:(reader=null, header=null, footer=null)->
    super(reader, header, footer)
  readFooter: ()->
    @reader.setPosition(@header.footerStartOffset)
    tagsLength = @reader.readUint16()
    tags = []
    for i in range(tagsLength)
      value = @reader.readCaAscii()
      tags.push(value)
    return new ReplayDataFooter(tags)
  parseGameTitle: (gameTitle)->
    result = gameTitle.match(/^([a-z|A-Z|\d]*)\:\sTotal\sWar\s([0-9|\.]*)\s\(.*Build\s([0-9]*).*\)\sChangelist\:\s([0-9]*)$/)
    return new ReplayDataGameTitle(result[1], result[2], result[3], Number(result[4]))
  parse: ()->
    root = @nodes[0]['root']
    battle_replay = root['BATTLE_REPLAY']
    battle_setup = battle_replay['BATTLE_SETUP']
    battle_setup_info = battle_setup['BATTLE_SETUP_INFO']

    empire_replay = battle_replay['EMPIRE_REPLAY']
    game = @parseGameTitle(empire_replay[0])
    tmp_map = battle_setup_info[0].split('/')
    map = tmp_map[tmp_map.length - 2]
    battle_results = battle_replay['BATTLE_RESULTS']
    alliances = battle_results['ALLIANCES']
    teams = []
    for alliance in alliances
      players = []
      for player in alliance['BATTLE_RESULT_ALLIANCE']['ARMIES']
        player = player['BATTLE_RESULT_ARMY']
        player_faction = player[0]
        player_name = player[1]
        player_units = []
        for unit in player['UNITS']
          player_units.push(unit['BATTLE_RESULT_UNIT'][0])
        players.push({
          FACTION: player_faction
          NAME: player_name
          UNITS: player_units
        })
      teams.push(players)
    return {
      MAP: map
      GAME: game
      TEAMS: teams
    }

