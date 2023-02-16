require 'spec_helper'
require 'python/pickle/protocol4'

require 'protocol0_read_instruction_examples'
require 'protocol1_read_instruction_examples'
require 'protocol2_read_instruction_examples'
require 'protocol3_read_instruction_examples'
require 'protocol4_read_instruction_examples'

describe Python::Pickle::Protocol4 do
  let(:pickle) { '' }
  let(:io) { StringIO.new(pickle) }

  subject { described_class.new(io) }

  describe "#read_uint64_le" do
    let(:uint16) { 0x0123456789abdef }
    let(:packed) { [uint16].pack('Q<') }
    let(:io)     { StringIO.new(packed) }

    it "must read two bytes and return an unpacked unsigned 64bit integer" do
      expect(subject.read_uint64_le).to eq(uint16)
    end
  end

  describe "#read_utf8_string" do
    let(:string) { "hello world\u1234" }
    let(:io)     { StringIO.new("#{string}XXX".b) }
    let(:length) { string.bytesize }

    it "must read a UTF-8 String with the desired number of bytes" do
      expect(subject.read_utf8_string(length)).to eq(string)
    end

    it "must return a UTF-8 encoded String" do
      expect(subject.read_utf8_string(length).encoding).to eq(Encoding::UTF_8)
    end
  end

  describe "#read_instruction" do
    include_context "Protocol0#read_instruction examples"
    include_context "Protocol1#read_instruction examples"
    include_context "Protocol2#read_instruction examples"
    include_context "Protocol3#read_instruction examples"
    include_context "Protocol4#read_instruction examples"

    context "when the opcode is not recognized" do
      let(:opcode) { 255 }
      let(:io)     { StringIO.new(opcode.chr) }

      it do
        expect {
          subject.read_instruction
        }.to raise_error(Python::Pickle::InvalidFormat,"invalid opcode (#{opcode.inspect}) for protocol 4")
      end
    end
  end
end
