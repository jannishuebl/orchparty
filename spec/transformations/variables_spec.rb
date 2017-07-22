require "spec_helper"

describe Orcparty::Transformations::Variable do
  subject(:ast) { Orcparty::DSLParser.new("spec/input/variable_example.rb").parse }

  describe "#transform" do

    subject(:transformed_ast) { Orcparty::Transformations::Variable.new.transform(ast) }

    let(:first_application) { transformed_ast.applications["web-example"]  }

    describe "services" do
      let(:first_service) { first_application.services["web"] }
      let(:second_service) { first_application.services["db"] }

      it { expect(second_service.command).to eq("ruby db") }
      it { expect(second_service.labels[:"com.example.db"]).to eq("postgres:latest label") }

    end

  end
end