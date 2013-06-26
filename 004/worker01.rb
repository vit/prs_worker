
require "amqp"
require "erb"
require "json"

$:.unshift __dir__
require "load_model"

# worker 1
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



class MsgWorker1
	def self.process args, msg

		if msg
			case msg['op']
			when 'mail.task'
#				puts msg
				regs = MsgGenerator.gen_registrators_from_confs({'confs' => msg['data']['confs']})
#				puts regs

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
#					p msg_o 
					args[:output_exchange].publish(msg_o.to_json)
					#puts 'w1 sent message'
					p 'w1 sent message'
STDOUT.flush
					sleep 0.1
				end

			end
		end

	end
end

p1 = fork do 
begin
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
				MsgWorker1.process args, JSON::parse( payload )
			end
 			puts "#{queue.name} is ready to go."

		#	sleep 3
		#	connection.close { EventMachine.stop }
 		end
	end
end
end

# end worker 1

# worker 2
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
#			p '====================================================='
#			p data
#			p '====================================================='
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

class MsgWorker2
	def self.process queue, msg
#		puts msg
#		puts msg['data']
		udata = MsgSupplier.supply_data( msg['data'] )

#		puts udata

		bm = BindMe.new(udata)
		templ = MsgTemplate.get_template msg['template']

#		puts templ

		ttt = ERB.new(templ)
		result = ttt.result(bm.get_binding)
#		puts result

		#puts 'w2 processed message'
		p 'w2 processed message'
STDOUT.flush
					sleep 0.1
	end
	def self.getUserData pin
		{
			fname: 'Vitaliy',
			lname: 'Shiegin',
			email: 'shiegin@gmail.com'
		}
	end
end


 
p2 = fork do 
begin
	#AMQP.start(:host => 'localhost') do
	EventMachine.run do
		AMQP.connect do |connection|
			channel  = AMQP::Channel.new(connection)

			channel = AMQP::Channel.new(connection)
			queue   = AMQP::Queue.new(channel, "comsep.mail.stage1", :auto_delete => true)

			queue.subscribe do |payload|
			#	MsgWorker.process queue, payload
				MsgWorker2.process queue, JSON::parse( payload )
			end
 
			puts "#{queue.name} is ready to go."
		end
	end
end
end

# end worker 2




Process.wait()

#Process.waitpid(p1)
#Process.waitpid(p2)


