$:.unshift __dir__
require "load_model"
$:.shift

puts 'Tasks:'
puts @app.post.taskmgr.get_prepared_elms 5
puts

