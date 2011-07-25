worker_processes 4
user "nobody", "nogroup"

APP_ROOT = "/var/www/expenses"

working_directory APP_ROOT
listen "#{APP_ROOT}/tmp/sockets/unicorn.sock", :backlog => 1024
timeout 30
pid "#{APP_ROOT}/tmp/pids/unicorn.pid"
stderr_path "#{APP_ROOT}/log/unicorn-stderr.log"
stdout_path "#{APP_ROOT}/log/unicorn-stdout.log"

preload_app true
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  old_pidfile = "#{APP_ROOT}/tmp/pids/unicorn.pid.oldbin"
  if File.exists?(old_pidfile) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pidfile).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end

