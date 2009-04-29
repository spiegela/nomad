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
    
    end # END context
  end
end