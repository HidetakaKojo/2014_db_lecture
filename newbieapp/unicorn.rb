@dir = '/home/ubuntu/2014_db_lecture/newbieapp'

worker_processes 10
working_directory @dir

timeout 30

listen 9393, :backlog => 16
pid "#{@dir}/pids/unicorn.pid"
