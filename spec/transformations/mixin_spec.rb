require "spec_helper"

describe Orchparty::Transformations::Mixin do
  subject(:ast) { Orchparty::DSLParser.new("spec/input/mixin_example.rb").parse }

  describe "#transform" do

    subject(:transformed_ast) { Orchparty::Transformations::Mixin.new.transform(ast) }

    let(:first_application) { transformed_ast.applications["child-application"]  }

    describe "services" do
      let(:first_service) { first_application.services["base-service-1"] }
      let(:second_service) { first_application.services["base-service-2"] }
      let(:third_service) { first_application.services["base-service-3"] }

      it { expect(first_application.services.count).to eq(3) }
      it { expect(first_service.name).to eq("base-service-1") }
      it { expect(first_service.image).to eq("application-base-base-service-1:latest") }
      it { expect(first_service.command).to eq("bundle exec base") }
      it { expect(first_service.expose.first).to eq(3456) }

      it { expect(second_service.name).to eq("base-service-2") }
      it { expect(second_service.image).to eq("child-application-base-service-2:latest") }
      it { expect(second_service.command).to eq("bundle exec base") }

      it { expect(second_service.labels[:"com.example.service-mixin"]).to eq("mixed") }
      it { expect(second_service.labels[:"com.example.application-service-mixin"]).to eq("mixed") }

      it { expect(third_service.expose[0]).to eq(3456) }
      it { expect(third_service.expose[1]).to eq(6543) }
    end

    describe "volumes" do

      it { expect(first_application.volumes.count).to eq(3) }

    end

    describe "networks" do

      it { expect(first_application.networks.count).to eq(2) }

    end

    context "nested mixins" do

      subject(:ast) { Orchparty::DSLParser.new("spec/input/nested_mixins_example.rb").parse }
      subject(:transformed_ast_mixin) { Orchparty::Transformations::Mixin.new.transform(ast) }
      subject(:transformed_ast_variable) { Orchparty::Transformations::Variable.new.transform(transformed_ast_mixin) }

      let(:first_application) { transformed_ast_variable.applications["nested-mixin-application"]  }

      describe "services" do
        let(:service_a) { first_application.services["service_a"] }
        let(:service_b) { first_application.services["service_b"] }

        it { expect(service_a.environment["MY_VAR"]).to eq("hello") }
        it { expect(service_b.environment["MY_VAR"]).to eq("hello") }

      end

    end

  end
end
