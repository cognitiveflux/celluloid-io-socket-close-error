require 'echo_server'
require 'socket'

describe EchoServer do
  before(:all) do
    @es = EchoServer.new("localhost",3000)
  end
    
  describe "#handle_connection" do
    let(:server1) { TCPSocket.open("localhost",3000)}
    let(:server2) { TCPSocket.open("localhost",3000)}
    it "should echo messages sent from client" do
      server1.puts("hello")
      expect(server1.gets).to eq("hello\n")
      server2.puts("world")
      expect(server2.gets).to eq("world\n")
    end
    
    it "should continue to handle send/receive with client disconnects" do
      server1.close
      server2.puts("bar")
      expect(server2.gets).to eq("bar\n")
    end
    
    it "should not terminate when closing a single connection socket" do
      server1.puts("foo")
      expect(server1.gets).to eq("foo\n")
      server2.puts("fubar") # Keyword that triggers server to close just this connection
      expect{@es.nil?}.to_not raise_error # Celluloid::DeadActorError
    end
    
    it "should allow new connections after closing a single connection socket" do
      expect {server1.puts("foo")}.to_not raise_exception # Errno::ECONNREFUSED
    end
    
    it "should not close the socket for all remaining connections if only one connection is closed" do
      new_echo_server = EchoServer.new("localhost", 3000)
      server1.puts("foo")
      expect(server1.gets).to eq("foo\n")
      server2.puts("fubar")
      expect {Timeout::timeout(10) {server1.puts("bar"); server1.gets}}.to_not raise_error # Timeout::Error
    end
    
  end
end

    