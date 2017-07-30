mixin "application-base" do

  service "base-service-1" do
    mix 'application-base.sub-mixin'
    image "application-base-base-service-1:latest"
    command "bundle exec base"
  end

  service "base-service-2" do
    image "application-base-base-service-2:latest"
    command "bundle exec base"
  end

  mixin "sub-mixin" do
    expose do
      e 3456
    end
  end

  mixin "mixin" do
    expose do
      e 6543
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

  service "base-service-3" do
    mix "application-base.base-service-1"
    mix "application-base.mixin"
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
