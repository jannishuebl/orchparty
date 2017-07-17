require "spec_helper"

describe Orcparty::Generators::DockerComposeV1 do

  let(:input_file) { "spec/input/#{name}.rb" }
  let(:output) { File.read("spec/output/docker_compose_v1/#{name}.yml") }

  subject(:generation) { Orcparty.docker_compose_v1(input_file) }

  describe "example" do
    let(:name) {"example"}

    it { expect(generation).to eq(output) }
  end

end
