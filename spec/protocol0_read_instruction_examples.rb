require 'spec_helper'

shared_examples_for "Protocol0#read_instruction examples" do
  context "when the opcode is 40" do
    let(:io) { StringIO.new(40.chr) }

    it "must return Python::Pickle::Instructions::MARK" do
      expect(subject.read_instruction).to be(
        Python::Pickle::Instructions::MARK
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

  context "when the opcode is 50" do
    let(:io) { StringIO.new(50.chr) }

    it "must return Python::Pickle::Instructions::DUP" do
      expect(subject.read_instruction).to be(
        Python::Pickle::Instructions::DUP
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

  context "when the opcode is 86" do
    let(:string) { 'ABC' }
    let(:io)     { StringIO.new("#{86.chr}#{string}\n") }

    it "must return a Python::Pickle::Instructions::String object" do
      expect(subject.read_instruction).to eq(
        Python::Pickle::Instructions::String.new(string)
      )
    end
  end

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

  context "when the opcode is 100" do
    let(:io) { StringIO.new(100.chr) }

    it "must return Python::Pickle::Instructions::DICT" do
      expect(subject.read_instruction).to be(
        Python::Pickle::Instructions::DICT
      )
    end
  end

  context "when the opcode is 103" do
    let(:index) { 1 }
    let(:io)    { StringIO.new("#{103.chr}#{index}\n") }

    it "must return a Python::Pickle::Instructions::Get object" do
      expect(subject.read_instruction).to eq(
        Python::Pickle::Instructions::Get.new(index)
      )
    end
  end

  context "when the opcode is 108" do
    let(:io) { StringIO.new(108.chr) }

    it "must return Python::Pickle::Instructions::LIST" do
      expect(subject.read_instruction).to be(
        Python::Pickle::Instructions::LIST
      )
    end
  end

  context "when the opcode is 112" do
    let(:index) { 1 }
    let(:io)    { StringIO.new("#{112.chr}#{index}\n") }

    it "must return a Python::Pickle::Instructions::Put object" do
      expect(subject.read_instruction).to eq(
        Python::Pickle::Instructions::Put.new(index)
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

  context "when the opcode is 116" do
    let(:io) { StringIO.new(116.chr) }

    it "must return Python::Pickle::Instructions::TUPLE" do
      expect(subject.read_instruction).to be(
        Python::Pickle::Instructions::TUPLE
      )
    end
  end
end
