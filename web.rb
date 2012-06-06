#!/usr/bin/ruby
# http to smtp mailer
#
require "rubygems"
require "webrick"
require "./rumino/rumino"

PORT = 38080
PIDFILE = nil
EMAILTO = "kengo.nakajima@gmail.com"

addconf=nil
if ARGV.size == 1 then 
  addconf = readJSON(ARGV[0])
  PORT = addconf["webPort"]
  PIDFILE = addconf["pidFile"]
end

$srv = WEBrick::HTTPServer.new({ 
                                :BindAddress => "0.0.0.0",
                                :Port => PORT 
                              })

$hist={}

class Receiver < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(req,res)
    path = req.path
    data = req.query
    p( path )
    p( data )
    if ! $hist[data] then
      from = path.gsub("/","") + "@ringo.io"
      subj = from
      sendmail( from, EMAILTO, subj, data )      
    else
      p("skip dup entry")
    end
  end
#  def do_GET(req,res)
#    p( req.query )
#  end
end

$srv.mount( "/", Receiver )



def terminate()
  cmd( "rm -f #{PIDFILE}")
  $srv.shutdown
end

trap("INT"){terminate()}
trap("TERM"){terminate()}

savePid(PIDFILE)

p "start server:", PORT
$srv.start()
