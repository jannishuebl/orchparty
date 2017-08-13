require "spec_helper"

describe Orchparty::Transformations do



  describe "#transform" do
    subject(:transformed_ast) { Orchparty::Transformations.transform(ast) }
    describe "empty" do
      subject(:ast) { Orchparty::DSLParser.new("spec/input/empty_example.rb").parse }


      let(:first_application) { transformed_ast.applications["empty"]  }

      describe "services" do

        it { expect(first_application.services.count).to eq(0) }

      end
    end

    describe "only-services" do
      subject(:ast) { Orchparty::DSLParser.new("spec/input/only_services_example.rb").parse }


      let(:first_application) { transformed_ast.applications["only-services"]  }

      describe "services" do

        it { expect(first_application.services.count).to eq(2) }

      end
    end

    describe "empty-mixin" do
      subject(:ast) { Orchparty::DSLParser.new("spec/input/empty_mixin.rb").parse }


      let(:first_application) { transformed_ast.applications["testapp"]  }

      describe "services" do

        it { expect(first_application.services.count).to eq(1) }

      end
    end

  end
end