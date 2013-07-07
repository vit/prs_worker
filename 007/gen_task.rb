require 'optparse'

options = {}
OptionParser.new do |opts|
	opts.banner = "Usage: #{$0} [options]"
#	opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
#		options[:verbose] = v
#	end
	opts.on("-p", "--producer NAME", "Producer name") do |v|
		options[:producer] = v
	end
	opts.on("-t", "--template NAME", "Template name") do |v|
		options[:template] = v
	end
end.parse!

p options

$:.unshift __dir__
require "load_model"
$:.shift

@app = Coms::App.model


producer = options[:producer]
template = options[:template]

if producer && @app.post.producer.exists?(producer) && template && @app.post.templatemgr.exists?(template)

end


