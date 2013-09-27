###
DataStream reads scalars, arrays and structs of data from an ArrayBuffer.
It's like a file-like DataView on steroids.

@param {ArrayBuffer} arrayBuffer ArrayBuffer to read from.
@param {?Number} byteOffset Offset from arrayBuffer beginning for the DataStream.
@param {?Boolean} endianness DataStream.BIG_ENDIAN or DataStream.LITTLE_ENDIAN (the default).
###
DataStream = (arrayBuffer, byteOffset, endianness) ->
  @_byteOffset = byteOffset or 0
  if arrayBuffer instanceof ArrayBuffer
    @buffer = arrayBuffer
  else if typeof arrayBuffer is "object"
    @dataView = arrayBuffer
    @_byteOffset += byteOffset  if byteOffset
  else
    @buffer = new ArrayBuffer(arrayBuffer or 0)
  @position = 0
  @endianness = (if not endianness? then DataStream.LITTLE_ENDIAN else endianness)

DataStream:: = {}

###
Big-endian const to use as default endianness.
@type {boolean}
###
DataStream.BIG_ENDIAN = false

###
Little-endian const to use as default endianness.
@type {boolean}
###
DataStream.LITTLE_ENDIAN = true

###
Whether to extend DataStream buffer when trying to write beyond its size.
If set, the buffer is reallocated to twice its current size until the
requested write fits the buffer.
@type {boolean}
###
DataStream::_dynamicSize = true
Object.defineProperty DataStream::, "dynamicSize",
  get: ->
    @_dynamicSize

  set: (v) ->
    @_trimAlloc()  unless v
    @_dynamicSize = v


###
Virtual byte length of the DataStream backing buffer.
Updated to be max of original buffer size and last written size.
If dynamicSize is false is set to buffer size.
@type {number}
###
DataStream::_byteLength = 0

###
Returns the byte length of the DataStream object.
@type {number}
###
Object.defineProperty DataStream::, "byteLength",
  get: ->
    @_byteLength - @_byteOffset


###
Set/get the backing ArrayBuffer of the DataStream object.
The setter updates the DataView to point to the new buffer.
@type {Object}
###
Object.defineProperty DataStream::, "buffer",
  get: ->
    @_trimAlloc()
    @_buffer

  set: (v) ->
    @_buffer = v
    @_dataView = new DataView(@_buffer, @_byteOffset)
    @_byteLength = @_buffer.byteLength


###
Set/get the byteOffset of the DataStream object.
The setter updates the DataView to point to the new byteOffset.
@type {number}
###
Object.defineProperty DataStream::, "byteOffset",
  get: ->
    @_byteOffset

  set: (v) ->
    @_byteOffset = v
    @_dataView = new DataView(@_buffer, @_byteOffset)
    @_byteLength = @_buffer.byteLength


###
Set/get the backing DataView of the DataStream object.
The setter updates the buffer and byteOffset to point to the DataView values.
@type {Object}
###
Object.defineProperty DataStream::, "dataView",
  get: ->
    @_dataView

  set: (v) ->
    @_byteOffset = v.byteOffset
    @_buffer = v.buffer
    @_dataView = new DataView(@_buffer, @_byteOffset)
    @_byteLength = @_byteOffset + v.byteLength


###
Internal function to resize the DataStream buffer when required.
@param {number} extra Number of bytes to add to the buffer allocation.
@return {null}
###
DataStream::_realloc = (extra) ->
  return  unless @_dynamicSize
  req = @_byteOffset + @position + extra
  blen = @_buffer.byteLength
  if req <= blen
    @_byteLength = req  if req > @_byteLength
  return
  blen = 1  if blen < 1
  blen *= 2  while req > blen
  buf = new ArrayBuffer(blen)
  src = new Uint8Array(@_buffer)
  dst = new Uint8Array(buf, 0, src.length)
  dst.set src
  @buffer = buf
  @_byteLength = req


###
Internal function to trim the DataStream buffer when required.
Used for stripping out the extra bytes from the backing buffer when
the virtual byteLength is smaller than the buffer byteLength (happens after
growing the buffer with writes and not filling the extra space completely).

@return {null}
###
DataStream::_trimAlloc = ->
  return  if @_byteLength is @_buffer.byteLength
  buf = new ArrayBuffer(@_byteLength)
  dst = new Uint8Array(buf)
  src = new Uint8Array(@_buffer, 0, dst.length)
  dst.set src
  @buffer = buf


###
Sets the DataStream read/write position to given position.
Clamps between 0 and DataStream length.

@param {number} pos Position to seek to.
@return {null}
###
DataStream::seek = (pos) ->
  npos = Math.max(0, Math.min(@byteLength, pos))
  @position = (if (isNaN(npos) or not isFinite(npos)) then 0 else npos)


###
Returns true if the DataStream seek pointer is at the end of buffer and
there's no more data to read.

@return {boolean} True if the seek pointer is at the end of the buffer.
###
DataStream::isEof = ->
  @position >= @_byteLength


