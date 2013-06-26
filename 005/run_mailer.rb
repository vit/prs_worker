require 'optparse'

options = {}
OptionParser.new do |opts|
	opts.banner = "Usage: #{$0} [options]"
#	opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
#		options[:verbose] = v
#	end
	opts.on("-p", "--pid PID", "Pid file") do |v|
		options[:pid] = v
	end
end.parse!

p options
#p ARGV

pid = Process.pid
p pid

File.open(options[:pid], 'w') { |file| file.write( pid ) } if options[:pid]


require "amqp"
require "erb"
require "json"

$:.unshift __dir__
require "load_model"
$:.shift





