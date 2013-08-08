#!/usr/bin/env ruby

require "rubygems"
require 'data_mapper'
require 'csv'

db = DataMapper.setup(:default, 'mysql://root:@localhost/hashdb')

class File
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
end


DataMapper.finalize
DataMapper.auto_migrate!
#DataMapper.auto_upgrade!

#nsrlfile = CSV.foreach(ARGV[1]) do |row|
CSV.foreach(ARGV[0], :headers => true) do |row|
  p row
  puts row[0].inspect
  #<CSV::Row "SHA-1":"000000206738748EDD92C4E3D2E823896700F849" "MD5":"392126E756571EBF112CB1C1CDEDF926" "CRC32":"EBD105A0" "FileName":"I05002T2.PFB" "FileSize":"98865" "ProductCode":"3095" "OpSystemCode":"WIN" "SpecialCode":"">
  File.create(:sha1 => row[0]) #, :md5 => row[2], :crc32 => row[3], :filename => row[4], :filesize => row[5], :productcode => row[6], :opsystemcode => row[7], :specialcode => row[8]
end


#nsrlmfg = File.open(ARGV[2], 'r')
#nsrlos = File.open(ARGV[3], 'r')
#nsrlprod = File.open(ARGV[4], 'r')
