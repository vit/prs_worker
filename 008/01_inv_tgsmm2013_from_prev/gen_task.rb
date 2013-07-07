
$:.unshift __dir__+'/..'
require "load_model"
$:.shift

puts
puts 'Confs:'
@app.conf.get_confs_list.each do |c|
	puts c['_id'] + ': ' + c['info']['title'].to_s
end
puts

puts 'Producers:'
puts @app.post.producer.get_list
puts


#task_id = @app.post.taskmgr.new_task( {'producer' => 'registrators_from_confs', 'args' => {'confs' => ['976190a6c9cb', '097976b5e04e']} } )
task_id = @app.post.taskmgr.new_task( {'producer' => 'registrators_from_confs', 'args' => {'confs' => ['976190a6c9cb']} } )

#puts @app.post.taskmgr.gen_task_elms task_id
@app.post.taskmgr.gen_task_elms task_id


puts 'Tasks:'
puts @app.post.taskmgr.get_tasks_list
puts

