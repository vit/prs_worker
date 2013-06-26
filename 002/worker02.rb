
require "amqp"
require "erb"
require "json"


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



class MsgWorker
	def self.process queue, msg
		#puts "Queue #{queue.name} received #{payload}"
		#puts "Queue #{queue.name} #{msg} start"
		#3000000.times { a = 'qwerqwrqwtqteyerurtu' }
		#puts "Queue #{queue.name} #{msg} stop"
		puts msg
msg = JSON.parse(msg)
		udata = getUserData msg['data']['pin']
	#	udata = getUserData( msg[:data] )
#puts msg.class
#msg = JSON.load(msg)
#		puts msg
	#	puts msg[:data]
		bm = BindMe.new(udata)
		templ = msg['data']['template']
#puts templ
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
	queue   = AMQP::Queue.new(channel, "amqpgem.examples.queues.shared", :auto_delete => true)

	queue.subscribe do |payload|
		MsgWorker.process queue, payload
	end
 
	puts "#{queue.name} is ready to go."
 
	end
end



