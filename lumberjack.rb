#!/usr/bin/env ruby -wKU
require 'rubygems'
require 'dm-migrations'

module Lumberjack

	class Filename
	  include DataMapper::Resource

	  # schema: uid | filename | file type

	  property :id,           Serial, :key => true
	  property :filename,     Text   # done
	  property :filetype,     String   # needs work
	  property :created_at,   DateTime # done
	  property :datemodified, DateTime
	  property :size,         Integer  # done
	  property :version,      Text   # done
	  property :filepath,     Text   # not done
	  property :md5,          String, # done
	  property :sha1,         String, # done
	  property :sha256,       Text,   :unique => true   # done
	  property :fuzzyhash,    Text, # done

	end

	class Log
	  def self.new(debug, verbose)
	    @debug = debug
		@verbose = verbose

	  	@db = DataMapper.setup(:default, 'mysql://root:8erLbWb-YCCYKe13QlkGMG0fv@192.168.45.131/hashdb')
        puts @db if @debug

	    DataMapper.finalize
	    DataMapper.auto_upgrade!
	  end


	  def self.paper(file, filetype, md5digest, sha1digest, sha256digest, filepath, fuzzyhash, fileversion, filesize)

	    puts "file #{file}" if @debug || @verbose
	    puts filetype if @debug
	    puts fileversion if @debug
	    puts md5digest if @debug

		begin
	      saved = Filename.create(
		    :filename => file.to_s,
		    :filetype => filetype.to_s,
		    :created_at => Time.now,
		    :size => filesize.to_i,
		    :version => fileversion.to_s,
		    :datemodified => Time.now,
		    :filepath => filepath.to_s,
		    :md5 => md5digest.to_s,
		    :sha1 => sha1digest.to_s,
		    :sha256 => sha256digest.to_s,
			  :fuzzyhash => fuzzyhash.to_s
		    )

			#saved.save!

			puts saved if @debug

		  rescue DataObjects::IntegrityError
		    puts "Already in DB" if @debug || @verbose
		  end
	  end

	end
end

