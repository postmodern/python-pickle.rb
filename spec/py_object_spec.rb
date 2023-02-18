require 'spec_helper'
require 'python/pickle/py_object'

describe Python::Pickle::PyObject do
  let(:namespace) { '__main__' }
  let(:name)      { 'MyClass'  }
  let(:py_class)  { Python::Pickle::PyClass.new(namespace,name) }

  let(:init_args)   { [1,2,3] }
  let(:init_kwargs) { {x: 1, y: 2} }

  subject { described_class.new(py_class,*init_args,**init_kwargs) }

  describe "#initialize" do
    it "must set #py_class" do
      expect(subject.py_class).to be(py_class)
    end

    it "must set #attributes to an empty Hash" do
      expect(subject.attributes).to eq({})
    end

    context "when called with additional arguments" do
      subject { described_class.new(py_class,*init_args) }

      it "must set #init_args" do
        expect(subject.init_args).to eq(init_args)
      end
    end

    context "when called with additional arguments" do
      subject { described_class.new(py_class,*init_args,**init_kwargs) }

      it "must set #init_kwargs" do
        expect(subject.init_kwargs).to eq(init_kwargs)
      end
    end
  end

  describe "#getattr" do
    context "when the object has an attribute with the given name" do
      let(:name)  { 'x' }
      let(:value) { 42  }

      before do
        subject.attributes[name] = value
      end

      it "must return the attribute's value" do
        expect(subject.getattr(name)).to eq(value)
      end
    end

    context "when the object does not have the given attribute" do
      let(:name) { 'foo' }

      it do
        expect {
          subject.getattr(name)
        }.to raise_error(ArgumentError,"Python object has no attribute #{name.inspect}: #{subject.inspect}")
      end
    end
  end

  describe "#setattr" do
    let(:name)  { 'x' }
    let(:value) { 42  }

    before do
      subject.setattr(name,value)
    end

    it "must set the value of the attribute in #attributes" do
      expect(subject.attributes[name]).to eq(value)
    end
  end

  describe "#__setstate__" do
    let(:new_attributes) { {'x' => 1, 'y' => 2} }

    before do
      subject.__setstate__(new_attributes)
    end

    it "must set #attributes" do
      expect(subject.attributes).to eq(new_attributes)
    end
  end

  describe "#to_h" do
    before do
      subject.setattr('x',1)
      subject.setattr('y',2)
    end

    it "must return #attributes" do
      expect(subject.to_h).to eq({'x' => 1, 'y' => 2})
    end
  end

  describe "#method_missing" do
    context "when the method name maps to an existing attribute" do
      let(:name)  { 'x' }
      let(:value) { 42  }

      before do
        subject.setattr(name,value)
      end

      it "must return the attribute's value" do
        expect(subject.send(name)).to eq(value)
      end
    end

    context "when the method name does not map to an attribute" do
      it "must return the attribute's value" do
        expect {
          subject.foo
        }.to raise_error(NoMethodError)
      end
    end

    context "when the method name ends with a '='" do
      context "and ther eis one argument" do
        it "must set the attribute's value" do
          subject.foo = 1

          expect(subject.foo).to eq(1)
        end
      end

      context "but there are no arguments" do
        it "must return the attribute's value" do
          expect {
            subject.send(:foo=)
          }.to raise_error(NoMethodError)
        end
      end

      context "but has more than one argument" do
        it "must return the attribute's value" do
          expect {
            subject.send(:foo,1,2,3)
          }.to raise_error(NoMethodError)
        end
      end
    end
  end
end
