#https://github.com/celluloid/celluloid-io/blob/master/examples/echo_server.rb

require 'bundler/setup'
require 'celluloid/io'

class EchoServer
  include Celluloid::IO
  finalizer :finalize

  def initialize(host, port)
    puts "*** Starting echo server on #{host}:#{port}"

    # Since we included Celluloid::IO, we're actually making a
    # Celluloid::IO::TCPServer here
    @server = TCPServer.new(host, port)
    async.run
  end

  def finalize
    @server.close if @server
  end

  def run
    loop { async.handle_connection @server.accept }
  end

  def handle_connection(socket)
    _, port, host = socket.peeraddr
    puts "*** Received connection from #{host}:#{port}"
    
    # Original:
    # loop { socket.write socket.readpartial(4096) }
    
    # Changed:
    # This could be a timeout, or any condition under
    # which the server should terminate the connection
    # instead of waiting for a remote connection disconnect 
    loop { 
      data = socket.readpartial(4096) 
      if data.chomp == "fubar"
        socket.close  # Closing this ONE socket closes all other open sockets
      end
      socket.write data 
    }
    
  rescue EOFError
    puts "*** #{host}:#{port} disconnected"
    socket.close
  rescue IOError
    puts "*** IOError detected"
  end
end