require "spec_helper"

describe Orcparty::DSLParser do
  subject(:parser) { Orcparty::DSLParser.new(input_file) }
  let(:input_file) { "spec/input/example.rb" }

  describe "#parse" do

    subject(:parse) { parser.parse }

    it { expect(parse).to be_kind_of(Orcparty::AST::Root) }


    describe "application" do

      let(:first_application) { parse.applications["web-example"]  }

      it { expect(first_application.name).to eq("web-example") }

      describe "services" do

        let(:first_service) { first_application.services["web"] }
        let(:second_service) { first_application.services["db"] }

        it { expect(first_service.name).to eq("web") }
        it { expect(first_service.image).to eq("my-web-example:latest") }
        it { expect(first_service.command).to eq("bundle exec rails s") }

        it { expect(second_service.name).to eq("db") }
        it { expect(second_service.image).to eq("postgres:latest") }

        describe "variables" do

          it { expect(first_service._variables.to_a[0]).to eq([:"service_var", "service"]) }

        end

      end

      describe "variables" do

        it { expect(first_application._variables.to_a[0]).to eq([:"app_var", "global"]) }

      end

      describe "all" do

        it { expect(first_application.all.labels.to_a[0]).to eq([:"com.example.overwrite", "global"]) }
        it { expect(first_application.all.labels.to_a[1]).to eq([:"com.example.description", "common description"]) }

      end
    end

    describe "mixin" do
      let(:input_file) { "spec/input/mixin_example.rb" }

      let(:first_mixin) { parse.mixins["application-base"]  }
      let(:first_service) { parse.mixins["application-base"].services["base-service-1"]  }
      let(:second_service) { parse.mixins["application-base"].services["base-service-2"]  }

      it { expect(first_mixin.name).to eq("application-base") }
      it { expect(first_service.name).to eq("base-service-1") }
      it { expect(first_service.image).to eq("application-base-base-service-1:latest") }
      it { expect(first_service.command).to eq("bundle exec base") }

      it { expect(second_service.name).to eq("base-service-2") }
      it { expect(second_service.image).to eq("application-base-base-service-2:latest") }
      it { expect(second_service.command).to eq("bundle exec base") }

    end

    describe "import" do
      let(:input_file) { "spec/input/import_example.rb" }

      it { expect(parse.applications.keys).to include("web-example") }
      it { expect(parse.applications.keys).to include("web-example-2") }
    end
  end
end