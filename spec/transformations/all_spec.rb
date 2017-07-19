require "spec_helper"

describe Orcparty::Transformations::All do
  subject(:ast) { Orcparty::DSLParser.new("spec/input/example.rb").parse }

  describe "#transform" do

    subject(:transformed_ast) { Orcparty::Transformations::All.new.transform(ast) }

    describe "services" do

      it { expect(transformed_ast.applications[0].services[0].labels.to_a[0]).to eq([:"com.example.overwrite", "web"]) }
      it { expect(transformed_ast.applications[0].services[0].labels.to_a[1]).to eq([:"com.example.description", "common description"]) }
      it { expect(transformed_ast.applications[0].services[0].labels.to_a[2]).to eq([:"com.example.web", "web label"]) }

      it { expect(transformed_ast.applications[0].services[1].labels.to_a[1]).to eq([:"com.example.description", "common description"]) }
      it { expect(transformed_ast.applications[0].services[1].labels.to_a[2]).to eq([:"com.example.db", "db label"]) }
      it { expect(transformed_ast.applications[0].services[1].labels.to_a[0]).to eq([:"com.example.overwrite", "global"]) }

    end

  end
end