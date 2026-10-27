# frozen_string_literal: true

RSpec.describe GrexRuby do
  it "has a version number" do
    expect(GrexRuby::VERSION).not_to be nil
  end

  it "can call into Rust" do
    result = GrexRuby.hello("earth")

    expect(result).to be("Hello earth, from Rust!")
  end
end