###
Maps an Int32Array into the DataStream buffer, swizzling it to native
endianness in-place. The current offset from the start of the buffer needs to
be a multiple of element size, just like with typed array views.

Nice for quickly reading in data. Warning: potentially modifies the buffer
contents.

@param {number} length Number of elements to map.
@param {?boolean} e Endianness of the data to read.
@return {Object} Int32Array to the DataStream backing buffer.
###
DataStream::mapInt32Array = (length, e) ->
  @_realloc length * 4
  arr = new Int32Array(@_buffer, @byteOffset + @position, length)
  DataStream.arrayToNative arr, (if not e? then @endianness else e)
  @position += length * 4
  arr


###
Maps an Int16Array into the DataStream buffer, swizzling it to native
endianness in-place. The current offset from the start of the buffer needs to
be a multiple of element size, just like with typed array views.

Nice for quickly reading in data. Warning: potentially modifies the buffer
contents.

@param {number} length Number of elements to map.
@param {?boolean} e Endianness of the data to read.
@return {Object} Int16Array to the DataStream backing buffer.
###
DataStream::mapInt16Array = (length, e) ->
  @_realloc length * 2
  arr = new Int16Array(@_buffer, @byteOffset + @position, length)
  DataStream.arrayToNative arr, (if not e? then @endianness else e)
  @position += length * 2
  arr


###
Maps an Int8Array into the DataStream buffer.

Nice for quickly reading in data.

@param {number} length Number of elements to map.
@param {?boolean} e Endianness of the data to read.
@return {Object} Int8Array to the DataStream backing buffer.
###
DataStream::mapInt8Array = (length) ->
  @_realloc length * 1
  arr = new Int8Array(@_buffer, @byteOffset + @position, length)
  @position += length * 1
  arr


###
Maps a Uint32Array into the DataStream buffer, swizzling it to native
endianness in-place. The current offset from the start of the buffer needs to
be a multiple of element size, just like with typed array views.

Nice for quickly reading in data. Warning: potentially modifies the buffer
contents.

@param {number} length Number of elements to map.
@param {?boolean} e Endianness of the data to read.
@return {Object} Uint32Array to the DataStream backing buffer.
###
DataStream::mapUint32Array = (length, e) ->
  @_realloc length * 4
  arr = new Uint32Array(@_buffer, @byteOffset + @position, length)
  DataStream.arrayToNative arr, (if not e? then @endianness else e)
  @position += length * 4
  arr


###
Maps a Uint16Array into the DataStream buffer, swizzling it to native
endianness in-place. The current offset from the start of the buffer needs to
be a multiple of element size, just like with typed array views.

Nice for quickly reading in data. Warning: potentially modifies the buffer
contents.

@param {number} length Number of elements to map.
@param {?boolean} e Endianness of the data to read.
@return {Object} Uint16Array to the DataStream backing buffer.
###
DataStream::mapUint16Array = (length, e) ->
  @_realloc length * 2
  arr = new Uint16Array(@_buffer, @byteOffset + @position, length)
  DataStream.arrayToNative arr, (if not e? then @endianness else e)
  @position += length * 2
  arr


###
Maps a Uint8Array into the DataStream buffer.

Nice for quickly reading in data.

@param {number} length Number of elements to map.
@param {?boolean} e Endianness of the data to read.
@return {Object} Uint8Array to the DataStream backing buffer.
###
DataStream::mapUint8Array = (length) ->
  @_realloc length * 1
  arr = new Uint8Array(@_buffer, @byteOffset + @position, length)
  @position += length * 1
  arr


###
Maps a Float64Array into the DataStream buffer, swizzling it to native
endianness in-place. The current offset from the start of the buffer needs to
be a multiple of element size, just like with typed array views.

Nice for quickly reading in data. Warning: potentially modifies the buffer
contents.

@param {number} length Number of elements to map.
@param {?boolean} e Endianness of the data to read.
@return {Object} Float64Array to the DataStream backing buffer.
###
DataStream::mapFloat64Array = (length, e) ->
  @_realloc length * 8
  arr = new Float64Array(@_buffer, @byteOffset + @position, length)
  DataStream.arrayToNative arr, (if not e? then @endianness else e)
  @position += length * 8
  arr


###
Maps a Float32Array into the DataStream buffer, swizzling it to native
endianness in-place. The current offset from the start of the buffer needs to
be a multiple of element size, just like with typed array views.

Nice for quickly reading in data. Warning: potentially modifies the buffer
contents.

@param {number} length Number of elements to map.
@param {?boolean} e Endianness of the data to read.
@return {Object} Float32Array to the DataStream backing buffer.
###
DataStream::mapFloat32Array = (length, e) ->
  @_realloc length * 4
  arr = new Float32Array(@_buffer, @byteOffset + @position, length)
  DataStream.arrayToNative arr, (if not e? then @endianness else e)
  @position += length * 4
  arr


###
Reads an Int32Array of desired length and endianness from the DataStream.

