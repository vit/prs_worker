#!/usr/bin/env ruby
# encoding: utf-8
 
require "rubygems"
require "amqp"
 
EventMachine.run do
	AMQP.connect(:host => '127.0.0.1') do |connection|
		puts "Connected to AMQP broker. Running #{AMQP::VERSION} version of the gem..."
		channel  = AMQP::Channel.new(connection)
		qn = "amqpgem.examples.hello_world"
	#	queue = channel.queue("amqpgem.examples.hello_world", :auto_delete => true)
		exchange = channel.default_exchange

	#	channel.queue("amqpgem.examples.helloworld", :auto_delete => true).subscribe do |payload|
	#		puts "Received a message: #{payload}. Disconnecting..."
	#	#	connection.close { EventMachine.stop }
	#	end

#		exchange.publish "Hello, world!", :routing_key => queue.name, :app_id => "Hello world"
#		exchange.publish "Hello, world!", :routing_key => queue.name
		exchange.publish "Hello, world!", :routing_key => qn

#		channel.direct("").publish "Hello, world! 001", :routing_key => "amqpgem.examples.helloworld"
#		sleep(200)
#		channel.direct("").publish "Hello, world! 002", :routing_key => "amqpgem.examples.helloworld"
#		sleep(200)
#		channel.direct("").publish "Hello, world! 003", :routing_key => "amqpgem.examples.helloworld"


		connection.close { EventMachine.stop }
	end
end


