require "vagrant"

module VagrantPlugins
  module GANETI
    class Config < Vagrant.plugin("2", :config)
      # The username for accessing GANETI.
      #
      # @return [String]
      attr_accessor :username

      # The password for accessing GANETI.
      #
      # @return [String]
      attr_accessor :password

      # The Host Detail
      #
      # @return [String]
      attr_accessor :host

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
      attr_accessor :os_name

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

      # The name of the Primary Node
      #
      # @return [String]
      attr_accessor :iallocator

      def initialize()
        @username    	= UNSET_VALUE
        @password  	= UNSET_VALUE
	@host           = UNSET_VALUE
        @version     	= 2
        @os_name      	= UNSET_VALUE
	@disk_template 	= UNSET_VALUE
	@disks 		= UNSET_VALUE
	@instance_name 	= UNSET_VALUE
	@mode		= UNSET_VALUE
	@nics 		= UNSET_VALUE
	@pnode 		= UNSET_VALUE
	@iallocator 	= UNSET_VALUE
        @__finalized 	= false
      end

      def finalize!
        # Username and password for the Ganei RAPI must be set .
        @username     = ENV['USERNAME'] if @username   == UNSET_VALUE
        @password = ENV['PASSWORD'] if @password == UNSET_VALUE

        # host must be nil, since we can't default that
        @host = nil if @host == UNSET_VALUE

        # OS_NAME must be nil, since we can't default that
        @os_name = nil if @os_name == UNSET_VALUE

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

        # pnode must be nil, since we can't default that
        @iallocator = nil if @iallocator == UNSET_VALUE
        
	# Set the default timeout for waiting for an instance to be ready
        @instance_ready_timeout = 120 if @instance_ready_timeout == UNSET_VALUE

        @version = nil if @version == UNSET_VALUE

        
        # Mark that we finalized
        @__finalized = true
      end


      def validate(machine)
        errors = _detected_errors

        errors << I18n.t("vagrant_ganeti.config.username_required") if @username.nil?
        errors << I18n.t("vagrant_ganeti.config.password_required") if @password.nil?
	errors << I18n.t("vagrant_ganeti.config.host_required") if @host.nil?
	errors << I18n.t("vagrant_ganeti.config.os_name_required") if @os_name.nil?
	errors << I18n.t("vagrant_ganeti.config.disk_template_required") if @disk_template.nil?
        errors << I18n.t("vagrant_ganeti.config.disks_required") if @disks == nil
	errors << I18n.t("vagrant_ganeti.config.instance_name_required") if @instance_name.nil?
        errors << I18n.t("vagrant_ganeti.config.mode_required") if @mode.nil?
	errors << I18n.t("vagrant_ganeti.config.nics_required") if @nics.nil?
	errors << I18n.t("vagrant_ganeti.config.pnode_required") if @pnode.nil? and  @iallocator.nil?
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
