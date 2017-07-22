application "web-example" do
  variables do 
    var app_var: "app"
    var app_var_overwrite: "app"
  end

  all do
    labels do
      label "com.example.overwrite":  "global"
      label "com.example.description":  "common description"
     end
  end

  service "web" do
    image "my-web-example:latest"
    command "bundle exec rails s"
    labels do
      label "com.example.web":  "web label"
      label "com.example.overwrite":  "web"
     end
  end

  service "db" do
    variables do 
      var service_var: "service"
      var app_var_overwrite: "service"
    end
    image "postgres:latest"
    command -> { "ruby #{ context.service.name }" }
    labels do
      label "com.example.db":  -> { "#{ service.image } label" }
      label "app_var":  -> { app_var }
      label "app_var_overwrite":  -> { app_var_overwrite }
      label "application.app_var_overwrite":  -> { application.app_var_overwrite }
      label "service_var":  -> { context.service_var }
     end
  end

end