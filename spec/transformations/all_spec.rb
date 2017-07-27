require "spec_helper"

describe Orchparty::Transformations::All do
  subject(:ast) { Orchparty::DSLParser.new("spec/input/example.rb").parse }


  describe "#transform" do

    subject(:transformed_ast) { Orchparty::Transformations::Mixin.new.transform(Orchparty::Transformations::All.new.transform(ast)) }

    let(:first_application) { transformed_ast.applications["web-example"]  }

    describe "services" do
      let(:first_service) { first_application.services["web"] }
      let(:second_service) { first_application.services["db"] }

      it { expect(first_service.labels.to_a[0]).to eq([:"all-mixin", "true"]) }
      it { expect(first_service.labels.to_a[1]).to eq([:"com.example.overwrite", "web"]) }
      it { expect(first_service.labels.to_a[2]).to eq([:"com.example.description", "common description"]) }
      it { expect(first_service.labels.to_a[3]).to eq([:"com.example.web", "web label"]) }
      it { expect(first_service.extra_hosts[0]).to eq("extra_host1") }
      it { expect(first_service.extra_hosts[1]).to eq("extra_host2") }
      it { expect(first_service.extra_hosts[2]).to eq("extra_host3") }

      it { expect(second_service.labels.to_a[0]).to eq([:"all-mixin", "true"]) }
      it { expect(second_service.labels.to_a[1]).to eq([:"com.example.overwrite", "global"]) }
      it { expect(second_service.labels.to_a[2]).to eq([:"com.example.description", "common description"]) }
      it { expect(second_service.labels.to_a[3]).to eq([:"com.example.db", "db label"]) }
      it { expect(second_service.extra_hosts[0]).to eq("extra_host1") }
      it { expect(second_service.extra_hosts[1]).to eq("extra_host2") }
      it { expect(second_service.extra_hosts[2]).to eq("extra_host3") }

    end

  end
end
