use "time"

class MCNotify is TimerNotify
  let _mc: MemoryConsumer tag

  new iso create(mc: MemoryConsumer tag) => _mc = mc

  fun apply(timer: Timer, count: U64): Bool =>
    _mc.allocMemory()
    true
    
actor MemoryConsumer
  let _env: Env
  var _bigData: (BigData | None) = None

  new create(env: Env, timers: Timers) =>
    _env = env
    let interval = Nanos.from_millis(100)
    let timer = Timer(MCNotify(this), interval, interval)
    timers(consume timer)

  be allocMemory() => 
    _env.out.print("allocMemory")
    _bigData = BigData
    
class BigData
  let _data: Array[I64]
  new create() => _data = Array[I64](1024)