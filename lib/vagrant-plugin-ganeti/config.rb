require "vagrant"

module VagrantPlugins
  module GANETI
    class Config < Vagrant.plugin("2", :config)
      # The username for accessing GANETI.
      #
      # @return [String]
      attr_accessor :rapi_user

      # The password for accessing GANETI.
      #
      # @return [String]
      attr_accessor :rapi_pass

      # The Host Detail
      #
      # @return [String]
      attr_accessor :cluster

      # The timeout to wait for an instance to become ready.
      #
      # @return [Fixnum]
      attr_accessor :instance_ready_timeout

     
      # The version of the GANETI api to use
      #
      # @return [String]
      attr_accessor :version


      # The name of the OS to use.
      #
      # @return [String]
      attr_accessor :os_type

      # The name of the OS to use.
      #
      # @return [String]
      attr_accessor :disk_template

      # An array of hash of disk sizes
      #
      # @return [{hash }]
      attr_accessor :disks

      # The name of the Instance
      #
      # @return [String]
      attr_accessor :instance_name

      # Mode of Creation
      #
      # @return [String]
      attr_accessor :mode

      # Network Configurations
      #
      # @return [{hash}]
      attr_accessor :nics

      # The name of the Primary Node
      #
      # @return [String]
      attr_accessor :pnode

      # The name of the Secondary Node for DRBD template
      #
      # @return [String]
      attr_accessor :snode
      
      # The name of the Iallocatoy
      #
      # @return [String]
      attr_accessor :iallocator

      # Memory Configurations in MB's
      #
      # @return [String]
      attr_accessor :memory

      # VCPU configuration
      #
      # @return [String]
      attr_accessor :vcpus

      # Name Check
      #
      # @return [Boolean]
      attr_accessor :name_check

      # IP Check  configuration
      #
      # @return [Boolean]
      attr_accessor :ip_check

      # hvparam Configs
      #
      # @return [String]
      attr_accessor :hvparam
      
      # hvparam Configs
      #
      # @return [String]
      attr_accessor :boot_order
      
      # hvparam Configs 
      #
      # @return [String]
      attr_accessor :cdrom_image_path

      # hvparam Configs 
      #
      # @return [String]
      attr_accessor :nic_type
      
      # hvparam Configs 
      #
      # @return [String]
      attr_accessor :disk_type

      # hvparam Configs 
      #
      # @return [String]
      attr_accessor :cpu_type
      
      # hvparam Configs 
      #
      # @return [String]
      attr_accessor :kernel_path

      # hvparam Configs 
      #
      # @return [String]
      attr_accessor :kernel_args
      
      # hvparam Configs 
      #
      # @return [String]
      attr_accessor :initrd_path

      # hvparam Configs 
      #
      # @return [String]
      attr_accessor :root_path

      # hvparam Configs 
      #
      # @return [String]
      attr_accessor :serial_console

      # hvparam Configs 
      #
      # @return [String]
      attr_accessor :kvm_flag
      
      def initialize()
        @rapi_user    	= UNSET_VALUE
        @rapi_pass 	= UNSET_VALUE
	@cluster        = UNSET_VALUE
        @version     	= 2
        @os_type      	= UNSET_VALUE
	@disk_template 	= UNSET_VALUE
	@disks 		= UNSET_VALUE
	@instance_name 	= UNSET_VALUE
	@mode		= UNSET_VALUE
	@nics 		= UNSET_VALUE
	@pnode 		= UNSET_VALUE
	@snode 		= UNSET_VALUE
	@iallocator 	= UNSET_VALUE
	@memory 	= UNSET_VALUE
	@vcpus 		= UNSET_VALUE
	@ip_check 	= UNSET_VALUE
	@name_check 	= UNSET_VALUE
	@boot_order 	= UNSET_VALUE
	@cdrom_image_path = UNSET_VALUE
	@nic_type	= UNSET_VALUE
	@disk_type	= UNSET_VALUE
	@cpu_type	= UNSET_VALUE
	@kernel_path 	= UNSET_VALUE
	@kernel_args 	= UNSET_VALUE
	@initrd_path	= UNSET_VALUE
	@root_path	= UNSET_VALUE
	@serial_console	= UNSET_VALUE
	@kvm_flag 	= UNSET_VALUE
        @__finalized 	= false
      end

      def finalize!
        # Username and password for the Ganei RAPI must be set .
        @rapi_user     = nil if @rapi_user   == UNSET_VALUE
        @rapi_pass = nil  if @rapi_pass == UNSET_VALUE

        # host must be nil, since we can't default that
        @cluster = nil if @cluster == UNSET_VALUE

        # OS_NAME must be nil, since we can't default that
        @os_type = nil if @os_type == UNSET_VALUE

        # disk_template since we can't default that
        @disk_template = "plain" if @disk_template == UNSET_VALUE

        # disks must be nil, since we can't default that
        @disks = [{"size"=>"8000"}]  if @disks == UNSET_VALUE

        # instance_name must be nil, since we can't default that
        @instance_name = nil if @instance_name == UNSET_VALUE

        # mode must be nil, since we can't default that
        @mode = "create" if @mode == UNSET_VALUE

        # nics must be nil, since we can't default that
        @nics = nil if @nics == UNSET_VALUE

        # pnode must be nil, since we can't default that
        @pnode = nil if @pnode == UNSET_VALUE
        
	# snode must be nil, since we can't default that
        @snode = nil if @snode == UNSET_VALUE

        # iallocator Get default from ganeti cluster
        @iallocator = "__DEFAULT__" if @iallocator == UNSET_VALUE

        # memory must be nil, since we can't default that
        @memory = nil if @memory == UNSET_VALUE

        # vcpu must be nil, since we can't default that
        @vcpus = nil if @vcpus == UNSET_VALUE
	
        # ip_check defaults to True
        @ip_check = true if @ip_check == UNSET_VALUE

        # name_check defaults to True
        @name_check = true if @name_check == UNSET_VALUE
	
        # boot_order defaults to Nil
        @boot_order = nil if @boot_order == UNSET_VALUE
	
        # cdrom_image_path to Nil
        @cdrom_image_path= nil if @cdrom_image_path == UNSET_VALUE
	
        # nic_type defaults to nil
        @nic_type = nil if @nic_type == UNSET_VALUE
	
        # disk_type defaults to nil
        @disk_type = nil if @disk_type == UNSET_VALUE
	
        # cpu_type defaults to nil
        @cpu_type = nil if @cpu_type == UNSET_VALUE
		
        # kernel_path defaults to nil
        @kernel_path = nil if @kernel_path == UNSET_VALUE
        
	# kernel_args defaults to nil
        @kernel_args = nil if @kernel_args == UNSET_VALUE
        
        
	# initrd_path defaults to nil
        @initrd_path = nil if @initrd_path == UNSET_VALUE
	
	# root_path_path defaults to nil
        @root_path = nil if @root_path == UNSET_VALUE
	
	# serial_console defaults to nil
        @serial_console = nil if @serial_console == UNSET_VALUE

	# kvm_flag defaults to nil
        @kvm_flag = nil if @kvm_flag == UNSET_VALUE
	
	# Set the default timeout for waiting for an instance to be ready
        @instance_ready_timeout = 120 if @instance_ready_timeout == UNSET_VALUE

        @version = nil if @version == UNSET_VALUE

        
        # Mark that we finalized
        @__finalized = true
      end


      def validate(machine)
        errors = _detected_errors

        errors << I18n.t("vagrant_ganeti.config.username_required") if @rapi_user.nil?
        errors << I18n.t("vagrant_ganeti.config.password_required") if @rapi_pass.nil?
	errors << I18n.t("vagrant_ganeti.config.host_required") if @cluster.nil?
	errors << I18n.t("vagrant_ganeti.config.os_name_required") if @os_type.nil?
	errors << I18n.t("vagrant_ganeti.config.disk_template_required") if @disk_template.nil?
        errors << I18n.t("vagrant_ganeti.config.disks_required") if @disks == nil
	errors << I18n.t("vagrant_ganeti.config.instance_name_required") if @instance_name.nil?
        errors << I18n.t("vagrant_ganeti.config.mode_required") if @mode.nil?
	errors << I18n.t("vagrant_ganeti.config.pnode_required") if @pnode.nil? and  @iallocator.nil?
	errors << I18n.t("vagrant_ganeti.config.snode_required") if @snode.nil? and  @disk_template == "drbd" and @iallocator.nil?
   	{ "GANETI Provider" => errors }

      end
      def get_config()
        if !@__finalized
          raise "Configuration must be finalized before calling this method."
        end

        self
      end
    end
  end
end
