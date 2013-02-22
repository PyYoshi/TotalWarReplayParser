/**
 * サポート外のファイルの時に使用するException
 * @param filename
 * @constructor
 */
NotSupportedFileException = function(filename){
    this.name = 'NotSupportedFileException';
    this.message = (filename ||'This file ') + 'is not supported File Codec.';
};
NotSupportedFileException.prototype = new Error();
NotSupportedFileException.prototype.constructor = NotSupportedFileException;


/**
 * 未実装時のException
 * @param methodName
 * @constructor
 */
NotImplementedException = function(methodName){
    this.name = 'NotImplementedException';
    this.message = (functionName|| 'This method ') + 'is not implemented. Check your browser or code.';
};
NotImplementedException.prototype = new Error();
NotImplementedException.prototype.constructor = NotImplementedException;


/**
 *
 * @param typeName
 * @constructor
 */
NotSupportedNodeTypeException = function(typeName){
    this.name = 'NotSupportedNodeTypeException';
    this.message = (typeName||'This type ') + 'is not supported Node Type.';
};
NotSupportedNodeTypeException.prototype = new Error();
NotSupportedNodeTypeException.prototype.constructor = NotSupportedNodeTypeException;


/**
 * リプレイパーサクラス
 * @param stream
 * @constructor
 */
ReplayParser = function(stream){
    this.reader = new DataStream(stream);
    this.header = null;
    this.footer = null;
    this.littleEndian = true;
    this.bigEndian = false;
    this.nodes = null;
};
ReplayParser.prototype = {};


function Enum(){}
Enum.typeCodes = {
    INVALID : 0x00,

    BOOL : 0x01,
    INT8 : 0x02,
    INT16 : 0x03,
    INT32 : 0x04,
    INT64 : 0x05,
    UINT8 : 0x06,
    UINT16 : 0x07,
    UINT32 : 0x08,
    UINT64 : 0x09,
    FLOAT32 : 0x0a,
    FLOAT64 : 0x0b,
    COORDINATES2D : 0x0c,
    COORDINATES3D : 0x0d,
    UTF16 : 0x0e, // ca_unicode
    ASCII : 0x0f, // ca_ascii
    ANGLE : 0x10,

    BOOL_ARRAY : 0x41,
    INT8_ARRAY : 0x42,
    INT16_ARRAY : 0x43,
    INT32_ARRAY : 0x44,
    INT64_ARRAY : 0x45,
    UINT8_ARRAY : 0x46,
    UINT16_ARRAY : 0x47,
    UINT32_ARRAY : 0x48,
    UINT64_ARRAY : 0x49,
    FLOAT32_ARRAY : 0x4a,
    FLOAT64_ARRAY : 0x4b,
    COORDINATES2D_ARRAY : 0x4c,
    COORDINATES3D_ARRAY : 0x4d,
    UTF16_ARRAY : 0x4e, // ca_unicode
    ASCII_ARRAY : 0x4f, // ca_ascii
    ANGLE_ARRAY : 0x50,

    BOOL_TRUE : 0x12,
    BOOL_FALSE : 0x13,
    UINT32_ZERO : 0x14,
    UINT32_ONE : 0x15,
    UINT32_BYTE : 0x16,
    UINT32_SHORT : 0x17,
    UINT32_24BIT : 0x18,
    INT32_ZERO : 0x19,
    INT32_BYTE : 0x1a,
    INT32_SHORT : 0x1b,
    INT32_24BIT : 0x1c,
    FLOAT32_ZERO : 0x1d,

    RECORD : 0x80,
    RECORD_ARRAY : 0x81,

    BOOL_TRUE_ARRAY : 0x52, // makes no sense
    BOOL_FALSE_ARRAY : 0x53, // makes no sense
    UINT_ZERO_ARRAY : 0x54, // makes no sense
    UINT_ONE_ARRAY : 0x55, // makes no sense
    UINT32_BYTE_ARRAY : 0x56,
    UINT32_SHORT_ARRAY : 0x57,
    UINT32_24BIT_ARRAY : 0x58,
    INT32_ZERO_ARRAY : 0x59, // makes no sense
    INT32_BYTE_ARRAY : 0x5a,
    INT32_SHORT_ARRAY : 0x5b,
    INT32_24BIT_ARRAY : 0x5c,
    SINGLE_ZERO_ARRAY : 0x5d // makes no sense
};


