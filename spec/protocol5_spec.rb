require 'spec_helper'
require 'python/pickle/protocol5'

require 'protocol0_read_instruction_examples'
require 'protocol1_read_instruction_examples'
require 'protocol2_read_instruction_examples'
require 'protocol3_read_instruction_examples'
require 'protocol4_read_instruction_examples'

describe Python::Pickle::Protocol5 do
  let(:pickle) { '' }
  let(:io) { StringIO.new(pickle) }

  subject { described_class.new(io) }

  describe "#read_instruction" do
    include_context "Protocol0#read_instruction examples"
    include_context "Protocol1#read_instruction examples"
    include_context "Protocol2#read_instruction examples"
    include_context "Protocol3#read_instruction examples"
    include_context "Protocol4#read_instruction examples"

    describe "when the opcode is 150" do
      let(:bytes)  { [0x41, 0x42, 0x43] }
      let(:length) { bytes.length }
      let(:packed) { [length, *bytes].pack('Q<C*') }
      let(:io)     { StringIO.new("#{150.chr}#{packed}".b) }

      it "must return a Python::Pickle::Instructions::ByteArray8" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::ByteArray8.new(length,bytes)
        )
      end
    end

    describe "when the opcode is 151" do
      let(:io) { StringIO.new(151.chr) }

      it "must return Python::Pickle::Instructions::NEXT_BUFFER" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::NEXT_BUFFER
        )
      end
    end

    describe "when the opcode is 152" do
      let(:io) { StringIO.new(152.chr) }

      it "must return Python::Pickle::Instructions::READONLY_BUFFER" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::READONLY_BUFFER
        )
      end
    end

    context "when the opcode is not recognized" do
      let(:opcode) { 255 }
      let(:io)     { StringIO.new(opcode.chr) }

      it do
        expect {
          subject.read_instruction
        }.to raise_error(Python::Pickle::InvalidFormat,"invalid opcode (#{opcode.inspect}) for protocol 5")
      end
    end
  end
end
