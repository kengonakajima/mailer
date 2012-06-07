#!/usr/bin/ruby
# http to smtp mailer
#
require "rubygems"
require "webrick"
require "./rumino/rumino"

EMAILTO = "kengo.nakajima@gmail.com"

$hist={}

web = MiniWeb.new()
web.useConfJSONs( "defaults.json", ARGV[0] )
web.useGlobalTrapAndPidFile()
web.onPOST() do |req,res|
  caption = req.path
  caption.gsub!("/","")
  caption = "crashreport" if caption.size == 0 

  data = req.query
  p( caption )
  p( data )
  if ! $hist[data] then
    from = caption + "@ringo.io"         # URL path is used as mail subject and from address.
    subj = caption
    sendmail( from, EMAILTO, subj, data )      
  else
    p("skip dup entry")
  end
end


web.start()
