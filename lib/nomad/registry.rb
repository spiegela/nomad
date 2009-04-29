require 'rubygems'
require 'redis'

module Nomad
  class VirtualRegistry
    attr :namespace
    attr :baseurl

    def initialize(opts={})
      @baseurl   = opts[:baseurl] || 'cluster'
      @namespace = opts[:namespace] || 'nomad'
    end
    
    private

    def properties
      %w(name ip port status services)
    end
  end
  
  class HttpRegistry < Nomad::VirtualRegistry
    attr :http
    
    def initialize(opts={})
      super
      raise "Host option is required" unless opts[:host]
      opts[:port] ||= 9292
      @http = FastHttp::HttpClient.new( opts[:host], opts[:port] )
    end
  
    def [] client_name
      request 'get', nil, {:name => client_name}
    end
  
    def []= client_name, details
      request 'post', client_name, details
    end
    
    def delete client_name
      
    end
    
    def list service_name=nil
      opts = service_name ? {:service => service_name} : nil 
      request 'head', nil, opts
    end
    
    def services client_name
      registration = request 'get', nil, {:name => client_name}
      registration['services']
    end
    
    private
    
    def request method, client_name=nil, details={}
      req  = @http.send method, "/#{baseurl}/registration.json", :query => details
      resp = JSON.parse(req.http_body)
      return resp['data'] if resp['success']
    end
    
  end

  class RedisRegistry < Nomad::VirtualRegistry
    attr :redis
    
    REDIS_BIN='/usr/bin/redis-server'
    
    def initialize
      super
      @redis = Redis.new
    end
    
    def [] client_name
      raise "Nomad Registry client: #{client_name} not found" unless @redis["/#{namespace}/#{client_name}/name"]
      
      properties.inject({}) do |result, prop|
        if prop != 'services'
          result[prop] = redis["/nomad/#{client_name}/#{prop}"]
        else
          result['services'] = services(client_name)
        end
        result
      end
    end

    def []= client_name, details
      raise "Client name is required to register." unless details['name']
      name = details['name']

      # set some basic details
      redis[ "/#{namespace}/#{client_name}/name" ]   = details['name']
      redis[ "/#{namespace}/#{client_name}/ip" ]     = details['ip']
      redis[ "/#{namespace}/#{client_name}/port" ]   = details['port'] || 6667
      redis[ "/#{namespace}/#{client_name}/status" ] = details['status'] if details['status']
      
      # using a redis set for the services (space delimited)
      details['services'].split.each { |s| redis.set_add("/#{namespace}/#{name}/services", s) }
    end
    
    def delete client_name
      properties.each{ |p| redis.delete "/#{namespace}/#{client_name}/#{p}" }
    end
    
    def list service_name=nil
      redis.keys("/nomad/*/services").collect { |client_str|
        client_str.split('/')[2] if
          redis.set_member?(client_str, service_name) or
          service_name.nil?
      }.compact
    end
    
    def services client_name
      s = redis.set_members("/nomad/#{client_name}/services").to_a
    end
    
    private
    
    def start_redis
      @@redis_thread = Thread.new{ `#{REDIS_BIN}` unless defined?(@@redis_thread) }
      redis['/nomad/activated_at'] = Time.now
    end

    def stop_redis
      @@redis_thread.kill
    end
  end
end