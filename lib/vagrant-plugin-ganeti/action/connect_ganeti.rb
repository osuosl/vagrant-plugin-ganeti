require "log4r"

module VagrantPlugins
  module GANETI
    module Action
      # This action connects to Ganeti, verifies credentials start the instance.
      class ConnectGANETI
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_ganeti::action::connect_ganeti")
        end

        def call(env)
            config     = env[:machine].provider_config.get_config()

            @logger.info("Connecting to GANETI...")
            #Call  ganeti_client ruby wrapper
	    #config.host
            
	    config.username
            config.password

	    @app.call(env)
        end
      end
    end
  end
end
