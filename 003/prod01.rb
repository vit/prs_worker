
require 'yaml'

#$:.unshift File.expand_path('../../../', __FILE__)
$:.unshift File.expand_path('../../', __dir__)

require 'prs_model/app'
#require 'streamsheet/streamsheet'

#Coms::App.init( File.expand_path('../../prs5/config/prs_model_conf.yaml', __FILE__) )
#Coms::App.init( File.expand_path('../../prs5/config/prs_model_conf.yaml', __dir__) , Rails.env)
Coms::App.init( File.expand_path('../../prs5/config/prs_model_conf.yaml', __dir__) , 'production')


confs = Coms::App.model.conf.get_confs_list.map do |c|
	c['_id']
end

p confs


papers = Coms::App.model.conf.paper._submitted_all(confs).map do |p|
	p['_id']
end

p papers

owners = Coms::App.model.conf.paper._submitted_all(confs).map do |p|
	p['_meta']['owner'].to_i
end.uniq

p owners

