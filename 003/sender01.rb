
require "amqp"
require "amqp/extensions/rabbitmq"
require "json"

$:.unshift __dir__
require "load_model"

class MsgGenerator
	def self.gen_registrators_from_confs args={}
		if args && args['confs'] && args['confs'].is_a?(Array)
			Coms::App.model.conf.paper._submitted_all(args['confs']).map do |p|
				p['_meta']['owner'].to_i
			end.uniq
		else
			[]
		end
	end
end

class MsgUtils
	def self.make_array_seq arr, stopper
		n = 0
			-> {
				if n < arr.length
				#	snd[arr[n]]
					yield arr[n]
					n = n + 1
				else
					stopper.call if stopper
				end
			}
	end
end



 
#AMQP.start(:host => 'localhost') do
EventMachine.run do
	AMQP.connect do |connection|
		channel  = AMQP::Channel.new(connection)
		exchange = channel.direct("comsep.mail.stage1", :auto_delete => true)
		q1 = channel.queue("comsep.mail.stage1", :auto_delete => true)
		#q1.bind(exchange, :routing_key => "stage1")
		q1.bind(exchange)

		confs = Coms::App.model.conf.get_confs_list.map do |c|
			c['_id']
		end

		show_stopper = Proc.new { connection.close { EventMachine.stop } }
		Signal.trap "TERM", show_stopper

		channel.confirm_select

		regs = MsgGenerator.gen_registrators_from_confs({'confs' => confs})

=begin
		seq = (-> (arr, n=0) {
			-> {
				if n < arr.length
					snd[arr[n]]
					n = n + 1
				else
					show_stopper.call
				end
			}
		})[regs]
=end

		seq = MsgUtils.make_array_seq regs, ->{show_stopper.call} do |r|
			msg = {
				type: 'mail.task.stage1',
				template: 'invitation_for_last_registrators',
			#	supplier: 'user_data',
				data: {
					user: r,
				#	qwe: 123
				}
			}
			p msg 
			#exchange.publish(msg.to_json, :routing_key => "stage1")
			exchange.publish(msg.to_json)
			#exchange.publish(msg.to_json, :persistent => true, :nowait => false)
		end

		channel.on_ack do |basic_ack|
			puts "Received an acknowledgement: delivery_tag = #{basic_ack.delivery_tag}, multiple = #{basic_ack.multiple}"
			seq[]
		end

		seq[]

=begin
		MsgGenerator.gen_registrators_from_confs({'confs' => confs}).each do |r|
			msg = {
				type: 'mail.task.stage1',
				data: {
					user: r,
					qwe: 123
				}
			}
			p msg 
			#exchange.publish(msg.to_json, :routing_key => "stage1")
			#exchange.publish(msg.to_json)
			exchange.publish(msg.to_json, :persistent => true, :nowait => false)
		end
=end

#		channel.wait_for_confirms

		#exchange.flush
		#channel.flush
		#exchange.commit
		#channel.commit
#		show_stopper.call

	#	connection.close { EventMachine.stop }

	end
end

