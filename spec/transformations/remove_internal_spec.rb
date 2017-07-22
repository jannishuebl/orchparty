require "spec_helper"

describe Orcparty::Transformations::RemoveInternal do
  subject(:ast) { Orcparty::DSLParser.new("spec/input/variable_example.rb").parse }

  describe "#transform" do

    subject(:transformed_ast) { Orcparty::Transformations::RemoveInternal.new.transform(ast) }

    let(:first_application) { transformed_ast.applications["web-example"]  }

    describe "services" do
      let(:first_service) { first_application.services["web"] }
      let(:second_service) { first_application.services["db"] }

      it { expect(second_service.keys).not_to include(:"_mix") }
      it { expect(second_service.keys).not_to include("_variables") }

    end

    it { expect(first_application.keys).not_to include("_variables") }

  end
end