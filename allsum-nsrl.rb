#!/usr/bin/env ruby

require "rubygems"
require 'data_mapper'
require 'csv'
require 'iconv'

db = DataMapper.setup(:default, 'mysql://root:@localhost/hashdb')
               
class Record
  include DataMapper::Resource

  property :id,           Serial
  property :sha1,         String
  property :md5,          String
  property :crc32,        String
  property :filename,     String
  property :filesize,     Integer
  property :productcode,  Integer
  property :opsystemcode, String
  property :specialcode,  String
  property :filepath,     Text
end

module DataMapper
  module Model
    def update_or_create(conditions = {}, attributes = {}, merger = true)
      begin
        if (row = first(conditions))
          row.update(attributes)
          row
        else
          create(merger ? (conditions.merge(attributes)) : attributes )
        end
      rescue
        false
      end
    end
  end # Module Model
end # Module DataMapper

DataMapper.finalize
#DataMapper.auto_migrate!
DataMapper.auto_upgrade!

CSV.parse(File.open(ARGV[0], 'r:iso-8859-1:utf-8'){|f| f.read}, col_sep: ',', headers: true)  do |row|
  
  begin
    filename = row[3].encode!("utf-8", "utf-8", :invalid => :replace)
    puts filename
    file = Record.create(:sha1 => row[0], :md5 => row[1], :crc32 => row[2], :filename => filename, :filesize => row[4], :productcode => row[5], :opsystemcode => row[6], :specialcode => row[7])
  rescue => e
    puts "Error: #{e}"
    puts row[3]
  end
  
end

module DataMapper
  module Model
    def update_or_create(conditions = {}, attributes = {}, merger = true)
      begin
        if (row = first(conditions))
          row.update(attributes)
          row
        else
          create(merger ? (conditions.merge(attributes)) : attributes )
        end
      rescue
        false
      end
    end
  end # Module Model
end # Module DataMapper
 
CSV.read("/Users/jonathancunningham/Desktop/nsrl/filepath-short.csv", "r:ISO-8859-15:UTF-8").each do |d|
  hash = d[0]
  metadata = d[1]

  p "hash = " + hash
  p "metadata = " + metadata
  Record.update_or_create({:hash => hash}, {:hash => hash, :metadata => metadata})
 
end