$: << File.join(File.dirname(__FILE__), "/../../lib")
$: << File.dirname(__FILE__)

require 'spec_helper'
require 'nomad/agent'

module Nomad
  describe Registrar do
    include RegistrarHelpers
    include ClientHelpers
    
    before(:all) do
      start_registrar
      daigo.register
      kusunoki.register
      @agent = Nomad::Agent.new
    end
    
    after(:all) do
      daigo.deregister
      kusunoki.deregister
    end
    
    context "listing clients and services" do
      before(:all) do
        @client_list  = @agent.list
        @service_list = @agent.list('/xend/status')
      end
      
      it "should retrieve a list of clients" do
        @client_list.class.should == Array
        @client_list.include?('daigo').should == true
      end
      
      it "should retrieve a list of clients for a specific service" do
        @service_list.class.should == Array
        @service_list.sort.should == %w(daigo kusunoki)
      end
      
      it "should retrieve services for a specific client" do
        @agent.services(:daigo).class.should == Array
        @agent.services(:daigo).sort.should == daigo.registration[:services].split.sort
      end
    end
    
    context "Hunting service states" do
      
      it "should retrieve a specific service state" do
        @agent.hunt(:daigo, '/xend/status').should == 'Running'
      end
      
      it "should handle params" do
        @agent.hunt(:daigo, '/xend/domain', :domain_id => 1).should == 'Running'
      end
    end
    
    context "Gathering service states" do
            
      it "should retrieve service state from multiple hosts" do
        list = @agent.gather(:all, '/xend/status')
        list.should == {
          'daigo' => 'Running',
          'kusunoki' => 'Running'
        }
        @agent.gather(%w(daigo kusunoki), '/xend/status').should == list
      end
      
      it "should handle multiple identicle params" do
        @agent.gather(:daigo, '/xen/domain', :domain_id => [1,2,3]).should == 
          { 1 => 'Running',
            2 => 'Syspended',
            3 => 'Shutdown'
          }
      end
    end # END context
  end
end