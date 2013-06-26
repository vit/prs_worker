
require "amqp"
 
#AMQP.start(:host => 'localhost') do
EventMachine.run do
  AMQP.connect do |connection|
	channel  = AMQP::Channel.new(connection)

	channel = AMQP::Channel.new(connection)
	queue   = AMQP::Queue.new(channel, "amqpgem.examples.queues.shared", :auto_delete => true)

#	queue.subscribe do |payload|
#		puts "Queue #{queue.name} received #{payload}"
#	end
 
	puts "#{queue.name} is ready to go."
	EventMachine.add_timer(0.5) do
	nn = 2
	while nn>0 do
#	loop do
		queue.pop do |metadata, payload|
			if payload
				puts "Fetched a message: #{payload.inspect}, content_type: #{metadata.content_type}. Shutting down..."
			else
				puts "No messages in the queue"
			end
		end
	#	sleep 100
	#	break
		nn = nn-1
	end
	end
 
#	connection.close {
#		EventMachine.stop { exit }
#	}

	end
end



