
require "amqp"

AMQP.start(:host => 'localhost') do

	channel = AMQP::Channel.new
	exchange = channel.fanout('multicast')

	channel.queue('listener').bind(exchange).subscribe do |msg|
		puts msg # process your message here
	end
end

