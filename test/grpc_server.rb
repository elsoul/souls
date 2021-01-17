require "./app"

def main
  s = GRPC::RpcServer.new
  s.add_http2_port("0.0.0.0:50051", :this_port_is_insecure)
  s.handle(ApplicationController)
  logger = Logger.new(STDOUT)
  logger.info "Running Server! SOULs Ready on localhost:50051"
  s.run_till_terminated_or_interrupted([1, "int", "SIGQUIT"])
end

main
