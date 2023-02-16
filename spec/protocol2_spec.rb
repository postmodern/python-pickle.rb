require 'spec_helper'
require 'python/pickle/protocol2'

require 'protocol1_read_instruction_examples'

describe Python::Pickle::Protocol2 do
  let(:pickle) { '' }
  let(:io) { StringIO.new(pickle) }

  subject { described_class.new(io) }

  describe "#read_uint16_le" do
    let(:uint16) { 0xfffe }
    let(:packed) { [uint16].pack('S<') }
    let(:io)     { StringIO.new(packed) }

    it "must read two bytes and return an unpacked unsigned 16bit integer" do
      expect(subject.read_uint16_le).to eq(uint16)
    end
  end

  describe "#unpack_int_le" do
    context "when given an empty String" do
      it "must return 0" do
        expect(subject.unpack_int_le("".b)).to eq(0)
      end
    end

    context "when given a single byte String" do
      it "must return the first byte" do
        expect(subject.unpack_int_le("\x01".b)).to eq(0x01)
      end

      context "but the most significant bits are set" do
        it "must return a negative integer" do
          expect(subject.unpack_int_le("\xff".b)).to eq(-1)
        end
      end
    end

    context "when given a two byte string" do
      it "must decode the string and return an integer" do
        expect(subject.unpack_int_le("\x00\x01".b)).to eq(0x100)
      end

      context "but the most significant bits are set" do
        it "must return a negative integer" do
          expect(subject.unpack_int_le("\x00\xff".b)).to eq(-256)
        end
      end
    end

    context "when given a three byte string" do
      it "must decode the string and return an integer" do
        expect(subject.unpack_int_le("\x00\x00\xff".b)).to eq(-65536)
      end
    end
  end

  describe "#read_int_le" do
    context "when called with 0" do
      let(:io) { StringIO.new("".b) }

      it "must read zero bytes return 0" do
        expect(subject.read_int_le(0)).to eq(0)
      end
    end

    context "when called with 1" do
      let(:io) { StringIO.new("\x01".b) }

      it "must read one byte return the first byte" do
        expect(subject.read_int_le(1)).to eq(0x01)
      end

      context "but the most significant bits are set" do
        let(:io) { StringIO.new("\xff".b) }

        it "must read one byte return a negative integer" do
          expect(subject.read_int_le(1)).to eq(-1)
        end
      end
    end

    context "when called with 2" do
      let(:io) { StringIO.new("\x00\x01".b) }

      it "must read two bytes and decode the string and return an integer" do
        expect(subject.read_int_le(2)).to eq(0x100)
      end

      context "but the most significant bits are set" do
        let(:io) { StringIO.new("\x00\xff".b) }

        it "must read two bytes and return a negative integer" do
          expect(subject.read_int_le(2)).to eq(-256)
        end
      end
    end

    context "when called with 3" do
      let(:io) { StringIO.new("\x00\x00\xff".b) }

      it "must read three bytes and decode the string and return an integer" do
        expect(subject.read_int_le(3)).to eq(-65536)
      end
    end
  end

  describe "#read_instruction" do
    include_context "Protocol1#read_instruction examples"
    include_context "Protocol2#read_instruction examples"

    context "when the opcode is not recognized" do
      let(:opcode) { 255 }
      let(:io)     { StringIO.new(opcode.chr) }

      it do
        expect {
          subject.read_instruction
        }.to raise_error(Python::Pickle::InvalidFormat,"invalid opcode (#{opcode.inspect}) for protocol 2")
      end
    end
  end
end
