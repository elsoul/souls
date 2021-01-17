module HelloMethod
  def say_hello(hello_req, _unused_call)
    logger = Logger.new(STDOUT)
    logger.info hello_req
    Souls::HelloReply.new(message: "Hello #{hello_req.name}")
  end

  def say_hello_again(hello_req, _unused_call)
    logger = Logger.new(STDOUT)
    logger.info hello_req
    Souls::HelloReply.new(message: "Works Perfect, #{hello_req.name}")
  end
end
