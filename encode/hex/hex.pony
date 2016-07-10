primitive Hex
  fun encode[A: Seq[U8] iso = String iso](src: ReadSeq[U8]): A^ =>
    //let table = "0123456789abcdef"
    //let table = [as U8: '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f']
    let table = [as U8: 48,49,50,51,52,53,54,55,56,57,97,98,99,100,101,102]

    let src_len = src.size()
    var dst = recover A(src_len * 2) end
    var i: USize = 0

    try
      while i < src_len do
        dst.push(table((src(i) >> 4).usize()))
        dst.push(table((src(i) and 0x0f).usize()))
        i = i + 1
      end
    end

    dst

  fun decode[A: Seq[U8] iso = String iso](src: ReadSeq[U8], env: Env): A^ ? =>
    let src_len = src.size()
    if (src_len % 2) != 0 then error end
    let dst_len = src_len / 2

    var dst = recover A(dst_len) end
    var i: USize = 0

    try
      while i < dst_len do
        var a = _from_hex_char(src(i * 2))
        if a._2 == false then error end
        var b = _from_hex_char(src((i * 2) + 1))
        if b._2 == false then error end
        dst.push((a._1 << 4) or b._1)
        i = i + 1
      end
    end

    dst

  fun _from_hex_char(c: U8): (U8, Bool) =>
    if ('0' <= c) and (c <= '9') then (c - '0', true)
    elseif ('a' <= c) and (c <= 'f') then ((c - 'a') + 10, true)
    elseif ('A' <= c) and (c <= 'F') then ((c - 'A') + 10, true)
    else (0, false)
    end
