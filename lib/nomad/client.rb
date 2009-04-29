require 'rubygems'
require 'fast_http'
require 'pp'
module Nomad
  # The client component can be mixed into any available HTTP server.  I'm using
  # Sinatra currently.
  class Client
    OPTIONS = [:registrar, :port, :url, :registration, :baseurl]

    attr :opts
    attr_accessor :status_proc
    
    def initialize(opts={})
      # Options:
      #   :registrar    - Registrar hostname or IP address
      #   :port         - Registrar listening port
      #   :url          - Registrar url string
      #   :registration - Hash containting registration information:
      #                   {:name => hostname, ip => address, load => avg }
      #   :baseurl      - Handy when a cluster node is running more than one webapp (including the client)
      
      # Define getters/setters for options
      OPTIONS.each do |meth|
        (class << self; self; end).class_eval do
          define_method meth       do       opts[meth]       end
          define_method "#{meth}=" do |arg| opts[meth] = arg end
        end
      end
      
      @opts = opts unless opts.empty?
      @status_proc = lambda { parse_uptime(`/usr/bin/uptime`) rescue 'no status' }
      registration ||= {}
      baseurl ||= ''
    end
    
    def call
      if env['REQUEST_PATH'] == "#{baseurl}/services.json" and env['REQUEST_METHOD'] == 'GET'
        [ 200, {'Content-Type' => 'application/json'}, registration[:services].split.to_json ]
      else
        super
      end
    end
    
    def register
      registration['status'] ||= status_proc.call
      request 'post'
    end
        
    def deregister; request 'delete'; end  
    def review;     request 'get';    end
    def list;       request 'head';   end
    
    private 
    
    def request method
      req = FastHttp::HttpClient.new( *registrar_opts ).send(method, *registrar_req)
      JSON.parse(req.http_body)
    end
    
    def registrar_opts
      [registrar,port]
    end
    
    def registrar_req
      [url, {:query => registration}]
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