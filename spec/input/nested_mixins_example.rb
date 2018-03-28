application "nested-mixin-application" do
  mixin 'm1' do
    variables do
      var my_var: 'hello'
    end
  end

  mixin 'm2' do
    mix 'm1'
    environment do
      env MY_VAR: -> { my_var }
    end
  end

  mixin 'm3' do
    mix 'm2'
  end

  service 'service_a' do
    mix 'm2'
  end

  service 'service_b' do
    mix 'm3'
  end
end
