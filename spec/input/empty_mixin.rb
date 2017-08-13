application 'testapp' do
  all do
    mix 'dev'
    image -> { image  }
  end
  variables do
    var image: 'test/test'
  end  
  mixin 'dev' do
  end
  service 'test' do
  end
end