/**
 * 8bit読み込んで文字列1つ返す関数。8bit分読み進めます。
 * @param endian {Boolean}, true: Little Endian|false: Big Endian
 * @param reader {DataStream}, new DataStream(); (要:DataStream.js参照)
 * @return {String}
 */
ReplayParser.prototype.readChar8 = function(endian,reader){
    var codepoint = reader.readUint8(endian);
    return String.fromCharCode(codepoint);
};


/**
 * 16bit読み込んで文字列1つ返す関数。 16bit分読み進めます。
 * @param endian {Boolean}, true: Little Endian|false: Big Endian
 * @param reader {DataStream}, new DataStream(); (要:DataStream.js参照)
 * @return {String}
 */
ReplayParser.prototype.readChar16 = function(endian,reader){
    var codepoint = reader.readUint16(endian);
    return String.fromCharCode(codepoint);
};


/**
 * 特定の範囲まで読み込んで文字列を返す関数。 Ascii文字列を読み込むため8bitずつ処理する。
 * @param reader {DataStream}, new DataStream(); (要:DataStream.js参照)
 * @return {String}
 */
ReplayParser.prototype.readCaAscii = function(reader){
    // uint16 count
    // char8[count] characters
    var count = reader.readUint16(this.littleEndian);
    var ret_string = '';
    for(var i=0;i<count;i++){
        ret_string += this.readChar8(this.littleEndian,reader);
    }
    return ret_string;
};


/**
 * 特定の範囲まで読み込んで文字列を返す関数。 UTF-16文字列を読み込むため16bitづつ処理する。
 * @param reader {DataStream}, new DataStream(); (要:DataStream.js参照)
 * @return {String}
 */
ReplayParser.prototype.readCaUnicode = function(reader){
    // uint16 count
    // char16
    var count = reader.readUint16(this.littleEndian);
    var ret_string = '';
    for(var j=0;j<count;j++){
        ret_string += this.readChar16(this.littleEndian,reader);
    }
    return ret_string;
};


/**
 * 可変長な範囲を読み込み、数値として返す関数。
 * @param reader {DataStream}, new DataStream(); (要:DataStream.js参照)
 * @return {Number}
 */
ReplayParser.prototype.readUIntVar = function(reader){
    var code = reader.readUint8();
    var result = 0;
    while(code & 0x80 !=0){
        result = (result << 7) + (code & 0x7f);
        code = reader.readUint8();
    }
    return ~~((result << 7) + (code & 0x7f));
};


/**
 * Int24分のデータを読み込み数値を返す関数。24bit分読み進めます。
 * @param reader {DataStream}, new DataStream(); (要:DataStream.js参照)
 * @return {Number}
 */
ReplayParser.prototype.readInt24 = function(reader){
    var value = reader.readInt8();
    var sign = (value & 0x80) != 0;
    value = value & 0x7f;
    for(var i=0;i<2;i++){
        value = (value << 8) + reader.readInt8();
    }
    if(sign){
        value = -1 * value;
    }
    return value;
};


/**
 * Uint24分のデータを読み込み数値を返す関数。 24bit分読み進めます。
 * @param reader {DataStream}, new DataStream(); (要:DataStream.js参照)
 * @return {Number}
 */
ReplayParser.prototype.readUInt24 = function(reader){
    var value = 0;
    for(var i=0;i<2;i++){
        value = (value <<8) + reader.readInt8();
    }
    return value;
};


/**
 * ReplayFileのヘッダーを取得する関数。
 * @return {Object},
 *          'magicNumber': {Number}, ReplayFileの種類の判別に利用。
 *          'date': {Date}, ReplayFileの作成日時。
 *          'footerOffset': {Number}, footerのOffset(開始位置)
 *          'headerIndex': {Array}, headerの開始位置と終了位置
 *          'nodesIndex': {Array}, nodeの開始位置と終了位置
 */
