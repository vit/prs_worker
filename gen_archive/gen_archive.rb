$:.unshift __dir__+'/../common/'
require "load_model"
$:.shift

%w[russian zip fileutils].each {|r| require r}

#work_dir = './work/'


def write_files_to_archive lst, zipfile_name, types=nil
	Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
		lst.each do |p|
			cnt = p['_meta']['paper_cnt']
			title = p['text']['title']
			title_ru = title['ru']
			title_en = title['en']
			title = title_en.to_s.length > 0 ? title_en.to_s : title_ru.to_s
			title = title[0...50]
			title = Russian.translit(title)
			title.gsub!(/[^0-9A-Za-z.\-]/, '_')
			dir_name = ("%04d_" % cnt) + title
		#	puts dir_name

			p['files'].each do |f|
				if !types or !types.is_a?(Array) or types.include?(f[:class_code])
				#	puts f
					#@appl.conf.paper.get_paper_file cont_id, f['meta']['parent'], lang, cl
					file = @appl.conf.paper.get_paper_file_by_id f[:_id]
					file_ext = File.extname  f[:filename]
					file_name = f[:class_code] + '_' + f[:_meta]['lang'] + file_ext
				#	file_name = f[:class_code] + '_' + f[:_meta]['lang']
					#zipfile.get_output_stream(dir_name+'/'+file_name) { |os| os.write file }
					zipfile.get_output_stream(dir_name+'/'+file_name) { |os| file.each{ |c| os.write c } }
					sleep(0.01)
				end
			end
		end
	end
end


@appl.conf.get_confs_list.each do |c|
	status = c['info']['status']
	cont_id = c['_id']

#	conf_dir = work_dir+cont_id.to_s+'/'
#	FileUtils.mkdir_p conf_dir
#	zipfile_name = conf_dir+cont_id.to_s+Time.new.strftime("_%Y_%m_%d_%H_%M_%S")+'.zip'

	dst_dir = "../../prs5/public/generated/#{cont_id}/"
	FileUtils.rm_rf("#{dst_dir}.", secure: true)

	if status=='active'
		puts c['info']['title']
		lst = @appl.conf.paper.get_all_papers_list cont_id

		Dir.mktmpdir("prs") do |dir|
			zipfile_name = dir+'/'+'full_'+cont_id.to_s+Time.new.strftime("_%Y_%m_%d_%H_%M_%S")+'.zip'
			#write_files_to_archive lst, zipfile_name
			write_files_to_archive lst, zipfile_name
			FileUtils.mkdir_p dst_dir
			FileUtils.mv(zipfile_name, dst_dir)
			zipfile_name = dir+'/'+'papers_'+cont_id.to_s+Time.new.strftime("_%Y_%m_%d_%H_%M_%S")+'.zip'
			#write_files_to_archive lst, zipfile_name
			write_files_to_archive lst, zipfile_name, ['abstract', 'paper', 'presentation']
			FileUtils.mkdir_p dst_dir
			FileUtils.mv(zipfile_name, dst_dir)
		end

	end

end


