require 'amqp'
 
AMQP.start(:host => 'localhost') do
	channel = AMQP::Channel
	#channel = AMQP::Channel.new
	queue = channel.queue('tasks')

	queue.publish("hello world")
	queue.publish("it is #{Time.now}")

	AMQP.stop { EM.stop }
end