@param {number} length Number of elements to map.
@param {?boolean} e Endianness of the data to read.
@return {Object} The read Int32Array.
###
DataStream::readInt32Array = (length, e) ->
  length = (if not length? then (@byteLength - @position / 4) else length)
  arr = new Int32Array(length)
  DataStream.memcpy arr.buffer, 0, @buffer, @byteOffset + @position, length * arr.BYTES_PER_ELEMENT
  DataStream.arrayToNative arr, (if not e? then @endianness else e)
  @position += arr.byteLength
  arr


###
Reads an Int16Array of desired length and endianness from the DataStream.

@param {number} length Number of elements to map.
@param {?boolean} e Endianness of the data to read.
@return {Object} The read Int16Array.
###
DataStream::readInt16Array = (length, e) ->
  length = (if not length? then (@byteLength - @position / 2) else length)
  arr = new Int16Array(length)
  DataStream.memcpy arr.buffer, 0, @buffer, @byteOffset + @position, length * arr.BYTES_PER_ELEMENT
  DataStream.arrayToNative arr, (if not e? then @endianness else e)
  @position += arr.byteLength
  arr


###
Reads an Int8Array of desired length from the DataStream.

@param {number} length Number of elements to map.
@param {?boolean} e Endianness of the data to read.
@return {Object} The read Int8Array.
###
DataStream::readInt8Array = (length) ->
  length = (if not length? then (@byteLength - @position) else length)
  arr = new Int8Array(length)
  DataStream.memcpy arr.buffer, 0, @buffer, @byteOffset + @position, length * arr.BYTES_PER_ELEMENT
  @position += arr.byteLength
  arr


###
Reads a Uint32Array of desired length and endianness from the DataStream.

@param {number} length Number of elements to map.
@param {?boolean} e Endianness of the data to read.
@return {Object} The read Uint32Array.
###
DataStream::readUint32Array = (length, e) ->
  length = (if not length? then (@byteLength - @position / 4) else length)
  arr = new Uint32Array(length)
  DataStream.memcpy arr.buffer, 0, @buffer, @byteOffset + @position, length * arr.BYTES_PER_ELEMENT
  DataStream.arrayToNative arr, (if not e? then @endianness else e)
  @position += arr.byteLength
  arr


###
Reads a Uint16Array of desired length and endianness from the DataStream.

@param {number} length Number of elements to map.
@param {?boolean} e Endianness of the data to read.
@return {Object} The read Uint16Array.
###
DataStream::readUint16Array = (length, e) ->
  length = (if not length? then (@byteLength - @position / 2) else length)
  arr = new Uint16Array(length)
  DataStream.memcpy arr.buffer, 0, @buffer, @byteOffset + @position, length * arr.BYTES_PER_ELEMENT
  DataStream.arrayToNative arr, (if not e? then @endianness else e)
  @position += arr.byteLength
  arr


###
Reads a Uint8Array of desired length from the DataStream.

@param {number} length Number of elements to map.
@param {?boolean} e Endianness of the data to read.
@return {Object} The read Uint8Array.
###
DataStream::readUint8Array = (length) ->
  length = (if not length? then (@byteLength - @position) else length)
  arr = new Uint8Array(length)
  DataStream.memcpy arr.buffer, 0, @buffer, @byteOffset + @position, length * arr.BYTES_PER_ELEMENT
  @position += arr.byteLength
  arr


###
Reads a Float64Array of desired length and endianness from the DataStream.

@param {number} length Number of elements to map.
@param {?boolean} e Endianness of the data to read.
@return {Object} The read Float64Array.
###
DataStream::readFloat64Array = (length, e) ->
  length = (if not length? then (@byteLength - @position / 8) else length)
  arr = new Float64Array(length)
  DataStream.memcpy arr.buffer, 0, @buffer, @byteOffset + @position, length * arr.BYTES_PER_ELEMENT
  DataStream.arrayToNative arr, (if not e? then @endianness else e)
  @position += arr.byteLength
  arr


###
Reads a Float32Array of desired length and endianness from the DataStream.

@param {number} length Number of elements to map.
@param {?boolean} e Endianness of the data to read.
@return {Object} The read Float32Array.
###
DataStream::readFloat32Array = (length, e) ->
  length = (if not length? then (@byteLength - @position / 4) else length)
  arr = new Float32Array(length)
  DataStream.memcpy arr.buffer, 0, @buffer, @byteOffset + @position, length * arr.BYTES_PER_ELEMENT
  DataStream.arrayToNative arr, (if not e? then @endianness else e)
  @position += arr.byteLength
  arr


###
Writes an Int32Array of specified endianness to the DataStream.

@param {Object} arr The array to write.
@param {?boolean} e Endianness of the data to write.
###
DataStream::writeInt32Array = (arr, e) ->
  @_realloc arr.length * 4
  if arr instanceof Int32Array and @byteOffset + @position % arr.BYTES_PER_ELEMENT is 0
    DataStream.memcpy @_buffer, @byteOffset + @position, arr.buffer, 0, arr.byteLength
    @mapInt32Array arr.length, e
  else
    i = 0

    while i < arr.length
      @writeInt32 arr[i], e
      i++


