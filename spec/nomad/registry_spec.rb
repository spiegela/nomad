$: << File.join(File.dirname(__FILE__), "/../../lib")
$: << File.dirname(__FILE__)

require 'spec_helper'
require 'nomad/registry'
require 'pp'
module Nomad
  describe VirtualRegistry do
    include RegistrarHelpers
    include ClientHelpers
    
    context "Navigating Registry" do
      before(:all) do
        @registrar = start_registrar        
        daigo.register
        kusunoki.register
        @r = Nomad::RedisRegistry.new
        @h = Nomad::HttpRegistry.new(:host => '127.0.0.1')
      end
            
      it "should retrieve a client via redis and HTTP" do
        reg = @r['daigo']
        reg.class.should == Hash
        @h['daigo'].should == @r['daigo']
      end
      
      it "should register a client via HTTP" do
        daigo.deregister
        @h['daigo'] = daigo.registration
        @h['daigo']['name'] == 'daigo'
      end
      
      it "should retrieve a list of all clients" do
        list = @r.list
        list.class.should == Array
        list.include?('daigo').should == true
        @h.list.should == @r.list
      end
      
      it "should list services for a host" do
        list = @r.services 'daigo'
        list.class.should == Array
        list.include?('/xend/status').should == true
        @h.services('daigo').should == list
      end
                  
      it "should list hosts containing a service" do
        list = @r.list('/xend/status').to_a
        list.include?('daigo').should == true
        @h.list('/xend/status').should == list
                
        list = @r.list('/merb/status').to_a
        list.include?('kusunoki').should == false
        @h.list('/merb/status').should == list
      end
    
    end # END context
    
  end
end