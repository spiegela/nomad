$: << File.dirname(__FILE__)

require 'rubygems'
require 'json'
require 'redis'
require 'registry'

module Nomad
  # The registrar component is a rack middleware component for managing cluster nodes.
  # Nomad clients will add themselves on start.
  class Registrar
    attr :baseurl
    
    def initialize(opts={})
      @baseurl = opts[:baseurl] || 'cluster'
      @@registry = Nomad::RedisRegistry.new
    end
    
    def call(env)
      request = Rack::Request.new(env)
      response = []
      if env['REQUEST_PATH'] == "/#{baseurl}/registration.json"
        # Choose a method based on HTTP request method
        case request.request_method
        when 'POST'  ; method = 'register_client'
        when 'DELETE'; method = 'deregister_client'
        when 'GET'   ; method = 'get_client_registration'
        when 'HEAD'  ; method = 'list_registrations'
        else; raise "Unsupported HTTP request method: #{request.request_method}."
        end
        # Actually run it and catch the response
        begin
          result = self.send method, request 
        rescue Exception => e
          response = {:success => false, :error => e.inspect.to_s, :trace => e.backtrace}
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
    def register_client request
      client = request.params
      client['ip'] ||= request.ip
      registry[ client['name'] ] = client
      {:success => true}
    end
    
    def deregister_client request
      registry.delete request.params['name']
      {:success => true}
    end
    
    def get_client_registration request
      {:success => true, :data => registry[ request.params['name'] ]}
    end
    
    def list_registrations request
      service = request.params['service'] if request.params['service']
      {:success => true, :data => registry.list(service) }
    end
    
    private
    
    def registry
      @@registry
    end
  end
end