###
Writes an Int16Array of specified endianness to the DataStream.

@param {Object} arr The array to write.
@param {?boolean} e Endianness of the data to write.
###
DataStream::writeInt16Array = (arr, e) ->
  @_realloc arr.length * 2
  if arr instanceof Int16Array and @byteOffset + @position % arr.BYTES_PER_ELEMENT is 0
    DataStream.memcpy @_buffer, @byteOffset + @position, arr.buffer, 0, arr.byteLength
    @mapInt16Array arr.length, e
  else
    i = 0

    while i < arr.length
      @writeInt16 arr[i], e
      i++


###
Writes an Int8Array to the DataStream.

@param {Object} arr The array to write.
###
DataStream::writeInt8Array = (arr) ->
  @_realloc arr.length * 1
  if arr instanceof Int8Array and @byteOffset + @position % arr.BYTES_PER_ELEMENT is 0
    DataStream.memcpy @_buffer, @byteOffset + @position, arr.buffer, 0, arr.byteLength
    @mapInt8Array arr.length
  else
    i = 0

    while i < arr.length
      @writeInt8 arr[i]
      i++


###
Writes a Uint32Array of specified endianness to the DataStream.

@param {Object} arr The array to write.
@param {?boolean} e Endianness of the data to write.
###
DataStream::writeUint32Array = (arr, e) ->
  @_realloc arr.length * 4
  if arr instanceof Uint32Array and @byteOffset + @position % arr.BYTES_PER_ELEMENT is 0
    DataStream.memcpy @_buffer, @byteOffset + @position, arr.buffer, 0, arr.byteLength
    @mapUint32Array arr.length, e
  else
    i = 0

    while i < arr.length
      @writeUint32 arr[i], e
      i++


###
Writes a Uint16Array of specified endianness to the DataStream.

@param {Object} arr The array to write.
@param {?boolean} e Endianness of the data to write.
###
DataStream::writeUint16Array = (arr, e) ->
  @_realloc arr.length * 2
  if arr instanceof Uint16Array and @byteOffset + @position % arr.BYTES_PER_ELEMENT is 0
    DataStream.memcpy @_buffer, @byteOffset + @position, arr.buffer, 0, arr.byteLength
    @mapUint16Array arr.length, e
  else
    i = 0

    while i < arr.length
      @writeUint16 arr[i], e
      i++


###
Writes a Uint8Array to the DataStream.

@param {Object} arr The array to write.
###
DataStream::writeUint8Array = (arr) ->
  @_realloc arr.length * 1
  if arr instanceof Uint8Array and @byteOffset + @position % arr.BYTES_PER_ELEMENT is 0
    DataStream.memcpy @_buffer, @byteOffset + @position, arr.buffer, 0, arr.byteLength
    @mapUint8Array arr.length
  else
    i = 0

    while i < arr.length
      @writeUint8 arr[i]
      i++


###
Writes a Float64Array of specified endianness to the DataStream.

@param {Object} arr The array to write.
@param {?boolean} e Endianness of the data to write.
###
DataStream::writeFloat64Array = (arr, e) ->
  @_realloc arr.length * 8
  if arr instanceof Float64Array and @byteOffset + @position % arr.BYTES_PER_ELEMENT is 0
    DataStream.memcpy @_buffer, @byteOffset + @position, arr.buffer, 0, arr.byteLength
    @mapFloat64Array arr.length, e
  else
    i = 0

    while i < arr.length
      @writeFloat64 arr[i], e
      i++


###
Writes a Float32Array of specified endianness to the DataStream.

@param {Object} arr The array to write.
@param {?boolean} e Endianness of the data to write.
###
DataStream::writeFloat32Array = (arr, e) ->
  @_realloc arr.length * 4
  if arr instanceof Float32Array and @byteOffset + @position % arr.BYTES_PER_ELEMENT is 0
    DataStream.memcpy @_buffer, @byteOffset + @position, arr.buffer, 0, arr.byteLength
    @mapFloat32Array arr.length, e
  else
    i = 0

    while i < arr.length
      @writeFloat32 arr[i], e
      i++


###
Reads a 32-bit int from the DataStream with the desired endianness.

@param {?boolean} e Endianness of the number.
@return {number} The read number.
###
DataStream::readInt32 = (e) ->
  v = @_dataView.getInt32(@position, (if not e? then @endianness else e))
  @position += 4
  v


###
Reads a 16-bit int from the DataStream with the desired endianness.

@param {?boolean} e Endianness of the number.
@return {number} The read number.
###
DataStream::readInt16 = (e) ->
  v = @_dataView.getInt16(@position, (if not e? then @endianness else e))
  @position += 2
  v


###
Reads an 8-bit int from the DataStream.

@return {number} The read number.
###
DataStream::readInt8 = ->
  v = @_dataView.getInt8(@position)
  @position += 1
  v


###
Reads a 32-bit unsigned int from the DataStream with the desired endianness.

@param {?boolean} e Endianness of the number.
@return {number} The read number.
###
DataStream::readUint32 = (e) ->
  v = @_dataView.getUint32(@position, (if not e? then @endianness else e))
  @position += 4
  v


