
require "amqp"
require "erb"
require "json"

$:.unshift __dir__
require "load_model"
$:.shift


confs = Coms::App.model.conf.get_confs_list.map do |c|
	c['_id']
end

			msg = {
				type: 'comsep.op',
				op: 'mail.task',
				data: {
					template: 'invitation_for_last_registrators',
					generator: 'to_registrators_of',
					confs: confs
				}
			}
			p msg 


#p Coms::App.model.post.producer.call 'test'
p Coms::App.model.post.producer.call 'registrators_from_confs', {'confs' => confs}


