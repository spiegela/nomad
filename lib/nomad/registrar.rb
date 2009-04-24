require 'rubygems'
require 'json'
require 'redis'

module Nomad
  # The registrar component is a rack middleware component for managing cluster nodes.
  # Nomad clients will add themselves on start.
  class Registrar
    
    REDIS_SERVER='/usr/bin/redis-server'
    REGISTRATION_PROPS = %w(name ip port status)
    
    def initialize
      start_redis
      super
    end
    
    def call(env)
      request = Rack::Request.new(env)
      response = []
      if env['REQUEST_PATH'] == '/cluster/registration.json'        
        # Choose a method based on HTTP request method
        case request.request_method
        when 'POST'  ; method = 'register_client'
        when 'DELETE'; method = 'deregister_client'
        when 'GET'   ; method = 'get_client_registration'
        else; raise "Unsupported HTTP request method: #{request.request_method}."
        end
        # Actually run it and catch the response
        begin
          result = self.send method, request 
        rescue Exception => e
          response = {:success => false, :error => e.inspect, :trace => e.backtrace}
        else
          response = result
        ensure
          return wrap_response(response)
        end
      end
    end
    
    def wrap_response response
      code = 500
      code = 200 if response[:success]
      [ code, {'Content-Type' => 'application/json'}, response.to_json ]
    end
    
    # Register clients (new or exinsting-- doesn't matter) into local redis database
    def register_client(request)
      details = request.params
      raise "Client name is required to register." unless details['name']
      r = Redis.new
    
      name = details['name']
    
      # set some basic details
      r[ "#{name}/name" ] = name
      r[ "#{name}/ip" ]   = details['ip'] || request.ip
      r[ "#{name}/port" ] = details['port'] || 6667
      r[ "#{name}/status" ] = details['status'] if details['status']
    
      # using a redis set for the services (space delimited)
      details['services'].split.each { |s| r.set_add "#{name}/services", s }
      {:success => true}
    end
    
    def deregister_client(request)
      properties {|prop| redis.delete "#{request.params['name']}/#{prop}"}
      {:success => true}
    end
    
    def get_client_registration(request)
      raise "Required parameter 'name' was not supplied for this request" unless request.params['name']
      name = request.params['name']
      registration = {}
      
      properties do |prop|
        if prop != 'services'
          registration[prop] = redis["#{name}/#{prop}"]
        else
          services = redis.set_members("#{name}/services").to_a
          registration['services'] = services.join(' ') unless services.empty?
        end
      end
      
      # We want to know about partial registrations (If that were to happen),
      # but lets not give ppl false hope if that reg doesn't actually exist
      return {:success => false} if registration.values.compact.empty?
      return {:success => true, :registration => registration}
    end
    
    def redis
      Redis.new
    end
    
    def start_redis
      @@redis_thread = Thread.new{ `#{REDIS_SERVER}` unless defined?(@@redis_thread) }
    end

    def stop_redis
      @@redis_thread.kill
    end
    
    private
    
    def properties
      %w(name ip port status services).each{|p| yield p}
    end
  end
end