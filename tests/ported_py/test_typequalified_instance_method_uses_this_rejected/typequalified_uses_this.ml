struct S
  x
  function inc()
    this.x = this.x + 1
    return this.x
  end function

  static function run()
    // illegal: missing receiver, and method uses `this`
    return S.inc()
  end function
end struct

function main(args)
  print S.run()
end function
