require 'rack/test'

World do
  def app
    @app = Rack::Builder.new do
      run Nomad::Registrar.new
    end
  end

  include Rack::Test::Methods
end