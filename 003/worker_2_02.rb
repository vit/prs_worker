
require "amqp"
require "erb"
require "json"

$:.unshift __dir__
require "load_model"

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

class MsgWorker
	def self.process queue, msg
		puts msg
		puts msg['data']
		udata = MsgSupplier.supply_data( msg['data'] )

		puts udata

#		msg = JSON.parse(msg)
#		udata = getUserData msg['data']['pin']
		bm = BindMe.new(udata)
		templ = MsgTemplate.get_template msg['template']

		puts templ

		ttt = ERB.new(templ)
		result = ttt.result(bm.get_binding)
		puts result
	end
	def self.getUserData pin
		{
			fname: 'Vitaliy',
			lname: 'Shiegin',
			email: 'shiegin@gmail.com'
		}
	end
end

 
#AMQP.start(:host => 'localhost') do
EventMachine.run do
  AMQP.connect do |connection|
	channel  = AMQP::Channel.new(connection)

	channel = AMQP::Channel.new(connection)
	queue   = AMQP::Queue.new(channel, "comsep.mail.stage1", :auto_delete => true)

	queue.subscribe do |payload|
	#	MsgWorker.process queue, payload
		MsgWorker.process queue, JSON::parse( payload )
	end
 
	puts "#{queue.name} is ready to go."
 
	end
end



