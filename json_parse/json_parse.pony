use "json"

actor Main
  new create(env: Env) =>
    var jsonSum: I64 = 0
    let jd: JsonDoc = JsonDoc
    for arg in env.args.slice(1).values() do
      try
        jd.parse(arg)?
        jsonSum = jsonSum + (jd.data as I64)
      else
        env.out.print("Parse " + arg + " failed.")
      end
    end
    env.out.print(jsonSum.string())