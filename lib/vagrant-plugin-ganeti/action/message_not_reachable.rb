module VagrantPlugins
  module GANETI
    module Action
      class MessageNotReachable
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t("vagrant_ganeti.host_not_reachable"))
          @app.call(env)
        end
      end
    end
  end
end
