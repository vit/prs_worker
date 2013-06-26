
require "amqp"
require "amqp/extensions/rabbitmq"
require "json"

$:.unshift __dir__
require "load_model"
 
#AMQP.start(:host => 'localhost') do
EventMachine.run do
	AMQP.connect do |connection|
		channel  = AMQP::Channel.new(connection)
		exchange = channel.direct("comsep.op", :auto_delete => true)
		q1 = channel.queue("comsep.op", :auto_delete => true)
		q1.bind(exchange)

		confs = Coms::App.model.conf.get_confs_list.map do |c|
			c['_id']
		end

		show_stopper = Proc.new { connection.close { EventMachine.stop } }
		Signal.trap "TERM", show_stopper

		channel.confirm_select

	#	seq = MsgUtils.make_array_seq regs, ->{show_stopper.call} do |r|
			msg = {
				type: 'comsep.op',
				op: 'mail.task',
				data: {
					template: 'invitation_for_last_registrators',
					generator: 'to_registrators_of',
					confs: confs
				}
			}
			p msg 
			#exchange.publish(msg.to_json, :routing_key => "stage1")
			exchange.publish(msg.to_json)
			#exchange.publish(msg.to_json, :persistent => true, :nowait => false)
	#	end

		channel.on_ack do |basic_ack|
			puts "Received an acknowledgement: delivery_tag = #{basic_ack.delivery_tag}, multiple = #{basic_ack.multiple}"
			show_stopper.call
	#		seq[]
		end

	#	seq[]

	end
end

