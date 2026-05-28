(module

  (memory (export "memory") 2)

  (func $find_dkim (export "find_dkim")
    (param $sptr i32)
    (param $eptr i32)
    (result i32)

    ;; input $sptr: the pointer to the start of the string(haystack)
    ;; input $eptr: the pointer to the end of the string
    ;; result:
    ;;   - if found: the pointer to the first "dkim="
    ;;   - if missing: -1
    ;; assumption: comments already removed, input fits in a page
    ;; example:
    ;;   input: ares.example.com; dkim=pass
    ;;          0123456789abcdef0123456789
    ;;          ^                 ^      ^
    ;;          sptr              |      eptr
    ;;                            found!
    ;;   output: 0x0000_0012

    (local $icur i32)

    local.get $sptr
    local.set $icur

    loop
      ;; return -1 if not found
      local.get $eptr
      local.get $icur
      i32.lt_u
      if
        i32.const -1
        return
      end

      ;; process 8 times per loop
      ;; e.g.,
      ;;   01234567
      ;;    12345678
      ;;     23456789
      ;;      3456789a
      ;;
      ;;       456789ab
      ;;        56789abc
      ;;         6789abcd
      ;;          789abcde

      ;; load the 1st 8 bytes; e.g., 0,1,2,3,4,5,6,7
      local.get $icur
      i64.load offset=0
      i64.const 0x0000_00ff_ffff_ffff
      i64.and
      i64.const 0x0000_003d_6d69_6b64
      i64.eq
      if
        local.get $icur
        return
      end

      ;; load the 2nd 8 bytes; e.g., 1,2,3,4,5,6,7,8
      local.get $icur
      i64.load offset=1
      i64.const 0x0000_00ff_ffff_ffff
      i64.and
      i64.const 0x0000_003d_6d69_6b64
      i64.eq
      if
        local.get $icur
        i32.const 1
        i32.add
        return
      end

      ;; load the 3rd 8 bytes; e.g., 2,3,4,5,6,7,8,9
      local.get $icur
      i64.load offset=2
      i64.const 0x0000_00ff_ffff_ffff
      i64.and
      i64.const 0x0000_003d_6d69_6b64
      i64.eq
      if
        local.get $icur
        i32.const 2
        i32.add
        return
      end

      ;; load the 4th 8 bytes; e.g., 3,4,5,6,7,8,9,a
      local.get $icur
      i64.load offset=3
      i64.const 0x0000_00ff_ffff_ffff
      i64.and
      i64.const 0x0000_003d_6d69_6b64
      i64.eq
      if
        local.get $icur
        i32.const 3
        i32.add
        return
      end

      ;; load the 5th 8 bytes; e.g., 4,5,6,7,8,9,a,b
      local.get $icur
      i64.load offset=4
      i64.const 0x0000_00ff_ffff_ffff
      i64.and
      i64.const 0x0000_003d_6d69_6b64
      i64.eq
      if
        local.get $icur
        i32.const 4
        i32.add
        return
      end

      ;; load the 6th 8 bytes; e.g., 5,6,7,8,9,a,b,c
      local.get $icur
      i64.load offset=5
      i64.const 0x0000_00ff_ffff_ffff
      i64.and
      i64.const 0x0000_003d_6d69_6b64
      i64.eq
      if
        local.get $icur
        i32.const 5
        i32.add
        return
      end

      ;; load the 7th 8 bytes; e.g., 6,7,8,9,a,b,c,d
      local.get $icur
      i64.load offset=6
      i64.const 0x0000_00ff_ffff_ffff
      i64.and
      i64.const 0x0000_003d_6d69_6b64
      i64.eq
      if
        local.get $icur
        i32.const 6
        i32.add
        return
      end

      ;; load the 8th 8 bytes; e.g., 7,8,9,a, b,c,d,e
      local.get $icur
      i64.load offset=7
      i64.const 0x0000_00ff_ffff_ffff
      i64.and
      i64.const 0x0000_003d_6d69_6b64
      i64.eq
      if
        local.get $icur
        i32.const 7
        i32.add
        return
      end

      ;; process next
      local.get $icur
      i32.const 8
      i32.add
      local.set $icur

      br 0

    end

    i32.const -1
  )

  (func $classify_dkim (export "classify_dkim")
    (param $dkim i32)
    (result i32)

    ;; input $dkim: the dkim value
    ;; output: dkim type
    ;; example:
    ;;   input: "pass" (0x7373_6170) -> 1
    ;;   input: "fail" (0x6c69_6166) -> 2
    ;;   input: (anything else)      -> 0

    local.get $dkim
    i32.const 0x7373_6170
    i32.eq
    if
      i32.const 1
      return
    end

    local.get $dkim
    i32.const 0x6c69_6166
    i32.eq
    if
      i32.const 2
      return
    end

    i32.const 0
  )

  (func $find_classify_dkim (export "find_classify_dkim")
    (param $sptr i32)
    (param $eptr i32)
    (result i32)

    ;; find the "dkim="
    local.get $sptr
    local.get $eptr
    call $find_dkim

    ;; navigate to the value part of "dkim=****"
    i32.const 5
    i32.add

    ;; load the value part
    i32.load

    ;; classify
    call $classify_dkim
  )

)