ReplayParser.prototype.getHeader = function(){
    // uint32 magic number
    // uint32 4bytes, always zero
    // unit32 4bytes, look like Unix timestamp
    // uint32 offset where footer starts
    this.reader.position = 0;
    var magicNumber = this.reader.readUint32(this.littleEndian);
    if(magicNumber != 0xabce && magicNumber !=0xabcf){
        throw new NotSupportedFileException();
    }
    var skipBlock = this.reader.readUint32(this.littleEndian);
    var timestamp = new Date();
    timestamp.setTime(this.reader.readUint32(this.littleEndian));
    footerOffset = this.reader.readUint32(this.littleEndian);
    return {
        'magicNumber': magicNumber,
        'date':timestamp,
        'footerOffset':footerOffset,
        'headerIndex': [0, this.reader.position-1],
        'nodesIndex':[this.reader.position, footerOffset-1]
    };
};


/**
 * ReplayFileのフッターを取得する関数。
 * @return {Object},
 *          'tags': {Array}, 各RecordNode/RecordArrayNodeの名前として利用するタグ。
 *          'ex_values': {Array}, ReplayFileのABCFとABCA形式時に格納されている値。 各RecordNode/RecordArrayNodeの値として利用する。
 */
ReplayParser.prototype.getFooter = function(){
    // uint16 number of tag types
    // ca_ascii name
    /*
    if ABCA, ABCF:
        uint16 size of Unicode string lookup table
        uint16 make no sense
        ca_unicode string A
        uint32 index of string A
    */
    this.reader.position = this.header['footerOffset'];
    var tags_length = this.reader.readUint16(this.littleEndian);
    var tags = [];
    for(var j=0;j<tags_length;j++){
        tags.push(this.readCaAscii(this.reader));
    }
    obj = {
        'tags':tags,
        'ex_values':null
    };

    if (this.header['magicNumber'] == 0xabca||this.header['magicNumber'] == 0xabcf){
        var ustr_size = this.reader.readUint16(this.littleEndian);
        var invalid_val = this.reader.readUint16(this.littleEndian);
        var ex_values = {};
        for(var k=0;k<ustr_size;k++){
            var ustr = this.readCaUnicode(this.reader);
            var index = this.reader.readUint32();
            ex_values[index] = ustr;
        }
        obj['ex_values'] = ex_values;
    }
    return obj;
};


/**
 * ValueNodeを読み込む関数。
 * @param typeCode {Number}, 読み込むための値の種類を表した数値。
 * @return {*}
 */
ReplayParser.prototype.readValueNode = function(typeCode){
    switch (typeCode){
        case Enum.typeCodes.BOOL:
            var result = this.reader.readUint8(this.littleEndian);
            switch (result){
                case Enum.typeCodes.BOOL_TRUE:
                    return true;
                case Enum.typeCodes.BOOL_FALSE:
                    return false;
                case 0x00:
                    return false;
                case 0x01:
                    return true;
                default:
                    throw new NotSupportedNodeTypeException('0x'+result.toString(16));
            }
        case Enum.typeCodes.INT8:
            return this.reader.readInt8(this.littleEndian);
        case Enum.typeCodes.INT16:
            return this.reader.readInt16(this.littleEndian);
        case Enum.typeCodes.INT32:
            return this.reader.readInt32(this.littleEndian);
        case Enum.typeCodes.INT64:
            // TODO: NotImplement: ブラウザでint64が実装されていない
            this.reader.position += 8;
            return null;
        case Enum.typeCodes.UINT8:
            return this.reader.readUint8(this.littleEndian);
        case Enum.typeCodes.UINT16:
            return this.reader.readUint16(this.littleEndian);
        case Enum.typeCodes.UINT32:
            return this.reader.readUint32(this.littleEndian);
        case Enum.typeCodes.UINT64:
            // TODO: NotImplement: ブラウザでUint64が実装されていない
            this.reader.position += 8;
            return null;
        case Enum.typeCodes.FLOAT32:
            return this.reader.readFloat32(this.littleEndian);
        case Enum.typeCodes.FLOAT64:
            return this.reader.readFloat64(this.littleEndian);
        case Enum.typeCodes.COORDINATES2D:
            var x = this.reader.readFloat32(this.littleEndian);
            var y = this.reader.readFloat32(this.littleEndian);
            return [x,y];
        case Enum.typeCodes.COORDINATES3D:
            var x = this.reader.readFloat32(this.littleEndian);
            var y = this.reader.readFloat32(this.littleEndian);
            var z = this.reader.readFloat32(this.littleEndian);
            return [x,y,z];
        case Enum.typeCodes.UTF16:
            switch (this.header['magicNumber']){
                case 0xabca:
                case 0xabcf:
                    var valueIndex = this.reader.readUint32(this.littleEndian);
                    return this.footer['ex_values'][valueIndex];
                case 43982:
                    return this.readCaUnicode(this.reader);
                default:
                    throw new NotSupportedFileException();
            }
        case Enum.typeCodes.ASCII:
            switch (this.header['magicNumber']){
                case 0xabca:
                case 0xabcf:
                    var valueIndex = this.reader.readUint32(this.littleEndian);
                    return this.footer['ex_values'][valueIndex];
                case 43982:
                    return this.readCaUnicode(this.reader);
                default:
                    throw new NotSupportedFileException();
            }
        case Enum.typeCodes.ANGLE:
            return this.reader.readUint16(this.littleEndian);
        case Enum.typeCodes.INVALID:
            return null;
        default :
            throw new NotSupportedNodeTypeException('0x'+typeCode.toString(16));
    }
};


