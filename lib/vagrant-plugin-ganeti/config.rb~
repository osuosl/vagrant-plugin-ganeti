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

      # The name of the OS to use.
      #
      # @return [String]
      attr_accessor :os_name

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



      def initialize()
        @username     = UNSET_VALUE
        @os_name                = UNSET_VALUE
        @password  = UNSET_VALUE
        @version            = UNSET_VALUE
	@host            = UNSET_VALUE

        @__finalized = false
      end

      def finalize!
        # Try to get access keys from standard GANETI environment variables; they
        # will default to nil if the environment variables are not present.
        @username     = ENV['USERNAME'] if @username   == UNSET_VALUE
        @password = ENV['PASSWORD'] if @password == UNSET_VALUE

        # OS_NAME must be nil, since we can't default that
        @os_name = nil if @os_name == UNSET_VALUE

        # host must be nil, since we can't default that
        @host = nil if @host == UNSET_VALUE

        # Set the default timeout for waiting for an instance to be ready
        @instance_ready_timeout = 120 if @instance_ready_timeout == UNSET_VALUE

        @version = nil if @version == UNSET_VALUE

        end

        # Mark that we finalized
        @__finalized = true
      end


      def validate(machine)
        errors = _detected_errors

        errors << I18n.t("vagrant_ganeti.config.username_required") if @username.nil?
        errors << I18n.t("vagrant_ganeti.config.password_required") if @password.nil?
	errors << I18n.t("vagrant_ganeti.config.os_name_required") if @os_name.nil?
	errors << I18n.t("vagrant_ganeti.config.host_required") if @host.nil?
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
