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

    context "when the opcode is 128" do
      let(:version) { 0x02 }
      let(:io)  { StringIO.new("#{128.chr}#{version.chr}") }

      it "must return a Python::Pickle::Instructions::Proto object" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::Proto.new(version)
        )
      end
    end

    context "when the opcode is 129" do
      let(:io) { StringIO.new(129.chr) }

      it "must return Python::Pickle::Instructions::NEWOBJ" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::NEWOBJ
        )
      end
    end

    context "when the opcode is 130" do
      let(:code) { 0xfe }
      let(:io)   { StringIO.new("#{130.chr}#{code.chr}") }

      it "must return Python::Pickle::Instructions::Ext1" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::Ext1.new(code)
        )
      end
    end

    context "when the opcode is 131" do
      let(:code)   { 0xfffe }
      let(:packed) { [code].pack('S<') }
      let(:io)     { StringIO.new("#{131.chr}#{packed}") }

      it "must return Python::Pickle::Instructions::Ext2" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::Ext2.new(code)
        )
      end
    end

    context "when the opcode is 132" do
      let(:code)   { 0xfffffffe }
      let(:packed) { [code].pack('L<') }
      let(:io)     { StringIO.new("#{132.chr}#{packed}") }

      it "must return Python::Pickle::Instructions::Ext4" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::Ext4.new(code)
        )
      end
    end

    context "when the opcode is 133" do
      let(:io) { StringIO.new(133.chr) }

      it "must return Python::Pickle::Instructions::TUPLE1" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::TUPLE1
        )
      end
    end

    context "when the opcode is 134" do
      let(:io) { StringIO.new(134.chr) }

      it "must return Python::Pickle::Instructions::TUPLE2" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::TUPLE2
        )
      end
    end

    context "when the opcode is 135" do
      let(:io) { StringIO.new(135.chr) }

      it "must return Python::Pickle::Instructions::TUPLE3" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::TUPLE3
        )
      end
    end

    context "when the opcode is 136" do
      let(:io) { StringIO.new(136.chr) }

      it "must return Python::Pickle::Instructions::NEWTRUE" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::NEWTRUE
        )
      end
    end

    context "when the opcode is 137" do
      let(:io) { StringIO.new(137.chr) }

      it "must return Python::Pickle::Instructions::NEWFALSE" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::NEWFALSE
        )
      end
    end

    describe "when the opcode is 138"
    describe "when the opcode is 139"

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
