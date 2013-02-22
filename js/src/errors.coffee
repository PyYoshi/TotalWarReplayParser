###

###
class NotSupportedFileException extends Error
  name: 'NotSupportedFileException'
  message: null
  constructor: (filename='This File')->
    @message = filename + ' is not supported File Codec.'

###

###
class NotImplementedException extends Error
  name: 'NotImplementedException'
  message: null
  constructor: (methodName='This method')->
    @message = methodName + ' is not implemented. Check your browser or code.'

###

###
class NotSupportedNodeTypeException extends Error
  name: 'NotSupportedNodeTypeException'
  message: null
  constructor: (typeName='This Type')->
    @message = typeName + ' is not supported Node Type.'