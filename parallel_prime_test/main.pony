use "time"
use "collections"
use "itertools"

actor Main
  new create(env: Env) => Coordinator(env)

actor Coordinator
  let _joinByComma: {(String, Stringable): String} = { (s, u) => s + u.string() + ", "} // lambda表达式，语法略啰嗦
  let _cpuCores: U8 = 8
  var _runningWorkerNum: U8 = 0
  let _taskStartTimeNanos: U64 = Time.nanos()

  new create(env: Env) =>
    let out = env.out
    try
      let upperBound = env.args(1)?.u64()? // ？表示调用的函数可能抛异常，异常处理过于简单，不方便定位问题
      let rangeLen = upperBound / _cpuCores.u64()
      out.print("Using upper bound: " + upperBound.string() + " rangeLen: " + rangeLen.string()) // 字符串拼接构建方式比较傻，不够方便

      var rangeBegin: U64 = 0
      while rangeBegin < upperBound do
        let rangeEnd = ((rangeBegin + rangeLen) - 1).min(upperBound) // 连续用infix运算符必须加括号指定优先级，否则编译报错
        PrimeTestWorker((rangeBegin, rangeEnd), this).start()
        _runningWorkerNum = _runningWorkerNum + 1
        rangeBegin = rangeEnd + 1
      end
    else
      let args = Iter[String](env.args.values()).fold[String]("[", _joinByComma) + "]" // 使用函数式操作集合语法略啰嗦
      out.print("Invalid args: " + args)
    end

  be report(primes: Array[U64] val, range: (U64, U64)) =>
    @printf[I32]("%d prime numbers found in range [%d, %d].\n".cstring(), primes.size(), range._1, range._2) // 支持FFI可以直接调用C的库
    _runningWorkerNum = _runningWorkerNum - 1
    if _runningWorkerNum == 0 then
      let costNanos = Time.nanos() - _taskStartTimeNanos
      @printf[I32]("Total cost time: %dms\n".cstring(), costNanos / 1_000_000)
    end

  fun _final() =>
    @printf[I32]("Coordinator finalized.\n".cstring())

actor PrimeTestWorker
  let _range: (U64, U64)
  let _coord: Coordinator tag

  let _isPrime: {(U64): Bool} val = { (n) =>
    if n <= 1 then false
    elseif n <= 3 then true
    elseif ((n % 2) == 0) or ((n % 3) == 0) then false
    else
      var i: U64 = 5
      while (i * i) <= n do
        if ((n % i) == 0) or ((n % (i + 2)) == 0) then
          break false // break可以带表达式的返回值
        end
        i = i + 6 // 没有i++，i+=6之类的运算符
        true
      else
        true
      end
    end
  }

  new create(range: (U64, U64), coord: Coordinator tag) =>
    _range = range
    _coord = coord

  fun _logEvent(event: String) =>
    (let min, let max) = _range
    @printf[I32]("Worker with range [%d, %d] %s.\n".cstring() , min, max, event.cstring())

  be start() =>
    _logEvent("started")
    (let min, let max) = _range
    let result = recover val Iter[U64](Range[U64](min, max + 1)).filter(_isPrime).collect(Array[U64]) end
    _coord.report(result, _range)

  fun _final() =>
    _logEvent("finalized")
    


    
    