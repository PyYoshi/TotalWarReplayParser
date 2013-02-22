jQuery.event.props.push('dataTransfer')

$ ->
  if !window.FileReader
    throw new Error('ブラウザがFileReaderをサポートしていない')

  analyseReplayFile = (file)->
    fr = new FileReader()
    if !fr.readAsArrayBuffer
      throw new Error('ブラウザがArrayBufferをサポートしていない')
    fr.onload = (ev)->
      stream = ev.target.result
      replayData = new ReplayData(stream)

    fr.readAsArrayBuffer(file)
    return

  $('html').bind(
    'drop'
    (ev)->
      ev.stopPropagation()
      ev.preventDefault()

      dt = ev.dataTransfer
      file = dt.files[0]

      analyseReplayFile(file)
  ).bind('dragenter dragover', false)
















