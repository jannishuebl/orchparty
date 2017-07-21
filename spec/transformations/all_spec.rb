require "spec_helper"

describe Orcparty::Transformations::All do
  subject(:ast) { Orcparty::DSLParser.new("spec/input/example.rb").parse }


  describe "#transform" do

    subject(:transformed_ast) { Orcparty::Transformations::All.new.transform(ast) }

    let(:first_application) { transformed_ast.applications["web-example"]  }

    describe "services" do
      let(:first_service) { first_application.services["web"] }
      let(:second_service) { first_application.services["db"] }

      it { expect(first_service.labels.to_a[0]).to eq([:"com.example.overwrite", "web"]) }
      it { expect(first_service.labels.to_a[1]).to eq([:"com.example.description", "common description"]) }
      it { expect(first_service.labels.to_a[2]).to eq([:"com.example.web", "web label"]) }

      it { expect(second_service.labels.to_a[1]).to eq([:"com.example.description", "common description"]) }
      it { expect(second_service.labels.to_a[2]).to eq([:"com.example.db", "db label"]) }
      it { expect(second_service.labels.to_a[0]).to eq([:"com.example.overwrite", "global"]) }

    end

  end
end