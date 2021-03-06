require "log4r"

module VagrantPlugins
  module GANETI
    module Action
      # "unlink" vagrant and the managed server
      class UnlinkServer

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_ganeti::action::unlink_server")
        end

        def call(env)

          server = env[:machine].id

          # "Unlink" 
          env[:ui].info(I18n.t("vagrant_ganeti.unlinking_server", :host => server))
          env[:ui].info(" -- Server: #{server}")

          # set machine id to nil
          env[:machine].id = nil

          @app.call(env)
        end
      end
    end
  end
end
