require 'rubygems'
require 'rack'
require 'daemons'
require 'thin'
require 'nomad'
require 'nomad/client'
require 'nomad/registrar'

module RegistrarHelpers
  def start_registrar(opts={:host => '0.0.0.0', :Port => 9292})
    registrar = Nomad::Registrar.new()
    @thin = Thin::Server.new(opts[:host], opts[:Port], registrar)
    @thin_thread = Thread.new { @thin.start }
    registrar
  end
    
  def stop_registrar registrar
    @thin.stop!
    Thread.kill(@thin_thread)
  end
end

module ClientHelpers
  def daigo
    Nomad::Client.new(
      :registrar => '127.0.0.1', :port => 9292,
      :url => '/cluster/registration.json',
      :registration => {
        :name => 'daigo',
        :ip => '127.0.0.1',
        :services => '/xend/status /xen/customer/domains /xen/customer/storage /xen/customer/bandwidth /merb/status /redis/status'
      }
    )
  end

  def kusunoki
    Nomad::Client.new(
      :registrar => '127.0.0.1', :port => 9292,
      :url => '/cluster/registration.json',
      :registration => {
        :name => 'kusunoki',
        :ip => '192.168.77.199',
        :services => '/xend/status /xen/customer/domains /xen/customer/storage /xen/customer/bandwidth'
      }
    )
  end
  
  def delete_client
    
  end
end