###
Reads a 16-bit unsigned int from the DataStream with the desired endianness.

@param {?boolean} e Endianness of the number.
@return {number} The read number.
###
DataStream::readUint16 = (e) ->
  v = @_dataView.getUint16(@position, (if not e? then @endianness else e))
  @position += 2
  v


###
Reads an 8-bit unsigned int from the DataStream.

@return {number} The read number.
###
DataStream::readUint8 = ->
  v = @_dataView.getUint8(@position)
  @position += 1
  v


###
Reads a 32-bit float from the DataStream with the desired endianness.

@param {?boolean} e Endianness of the number.
@return {number} The read number.
###
DataStream::readFloat32 = (e) ->
  v = @_dataView.getFloat32(@position, (if not e? then @endianness else e))
  @position += 4
  v


###
Reads a 64-bit float from the DataStream with the desired endianness.

@param {?boolean} e Endianness of the number.
@return {number} The read number.
###
DataStream::readFloat64 = (e) ->
  v = @_dataView.getFloat64(@position, (if not e? then @endianness else e))
  @position += 8
  v


###
Writes a 32-bit int to the DataStream with the desired endianness.

@param {number} v Number to write.
@param {?boolean} e Endianness of the number.
###
DataStream::writeInt32 = (v, e) ->
  @_realloc 4
  @_dataView.setInt32 @position, v, (if not e? then @endianness else e)
  @position += 4


###
Writes a 16-bit int to the DataStream with the desired endianness.

@param {number} v Number to write.
@param {?boolean} e Endianness of the number.
###
DataStream::writeInt16 = (v, e) ->
  @_realloc 2
  @_dataView.setInt16 @position, v, (if not e? then @endianness else e)
  @position += 2


###
Writes an 8-bit int to the DataStream.

@param {number} v Number to write.
###
DataStream::writeInt8 = (v) ->
  @_realloc 1
  @_dataView.setInt8 @position, v
  @position += 1


###
Writes a 32-bit unsigned int to the DataStream with the desired endianness.

@param {number} v Number to write.
@param {?boolean} e Endianness of the number.
###
DataStream::writeUint32 = (v, e) ->
  @_realloc 4
  @_dataView.setUint32 @position, v, (if not e? then @endianness else e)
  @position += 4


###
Writes a 16-bit unsigned int to the DataStream with the desired endianness.

@param {number} v Number to write.
@param {?boolean} e Endianness of the number.
###
DataStream::writeUint16 = (v, e) ->
  @_realloc 2
  @_dataView.setUint16 @position, v, (if not e? then @endianness else e)
  @position += 2


###
Writes an 8-bit unsigned  int to the DataStream.

@param {number} v Number to write.
###
DataStream::writeUint8 = (v) ->
  @_realloc 1
  @_dataView.setUint8 @position, v
  @position += 1


###
Writes a 32-bit float to the DataStream with the desired endianness.

@param {number} v Number to write.
@param {?boolean} e Endianness of the number.
###
DataStream::writeFloat32 = (v, e) ->
  @_realloc 4
  @_dataView.setFloat32 @position, v, (if not e? then @endianness else e)
  @position += 4


###
Writes a 64-bit float to the DataStream with the desired endianness.

@param {number} v Number to write.
@param {?boolean} e Endianness of the number.
###
DataStream::writeFloat64 = (v, e) ->
  @_realloc 8
  @_dataView.setFloat64 @position, v, (if not e? then @endianness else e)
  @position += 8


###
Native endianness. Either DataStream.BIG_ENDIAN or DataStream.LITTLE_ENDIAN
depending on the platform endianness.

@type {boolean}
###
DataStream.endianness = new Int8Array(new Int16Array([1]).buffer)[0] > 0

###
Copies byteLength bytes from the src buffer at srcOffset to the
dst buffer at dstOffset.

@param {Object} dst Destination ArrayBuffer to write to.
@param {number} dstOffset Offset to the destination ArrayBuffer.
@param {Object} src Source ArrayBuffer to read from.
@param {number} srcOffset Offset to the source ArrayBuffer.
@param {number} byteLength Number of bytes to copy.
###
DataStream.memcpy = (dst, dstOffset, src, srcOffset, byteLength) ->
  dstU8 = new Uint8Array(dst, dstOffset, byteLength)
  srcU8 = new Uint8Array(src, srcOffset, byteLength)
  dstU8.set srcU8


###
Converts array to native endianness in-place.

@param {Object} array Typed array to convert.
@param {boolean} arrayIsLittleEndian True if the data in the array is
little-endian. Set false for big-endian.
@return {Object} The converted typed array.
###
DataStream.arrayToNative = (array, arrayIsLittleEndian) ->
  if arrayIsLittleEndian is @endianness
    array
  else
    @flipArrayEndianness array


###
Converts native endianness array to desired endianness in-place.

