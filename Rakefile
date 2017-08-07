require "bundler/gem_tasks"
require_relative 'lib/orchparty/version.rb'


task :upload_docker => [:build] do
  version = Orchparty::VERSION.split(".")
  tags = []
  tags << "latest"
  tags << version.join(".")
  tags << version[0..1].join(".")
  tags << version[0]

  puts `docker login -u $DOCKER_USER -p $DOCKER_PASS`
  puts `docker build . -t orchparty`
  tags.each do |tag|
    puts `docker tag orchparty jannishuebl/orchparty:#{tag}`
    puts `docker push jannishuebl/orchparty:#{tag}`
  end
end
