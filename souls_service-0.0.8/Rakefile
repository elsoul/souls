require "yaml"
require "erb"
require "logger"

desc "Generate proto files"
task :proto do
  system "grpc_tools_ruby_protoc -I ./protos --ruby_out=./app/services --grpc_out=./app/services ./protos/blog.proto"
end

desc "Run gRPC Server"
task :run_server do
  system "ruby grpc_server.rb"
end

desc "Run gRPC Client"
task :run_client do
  system "ruby greeter_client.rb"
end

desc "Run gRPC Server with Docker"
task :run_test do
  system "docker build . -t souls_service:latest"
  system "docker rm -f web"
  system "docker run --name web -p 50051:50051 souls_service:latest"
end

desc "Update Google Container Registry"
task :update do
  version = ARGV[1]
  project_id = "elsoul2"
  system("docker build . -t souls_service:#{version}")
  system("docker tag souls_service:#{version} asia.gcr.io/#{project_id}/souls_service:#{version}")
  system("docker push asia.gcr.io/#{project_id}/souls_service:#{version}")
end