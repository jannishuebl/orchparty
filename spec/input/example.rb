mixin "mixin" do
  service "mixin1" do
    labels do
      label "all-mixin":  "true"
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
      label "com.example.overwrite":  "global"
      label "com.example.description":  "common description"
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

end
