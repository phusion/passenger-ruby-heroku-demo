# Fixes up headers based on information given by the Heroku router.
# by @honglilai
class HerokuNginxHeadersMiddleware
  def initialize(app)
    @app = app
  end
 
  def call(env)
    env["SERVER_PORT"] = env["HTTP_X_FORWARDED_PORT"]
    env["REMOTE_ADDR"] = env["HTTP_X_FORWARDED_FOR"]
    @app.call(env)
  end
end
