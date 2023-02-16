require 'spec_helper'

shared_examples_for "Protocol1#read_instruction examples" do
  context "when the opcode is 41" do
    let(:io) { StringIO.new(41.chr) }

    it "must return Python::Pickle::Instructions::EMPTY_TUPLE" do
      expect(subject.read_instruction).to be(
        Python::Pickle::Instructions::EMPTY_TUPLE
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

  context "when the opcode is 75" do
    let(:int) { 0xff }
    let(:io)  { StringIO.new("#{75.chr}#{int.chr}") }

    it "must return a Python::Pickle::Instructions::BinInt1 object" do
      expect(subject.read_instruction).to eq(
        Python::Pickle::Instructions::BinInt1.new(int)
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

  context "when the opcode is 117" do
    let(:io) { StringIO.new(117.chr) }

    it "must return Python::Pickle::Instructions::SETITEMS" do
      expect(subject.read_instruction).to be(
        Python::Pickle::Instructions::SETITEMS
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
