require "log4r"

require 'vagrant/util/retryable'

require 'vagrant-ganeti/util/timer'

module VagrantPlugins
  module GANETI
    module Action
      # This runs the configured instance.
      class RunInstance
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_ganeti::action::run_instance")
        end

        def call(env)
          # Initialize metrics if they haven't been
          env[:metrics] ||= {}


          # Get the configs
          config      	= env[:machine].provider_config.get_config()
          username    	= config.username
          os_name      	= config.os_name
          password  	= config.password
          version     	= config.version
	  host          = config.host
	  disk_template = config.disk_template
	  disks 	= config.disks
	  instance_name = config.instance_name
	  mode		= config.mode
	  nics 		= config.nics
	  pnode 	= config.pnode


          # Launch!
          env[:ui].info(I18n.t("vagrant_ganeti.launching_instance"))
          env[:ui].info(" -- Username: #{username}")
          env[:ui].info(" -- OS NAME: #{os_name}")
          env[:ui].info(" -- Instance NAME: #{instance_name}")
          env[:ui].info(" -- Host: #{host}")
          env[:ui].info(" -- Primary Noode #{pnode}") 
          env[:ui].info(" -- Disk Template: #{disk_template}")
          env[:ui].info(" -- Disks #{disks}") 
          env[:ui].info(" -- Network Configurations: #{nics}") 
          env[:ui].info(" -- Version : #{version }") if version 

          begin
            options = {
              :availability_zone  => availability_zone,
              :flavor_id          => instance_type,
              :image_id           => ami,
              :key_name           => keypair,
              :private_ip_address => private_ip_address,
              :subnet_id          => subnet_id,
              :tags               => tags,
              :user_data          => user_data
            }


            server = env[:ganeti_compute].servers.create(options)
          rescue Fog::Compute::GANETI::NotFound => e
            # Invalid subnet doesn't have its own error so we catch and
            # check the error message here.
            if e.message =~ /subnet ID/
              raise Errors::FogError,
                :message => "Subnet ID not found: #{subnet_id}"
            end

            raise
          rescue Fog::Compute::GANETI::Error => e
            raise Errors::FogError, :message => e.message
          end

          # Immediately save the ID since it is created at this point.
          env[:machine].id = server.id

          # Wait for the instance to be ready first
          env[:metrics]["instance_ready_time"] = Util::Timer.time do
            tries = config.instance_ready_timeout / 2

            env[:ui].info(I18n.t("vagrant_ganeti.waiting_for_ready"))
            begin
              retryable(:on => Fog::Errors::TimeoutError, :tries => tries) do
                # If we're interrupted don't worry about waiting
                next if env[:interrupted]

                # Wait for the server to be ready
                server.wait_for(2) { ready? }
              end
            rescue Fog::Errors::TimeoutError
              # Delete the instance
              terminate(env)

              # Notify the user
              raise Errors::InstanceReadyTimeout,
                timeout: region_config.instance_ready_timeout
            end
          end

          @logger.info("Time to instance ready: #{env[:metrics]["instance_ready_time"]}")

          if !env[:interrupted]
            env[:metrics]["instance_ssh_time"] = Util::Timer.time do
              # Wait for SSH to be ready.
              env[:ui].info(I18n.t("vagrant_ganeti.waiting_for_ssh"))
              while true
                # If we're interrupted then just back out
                break if env[:interrupted]
                break if env[:machine].communicate.ready?
                sleep 2
              end
            end

            @logger.info("Time for SSH ready: #{env[:metrics]["instance_ssh_time"]}")

            # Ready and booted!
            env[:ui].info(I18n.t("vagrant_ganeti.ready"))
          end

          # Terminate the instance if we were interrupted
          terminate(env) if env[:interrupted]

          @app.call(env)
        end

        def recover(env)
          return if env["vagrant.error"].is_a?(Vagrant::Errors::VagrantError)

          if env[:machine].provider.state.id != :not_created
            # Undo the import
            terminate(env)
          end
        end

        def terminate(env)
          destroy_env = env.dup
          destroy_env.delete(:interrupted)
          destroy_env[:config_validate] = false
          destroy_env[:force_confirm_destroy] = true
          env[:action_runner].run(Action.action_destroy, destroy_env)
        end
      end
    end
  end
end