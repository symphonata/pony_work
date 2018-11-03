use "format"

actor Main
  fun disp(desc: String, v: I32, fmt: FormatInt = FormatDefault): String =>
    Format(desc where width = 10)
      + ":"
      + Format.int[I32](v where width = 10, align = AlignRight, fmt = fmt)

  new create(env: Env) =>
    try
      (let x, let y) = (env.args(1)?.i32()?, env.args(2)?.i32()?)
      env.out.print(disp("x", x))
      env.out.print(disp("y", y))
      env.out.print(disp("hex(x)", x, FormatHex))
      env.out.print(disp("hex(y)", y, FormatHex))
      env.out.print(disp("x * y", x * y))
    else
      let exe = try env.args(0)? else "fmt_example" end
      env.err.print("Usage: " + exe + " NUMBER1 NUMBER2")
    end
