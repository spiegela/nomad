$: << File.dirname(__FILE__)
# $: << File.join(File.dirname(__FILE__), "/../../lib/ext")
require 'registry'
require 'forwardable'

module Nomad  
      
  # The agent component queries the selected websever(s) running on cluster client
  # nodes, and returns the object back.  Currently supports JSON encodings, but
  # future encodings will be added based on the mime_type received.
  #
  # EXAMPLES:
  #
  # hosts   = @agent.list
  # service = @agent.list(:ascent01)
  # 
  class Agent
    extend Forwardable    

    attr :opts
    attr :registry
    attr :hunt_selectors, true
    attr :gather_selectors, true
        
    def initialize(options={})
      opts = options
      hunt_selectors   = [:random, :least_loaded, :rr, :previous]
      gather_selectors = [:all, :all_but_me, :several]
      
      options[:lookup_method] ||= :redis
      create_registry options
    end

    def_delegators :@registry, :list, :services
    
    def hunt target, url_string
      
      # content = FastHttp::HttpClient.new(target, 4567).get(url_string).http_body
      # resp = JSON.parse(content)
      # result = nil
      # if resp['success']
      #   result = resp['data']
      # end
      # result
    end

    def gather url_string, params={}
      # raise "Method requires 'from' option be given" unless params[:from]
      # hosts = get_hosts params.delete(:from)
      # hosts.each do |host|
      #   content = FastHttp::HttpClient.new(host, 4567).get(url_string).http_body
      #   resp = JSON.parse(content)
      #   results = {}
      #   if resp['success']
      #     results[host] = resp['data']
      #   end
      # end
      # result  
    end
    
    def create_registry options
      if options[:lookup_method] == :redis
        @registry = Nomad::RedisRegistry.new options
      elsif lookup_method == :http
        @registry = Nomad::HttpRegistry.new  options
      else
        raise "Unknown Registry lookup method: #{lookup_method}"
      end
    end
    
  end
end