/**
 * ArrayNodeを読み込む関数。
 * @param typeCode {Number}, 読み込むための値の種類を表した数値。
 */
ReplayParser.prototype.readArrayNode = function(typeCode){
    var offset = this.reader.readUint32();
    var results = [];
    switch (typeCode){
        case Enum.typeCodes.BOOL_ARRAY:
            while(true){
                if(this.reader.position >= offset){
                    break;
                }else{
                    var result = this.reader.readUint8(this.littleEndian);
                    switch (result){
                        case Enum.typeCodes.BOOL_TRUE:
                        case 0x01:
                            results.push(true);
                            break;
                        case Enum.typeCodes.BOOL_FALSE:
                        case 0x00:
                            results.push(false);
                            break;
                        default:
                            throw new NotSupportedNodeTypeException('0x'+result.toString(16));
                    }
                }
            }
            break;

        case Enum.typeCodes.INT8_ARRAY:
            while(true){
                if(this.reader.position >= offset){
                    break;
                }else{
                    results.push(this.reader.readInt8(this.littleEndian));
                }
            }
            break;
        case Enum.typeCodes.INT16_ARRAY:
            while(true){
                if(this.reader.position >= offset){
                    break;
                }else{
                    results.push(this.reader.readInt16(this.littleEndian));
                }
            }
            break;
        case Enum.typeCodes.INT32_ARRAY:
            while(true){
                if(this.reader.position >= offset){
                    break;
                }else{
                    results.push(this.reader.readInt32(this.littleEndian));
                }
            }
            break;
        case Enum.typeCodes.INT64_ARRAY:
            // TODO: NotImplement: ブラウザでint64が実装されていない
            while(true){
                if(this.reader.position >= offset){
                    break;
                }else{
                    this.reader.position += 8;
                    results.push(null);
                }
            }
            break;
        case Enum.typeCodes.UINT8_ARRAY:
            while(true){
                if(this.reader.position >= offset){
                    break;
                }else{
                    results.push(this.reader.readUint8(this.littleEndian));
                }
            }
            break;
        case Enum.typeCodes.UINT16_ARRAY:
            while(true){
                if(this.reader.position >= offset){
                    break;
                }else{
                    results.push(this.reader.readUint16(this.littleEndian));
                }
            }
            break;
        case Enum.typeCodes.UINT32_ARRAY:
            while(true){
                if(this.reader.position >= offset){
                    break;
                }else{
                    results.push(this.reader.readUint32(this.littleEndian));
                }
            }
            break;
        case Enum.typeCodes.UINT64_ARRAY:
            // TODO: NotImplement: ブラウザでUint64が実装されていない
            while(true){
                if(this.reader.position >= offset){
                    break;
                }else{
                    this.reader.position += 8;
                    results.push(null);
                }
            }
            break;
        case Enum.typeCodes.FLOAT32_ARRAY:
            while(true){
                if(this.reader.position >= offset){
                    break;
                }else{
                    results.push(this.reader.readFloat32(this.littleEndian));
                }
            }
            break;
        case Enum.typeCodes.FLOAT64_ARRAY:
            while(true){
                if(this.reader.position >= offset){
                    break;
                }else{
                    results.push(this.reader.readFloat64(this.littleEndian));
                }
            }
            break;
        case Enum.typeCodes.COORDINATES2D_ARRAY:
            while(true){
                if(this.reader.position >= offset){
                    break;
                }else{
                    var x = this.reader.readFloat32(this.littleEndian);
                    var y = this.reader.readFloat32(this.littleEndian);
                    results.push([x,y]);
                }
            }
            break;
        case Enum.typeCodes.COORDINATES3D_ARRAY:
            while(true){
                if(this.reader.position >= offset){
                    break;
                }else{
                    var x = this.reader.readFloat32(this.littleEndian);
                    var y = this.reader.readFloat32(this.littleEndian);
                    var z = this.reader.readFloat32(this.littleEndian);
                    results.push([x,y,z]);
                }
            }
            break;
        case Enum.typeCodes.UTF16_ARRAY:
            while(true){
                if(this.reader.position >= offset){
                    break;
                }else{
                    switch (this.header['magicNumber']){
                        case 0xabca:
                        case 0xabcf:
                            var valueIndex = this.reader.readUint32(this.littleEndian);
                            var result = this.footer['ex_values'][valueIndex];
                            results.push(result);
                            break;
                        case 43982:
                            results.push(this.readCaUnicode(this.reader));
                            break;
                        default:
                            throw new NotSupportedFileException();
                    }

                }
            }
            break;
        case Enum.typeCodes.ASCII_ARRAY:
            while(true){
                if(this.reader.position >= offset){
                    break;
                }else{
                    switch (this.header['magicNumber']){
                        case 0xabca:
                        case 0xabcf:
                            var valueIndex = this.reader.readUint32(this.littleEndian);
                            var result = this.footer['ex_values'][valueIndex];
                            results.push(result);
                            break;
                        case 43982:
                            results.push(this.readCaAscii(this.reader));
                            break;
                        default:
                            throw new NotSupportedFileException();
                    }
                }
            }
            break;
        case Enum.typeCodes.ANGLE_ARRAY:
            while(true){
                if(this.reader.position >= offset){
                    break;
                }else{
                    results.push(this.reader.readUint16(this.littleEndian));
                }
            }
            break;
        default :
            throw new NotSupportedNodeTypeException('0x'+typeCode.toString(16));
    }
};


