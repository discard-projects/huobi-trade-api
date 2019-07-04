require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)
# require 'mina/rvm'    # for rvm support. (https://rvm.io)
require 'mina/puma'
require 'mina/bundler'
# require 'mina/whenever'
require 'mina_sidekiq/tasks'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :application_name, 'huobi-api'
set :domain, 'root@104.199.175.127'
set :deploy_to, '/mnt/www/huobi/huobi-api'
set :repository, 'git@gitee.com:huobigroup/huobi-auto-trade.git'
set :branch, 'master'

set :sidekiq_pid, "#{fetch(:shared_path)}/tmp/pids/sidekiq.pid"
set :sidekiq_processes, 2
set :sidekiq_config, "#{fetch(:shared_path)}/config/sidekiq.yml"

# Optional settings:
#   set :user, 'foobar'          # Username in the server to SSH to.
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
# set :shared_dirs, fetch(:shared_dirs, []).push('public/assets')
# set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')
set :shared_dirs, fetch(:shared_dirs, []).push('log', 'tmp/pids', 'tmp/sockets', 'public/uploads')
set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/application.yml', 'config/master.key', 'config/puma.rb', 'config/sidekiq.yml')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use', 'ruby-1.9.3-p125@default'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  command %{rbenv install 2.6.3 --skip-existing}
  command %[touch "#{fetch(:shared_path)}/config/database.yml"]
  command %[touch "#{fetch(:shared_path)}/config/application.yml"]
  command %[touch "#{fetch(:shared_path)}/config/master.key"]
  # command %[touch "#{fetch(:shared_path)}/config/secrets.yml"]
  command %[touch "#{fetch(:shared_path)}/config/puma.rb"]
  command %[touch "#{fetch(:shared_path)}/config/sidekiq.yml"]
  comment "Be sure to edit '#{fetch(:shared_path)}/config/database.yml', 'application.yml', 'master.key' and puma.rb."
end

desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    # 停止 sidekiq
    invoke :'sidekiq:quiet'
    invoke :'bundle:install'
    # invoke :'rails:db_create'
    invoke :'rails:db_migrate'
    # invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %{mkdir -p tmp/}
        command %{touch tmp/restart.txt}
      end
      # invoke :'whenever:update'
      # # 重启 sidekiq
      # invoke :'sidekiq:restart'
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
# mina 'rake[samples:all]' on=production
# mina 'rake[jobs:first_init]' on=production
# mina sidekiq:restart