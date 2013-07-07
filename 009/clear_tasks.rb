$:.unshift __dir__
require "load_model"
$:.shift

#puts 'Tasks:'
#puts @app.post.taskmgr.get_tasks_list
#puts

@app.post.taskmgr.get_tasks_list.each do |t|
#	puts t
	@app.post.taskmgr.remove_task( t['_id'] )
end