/**
 * フッターからタグ情報を取得する関数。
 * @param tagNameIndex {Number}, tagのインデックス値。
 * @return {String}
 */
ReplayParser.prototype.getTagName = function(tagNameIndex){
    return this.footer['tags'][tagNameIndex];
};


/**
 * RecordArrayNodeを読み込む関数。
 * @return {*}
 */
ReplayParser.prototype.readRecordArrayNode = function(){
    //uint16 tag name - it's index to table of tags in the footer
    //uint8 version - version number
    //uint32 offset of first byte after end of array
    //uint32 number of elements
    //uint32 offset of first byte after end of record #0
    //contents of record 0
    //uint32 offset of first byte after end of record #1
    //contents of record 1

    var tagNameIndex = this.reader.readUint16(this.littleEndian);
    var tagName = this.getTagName(tagNameIndex);
    var version = this.reader.readUint8(this.littleEndian);
    var offset = this.reader.readUint32(this.littleEndian); // Size = offset - position
    var elements_length = this.reader.readUint32(this.littleEndian); // itemCount
    var values = [];
    while(true){
        if(this.reader.position >= offset){
            break;
        }else{
            var element_offset = this.reader.readUint32(this.littleEndian);
            while(true){
                if(this.reader.position >= element_offset){
                    break;
                }else{
                    var code = this.reader.readUint8(this.littleEndian);
                    var result = this.decode(code);
                    values.push(result);
                }
            }
        }
    }
    obj = {};
    obj[tagName] = values;
    return obj;
};


