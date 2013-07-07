require 'optparse'

options = {}
OptionParser.new do |opts|
	opts.banner = "Usage: #{$0} [options]"
#	opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
#		options[:verbose] = v
#	end
	opts.on("-t", "--task NAME", "Task name") do |v|
		options[:task] = v
	end
end.parse!

p options


class TaskConfig
	attr_reader :config
	def initialize
		@config = {}
	end
	def template name
		@config[:template] = name
	end
	def producer name
		@config[:producer] = name
	end
	def args data
		@config[:args] = data
	end
#	def main &block
#		@query = block
#	end
end

if options[:task]
	File.open( File.join( File.expand_path( __dir__ ), 'tasks', options[:task]+'.rb' ), "r:UTF-8") do |f|
		str = f.read
		config = TaskConfig.new
		config.instance_exec do
			eval str, binding
		end
	#	scope = Scope.new @appl
	#	return scope.instance_exec args, &config.query if config.query
		puts
		puts config.config
		puts
	end
end


$:.unshift __dir__
require "load_model"
$:.shift

#puts
#puts 'Confs:'
#@app.conf.get_confs_list.each do |c|
#	puts c['_id'] + ': ' + c['info']['title'].to_s
#end

puts

#puts 'Producers:'
#puts @app.post.producer.get_list
#puts

task_id = @app.post.taskmgr.new_task( {'producer' => 'registrators_from_confs', 'args' => {'confs' => ['976190a6c9cb']} } )
@app.post.taskmgr.gen_task_elms task_id

=begin

#task_id = @app.post.taskmgr.new_task( {'producer' => 'registrators_from_confs', 'args' => {'confs' => ['976190a6c9cb', '097976b5e04e']} } )

#puts @app.post.taskmgr.gen_task_elms task_id
@app.post.taskmgr.gen_task_elms task_id

=end

#puts 'Tasks:'
#puts @app.post.taskmgr.get_tasks_list
#puts



