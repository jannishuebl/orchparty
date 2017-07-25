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

mixin "service-base" do

  service "service-mixin" do
    labels do
      label "com.example.service-mixin":  "mixed"
     end
  end

end

application "child-application" do
  mix "application-base"

  mixin "application-service-mixin" do
    labels do
      label "com.example.application-service-mixin":  "mixed"
     end
  end

  all do
    labels do
      label "com.example.overwrite":  "global"
      label "com.example.description":  "common description"
     end
  end

  service "base-service-2" do
    mix "service-base.service-mixin"
    mix "application-service-mixin"
    image "child-application-base-service-2:latest"
  end

end
