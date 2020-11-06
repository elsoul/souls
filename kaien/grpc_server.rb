require "./app"

# main starts an RpcServer that receives requests to GreeterServer at the sample
# server port.
def main
  s = GRPC::RpcServer.new
  s.add_http2_port("0.0.0.0:50051", :this_port_is_insecure)
  s.handle(GreeterServerController)
  logger = Logger.new(STDOUT)
  logger.info "Running Server! Ready on localhost:50051"
  # Runs the server with SIGHUP, SIGINT and SIGQUIT signal handlers to
  #   gracefully shutdown.
  # User could also choose to run server via call to run_till_terminated
  s.run_till_terminated_or_interrupted([1, "int", "SIGQUIT"])
end

main
