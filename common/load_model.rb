

require 'yaml'
$:.unshift File.expand_path('../../', __dir__)
require 'prs_model/app'
Coms::App.init( File.expand_path('../../prs5/config/prs_model_conf.yaml', __dir__) , 'production')

@appl = Coms::App.model


