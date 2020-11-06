require "./app/services/helloworld_services_pb"

class GreeterServerController < Helloworld::Greeter::Service
  # say_hello implements the SayHello rpc method.
  def say_hello(hello_req, _unused_call)
    logger = Logger.new(STDOUT)
    res = Helloworld::HelloReply.new(message: "Hello #{hello_req.name}") 
    logger.info res
    res
  end

  def say_hello_again(hello_req, _unused_call)
    Helloworld::HelloReply.new(message: "Hello again, #{hello_req.name}")
  end
end