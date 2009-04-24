module Nomad  
  # The agent component queries the selected websever(s) running on cluster client
  # nodes, and returns the object back.  Currently supports JSON encodings, but
  # future encodings will be added based on the mime_type received.
  #
  # EXAMPLES:
  #
  # status = hunt   '/xen/domain/info.json', :from => 'ascend01',    :name => 'test01'
  # status = hunt   '/xen/domain/info.json', :from => :least_loaded, :name => 'test01'
  # status = hunt   '/xen/domain/info.json', :from => :random,       :name => 'test01'
  # 
  # status = gather '/xen/domain/info.json', :from => :all, :name => 'test01'
  # status = gather '/xen/domain/info.json', :from => :all_but_me, :name => 'test01'
  class Agent
    def hunt url_string, params={}
      raise "Method requires 'from' option be given" unless params[:from]
      host = get_host params.delete(:from)
      content = FastHttp::HttpClient.new(host, 4567).get(url_string).http_body
      resp = JSON.parse(content)
      result = nil
      if resp['success']
        result = resp['data']
      end
      result
    end

    def gather url_string, params={}
      raise "Method requires 'from' option be given" unless params[:from]
      hosts = get_hosts params.delete(:from)
      hosts.each do |host|
        content = FastHttp::HttpClient.new(host, 4567).get(url_string).http_body
        resp = JSON.parse(content)
        results = {}
        if resp['success']
          results[host] = resp['data']
        end
      end
      result  
    end

    private 

    def get_host
      
    end

    def get_hosts
      
    end
  end
end