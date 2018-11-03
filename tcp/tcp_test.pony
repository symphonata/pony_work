use "net"

class MyTCPConnectionNotify is TCPConnectionNotify
  fun ref received(
    conn: TCPConnection ref,
    data: Array[U8] iso,
    times: USize)
    : Bool
  =>
    conn.write(String.from_array(consume data))
    true

  fun ref connect_failed(conn: TCPConnection ref) =>
    None

class MyTCPListenNotify is TCPListenNotify
  fun ref connected(listen: TCPListener ref): TCPConnectionNotify iso^ =>
    MyTCPConnectionNotify

  fun ref not_listening(listen: TCPListener ref) =>
    None

actor Main
  new create(env: Env) =>
    try
      TCPListener(env.root as AmbientAuth,
        recover MyTCPListenNotify end, "0.0.0.0", "8989")
    end