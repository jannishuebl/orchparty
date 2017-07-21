require "spec_helper"

describe Orcparty::Transformations::Mixin do
  subject(:ast) { Orcparty::DSLParser.new("spec/input/mixin_example.rb").parse }

  describe "#transform" do

    subject(:transformed_ast) { Orcparty::Transformations::Mixin.new.transform(ast) }

    let(:first_application) { transformed_ast.applications["child-application"]  }

    describe "services" do
      let(:first_service) { first_application.services["base-service-1"] }
      let(:second_service) { first_application.services["base-service-2"] }

      it { expect(first_service.name).to eq("base-service-1") }
      it { expect(first_service.image).to eq("application-base-base-service-1:latest") }
      it { expect(first_service.command).to eq("bundle exec base") }

      it { expect(second_service.name).to eq("base-service-2") }
      it { expect(second_service.image).to eq("child-application-base-service-2:latest") }
      it { expect(second_service.command).to eq("bundle exec base") }

    end

  end
end