#!/usr/bin/env ruby
# encoding: utf-8
 
require "rubygems"
require "amqp"
 
EventMachine.run do
	AMQP.connect(:host => '127.0.0.1') do |connection|
		puts "Connected to AMQP broker. Running #{AMQP::VERSION} version of the gem..."
		channel  = AMQP::Channel.new(connection)
		queue=channel.queue("amqpgem.examples.helloworld", :auto_delete => true)
		queue.subscribe do |payload|
			puts "Received a message: #{payload}"
		#	connection.close { EventMachine.stop }
		end
		puts "queue name: #{queue.name}"
	#	queue = channel.queue("amqpgem.examples.hello_world", :auto_delete => true)
	#	channel.direct("").publish "Hello, world!", :routing_key => "amqpgem.examples.helloworld"
	end
end


