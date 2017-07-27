application 'test' do

  service 'web' do

    variables do
      var port: 4000
    end

    image -> { "image" }
  end
end
