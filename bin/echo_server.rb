#!/usr/bin/env ruby
$LOAD_PATH.unshift ::File.expand_path(::File.dirname(__FILE__) + '/../lib')

require 'echo_server'

EchoServer.run('localhost',3000)