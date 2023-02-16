require 'spec_helper'
require 'python/pickle/protocol1'

require 'protocol0_read_instruction_examples'
require 'protocol1_read_instruction_examples'

describe Python::Pickle::Protocol1 do
  let(:pickle) { '' }
  let(:io) { StringIO.new(pickle) }

  subject { described_class.new(io) }

  describe "#read_float64_be" do
    let(:float)  { 1234.5678 }
    let(:packed) { [float].pack('G') }

    let(:io) { StringIO.new(packed) }

    it "must read eight bytes and decode a big-endian floating point number" do
      expect(subject.read_float64_be).to eq(float)
    end
  end

  describe "#read_uint8" do
    let(:io) { StringIO.new("\xff".b) }

    it "must read a single unsignd byte" do
      expect(subject.read_uint8).to eq(0xff)
    end
  end

  describe "#read_uint32_le" do
    let(:uint32) { 0xffeeddcc }
    let(:packed) { [uint32].pack('L<') }
    let(:io)     { StringIO.new(packed) }

    it "must read four bytes and return an unpacked uint32 in little-endian byte-order" do
      expect(subject.read_uint32_le).to eq(uint32)
    end
  end

  let(:fixtures_dir) { File.join(__dir__,'fixtures') }

  describe "#read_instruction" do
    include_context "Protocol0#read_instruction examples"
    include_context "Protocol1#read_instruction examples"

    context "when the opcode is not recognized" do
      let(:opcode) { 255 }
      let(:io)     { StringIO.new(opcode.chr) }

      it do
        expect {
          subject.read_instruction
        }.to raise_error(Python::Pickle::InvalidFormat,"invalid opcode (#{opcode.inspect}) for protocol 1")
      end
    end
  end
end
