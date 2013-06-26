
require "amqp"
require "erb"
require "json"

$:.unshift __dir__
require "load_model"

=begin
class BindMe
	def initialize(data = {})
		data.each_pair do |k, v|
			instance_variable_set '@'+k.to_s, v
		end
	end
	def get_binding
		return binding()
	end
end

class MsgSupplier
	def self.supply_data data
		rez = {}
			p '====================================================='
			p data
			p '====================================================='
		if data['user']
			rez['user'] = Coms::App.model.user.get_user_info_ext( data['user'] )
		end
		rez
	end
end

class MsgTemplate
	def self.get_template id
		<<EOF
Dear <%= @user.to_s%>!
sadf asdf asd sdf
sdf  asdf as sag asf
sa fasgafg fdg dfg sd
EOF
	end
end
=end

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

class MsgWorker
	def self.process args, msg

		if msg
			case msg['op']
			when 'mail.task'
				puts msg
				regs = MsgGenerator.gen_registrators_from_confs({'confs' => msg['data']['confs']})
				puts regs

				regs.each do |r|	
					msg_o = {
						type: 'mail.task.stage1',
						template: 'invitation_for_last_registrators',
					#	supplier: 'user_data',
						data: {
							user: r,
						#	qwe: 123
						}
					}
					p msg_o 
					args[:output_exchange].publish(msg_o.to_json)
				end

			end
		end

	end
end

 
#AMQP.start(:host => 'localhost') do
EventMachine.run do
  AMQP.connect do |connection|
	channel = AMQP::Channel.new(connection)
	queue   = AMQP::Queue.new(channel, "comsep.op", :auto_delete => true)


	ex2 = channel.direct("comsep.mail.stage1", :auto_delete => true)
	q2 = channel.queue("comsep.mail.stage1", :auto_delete => true)
	q2.bind(ex2)

	args = {input_queue: queue, output_exchange: ex2}

	queue.subscribe do |payload|
	#	MsgWorker.process queue, payload
		MsgWorker.process args, JSON::parse( payload )
	end
 
	puts "#{queue.name} is ready to go."
 
	end
end



