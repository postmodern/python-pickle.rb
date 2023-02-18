require 'spec_helper'
require 'python/pickle/byte_array'

describe Python::Pickle::ByteArray do
  let(:string) { "ABC" }

  subject { described_class.new(string) } 

  describe "#initialize" do
    context "when called with no arguments" do
      subject { described_class.new() } 

      it "must initialize an empty bytearray with ASCII encoding" do
        expect(subject.length).to eq(0)
        expect(subject.encoding).to be(Encoding::ASCII_8BIT)
      end
    end

    context "when called with a String argument" do
      let(:string) { "ABC" }

      subject { described_class.new(string) } 

      it "must initialize a #{described_class} with the String" do
        expect(subject.to_s).to eq(string)
      end

      it "must set encoding to ASCII 8bit" do
        expect(subject.encoding).to be(Encoding::ASCII_8BIT)
      end
    end

    context "when called with a String and 'latin-1'" do
      let(:string)   { "ABC" }
      let(:encoding) { 'latin-1' }

      subject { described_class.new(string,encoding) } 

      it "must initialize a #{described_class} with the String" do
        expect(subject.to_s).to eq(string)
      end

      it "must set encoding to ISO-8859-1" do
        expect(subject.encoding).to be(Encoding::ISO_8859_1)
      end
    end
  end

  describe "#inspect" do
    it "must include the class name and string value of the bytearray" do
      expect(subject.inspect).to eq("#<#{described_class}: #{string.inspect}>")
    end
  end
end
