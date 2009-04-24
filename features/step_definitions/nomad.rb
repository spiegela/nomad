$: << File.join(File.dirname(__FILE__), "/../../lib")
require 'rubygems'
require 'rack/test'
require 'nomad'
require 'nomad/client'
require 'nomad/registrar'

Given /^I am not yet registered/ do
  
end

When /^I start up$/ do
  @client = Nomad::Client.new(
    :registrar => '127.0.0.1', :port => 80,
    :url => '/cluster/registration.json',
    :registration => {
      :name => 'localhost',
      :load => `/usr/bin/uptime |awk '{print $10}'`,
      :services => '/xend/status /xen/customer/domains /xen/customer/storage /xen/customer/bandwidth'
    }
  )
end

Then /^I should publish my status with the registrar$/ do
  @client.register
end