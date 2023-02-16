require 'spec_helper'

shared_examples_for "Protocol2#read_instruction examples" do
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

  describe "when the opcode is 138" do
    let(:length) { 2 }
    let(:uint)   { 0x1234 }
    let(:packed) { [length, uint].pack('CS<') }
    let(:io)     { StringIO.new("#{138.chr}#{packed}".b) }

    it "must return Python::Pickle::Instructions::Long1" do
      expect(subject.read_instruction).to eq(
        Python::Pickle::Instructions::Long1.new(length,uint)
      )
    end
  end

  describe "when the opcode is 139" do
    let(:length) { 4 }
    let(:uint)   { 0x12345678 }
    let(:packed) { [length, uint].pack('L<L<') }
    let(:io)     { StringIO.new("#{139.chr}#{packed}".b) }

    it "must return Python::Pickle::Instructions::Long4" do
      expect(subject.read_instruction).to eq(
        Python::Pickle::Instructions::Long4.new(length,uint)
      )
    end
  end
end
