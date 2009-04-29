$: << File.join(File.dirname(__FILE__), "/../../lib")
$: << File.dirname(__FILE__)

require 'spec_helper'
module Nomad
  describe Client do
    include RegistrarHelpers
    include ClientHelpers
    
    context "upon registering" do
      before(:all) do
        @registrar = start_registrar
      end
            
      after(:all) do
        
      end
            
      it "should read my config for the registrar name" do
        daigo.opts[:registrar].class.should == String
      end
        
      it "should publish my status with the registrar" do
        pp daigo.register
        daigo.register['success'].should == true
      end
    end # END context

    context "once registered" do
      before(:all) do
        @registrar = start_registrar
        daigo.register
      end
      
      after(:all) do

      end
      
      it "should review its own registration info" do
        reg = daigo.review
        pp reg
        reg['success'].should == true
        reg['data']['name'].should == 'daigo'
        reg['data']['services'].sort.should == daigo.registration[:services].split.sort
      end
      
      it "should be able to deregister itself" do
        dereg = daigo.deregister
        pp dereg
        dereg['success'].should == true
        daigo.review['success'].should == false
      end
      
    end # END context
    
  end # END describe
  
end