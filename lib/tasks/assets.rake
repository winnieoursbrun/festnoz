# Ensure npm dependencies are installed before asset precompilation
# This is needed for Heroku deployments where assets:precompile runs before npm install
Rake::Task["assets:precompile"].enhance([ "vite:install_dependencies" ])
