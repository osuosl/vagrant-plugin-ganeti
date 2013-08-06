require "log4r"

module VagrantPlugins
  module GANETI
    module Action
      # "unlink" vagrant and the managed server
      class RunInstance

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_ganeti::action::remove_instance")
        end

        def call(env)
            config     = env[:machine].provider_config.get_config()
	    client = env[:ganeti_compute]
           # Launch!
            env[:ui].info(I18n.t("vagrant_ganeti.launching_instance"))
            env[:ui].info(" -- Rapi User: #{config.rapi_user}")
            env[:ui].info(" -- OS Type: #{config.os_type}")
            env[:ui].info(" -- Instance NAME: #{config.instance_name}")
            env[:ui].info(" -- Cluster: #{config.cluster}")
            env[:ui].info(" -- Primary Node #{config.pnode}") if not config.pnode.nil?
            env[:ui].info(" -- Disk Template: #{config.disk_template}")
            env[:ui].info(" -- Disks #{config.disks}") 
            env[:ui].info(" -- Network Configurations: #{config.nics}") 
            env[:ui].info(" -- Memory : #{config.memory }") if not config.memory.nil?
            env[:ui].info(" -- VCPUs : #{config.vcpus }") if not config.vcpus.nil? 
            env[:ui].info(" -- Iallocator Policy : #{config.iallocator }") if not config.iallocator.nil?
            env[:ui].info(" -- Version : #{config.version }") if config.version 
            env[:ui].info(" -- ip_check : #{config.ip_check }") if not config.ip_check.nil?
            env[:ui].info(" -- name_check : #{config.name_check }") if not config.name_check.nil?
	    
	    createjob = client.instance_create()
	    env[:ui].info( "New Job Created #{createjob}.")
 	    env[:ui].info( "Preparing to Create Instance")
	    env[:ui].info( "This might take few minutes.....")
	    puts env[:ganeti_compute]


	    while true
		status =  client.is_job_ready(createjob)

		if  status == "error"
			env[:ui].info("Error Creating instance")
			break
		elsif status == "running"
			#Waiting for the message to succeed
			sleep(15)
		elsif status  == "success"
	    		env[:ui].info( "Instance sucessfully Created.")
 	    		env[:ui].info( "Booting up the Instance.")
            		bootinstancejob = client.start_instance()
			sleep(3)
		      	if client.is_job_ready(bootinstancejob) == "success" 
				env[:machine].id = client.info['nics'][0]['ip']
			        env[:ui].info( "#{ env[:machine].id}")
				env[:ui].info("Instance Started Successfully")
		        else
			 	env[:ui].info("Error Staring Instance")
                        end 
			break
		elsif status == "already_exists"
			env[:ui].info( "Instance already Exists. Use Vagrant SSH to login .\nUse 'vagrant destroy' and 'vagrant up' again to create instance afresh")	
			env[:machine].id = client.info['nics'][0]['ip']
			break
		end
	
            end

          @app.call(env)
        end
      end
    end
  end
end
