module VagrantPlugins
  module GANETI
    module Action
      # This can be used with "Call" built-in to check if the machine
      # is created and branch in the middleware.
      class IsReachable
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:result] = true
          @app.call(env)
        end
      end
    end
  end
end
