require "spec_helper"

describe Orchparty::Plugin::DockerComposeV2 do

  let(:input_file) { "spec/input/#{name}.rb" }
  let(:output) { File.read("spec/output/docker_compose_v2/#{name}.yml") }

  subject(:generation) { Orchparty::Plugin::DockerComposeV2.output(Orchparty.ast(filename: input_file, application: application_name)) }

  describe "example" do
    let(:name) {"example"}
    let(:application_name) {"web-example"}

    it { expect(generation).to eq(output) }
  end

end