/**
 * RecordNodeを読み込む関数。
 * @return {*}
 */
ReplayParser.prototype.readRecordNode = function(){
    //uint16 tag name - it's index to table of tags in the footer. index
    //uint8 version - version number - starts with 0, updated every time object format changes
    //uint32 offset of first byte after end of record
    var tagNameIndex = this.reader.readUint16(this.littleEndian);
    var tagName = this.getTagName(tagNameIndex);
    var version = this.reader.readUint8(this.littleEndian);
    var offset = this.reader.readUint32(this.littleEndian);
    var values = [];
    while(true){
        if(this.reader.position >= offset){
            break;
        }else{
            var code = this.reader.readUint8(this.littleEndian);
            var result = this.decode(code);
            values.push(result);
        }
    }
    obj = {};
    obj[tagName] = values;
    return obj;
};


/**
 * Nodeを適切なリーダに渡すためのデコード関数。
 * @param typeCode {Number}, 読み込むための値の種類を表した数値。
 * @return {*}
 */
ReplayParser.prototype.decode = function(typeCode){
    if(typeCode < Enum.typeCodes.BOOL_ARRAY){
        return this.readValueNode(typeCode);
    }else if(typeCode < Enum.typeCodes.RECORD){
        return this.readArrayNode(typeCode);
    }else if(typeCode == Enum.typeCodes.RECORD){
        return this.readRecordNode()
    }else if(typeCode == Enum.typeCodes.RECORD_ARRAY){
        return this.readRecordArrayNode();
    }else{
        throw new NotSupportedNodeTypeException('0x'+typeCode.toString(16));
    }

};


/**
 * すべてのNodeを再帰的に読み込む関数。
 * @return {Array}
 */
ReplayParser.prototype.getNodes = function(){
    var nodesIndex = this.header['nodesIndex'];
    this.reader.position = nodesIndex[0];
    var nodes = [];
    while(true){
        if(this.reader.position >= nodesIndex[1]){
            break;
        }else{
            var code = this.reader.readUint8(this.littleEndian);
            var result = this.decode(code);
            nodes.push(result);
        }
    }
    return nodes;
};


/**
 * ReplayFileに格納されているゲーム情報をパースする関数。
 * @param gameTitleString {String}, パースしたいゲーム情報。
 * @param magicNumber {Number}, ReplayFileの種類の判別に利用。
 * @return {Object},
 *          'gameName': {String},
 *          'gameVersion': {String},
 *          'buildNumber': {Number},
 *          'changelistNumber': {Number},
 */
ReplayParser.parseGameTitle = function(gameTitleString,magicNumber){
    switch (magicNumber){
        case 0xabca:
        case 0xabcf:
            result = gameTitleString.match(/^([a-z|A-Z|\d]*)\:TotalWar\(([0-9|\.]*)\)\(.*Build\(([0-9]*)\).*\)\sChangelist\(([0-9]*)\)$/);
            break;
        case 0xabce:
            result = gameTitleString.match(/^([a-z|A-Z|\d]*)\:\sTotal\sWar\s([0-9|\.]*)\s\(.*Build\s([0-9]*).*\)\sChangelist\:\s([0-9]*)$/);
            break;
        default:
            throw new NotSupportedFileException();
    }
    return {
        'gameName': result[1],
        'gameVersion': result[2],
        'buildNumber':Number(result[3]),
        'changelistNumber':Number(result[4])
    }

};


/**
 *
 * @return {Object}
 */
