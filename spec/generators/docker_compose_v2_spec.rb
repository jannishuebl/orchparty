require "spec_helper"

describe Orcparty::Generators::DockerComposeV2 do

  let(:input_file) { "spec/input/#{name}.rb" }
  let(:output) { File.read("spec/output/docker_compose_v2/#{name}.yml") }

  subject(:generation) { Orcparty.docker_compose_v2(input_file, application_name) }

  describe "example" do
    let(:name) {"example"}
    let(:application_name) {"web-example"}

    it { expect(generation).to eq(output) }
  end

end
