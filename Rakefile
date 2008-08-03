
desc "launch network config tool"
task :netconfig do
  puts "sudo xandrosncs-proxy --launch-manage-tool"
end

desc "default repositories"
task :default_repos do
  %x{sudo cp original/sources.list /etc/apt/sources.list}
  %x{sudo rm /etc/apt/preferences}
end

desc "custom repositories"
task :custom_repos do
  %x{sudo cp custom/sources.list /etc/apt/sources.list}
  %x{sudo cp custom/preferences /etc/apt/preferences}
end

desc "default startup"
task :default_startup do
  %x{sudo cp original/services.sh /usr/sbin/services.sh}
  %x{sudo cp original/startsimple.sh /usr/bin/startsimple.sh}
  %x{sudo cp original/fastservices /etc/fastservices}
end

desc "custom startup"
task :custom_startup do
  %x{sudo cp custom/services.sh /usr/sbin/services.sh}
  %x{sudo cp custom/startsimple.sh /usr/bin/startsimple.sh}
  %x{sudo rm /etc/fastservices}
end

desc "my setup"
task :customise => [:custom_repos, :custom_startup]

desc "default setup"
task :restore => [:default_repos, :repos_startup]



