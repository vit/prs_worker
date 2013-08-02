$:.unshift __dir__
require "load_model"
$:.shift

%w[mail].each {|r| require r}

@appl.post.taskmgr.get_pkg_for_sending(2).each do |t|
	task_item_id = t['_id']
	template = t['attr'] ? t['attr']['template'] : nil
	data = t['data']
	log = nil
	state = 'nonexistent'
	if template
		templ_data = @appl.post.get_template_data nil, template
		templ_text = templ_data ? templ_data['text'] : nil
		if templ_text
			begin
				p = @appl.post.templatemgr.parse_src templ_text
				begin
					subject = @appl.post.templatemgr.apply p.parsed['subject'], data
					body = @appl.post.templatemgr.apply p.parsed['body'], data
				#	puts subject
				#	puts body

					if subject
						if body

							email = ''
							if data && data['user']
								email = data['user']['email']
							end

							if email
								puts email

								begin

									mail = Mail.new do
										from 'system@comsep.ru'
										to email
							#			to 'shiegin@gmail.com'
										subject subject
										body body
									end
									mail.charset = 'UTF-8'
									mail.delivery_method :sendmail
									mail.deliver

									state = 'sent'

								rescue Exception => e # mail delivery error
									log = 'mail delivery error: '+e.to_s
									state = 'error'
								end

							else # no email
								log = 'no email'
								state = 'error'
							end

						else # no body
							log = 'no body'
							state = 'error'
						end
					else # no subject
						log = 'no subject'
						state = 'error'
					end

				rescue Exception => e # data substitution error
			#		puts e.inspect
					log = 'data substitution error: '+e.to_s
					state = 'error'
				end
			rescue Exception => e # template parsing error
			#	puts e.inspect
				log = 'template parsing error: '+e.to_s
				state = 'error'
			end
		else # no template data
			log = 'no template data'
			state = 'error'
		end
	else # no teplate id
		log = 'no template id'
		state = 'error'
	end
	@appl.post.taskmgr.set_task_elm_state task_item_id, state, log
end


