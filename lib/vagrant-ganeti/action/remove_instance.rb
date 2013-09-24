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
	  createjob = server.instance_terminate
          # set machine id to nil
          env[:machine].id = nil

	  env[:ui].info("Removing the instance #{server.info['instance_name']}")
	  while true
		status =  server.is_job_ready(createjob)

		if  status == "error"
			env[:ui].info("Error Removing instance")
			break
		elsif status == "running"
			#Waiting for the message to succeed
			sleep(15)
		elsif status  == "success"
	    		env[:ui].info("Instance #{server.info['instance_name']} Sucessfully Removed")
			break
		end
	
            end

          @app.call(env)
        end
      end
    end
  end
end
