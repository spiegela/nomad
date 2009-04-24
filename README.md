Nomad
=======

Nomad is a light-weight Rack-based cluster communication system.  It lets you *hunt* and *gather* state information and quick command responses from your cluster nodes synchronously.  Nomad support Nanite style selectors: ":all", ":random", ":target", ":least_loaded", etc.

How it Works
============

Nomad has 3 components to make all this:

1. Nomad::Agent
---------------
The agent is the nomad in our story.  They're able to hunt and gather information from your cluster ecosystem by querying the Nomad clients over HTTP.
	
You might embed your Nomad agents into your Ruby app (Rails, Merb, command-line, whatever...) to find out info on or from the rest of your cluster nodes.  Right now, the agent is written to consume JSON, but as the need arises this can be expanded to other possible data streams.

2. Nomad::Client
----------------
The client provides our nomad agents with wild-game, nuts and berries in the form of HTTP delivered content (right now JSON, like I mentioned.)
	
The actual Nomad::Client class just provides a list of _services_ or URLs to a central server (the registrar.)  This way the Nomad agent knows which cluster nodes will respond to desired queries.  Providing the content is up to you; you can use a straight Rack, Sinatra, Rails, Merb app to serve the content-- so long as it serves up what your agent is expecting.  You could even run the client-code stand-alone and run a web-service in some other language if that's your thing.

3. Nomad::Registrar
-------------------
The registrar is the water hole (What's so great about the water hole?).  It's a place where the wild-game congregate so that agents can enjoy their tasty meat (or nuts/berries if your nomads are vegetarian).
	
Clients can register on startup or regularly.  This way we can keep a [redis](http://code.google.com/p/redis/) registry of all the available clients on hand so that hunting and gathering is made easy.  To be clear, agents talk directly to the clients, the registrar is just so that an agent will know where to go.

Features
========
 Nomad provides:

* Web-framework independent cluster communication service
* Self-maintaining registry of cluster client services
* Light-weight rack servers providing Registrar and Client functionality
* Dynamic way to choose which servers to query

	
Why not just use:
=================
[Backgroundrb | Nanite | Vertebra | something else]?
----------------------------------------------------

Good question.  Luckily, its a question I asked myself.  These projects are generally designed for off-loading long running work, and while some offer synchronous options, they're built with asynch in mind.  Nomad isn't for long tasks, its for hunting and gathering info quickly and accurately whenever I want to know *now*.  My nomads want instant gratification.

Cluster clients publish their supported services with a chosen centralized node-- or registrar, and nodes can be queried based on the services they support, their states (typically load, but configurable) or by other criteria.

Nomad::Agent Example
====================

somewhere in your app...

	include 'nomad/agent'

	...

	@agent = Nomad::Agent.new
	state = @agent.hunt :least_loaded, '/daemon/state'
	# "Running"  <-- this result was JSON, but this one was simple-- just a string
	
	state = @agent.hunt :node01, '/resource/info'
	# { 'state' => 'enabled',
	#   'available' => true,
	#   'pct_avail' => '30%'
	# } <-- returns something a little more exciting
	
	states_hash = @agent.gather(:all, '/resource/sub-resource/info')
	# { 'node01' => {...},
	#   'node02' => {...},
	#   'node03' => {...}
	# } <-- when gathering we return a hash of results
	
	...


Rack + Nomad::Client Example
============================

Although this shows a truncated Rack app, you can use Nomad::Client with any web-framework or stand-alone.

	require 'nomad/client'
	
	class MyApp
		include Nomad::Client
		
		# set all the client options in one shot
		def opts
		  #   :registrar   - Registrar hostname or IP address
      	  #   :port         - Registrar listening port
          #   :url          - Registrar url string
          #   :registration - Hash containting registration information
          #                   {:name => hostname, :ip => address,
	      #                    :state => status_proc, :services => "service service ..."}
      
			{ :registrar => 'node02', :port => 9292, :url => '/cluster/registration.json',
			  :registration => {
			    :services => '/daemon/state /resource/info /resource/sub-resource/info'
			  }
			}
		end
		
		def call
			case env['REQUEST_PATH']
			when '/daemon/state'; ...
			when '/resource/info'; ...
			when '/resource/sub-resource/info'; ...
			else; raise "WTF"
			end
		end
	end

We also don't try to guess when you want to register.  You might want to have EventMachine do it for you, or some other logic...

	require 'nomad/client'
	require 'eventmachine'
	
	class MyApp
		include Nomad::Client
		
		def initialize
			Thread.new do			
				EM.add_periodic_timer(60) { self.register }
			end
		end
	end

Project Status
==============

Nomad isn't quite finished, but it's getting pretty close.  I'm working on the agent-code next.

Sponsonship
===========
This project is sponsored by [Ascent VPS Hosting](http://ascentvps.com/)