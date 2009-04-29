$: << File.join(File.dirname(__FILE__), "/../../lib")
$: << File.dirname(__FILE__)

require 'spec_helper'
require 'nomad/agent'

module Nomad
  describe Registrar do
    include RegistrarHelpers
    include ClientHelpers
    
    context "starting up" do
      before(:all) do
        start_registrar
        client.register
        @agent = Nomad::Agent.new
      end
      
      it "should retrieve services for a specific client" do
        @agent.hunt(:daigo, '/services.json').sort.should ==
          %w(/xend/status /xen/domain /xen/storage /xen/bandwidth).osrt
      end
      
      it "should retrieve a specific service state" do
        @agent.hunt(:daigo, '/xend/status').should == 'Running'
      end
      
      it "should handle params" do
        @agent.hunt(:daigo, '/xend/domain', :domain_id => 1).should == 'Running'
      end
            
      it "should retrieve service state from multiple hosts" do
        @agent.gather(:all, '/xend/status').should == {
          'daigo' => 'Running',
          'kusunoki' => 'Running'
        }
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