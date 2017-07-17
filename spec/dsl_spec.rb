require "spec_helper"

describe Orcparty::DSLParser do
  subject(:parser) { Orcparty::DSLParser.new("spec/input/example.rb") }

  describe "#parse" do

    subject(:parse) { parser.parse }

    it { expect(parse).to be_kind_of(Orcparty::AST::Application) }

    it { expect(parse.name).to eq("web-example") }

    it { expect(parse.services[0].name).to eq("web") }
    it { expect(parse.services[0].image).to eq("my-web-example:latest") }
    it { expect(parse.services[0].command).to eq("bundle exec rails s") }

    it { expect(parse.services[1].name).to eq("db") }
    it { expect(parse.services[1].image).to eq("postgres:latest") }

  end
end