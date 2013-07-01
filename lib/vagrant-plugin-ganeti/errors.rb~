require "vagrant"

module VagrantPlugins
  module GANETI
    module Errors
      class VagrantGANETIError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_ganeti.errors")
      end

      class InstanceReadyTimeout < VagrantGANETIError
        error_key(:instance_ready_timeout)
      end

      class RsyncError < VagrantGANETIError
        error_key(:rsync_error)
      end
    end
  end
end
