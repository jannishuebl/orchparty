require "spec_helper"

describe Orchparty::Generators::DockerComposeV1 do

  let(:input_file) { "spec/input/#{name}.rb" }
  let(:output) { File.read("spec/output/docker_compose_v1/#{name}.yml") }
  let(:application_name) {  }

  subject(:generation) { Orchparty.docker_compose_v1(input_file, application_name) }

  describe "example" do
    let(:name) {"example"}
    let(:application_name) {"web-example"}

    it { expect(generation).to eq(output) }
  end

end
