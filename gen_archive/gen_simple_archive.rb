# encoding: utf-8

$:.unshift __dir__+'/../common/'
require "load_model"
$:.shift

%w[russian zip fileutils nokogiri].each {|r| require r}

#work_dir = './work/'

EN = "en_US"
RU = "ru_RU"

def make_name_from_title title
	res = nil
	if title
		if title && title['en'] && title['en'].length > 0
			res = conf_file_name = title['en']
		elsif  title && title['ru'] && title['ru'].length > 0
			res = conf_file_name = Russian.translit( title['ru'] )
		else
		end
	end
	res
end

def make_dc_tags_from_paper p
	res = []
	title = p['text']['title']
	title_ru = title['ru']
	title_en = title['en']
	title_types = %w[none alternative]
	if title_en.to_s.length > 0
		res << ['title', title_types.shift, title_en, EN]
	end
	if title_ru.to_s.length > 0
		res << ['title', title_types.shift, title_ru, RU]
	end

	abstract = p['text']['abstract']
	abstract_ru = abstract['ru']
	abstract_en = abstract['en']
	if abstract_en.to_s.length > 0
		res << ['description', 'abstract', abstract_en, EN]
	end
	if abstract_ru.to_s.length > 0
		res << ['description', 'abstract', abstract_ru, RU]
	end

	mtime = p['_meta']['mtime']
	mtime = Date.parse(mtime) #.year #rescue nil
	if mtime && mtime.to_s.length > 0
		res << ['date', 'issued', mtime, '']
	end

	#p p['authors']
	p['authors'].each do |a|
		%w[en ru].each do |lang|
			lname = a['lname'][lang]+'' rescue ''
			fname = a['fname'][lang]+'' rescue ''
			mname = a['mname'][lang]+'' rescue ''
			if lname && lname.length > 0
				full_name = "%s, %s %s" % [lname, fname, mname]
				res << ['creator', 'none', full_name, lang]
			end
		end
	end #rescue nil

	#p p['keywords']
	p['keywords'].each do |kw|
		%w[en ru].each do |lang|
			word = kw[lang]+'' rescue ''
			if word && word.length > 0
				res << ['subject', 'none', word, lang]
			end
		end
	end #rescue nil


	res
end

def write_dc_to_file data, filename, zipfile
	builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
		xml.dublin_core {
			data.each do |k|
				#dcvalue('element': k[0], 'qualifier': k[1])
				xml.dcvalue(k[2], :element => k[0], :qualifier => k[1], :language => k[3])
			end
		}
	end
	#builder.to_xml
	zipfile.get_output_stream(filename) { |f| f.puts builder.to_xml }
end
def copy_file src, filename, zipfile
	zipfile.get_output_stream(filename) { |os| src.each{ |c| os.write c } }
end
def write_fileslist_to_file filenames, filename, zipfile
	zipfile.get_output_stream(filename) { |os| filenames.each{ |c| os.puts c } }
end


def write_files_to_archive lst, zipfile_name
	Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
		lst.each do |p|
			cnt = p['_meta']['paper_cnt']
			dir_name = "%04d_" % cnt
			#puts cnt

			metadata = make_dc_tags_from_paper p
		#	puts metadata
		#	puts

			write_dc_to_file metadata, dir_name + "/dublin_core.xml", zipfile

			#puts p
			#if p['decision'] && p['decision']['decision']
			#	puts p['decision']['decision']
			#	puts
			#end

		#	puts dir_name

			filenames = []
			p['files'].each do |f|
				#if !types or !types.is_a?(Array) or types.include?(f[:class_code])
				if %w[paper abstract presentation].include?(f[:class_code])
					file = @appl.conf.paper.get_paper_file_by_id f[:_id]
					file_ext = File.extname  f[:filename]
					#dir_name = f[:_meta]['lang'] if folder==:by_lang
					#file_name = f[:class_code] + '_' + ("%04d_" % cnt) + (long_names ? title_no_translit+'_' : '') + f[:_meta]['lang'] + file_ext
					file_name = f[:class_code] + '_' + ("%04d_" % cnt) + f[:_meta]['lang'] + file_ext
					#zipfile.get_output_stream(dir_name+'/'+file_name) { |os| file.each{ |c| os.write c } }
					copy_file file, dir_name+'/'+file_name, zipfile
					filenames << file_name
					sleep(0.01)
				end
			end
			write_fileslist_to_file filenames, dir_name+'/contents', zipfile
		end
	end
end


@appl.conf.get_confs_list.select{|c| c['info']['status']=='archived' }.each do |c|
#@appl.conf.get_confs_list.select{|c| c['info']['status']=='archived' }.last do |c|
#@appl.conf.get_confs_list[0..9].each do |c|
	status = c['info']['status']
	cont_id = c['_id']

#puts status

	#dst_dir = "../../prs5/public/generated/#{cont_id}/"
	dst_dir = "/mnt/data/comsep_zip_export/"

#	FileUtils.rm_rf("#{dst_dir}.", secure: true)

	#if status=='active'
	if status=='archived'
		conf_file_name = make_name_from_title(c['info']['title']) || cont_id.to_s
		conf_file_name =
			'simple_'+Time.new.strftime("%Y_%m_%d_%H_%M_%S") +'_||_' +
			conf_file_name.gsub(/[\n\r\/\\]/, '_') +
			'.zip'
		puts conf_file_name

		lst = @appl.conf.paper.get_all_papers_list(cont_id).map{ |p|
			p['decision'] = @appl.conf.paper.get_paper_decision cont_id, p['_id']
			p
		}.select{ |p|
			p['decision'] && p['decision']['decision']=='accept'
		}
		puts lst.length

		if lst.length > 0
			Dir.mktmpdir("prs") do |dir|
				zipfile_name = conf_file_name
				write_files_to_archive lst, zipfile_name
				FileUtils.mkdir_p dst_dir
				FileUtils.mv(zipfile_name, dst_dir)
			end
		end

	end
end


