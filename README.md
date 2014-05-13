celluloid-io-socket-close-error
===============================

This provides an error example for Celluloid::IO.  The current commit includes a ```rescue IOError``` clause to prevent the crash.

A server initiatied socket closure terminates (e.g. as a result of invalid input or more likley, a server side timeout) the actor and **all** associated sockets.

Based off of Celluloid::IO echo server example:

https://github.com/celluloid/celluloid-io/blob/master/examples/echo_server.rb

Start the server:
```ruby
#  bin/echo_server.rb
```

Connect to the server, it will echo back your input:
```bash
# echo "foo" | nc localhost 3000
foo

# echo "bar" | nc localhost 3000
bar
```

Now send a keyword to the server, at which point the server should disconnect JUST that socket.  Note that this could be triggered by many things, most likely a server-side timeout:
```bash
# echo "fubar" | nc localhost 3000
```

On the console you should see the EchoServer crash:
```bash
E, [2014-05-13T00:59:25.023262 #60791] ERROR -- : EchoServer crashed!
IOError: closed stream
	[PATH]/gems/ruby-2.0.0-p247@celluloid-bug/gems/celluloid-io-0.15.0/lib/celluloid/io/stream.rb:64:in `block in syswrite'
	[PATH]/gems/ruby-2.0.0-p247@celluloid-bug/gems/celluloid-io-0.15.0/lib/celluloid/io/stream.rb:390:in `synchronize'
	[PATH]/gems/ruby-2.0.0-p247@celluloid-bug/gems/celluloid-io-0.15.0/lib/celluloid/io/stream.rb:61:in `syswrite'
	[PATH]/gems/ruby-2.0.0-p247@celluloid-bug/gems/celluloid-io-0.15.0/lib/celluloid/io/stream.rb:356:in `do_write'
	[PATH]/gems/ruby-2.0.0-p247@celluloid-bug/gems/celluloid-io-0.15.0/lib/celluloid/io/stream.rb:249:in `write'
	[REPO-PATH]/celluloid-io-socket-close-error/lib/echo_server.rb:43:in `block in handle_connection'
	[REPO-PATH]/celluloid-io-socket-close-error/lib/echo_server.rb:38:in `loop'
	[REPO-PATH]/celluloid-io-socket-close-error/lib/echo_server.rb:38:in `handle_connection'
	[PATH]/gems/ruby-2.0.0-p247@celluloid-bug/gems/celluloid-0.15.2/lib/celluloid/calls.rb:25:in `public_send'
	[PATH]/gems/ruby-2.0.0-p247@celluloid-bug/gems/celluloid-0.15.2/lib/celluloid/calls.rb:25:in `dispatch'
	[PATH]/gems/ruby-2.0.0-p247@celluloid-bug/gems/celluloid-0.15.2/lib/celluloid/calls.rb:122:in `dispatch'
	[PATH]/gems/ruby-2.0.0-p247@celluloid-bug/gems/celluloid-0.15.2/lib/celluloid/actor.rb:322:in `block in handle_message'
	[PATH]/gems/ruby-2.0.0-p247@celluloid-bug/gems/celluloid-0.15.2/lib/celluloid/actor.rb:416:in `block in task'
	[PATH]/gems/ruby-2.0.0-p247@celluloid-bug/gems/celluloid-0.15.2/lib/celluloid/tasks.rb:55:in `block in initialize'
	[PATH]/gems/ruby-2.0.0-p247@celluloid-bug/gems/celluloid-0.15.2/lib/celluloid/tasks/task_fiber.rb:13:in `block in create'
W, [2014-05-13T00:59:25.024824 #60791]  WARN -- : Terminating task: type=:call, meta={:method_name=>:run}, status=:iowait
```

If the server is working as expected, the proposed tests should complete successfully:
```bash
# rspec
```

Adding a ```rescue IOError``` clause will prevent the actor from crashing and thus keep the remaining connections open:
https://github.com/cognitiveflux/celluloid-io-socket-close-error/blob/master/lib/echo_server.rb#L49