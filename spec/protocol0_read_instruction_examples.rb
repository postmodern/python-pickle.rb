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
