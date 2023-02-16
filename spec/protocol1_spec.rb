require 'spec_helper'
require 'python/pickle/protocol1'

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
    context "when the opcode is 40" do
      let(:io) { StringIO.new(40.chr) }

      it "must return Python::Pickle::Instructions::MARK" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::MARK
        )
      end
    end

    context "when the opcode is 41" do
      let(:io) { StringIO.new(41.chr) }

      it "must return Python::Pickle::Instructions::EMPTY_TUPLE" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::EMPTY_TUPLE
        )
      end
    end

    context "when the opcode is 46" do
      let(:io) { StringIO.new(46.chr) }

      it "must return Python::Pickle::Instructions::STOP" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::STOP
        )
      end
    end

    context "when the opcode is 71" do
      let(:float)  { 1234.5678 }
      let(:packed) { [float].pack('G') }

      let(:io) { StringIO.new("#{71.chr}#{packed}\n") }

      it "must return a Python::Pickle::Instructions::BinFloat object" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::BinFloat.new(float)
        )
      end
    end

    context "when the opcode is 73" do
      let(:int) { 1234 }
      let(:io)  { StringIO.new("#{73.chr}#{int}\n") }

      it "must return a Python::Pickle::Instructions::Int object" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::Int.new(int)
        )
      end
    end

    context "when the opcode is 75" do
      let(:int) { 0xff }
      let(:io)  { StringIO.new("#{75.chr}#{int.chr}") }

      it "must return a Python::Pickle::Instructions::BinInt1 object" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::BinInt1.new(int)
        )
      end
    end

    context "when the opcode is 76" do
      let(:long) { (2**64)-1 }
      let(:io)   { StringIO.new("#{76.chr}#{long}L\n") }

      it "must return a Python::Pickle::Instructions::Long object" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::Long.new(long)
        )
      end
    end

    context "when the opcode is 78" do
      let(:io) { StringIO.new(78.chr) }

      it "must return Python::Pickle::Instructions::NONE" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::NONE
        )
      end
    end

    context "when the opcode is 82" do
      let(:io) { StringIO.new(82.chr) }

      it "must return Python::Pickle::Instructions::REDUCE" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::REDUCE
        )
      end
    end

    context "when the opcode is 84" do
      let(:string) { "hello\0world".b }
      let(:length) { string.bytesize  }
      let(:packed) { [length, string].pack('L<a*') }
      let(:io)     { StringIO.new("#{84.chr}#{packed}") }

      it "must return a Python::Pickle::Instructions::BinString object" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::BinString.new(length,string)
        )
      end
    end

    context "when the opcode is 85" do
      let(:string) { "hello\0world".b }
      let(:length) { string.bytesize  }
      let(:packed) { [length, string].pack('Ca*') }
      let(:io)     { StringIO.new("#{85.chr}#{packed}") }

      it "must return a Python::Pickle::Instructions::ShortBinString object" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::ShortBinString.new(length,string)
        )
      end
    end

    context "when the opcode is 88" do
      let(:string) { "hello world \u1234" }
      let(:length) { string.bytesize  }
      let(:packed) { [length, string].pack('L<a*') }
      let(:io)     { StringIO.new("#{88.chr}#{packed}") }

      it "must return a Python::Pickle::Instructions::BinUnicode object" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::BinUnicode.new(length,string)
        )
      end

      it "must set the encoding of the String to Encoding::UTF_8" do
        expect(subject.read_instruction.value.encoding).to eq(
          Encoding::UTF_8
        )
      end
    end

    context "when the opcode is 93" do
      let(:io) { StringIO.new(93.chr) }

      it "must return Python::Pickle::Instructions::EMPTY_LIST" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::EMPTY_LIST
        )
      end
    end

    # NOTE: when APPEND (97) deprecated?
    context "when the opcode is 97" do
      let(:io) { StringIO.new(97.chr) }

      it "must return Python::Pickle::Instructions::APPEND" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::APPEND
        )
      end
    end

    context "when the opcode is 98" do
      let(:io) { StringIO.new(98.chr) }

      it "must return Python::Pickle::Instructions::BUILD" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::BUILD
        )
      end
    end

    context "when the opcode is 99" do
      let(:namespace) { "foo" }
      let(:name)      { "bar" }

      let(:io) { StringIO.new("#{99.chr}#{namespace}\n#{name}\n") }

      it "must return Python::Pickle::Instructions::GLOBAL" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::Global.new(namespace,name)
        )
      end
    end

    context "when the opcode is 101" do
      let(:io) { StringIO.new(101.chr) }

      it "must return Python::Pickle::Instructions::APPENDS" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::APPENDS
        )
      end
    end

    context "when the opcode is 113" do
      let(:index) { 2 }
      let(:io)    { StringIO.new("#{113.chr}#{index.chr}") }

      it "must return a Python::Pickle::Instructions::BinPut object" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::BinPut.new(index)
        )
      end
    end

    context "when the opcode is 115" do
      let(:io) { StringIO.new(115.chr) }

      it "must return Python::Pickle::Instructions::SETITEM" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::SETITEM
        )
      end
    end

    context "when the opcode is 117" do
      let(:io) { StringIO.new(117.chr) }

      it "must return Python::Pickle::Instructions::SETITEMS" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::SETITEMS
        )
      end
    end

    context "when the opcode is 116" do
      let(:io) { StringIO.new(116.chr) }

      it "must return Python::Pickle::Instructions::TUPLE" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::TUPLE
        )
      end
    end

    context "when the opcode is 125" do
      let(:io) { StringIO.new(125.chr) }

      it "must return Python::Pickle::Instructions::EMPTY_DICT" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::EMPTY_DICT
        )
      end
    end
  end
end
