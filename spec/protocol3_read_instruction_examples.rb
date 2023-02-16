require 'spec_helper'

shared_examples_for "Protocol3#read_instruction examples" do
  describe "when the opcode is 66" do
    let(:length) { 12 }
    let(:bytes)  { "hello world\0".b }
    let(:packed) { [length, bytes].pack('L<a*') }
    let(:io)     { StringIO.new("#{66.chr}#{packed}".b) }

    it "must return Python::Pickle::Instructions::BinBytes" do
      expect(subject.read_instruction).to eq(
        Python::Pickle::Instructions::BinBytes.new(length,bytes)
      )
    end
  end

  describe "when the opcode is 67" do
    let(:length) { 12 }
    let(:bytes)  { "hello world\0".b }
    let(:packed) { [length, bytes].pack('Ca*') }
    let(:io)     { StringIO.new("#{67.chr}#{packed}".b) }

    it "must return Python::Pickle::Instructions::ShortBinBytes" do
      expect(subject.read_instruction).to eq(
        Python::Pickle::Instructions::ShortBinBytes.new(length,bytes)
      )
    end
  end
end
