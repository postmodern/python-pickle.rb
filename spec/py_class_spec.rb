require 'spec_helper'
require 'python/pickle/py_class'

describe Python::Pickle::PyClass do
  let(:namespace) { '__main__' }
  let(:name)      { 'MyClass'  }

  subject { described_class.new(namespace,name) }

  describe "#initialize" do
    it "must set #namespace" do
      expect(subject.namespace).to eq(namespace)
    end

    it "must set #name" do
      expect(subject.name).to eq(name)
    end
  end

  describe "#new" do
    let(:args) { [1,2,3] }

    it "must return a new Python::Pickle::PyObject with the given arguments" do
      py_object = subject.new(*args)

      expect(py_object).to be_kind_of(Python::Pickle::PyObject)
      expect(py_object.init_args).to eq(args)
    end

    context "when keyword arguments are given" do
      let(:kwargs) { {x: 1, y: 2} }

      it "must set #init_kwargs" do
        py_object = subject.new(*args,**kwargs)

        expect(py_object.init_kwargs).to eq(kwargs)
      end
    end
  end

  describe "#to_s" do
    context "when #namespace is set" do
      it "must return namespace.name" do
        expect(subject.to_s).to eq("#{namespace}.#{name}")
      end
    end

    context "when #namespace is not set" do
      subject { described_class.new(name) }

      it "must return #name" do
        expect(subject.to_s).to eq(name)
      end
    end
  end

  describe "#inspect" do
    it "must include the class name and namespace.name" do
      expect(subject.inspect).to eq("#<#{described_class}: #{namespace}.#{name}>")
    end
  end
end
