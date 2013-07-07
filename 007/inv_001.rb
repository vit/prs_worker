$:.unshift __dir__
require "load_model"
$:.shift


confs = Coms::App.model.conf.get_confs_list.map do |c|
	c['_id']
end

p confs

#p Coms::App.model.post.producer.call 'test'
#p Coms::App.model.post.producer.call 'registrators_from_confs', {'confs' => confs}


ttt = Coms::App.model.post.templatemgr.get_files_list
p ttt


ttt2 = Coms::App.model.post.templatemgr.get_file "invit_tgsmm2013_for_prev_regs"
p ttt2


p Coms::App.model.post.producer.get_list



