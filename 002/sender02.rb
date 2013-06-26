
require "amqp"
require "json"
 
#AMQP.start(:host => 'localhost') do
EventMachine.run do
	AMQP.connect do |connection|
		channel  = AMQP::Channel.new(connection)

		exchange = channel.direct("amqpgem.examples.exchanges.direct", :auto_delete => true)

		q1 = channel.queue("amqpgem.examples.queues.shared", :auto_delete => true).bind(exchange, :routing_key => "shared.key")

		EventMachine.add_timer(1.2) do
			5.times { |i|
				msg = {
					type: 'mail.send.one',
					data: {
						pin: 1,
						template: <<EOS
fname: <%= @fname%>
 fgkfghj kfhj kf jkfhjk fhjkhjk
EOS
					},
				}
				#exchange.publish("Hello #{i}, direct exchanges world!", :routing_key => "shared.key")
			#	exchange.publish(msg, :routing_key => "shared.key")
				exchange.publish(msg.to_json, :routing_key => "shared.key")
				
			}
		end

		show_stopper = Proc.new { connection.close { EventMachine.stop } }
	 
		Signal.trap "TERM", show_stopper
		EM.add_timer(3, show_stopper)
	end
end