@param {Object} array Typed array to convert.
@param {boolean} littleEndian True if the converted array should be
little-endian. Set false for big-endian.
@return {Object} The converted typed array.
###
DataStream.nativeToEndian = (array, littleEndian) ->
  if @endianness is littleEndian
    array
  else
    @flipArrayEndianness array


###
Flips typed array endianness in-place.

@param {Object} array Typed array to flip.
@return {Object} The converted typed array.
###
DataStream.flipArrayEndianness = (array) ->
  u8 = new Uint8Array(array.buffer, array.byteOffset, array.byteLength)
  i = 0

  while i < array.byteLength
    j = i + array.BYTES_PER_ELEMENT - 1
    k = i

    while j > k
      tmp = u8[k]
      u8[k] = u8[j]
      u8[j] = tmp
      j--
      k++
    i += array.BYTES_PER_ELEMENT
  array


###
Seek position where DataStream#readStruct ran into a problem.
Useful for debugging struct parsing.

@type {number}
###
DataStream::failurePosition = 0

###
Reads a struct of data from the DataStream. The struct is defined as
a flat array of [name, type]-pairs. See the example below:

ds.readStruct([
'headerTag', 'uint32', // Uint32 in DataStream endianness.
'headerTag2', 'uint32be', // Big-endian Uint32.
'headerTag3', 'uint32le', // Little-endian Uint32.
'array', ['[]', 'uint32', 16], // Uint32Array of length 16.
'array2Length', 'uint32',
'array2', ['[]', 'uint32', 'array2Length'] // Uint32Array of length array2Length
]);

The possible values for the type are as follows:

// Number types

// Unsuffixed number types use DataStream endianness.
// To explicitly specify endianness, suffix the type with
// 'le' for little-endian or 'be' for big-endian,
// e.g. 'int32be' for big-endian int32.

'uint8' -- 8-bit unsigned int
'uint16' -- 16-bit unsigned int
'uint32' -- 32-bit unsigned int
'int8' -- 8-bit int
'int16' -- 16-bit int
'int32' -- 32-bit int
'float32' -- 32-bit float
'float64' -- 64-bit float

// String types
'cstring' -- ASCII string terminated by a zero byte.
'string:N' -- ASCII string of length N.
'string,CHARSET:N' -- String of byteLength N encoded with given CHARSET.
'u16string:N' -- UCS-2 string of length N in DataStream endianness.
'u16stringle:N' -- UCS-2 string of length N in little-endian.
'u16stringbe:N' -- UCS-2 string of length N in big-endian.

// Complex types
[name, type, name_2, type_2, ..., name_N, type_N] -- Struct
function(dataStream, struct) {} -- Callback function to read and return data.
{get: function(dataStream, struct) {},
set: function(dataStream, struct) {}}
-- Getter/setter functions to read and return data, handy for using the same
struct definition for reading and writing structs.
['[]', type, length] -- Array of given type and length. The length can be either
a number, a string that references a previously-read
field, or a callback function(struct, dataStream, type){}.
If length is '*', reads in as many elements as it can.

@param {Object} structDefinition Struct definition object.
@return {Object} The read struct. Null if failed to read struct.
###
DataStream::readStruct = (structDefinition) ->
  struct = {}
  t = undefined
  v = undefined
  n = undefined
  p = @position
  i = 0

  while i < structDefinition.length
    t = structDefinition[i + 1]
    v = @readType(t, struct)
    unless v?
      @failurePosition = @position  if @failurePosition is 0
      @position = p
    return null
    struct[structDefinition[i]] = v
    i += 2
  struct


###
Read UCS-2 string of desired length and endianness from the DataStream.

@param {number} length The length of the string to read.
@param {boolean} endianness The endianness of the string data in the DataStream.
@return {string} The read string.
###
DataStream::readUCS2String = (length, endianness) ->
  String.fromCharCode.apply null, @readUint16Array(length, endianness)


###
Write a UCS-2 string of desired endianness to the DataStream. The
lengthOverride argument lets you define the number of characters to write.
If the string is shorter than lengthOverride, the extra space is padded with
zeroes.

@param {string} str The string to write.
@param {?boolean} endianness The endianness to use for the written string data.
@param {?number} lengthOverride The number of characters to write.
###
DataStream::writeUCS2String = (str, endianness, lengthOverride) ->
  lengthOverride = str.length  unless lengthOverride?
  i = 0

  while i < str.length and i < lengthOverride
    @writeUint16 str.charCodeAt(i), endianness
    i++
  while i < lengthOverride
    @writeUint16 0
    i++


###
Read a string of desired length and encoding from the DataStream.

@param {number} length The length of the string to read in bytes.
@param {?string} encoding The encoding of the string data in the DataStream.
Defaults to ASCII.
@return {string} The read string.
###
DataStream::readString = (length, encoding) ->
  if not encoding? or encoding is "ASCII"
    String.fromCharCode.apply null, @mapUint8Array((if not length? then @byteLength - @position else length))
  else
    (new TextDecoder(encoding)).decode @mapUint8Array(length)


###
Writes a string of desired length and encoding to the DataStream.

