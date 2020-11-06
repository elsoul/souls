require "yaml"
require "grpc"
require "./app"

def main
  user = !ARGV.empty? ? ARGV[0] : "world"
  hostname = ARGV.size > 1 ? ARGV[1] : "localhost:50051"
  stub = Helloworld::Greeter::Stub.new(hostname, :this_channel_is_insecure)
  begin
    message = stub.say_hello(Helloworld::HelloRequest.new(name: user)).message
    p "Greeting: #{message}"
    message = stub.say_hello_again(Helloworld::HelloRequest.new(name: user)).message
    p "Greeting: #{message}"
  rescue GRPC::BadStatus => e
    abort "ERROR: #{e.message}"
  end
end

main
