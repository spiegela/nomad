require 'rubygems'
require 'fast_http'
require 'pp'
module Nomad
  # The client component can be mixed into any available HTTP server.  I'm using
  # Sinatra currently.
  class Client

    attr :opts
    attr_accessor :status_proc
    
    def initialize(opts={})
      # Options:
      #   :registrar   - Registrar hostname or IP address
      #   :port         - Registrar listening port
      #   :url          - Registrar url string
      #   :registration - Hash containting registration information
      #                   {:name => hostname, ip => address, load => avg, services => "service service ..."}
      @opts = opts unless opts.empty?
      @status_proc = lambda { parse_uptime(`/usr/bin/uptime`) rescue 'no status' }
      opts[:registration] ||= {}
    end
    
    def register
      opts[:registration][:status] ||= status_proc.call
      request 'post'
    end
        
    def deregister
      request 'delete'
    end
    
    def registration
      request 'get'
    end
    
    def list
      request 'head'
    end
    
    private 
    
    def request method
      req = FastHttp::HttpClient.new( opts[:registrar], opts[:port] ).send(method, opts[:url], :query => opts[:registration] )
      JSON.parse(req.http_body)
    end
      
    # Shamelessly stolen from ezmobius/nanite
    def parse_uptime(up)
      if up =~ /load averages?: (.*)/
        a,b,c = $1.split(/\s+|,\s+/)
        (a.to_f + b.to_f + c.to_f) / 3
      end
    end
  end
end