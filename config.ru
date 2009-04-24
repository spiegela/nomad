$: << File.join(File.dirname(__FILE__), "/lib")
require 'nomad'
require 'nomad/registrar'

use Rack::Reloader
use Rack::CommonLogger
use Rack::ShowExceptions

run Nomad::Registrar.new
