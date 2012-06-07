#!/usr/bin/ruby
# http to smtp mailer
#
require "rubygems"
require "webrick"
require "./rumino/rumino"



conf = mergeJSONs( "defaults.json", ARGV[0] )

raise "need 'emailTo' in config" if ! conf["emailTo"]
raise "need 'emailFromDomain' in config" if ! conf["emailFromDomain"]

$hist={}

web = MiniWeb.new()
web.configure(conf)
web.useGlobalTrapAndPidFile()
web.onPOST() do |req,res|
  caption = req.path
  caption.gsub!("/","")
  caption = "crashreport" if caption.size == 0 

  data = req.query
  p( caption )
  p( data )
  if ! $hist[data] then
    from = caption + "@" + conf["emailFromDomain"]         # URL path is used as mail subject and from address.
    subj = caption
    sendmail( from, conf["emailTo"], subj, data )      
  else
    p("skip dup entry")
  end
end


web.start()
