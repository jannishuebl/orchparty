mixin "application-base" do

  service "base-service-1" do
    image "application-base-base-service-1:latest"
    command "bundle exec base"
  end

  service "base-service-2" do
    image "application-base-base-service-2:latest"
    command "bundle exec base"
  end

end

application "child-application" do
  mix "application-base"

  all do
    labels do
      label "com.example.overwrite":  "global"
      label "com.example.description":  "common description"
     end
  end

  service "base-service-2" do
    image "child-application-base-service-2:latest"
  end

end