ReplayParser.prototype.parseAbceCodec = function(){
    var obj = {};
    var root = this.nodes[0]['root'];
    var battleReplay = root[0]['BATTLE_REPLAY'];
    var empireReplay = battleReplay[1]['EMPIRE_REPLAY'];
    obj['GAME_TITLE'] = empireReplay[0];
    // EmpireとNapoleonでMAPの取得方法を変える
    var battleSetup = battleReplay[2]['BATTLE_SETUP'];
    var battleSetupInfo = battleSetup[0]['BATTLE_SETUP_INFO'];
    var gameTitle = ReplayParser.parseGameTitle(obj['GAME_TITLE'],0xabce)['gameName'];
    if(gameTitle == 'Empire'){
        obj['BATTLEFIELD_MAP_ID'] = battleSetupInfo[26];
    }else if(gameTitle == 'Napoleon'){
        // len: 34の時は後ろから6番目。 33の時は後ろから5番目
        var map_index = 0;
        if(battleSetupInfo.length == 33){
            map_index = battleSetupInfo.length - 5;
        }else if(battleSetupInfo.length == 34){
            map_index = battleSetupInfo.length - 6;
        }else{
            throw new NotSupportedFileException();
        }
        obj['BATTLEFIELD_MAP_ID'] = battleSetupInfo[map_index];
    }
    var battlefieldMap = battleSetupInfo[0].split('/');
    battlefieldMap.pop();
    obj['BATTLEFIELD_MAP_ID_SUB'] = battlefieldMap.pop();
    var battleResults = battleReplay[4]['BATTLE_RESULTS'];
    var alliances = battleResults[3]['ALLIANCES'];
    var allTeams = [];
    for(var i=0;i<alliances.length;i++){
        var battleResultAlliance = alliances[i]['BATTLE_RESULT_ALLIANCE'];
        var armyList = battleResultAlliance[16]['ARMIES'];
        var teamPlayers = [];
        for(var j=0;j<armyList.length;j++){
            var player = {};
            var battleResultArmy = armyList[j]['BATTLE_RESULT_ARMY'];
            player['PLAYER_NAME'] = battleResultArmy[1];
            player['PLAYER_REGION_ID'] = battleResultArmy[0];
            teamPlayers.push(player);
        }
        allTeams.push(teamPlayers);
    }
    obj['ALL_TEAMS'] = allTeams;
    return obj;
};


/**
 *
 * @return {Object}
 */
ReplayParser.prototype.parseAbcaAbcfCodec = function(){
    var obj = {};
    var root = this.nodes[0]['root'];
    var battleReplay = root[0]['BATTLE_REPLAY'];
    var empireReplay = battleReplay[1]['EMPIRE_REPLAY'];
    obj['GAME_TITLE'] = empireReplay[0];
    var battleSetup = battleReplay[2]['BATTLE_SETUP'];
    var battleSetupInfo = battleSetup[0]['BATTLE_SETUP_INFO'];
    var map_index = battleSetupInfo.length - 5;
    obj['BATTLEFIELD_MAP_ID'] = battleSetupInfo[map_index];
    var battlefieldMap = battleSetupInfo[0].split('/');
    battlefieldMap.pop();
    obj['BATTLEFIELD_MAP_ID_SUB'] = battlefieldMap.pop();
    var battleResults = battleReplay[4]['BATTLE_RESULTS'];
    var alliances = battleResults[4]['ALLIANCES'];
    var allTeams = [];
    for(var i=0;i<alliances.length;i++){
        var battleResultAlliance = alliances[i]['BATTLE_RESULT_ALLIANCE'];
        var armyList = battleResultAlliance[16]['ARMIES'];
        var teamPlayers = [];
        for(var j=0;j<armyList.length;j++){
            var player = {};
            var battleResultArmy = armyList[j]['BATTLE_RESULT_ARMY'];
            player['PLAYER_NAME'] = battleResultArmy[1];
            var battleSetupFaction = battleResultArmy[0]['BATTLE_SETUP_FACTION'];
            player['PLAYER_REGION_ID'] = battleSetupFaction[0];
            teamPlayers.push(player);
        }
        allTeams.push(teamPlayers);
    }
    obj['ALL_TEAMS'] = allTeams;
    return obj
};


ReplayParser.prototype.parse = function(){
    this.header = this.getHeader();
    this.footer = this.getFooter();
    this.nodes = this.getNodes();
    var result = null;
    //console.log(JSON.stringify(this.nodes));
    switch (this.header['magicNumber']){
        case 0xabca:
        case 0xabcf:
            //console.log('ABCA/ABCF');
            result = this.parseAbcaAbcfCodec();
            //console.log(result);
            break;
        case 0xabce:
            //console.log('ABCE');
            result = this.parseAbceCodec();
            //console.log(result);
            break;

    }
    return result;
};