@param {string} s The string to write.
@param {?string} encoding The encoding for the written string data.
Defaults to ASCII.
@param {?number} length The number of characters to write.
###
DataStream::writeString = (s, encoding, length) ->
  if not encoding? or encoding is "ASCII"
    if length?
      i = 0
      len = Math.min(s.length, length)
      i = 0
      while i < len
        @writeUint8 s.charCodeAt(i)
        i++
      while i < length
        @writeUint8 0
        i++
    else
      i = 0

      while i < s.length
        @writeUint8 s.charCodeAt(i)
        i++
  else
    @writeUint8Array (new TextEncoder(encoding)).encode(s.substring(0, length))


###
Read null-terminated string of desired length from the DataStream. Truncates
the returned string so that the null byte is not a part of it.

@param {?number} length The length of the string to read.
@return {string} The read string.
###
DataStream::readCString = (length) ->
  blen = @byteLength - @position
  u8 = new Uint8Array(@_buffer, @_byteOffset + @position)
  len = blen
  len = Math.min(length, blen)  if length?
  i = 0 # find first zero byte

  while i < len and u8[i] isnt 0
    i++
  s = String.fromCharCode.apply(null, @mapUint8Array(i))
  if length?
    @position += len - i
  else @position += 1  unless i is blen # trailing zero if not at end of buffer
  s


###
Writes a null-terminated string to DataStream and zero-pads it to length
bytes. If length is not given, writes the string followed by a zero.
If string is longer than length, the written part of the string does not have
a trailing zero.

@param {string} s The string to write.
@param {?number} length The number of characters to write.
###
DataStream::writeCString = (s, length) ->
  if length?
    i = 0
    len = Math.min(s.length, length)
    i = 0
    while i < len
      @writeUint8 s.charCodeAt(i)
      i++
    while i < length
      @writeUint8 0
      i++
  else
    i = 0

    while i < s.length
      @writeUint8 s.charCodeAt(i)
      i++
    @writeUint8 0


###
Reads an object of type t from the DataStream, passing struct as the thus-far
read struct to possible callbacks that refer to it. Used by readStruct for
reading in the values, so the type is one of the readStruct types.

@param {Object} t Type of the object to read.
@param {?Object} struct Struct to refer to when resolving length references
and for calling callbacks.
@return {?Object} Returns the object on successful read, null on unsuccessful.
###
DataStream::readType = (t, struct) ->
  if typeof t is "function"
    return t(this, struct)
  else if typeof t is "object" and (t not instanceof Array)
    return t.get(this, struct)
  else return @readStruct(t, struct)  if t instanceof Array and t.length isnt 3
  v = null
  lengthOverride = null
  charset = "ASCII"
  pos = @position
  if typeof t is "string" and /:/.test(t)
    tp = t.split(":")
    t = tp[0]
    lengthOverride = parseInt(tp[1])
  if typeof t is "string" and /,/.test(t)
    tp = t.split(",")
    t = tp[0]
    charset = parseInt(tp[1])
  switch t
    when "uint8"
      v = @readUint8()
    when "int8"
      v = @readInt8()
    when "uint16"
      v = @readUint16(@endianness)
    when "int16"
      v = @readInt16(@endianness)
    when "uint32"
      v = @readUint32(@endianness)
    when "int32"
      v = @readInt32(@endianness)
    when "float32"
      v = @readFloat32(@endianness)
    when "float64"
      v = @readFloat64(@endianness)
    when "uint16be"
      v = @readUint16(DataStream.BIG_ENDIAN)
    when "int16be"
      v = @readInt16(DataStream.BIG_ENDIAN)
    when "uint32be"
      v = @readUint32(DataStream.BIG_ENDIAN)
    when "int32be"
      v = @readInt32(DataStream.BIG_ENDIAN)
    when "float32be"
      v = @readFloat32(DataStream.BIG_ENDIAN)
    when "float64be"
      v = @readFloat64(DataStream.BIG_ENDIAN)
    when "uint16le"
      v = @readUint16(DataStream.LITTLE_ENDIAN)
    when "int16le"
      v = @readInt16(DataStream.LITTLE_ENDIAN)
    when "uint32le"
      v = @readUint32(DataStream.LITTLE_ENDIAN)
    when "int32le"
      v = @readInt32(DataStream.LITTLE_ENDIAN)
    when "float32le"
      v = @readFloat32(DataStream.LITTLE_ENDIAN)
    when "float64le"
      v = @readFloat64(DataStream.LITTLE_ENDIAN)
    when "cstring"
      v = @readCString(lengthOverride)
    when "string"
      v = @readString(lengthOverride, charset)
    when "u16string"
      v = @readUCS2String(lengthOverride, @endianness)
    when "u16stringle"
      v = @readUCS2String(lengthOverride, DataStream.LITTLE_ENDIAN)
    when "u16stringbe"
      v = @readUCS2String(lengthOverride, DataStream.BIG_ENDIAN)
    else
      if t.length is 3
        ta = t[1]
        len = t[2]
        length = 0
        if typeof len is "function"
          length = len(struct, this, t)
        else if typeof len is "string" and struct[len]?
          length = parseInt(struct[len])
        else
          length = parseInt(len)
        if typeof ta is "string"
          tap = ta.replace(/(le|be)$/, "")
          endianness = null
          if /le$/.test(ta)
            endianness = DataStream.LITTLE_ENDIAN
          else endianness = DataStream.BIG_ENDIAN  if /be$/.test(ta)
          length = null  if len is "*"
          switch tap
            when "uint8"
              v = @readUint8Array(length)
            when "uint16"
              v = @readUint16Array(length, endianness)
            when "uint32"
              v = @readUint32Array(length, endianness)
            when "int8"
              v = @readInt8Array(length)
            when "int16"
              v = @readInt16Array(length, endianness)
            when "int32"
              v = @readInt32Array(length, endianness)
            when "float32"
              v = @readFloat32Array(length, endianness)
            when "float64"
              v = @readFloat64Array(length, endianness)
            when "cstring", "utf16string"
            , "string"
              unless length?
                v = []
                until @isEof()
                  u = @readType(ta, struct)
                  break  unless u?
                  v.push u
              else
                v = new Array(length)
                i = 0

                while i < length
                  v[i] = @readType(ta, struct)
                  i++
        else
          if len is "*"
            v = []
            @buffer
            loop
              p = @position
              try
                o = @readType(ta, struct)
                unless o?
                  @position = p
                  break
                v.push o
              catch e
                @position = p
                break
          else
            v = new Array(length)
            i = 0

            while i < length
              u = @readType(ta, struct)
              return null  unless u?
              v[i] = u
              i++
        break
  @position = pos + lengthOverride  if lengthOverride?
  v


