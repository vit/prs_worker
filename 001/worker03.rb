require 'amqp'
 
AMQP.start(:host => 'localhost' ) do
	channel = AMQP::Channel.new
	queue = channel.queue('tasks')
	queue.subscribe do |msg|
		puts msg
	end
end

