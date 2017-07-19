require "spec_helper"

describe Orcparty::Transformations::Mixin do
  subject(:ast) { Orcparty::DSLParser.new("spec/input/mixin_example.rb").parse }

  describe "#transform" do

    subject(:transformed_ast) { Orcparty::Transformations::Mixin.new.transform(ast) }

    describe "services" do

      it { expect(transformed_ast.applications[0].services[0].name).to eq("base-service-1") }
      it { expect(transformed_ast.applications[0].services[0].image).to eq("application-base-base-service-1:latest") }
      it { expect(transformed_ast.applications[0].services[0].command).to eq("bundle exec base") }

      it { expect(transformed_ast.applications[0].services[1].name).to eq("base-service-2") }
      it { expect(transformed_ast.applications[0].services[1].image).to eq("child-application-base-service-2:latest") }
      it { expect(transformed_ast.applications[0].services[1].command).to eq("bundle exec base") }

    end

  end
end