###
Writes a struct to the DataStream. Takes a structDefinition that gives the
types and a struct object that gives the values. Refer to readStruct for the
structure of structDefinition.

@param {Object} structDefinition Type definition of the struct.
@param {Object} struct The struct data object.
###
DataStream::writeStruct = (structDefinition, struct) ->
  i = 0

  while i < structDefinition.length
    t = structDefinition[i + 1]
    @writeType t, struct[structDefinition[i]], struct
    i += 2


###
Writes object v of type t to the DataStream.

@param {Object} t Type of data to write.
@param {Object} v Value of data to write.
@param {Object} struct Struct to pass to write callback functions.
###
DataStream::writeType = (t, v, struct) ->
  if typeof t is "function"
    return t(this, v)
  else return t.set(this, v, struct)  if typeof t is "object" and (t not instanceof Array)
  lengthOverride = null
  charset = "ASCII"
  pos = @position
  if typeof (t) is "string" and /:/.test(t)
    tp = t.split(":")
    t = tp[0]
    lengthOverride = parseInt(tp[1])
  if typeof t is "string" and /,/.test(t)
    tp = t.split(",")
    t = tp[0]
    charset = parseInt(tp[1])
  switch t
    when "uint8"
      @writeUint8 v
    when "int8"
      @writeInt8 v
    when "uint16"
      @writeUint16 v, @endianness
    when "int16"
      @writeInt16 v, @endianness
    when "uint32"
      @writeUint32 v, @endianness
    when "int32"
      @writeInt32 v, @endianness
    when "float32"
      @writeFloat32 v, @endianness
    when "float64"
      @writeFloat64 v, @endianness
    when "uint16be"
      @writeUint16 v, DataStream.BIG_ENDIAN
    when "int16be"
      @writeInt16 v, DataStream.BIG_ENDIAN
    when "uint32be"
      @writeUint32 v, DataStream.BIG_ENDIAN
    when "int32be"
      @writeInt32 v, DataStream.BIG_ENDIAN
    when "float32be"
      @writeFloat32 v, DataStream.BIG_ENDIAN
    when "float64be"
      @writeFloat64 v, DataStream.BIG_ENDIAN
    when "uint16le"
      @writeUint16 v, DataStream.LITTLE_ENDIAN
    when "int16le"
      @writeInt16 v, DataStream.LITTLE_ENDIAN
    when "uint32le"
      @writeUint32 v, DataStream.LITTLE_ENDIAN
    when "int32le"
      @writeInt32 v, DataStream.LITTLE_ENDIAN
    when "float32le"
      @writeFloat32 v, DataStream.LITTLE_ENDIAN
    when "float64le"
      @writeFloat64 v, DataStream.LITTLE_ENDIAN
    when "cstring"
      @writeCString v, lengthOverride
    when "string"
      @writeString v, charset, lengthOverride
    when "u16string"
      @writeUCS2String v, @endianness, lengthOverride
    when "u16stringle"
      @writeUCS2String v, DataStream.LITTLE_ENDIAN, lengthOverride
    when "u16stringbe"
      @writeUCS2String v, DataStream.BIG_ENDIAN, lengthOverride
    else
      if t.length is 3
        ta = t[1]
        i = 0

        while i < v.length
          @writeType ta, v[i]
          i++
        break
      else
        @writeStruct t, v
        break
  if lengthOverride?
    @position = pos
    @_realloc lengthOverride
    @position = pos + lengthOverride