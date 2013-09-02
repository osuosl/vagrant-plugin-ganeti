require 'rubygems'
require 'uri'
require 'net/http'
require 'net/https'
require 'base64'
require 'json'
require 'log4r'

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
	    client = VagrantPlugins::GANETI::Util::GanetiClient.new(config.cluster,config.rapi_user,config.rapi_pass)
	    info = {}  
	    info['__version__'] = 1 
	    info['os_type'] = config.os_type               
	    info['disk_template'] = config.disk_template 
	    info['disks'] = config.disks
	    info['instance_name'] = config.instance_name
	    info['mode'] = config.mode        
	    info['nics'] = config.nics

            if config.iallocator == "__DEFAULT__"  and config.pnode.nil? 
                config.iallocator =  client.set_default_iallocator
		info['iallocator'] = config.iallocator
	    elsif not config.iallocator.nil? and config.pnode.nil?
		info['iallocator'] = config.iallocator
	    end

	    # Adding optional parameters
	    info['ip_check'] =false if not config.ip_check.nil? and config.ip_check ==false
	    info['name_check'] =false if not config.name_check.nil? and config.name_check ==false
	    info['pnode'] = config.pnode if not config.pnode.nil?
	    info['snode'] = config.snode if not config.snode.nil?
	    info['beparams'] = {} #Key value pairs
	    info['beparams']['memory'] = config.memory if not config.memory.nil?
	    info['beparams']['vcpus'] = config.vcpus if not config.vcpus.nil?  
	    info['hvparams'] = {} #key value pairs
	    info['hvparams']['boot_order'] = config.boot_order if not config.boot_order.nil?
	    info['hvparams']['cdrom_image_path'] = config.cdrom_image_path if not config.cdrom_image_path.nil?
	    info['hvparams']['nic_type'] = config.nic_type if not config.nic_type.nil?
	    info['hvparams']['disk_type'] = config.disk_type if not config.disk_type.nil?
	    info['hvparams']['cpu_type'] = config.cpu_type if not config.cpu_type.nil?
	    info['hvparams']['kernel_path'] = config.kernel_path if not config.kernel_path.nil?
	    info['hvparams']['kernel_args'] = config.kernel_args if not config.kernel_args.nil?
	    info['hvparams']['initrd_path'] = config.initrd_path if not config.initrd_path.nil?
	    info['hvparams']['root_path'] = config.root_path if not config.root_path.nil?
	    info['hvparams']['serial_console'] = config.serial_console if not config.serial_console.nil?
	    info['hvparams']['kvm_flag'] = config.kvm_flag if not config.kvm_flag.nil?


	    client.set_config(info)
	    @logger.info("Connecting to GANETI...")
            #Call  ganeti_client ruby wrapper
	    env[:ganeti_compute] = client
	    @app.call(env)
        end
       end
      end #Action
  end #ganeti
end #VagrantPlugin
