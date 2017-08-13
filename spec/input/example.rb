mixin "mixin" do
  service "mixin1" do
    labels do
      label "all-mixin":  "true"
    end
  end

  volumes do
    volume "data-volume-3" do
      v external: false
    end
  end

  networks do 
    network "outside" do
      net external: true
    end
  end
end

application "web-example" do
  variables do 
    var app_var: "global"
  end

  all do
    mix "mixin.mixin1"
    labels do
      label "com.example.description":  "common description"
      label "com.example.overwrite":  "global"
    end
    extra_hosts do
      env "extra_host1"
      env "extra_host2"
      env "extra_host3"
    end
  end

  service "web" do
    variables do 
      var service_var: "service"
    end
    image "my-web-example:latest"
    command "bundle exec rails s"
    labels do
      label "com.example.web":  "web label"
      label "com.example.overwrite":  "web"
    end
  end

  service "db" do
    image "postgres:latest"
    labels do
      label "com.example.db":  "db label"
    end
  end

  volumes do
    volume "data-volume-1": nil
    volume "data-volume-2" do
      v external: true
    end
  end

  networks do 
    network "inside" do
      net external: false
    end
  end

end
