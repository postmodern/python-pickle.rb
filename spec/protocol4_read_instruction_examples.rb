require 'spec_helper'

shared_examples_for "Protocol4#read_instruction examples" do
  describe "when the opcode is 140" do
    let(:string) { "hello world\u1234" }
    let(:length) { string.bytesize }
    let(:packed) { [length, *string.codepoints].pack('CU*') }
    let(:io)     { StringIO.new("#{140.chr}#{packed}".b) }

    it "must return Python::Pickle::Instructions::ShortBinUnicode" do
      expect(subject.read_instruction).to eq(
        Python::Pickle::Instructions::ShortBinUnicode.new(length,string)
      )
    end
  end

  describe "when the opcode is 141" do
    let(:string) { "hello world\u1234" }
    let(:length) { string.bytesize }
    let(:packed) { [length, *string.codepoints].pack('Q<U*') }
    let(:io)     { StringIO.new("#{141.chr}#{packed}".b) }

    it "must return Python::Pickle::Instructions::BinUnicode8" do
      expect(subject.read_instruction).to eq(
        Python::Pickle::Instructions::BinUnicode8.new(length,string)
      )
    end
  end

  describe "when the opcode is 142" do
    let(:length) { 12 }
    let(:bytes)  { "hello world\0".b }
    let(:packed) { [length, bytes].pack('Q<a*') }
    let(:io)     { StringIO.new("#{142.chr}#{packed}".b) }

    it "must return Python::Pickle::Instructions::BinBytes8" do
      expect(subject.read_instruction).to eq(
        Python::Pickle::Instructions::BinBytes8.new(length,bytes)
      )
    end
  end

  describe "when the opcode is 143" do
    let(:io) { StringIO.new(143.chr) }

    it "must return Python::Pickle::Instructions::EMPTY_SET" do
      expect(subject.read_instruction).to be(
        Python::Pickle::Instructions::EMPTY_SET
      )
    end
  end

  describe "when the opcode is 144" do
    let(:io) { StringIO.new(144.chr) }

    it "must return Python::Pickle::Instructions::ADDITEMS" do
      expect(subject.read_instruction).to be(
        Python::Pickle::Instructions::ADDITEMS
      )
    end
  end

  describe "when the opcode is 145" do
    let(:io) { StringIO.new(145.chr) }

    it "must return Python::Pickle::Instructions::FROZENSET" do
      expect(subject.read_instruction).to be(
        Python::Pickle::Instructions::FROZENSET
      )
    end
  end

  describe "when the opcode is 146" do
    let(:io) { StringIO.new(146.chr) }

    it "must return Python::Pickle::Instructions::NEWOBJ_EX" do
      expect(subject.read_instruction).to be(
        Python::Pickle::Instructions::NEWOBJ_EX
      )
    end
  end

  describe "when the opcode is 147" do
    let(:io) { StringIO.new(147.chr) }

    it "must return Python::Pickle::Instructions::STACK_GLOBAL" do
      expect(subject.read_instruction).to be(
        Python::Pickle::Instructions::STACK_GLOBAL
      )
    end
  end

  describe "when the opcode is 148" do
    let(:io) { StringIO.new(148.chr) }

    it "must return Python::Pickle::Instructions::MEMOIZE" do
      expect(subject.read_instruction).to be(
        Python::Pickle::Instructions::MEMOIZE
      )
    end
  end

  describe "when the opcode is 149" do
    let(:frame)  { "\x8C\x03ABC\x94.".b }
    let(:length) { frame.bytesize }
    let(:packed) { [length, frame].pack('Q<a*') }
    let(:io)    { StringIO.new("#{149.chr}#{packed}") }

    it "must return Python::Pickle::Instructions::Frame" do
      expect(subject.read_instruction).to eq(
        Python::Pickle::Instructions::Frame.new(length)
      )
    end

    context "after a Python::Pickle::Instructions::Frame has been returned" do
      it "must change #io to be a StringIO pointing to the frame's contents" do
        subject.read_instruction

        expect(subject.io).to be_kind_of(StringIO)
        expect(subject.io.string).to eq(frame)
      end

      it "must then read instructions from inside of a frame" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::Frame.new(length)
        )

        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::ShortBinUnicode.new(3,'ABC')
        )

        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::MEMOIZE
        )

        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::STOP
        )
      end
    end
  end
end
