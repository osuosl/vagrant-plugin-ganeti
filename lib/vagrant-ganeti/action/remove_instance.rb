require "log4r"

module VagrantPlugins
  module GANETI
    module Action
      # "unlink" vagrant and the managed server
      class RemoveInstance

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_ganeti::action::remove_instance")
        end

        def call(env)
	  server = env[:ganeti_compute]
          env[:ui].info("Removing the instance#{server.info['instance_name']}")
	  server.instance_terminate
          # set machine id to nil
          env[:machine].id = nil

          @app.call(env)
        end
      end
    end
  end
end
