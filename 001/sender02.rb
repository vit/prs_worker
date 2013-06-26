require "amqp"

AMQP.start(:host => 'localhost') do
	channel = AMQP::Channel.new
	exchange = channel.fanout('multicast')

	exchange.publish('hello')
	exchange.publish('world')
end


