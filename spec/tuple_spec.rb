require 'spec_helper'
require 'python/pickle/tuple'

describe Python::Pickle::Tuple do
  let(:elements) { [1,2,3] }

  subject { described_class.new(elements) }

  it "must inherit from Array" do
    expect(subject).to be_kind_of(Array)
  end

  describe "#inspect" do
    it "must include the class name and elements" do
      expect(subject.inspect).to eq("#<#{described_class}: #{elements.inspect}>")
    end
  end
end
