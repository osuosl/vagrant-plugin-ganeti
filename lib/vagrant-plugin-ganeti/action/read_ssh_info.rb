require "log4r"

module VagrantPlugins
  module GANETI
    module Action
      # This action reads the SSH info for the machine and puts it into the
      # `:machine_ssh_info` key in the environment.
      class ReadSSHInfo
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_ganeti::action::read_ssh_info")
        end

        def call(env)
          env[:machine_ssh_info] = read_ssh_info(env[:ganeti_compute], env[:machine])

          @app.call(env)
        end

        def read_ssh_info(ganeti, machine)
          return nil if machine.id.nil?

          # Find the machine
          server = ganeti.servers.get(machine.id)
          if server.nil?
            # The machine can't be found
            @logger.info("Machine couldn't be found, assuming it got destroyed.")
            machine.id = nil
            return nil
          end

          # Read the DNS info
          return {
            :host => server.dns_name || server.private_ip_address,
            :port => 22
          }
        end
      end
    end
  end
end
