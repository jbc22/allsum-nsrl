#!/usr/bin/env ruby

require "rubygems"
require 'data_mapper'
require 'csv'

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

DataMapper.finalize
#DataMapper.auto_migrate!
#DataMapper.auto_upgrade!

#CSV.foreach(ARGV[0], {:encoding => "r:ISO-8859-15:UTF-8", :headers => true}) do |row|
#  #<CSV::Row "SHA-1":"000000206738748EDD92C4E3D2E823896700F849" "MD5":"392126E756571EBF112CB1C1CDEDF926" "CRC32":"EBD105A0" "FileName":"I05002T2.PFB" "FileSize":"98865" "ProductCode":"3095" "OpSystemCode":"WIN" "SpecialCode":"">
#  file = Record.create(:sha1 => row[0], :md5 => row[1], :crc32 => row[2], :filename => row[3], :filesize => row[4], :productcode => row[5], :opsystemcode => row[6], :specialcode => row[7])
#  puts file
#end

#CSV.foreach(ARGV[0], :headers => true) do |row|

#paths = Hash[ CSV.read('filepath.csv', "r:ISO-8859-15:UTF-8").map do |row|
#  puts [ row[0].to_i, [row[1].strip] ]
#end ]
h = Hash.new
paths = CSV.read("filepath-short.csv", "r:ISO-8859-15:UTF-8").each_with_object({}) do |k, v|
  #h{:sha1 = v} = v
  #puts h[1].inspect
  #puts k[0]
  #puts k[1]
  #puts v
  
  puts a = Record.all(:sha1 => k[0]).first.inspect #k[0].to_s).inspect
  a.filepath = k[1]
  #puts a.inspect
  #a.update(:filepath => k)
end



#nsrlmfg = File.open(ARGV[2], 'r')
#nsrlos = File.open(ARGV[3], 'r')
#nsrlprod = File.open(ARGV[4], 'r')
