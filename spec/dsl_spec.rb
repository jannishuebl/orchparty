require "spec_helper"

describe Orcparty::DSLParser do
  subject(:parser) { Orcparty::DSLParser.new(input_file) }
  let(:input_file) { "spec/input/example.rb" }

  describe "#parse" do

    subject(:parse) { parser.parse }

    it { expect(parse).to be_kind_of(Orcparty::AST::Root) }


    describe "application" do

      it { expect(parse.applications[0].name).to eq("web-example") }

      describe "services" do

        it { expect(parse.applications[0].services[0].name).to eq("web") }
        it { expect(parse.applications[0].services[0].image).to eq("my-web-example:latest") }
        it { expect(parse.applications[0].services[0].command).to eq("bundle exec rails s") }

        it { expect(parse.applications[0].services[1].name).to eq("db") }
        it { expect(parse.applications[0].services[1].image).to eq("postgres:latest") }

      end

      describe "all" do

        it { expect(parse.applications[0].all.labels.to_a[0]).to eq([:"com.example.overwrite", "global"]) }
        it { expect(parse.applications[0].all.labels.to_a[1]).to eq([:"com.example.description", "common description"]) }

      end
    end

    describe "mixin" do
      let(:input_file) { "spec/input/mixin_example.rb" }

      it { expect(parse.mixins[0].name).to eq("application-base") }
      it { expect(parse.mixins[0].services[0].name).to eq("base-service-1") }
      it { expect(parse.mixins[0].services[0].image).to eq("application-base-base-service-1:latest") }
      it { expect(parse.mixins[0].services[0].command).to eq("bundle exec base") }

      it { expect(parse.mixins[0].services[1].name).to eq("base-service-2") }
      it { expect(parse.mixins[0].services[1].image).to eq("application-base-base-service-2:latest") }
      it { expect(parse.mixins[0].services[1].command).to eq("bundle exec base") }

    end
  end
end