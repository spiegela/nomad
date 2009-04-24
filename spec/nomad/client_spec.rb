$: << File.join(File.dirname(__FILE__), "/../../lib")
$: << File.dirname(__FILE__)

require 'spec_helper'
require 'yaml'
module Nomad
  describe Client do
    include RegistrarHelpers
    include ClientHelpers
    
    context "upon registering" do
      before(:all) do
        @registrar = start_registrar
      end
            
      after(:all) do
        stop_registrar @registrar
      end
            
      it "should read my config for the registrar name" do
        client.opts[:registrar].class.should == String
      end
        
      it "should publish my status with the registrar" do
        client.register['success'].should == true
      end
    end # END context

    context "once registered" do
      before(:all) do
        @registrar = start_registrar        
        client.register
      end
      
      after(:all) do
        stop_registrar @registrar
      end
      
      it "should read its own registration info" do
        reg = client.registration
        reg['success'].should == true
        reg['registration']['name'].should == 'daigo'
        reg['registration']['services'].split.sort.should == ["/xen/customer/bandwidth", "/xen/customer/domains", "/xen/customer/storage", "/xend/status"]
      end
      
      it "should be able to deregister itself" do
        client.deregister['success'].should == true
        client.registration['success'].should == false
      end
      
    end # END context
    
  end # END describe
  
end