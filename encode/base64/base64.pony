class Base64
  let _en_table: Array[U8]
  let _de_table: Array[U8]
  let _pad_char: U8

  new create(str: String = 
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/") ? =>
    if str.size() != 64 then error end

    _en_table = Array[U8](64)

    var i: USize = 0
    while i < 64 do
      _en_table.push(str(i))
      i = i + 1
    end

    _de_table = Array[U8].init(0xff,256)

    i = 0
    while i < 64 do
      _de_table(_en_table(i.usize()).usize()) = i.u8()
      i = i + 1
    end
    _pad_char = '='


  fun encode[A: Seq[U8] iso = String iso](src: ReadSeq[U8]): A^ =>
    let len = ((src.size() + 2) / 3) * 4
    let dst = recover A(len) end

    var si: USize = 0
    var n: USize = (src.size() / 3) * 3

    try
      while si < n do   
        var v = (src(si + 0).usize() << 16) or (src(si + 1).usize() << 8) or src(si + 2).usize()

        dst.push(_en_table((v >> 18) and 0x3f))
        dst.push(_en_table((v >> 12) and 0x3f)) 
        dst.push(_en_table((v >> 6) and 0x3f))
        dst.push(_en_table(v and 0x3f))

        si = si + 3
      end     
    end

    var remain = src.size() - si
    if remain == 0 then dst end

    try
      var v = src(si + 0).usize() << 16
      if remain == 2 then v = v or (src(si + 1).usize() << 8) end

      dst.push(_en_table((v >> 18) and 0x3f))
      dst.push(_en_table((v >> 12) and 0x3f))

      match remain
      |2 =>
        dst.push(_en_table((v >> 6) and 0x3f))
        dst.push(_pad_char)
      |1 =>
        dst.push(_pad_char)
        dst.push(_pad_char)
      end
    end

    dst


  fun decode[A: Seq[U8] iso = String iso](src: ReadSeq[U8]): A^ ?=>
    let len = (src.size() * 4) / 3
    let dst = recover A(len) end

    let src_len = src.size()
    var si: USize = 0

    while (si < src_len) and ((src(si) == '\n') or (src(si) == '\r'))  do
      si = si + 1
    end

    var is_end: Bool = false
    
    while (si < src_len) and (is_end == false) do
      var dbuf = [as U8:0, 0, 0, 0]
      var dinc: USize = 3
      var dlen: USize = 4
      var i: USize = 0
      while i < 4 do
        if si == src_len then
          if i < 2 then error end
          dinc = i - 1
          dlen = i
          is_end = true
          break
        end
        var now: U8 = 0
        now = src(si)
        si = si + 1
        while (si < src_len) and ((src(si) == '\n') or (src(si) == '\r'))  do
          si = si + 1
        end

        if now == _pad_char then
          if (i == 0) or (i == 1) then error end
          if i == 2 then
            if si == src_len then error end
            if src(si) != _pad_char then error end
            si = si + 1
            while (si < src_len) and ((src(si) == '\n') or (src(si) == '\r')) do
              si = si + 1
            end
          end
          if si < src_len then None end
          dinc = 3
          dlen = i
          is_end = true
          break
        end

        dbuf(i)= _de_table(now.usize())
        if dbuf(i) == 0xff then error end

        i = i + 1
      end

      var v = (dbuf(0).usize() << 18) or (dbuf(1).usize() << 12) or (dbuf(2).usize() << 6) or (dbuf(3).usize())

      if dlen > 1 then
        dst.push((v >> 16).u8())
      end
      if dlen > 2 then
        dst.push((v >> 8).u8())
      end
      if dlen > 3 then
        dst.push((v >> 0).u8())
      end
    end

    dst