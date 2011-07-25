worker_processes 2
user "dennis"

APP_ROOT = "/Users/dennis/code/expenses"

working_directory APP_ROOT
listen "#{APP_ROOT}/tmp/sockets/unicorn.sock", :backlog => 64
timeout 30
pid "#{APP_ROOT}/tmp/pids/unicorn.pid"
stderr_path "#{APP_ROOT}/log/unicorn-stderr.log"
stdout_path "#{APP_ROOT}/log/unicorn-stdout.log"

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  old_pidfile = "#{APP_ROOT}/tmp/pids/unicorn.pid.oldbin"
  if File.exists?(old_pidfile) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pidfile).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
