
require "amqp"
 
#AMQP.start(:host => 'localhost') do
EventMachine.run do
  AMQP.connect do |connection|
	channel  = AMQP::Channel.new(connection)

	channel = AMQP::Channel.new(connection)
	queue   = AMQP::Queue.new(channel, "amqpgem.examples.queues.shared", :auto_delete => true)

	queue.subscribe do |payload|
		puts "Queue #{queue.name} received #{payload}"
	end
 
	puts "#{queue.name} is ready to go."
 
#	connection.close {
#		EventMachine.stop { exit }
#	}

	end
end



