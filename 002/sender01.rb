
require "amqp"
 
#AMQP.start(:host => 'localhost') do
EventMachine.run do
  AMQP.connect do |connection|
	channel  = AMQP::Channel.new(connection)

	exchange = channel.direct("amqpgem.examples.exchanges.direct", :auto_delete => true)

	q1 = channel.queue("amqpgem.examples.queues.shared", :auto_delete => true).bind(exchange, :routing_key => "shared.key")
#	q1.subscribe do |payload|
#		puts "Queue #{q1.name} on channel 1 received #{payload}"
#	end
 

	EventMachine.add_timer(1.2) do
		5.times { |i| exchange.publish("Hello #{i}, direct exchanges world!", :routing_key => "shared.key") }
	end


   show_stopper = Proc.new { connection.close { EventMachine.stop } }
 
    Signal.trap "TERM", show_stopper
    EM.add_timer(3, show_stopper)

 
	end
end

