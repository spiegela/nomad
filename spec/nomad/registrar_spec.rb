$: << File.join(File.dirname(__FILE__), "/../../lib")
$: << File.dirname(__FILE__)

require 'spec_helper'
require 'rack/test'

module Nomad
  describe Registrar do
    include RegistrarHelpers
    include ClientHelpers
    include Rack::Test::Methods
    
    def app
      Nomad::Registrar.new
    end
    
    context "starting up" do
      it "should bring the redis daemon up" do
        registrar = start_registrar
        registrar.redis.class.should == Redis
        stop_registrar registrar
      end
    end # END context
  end
end