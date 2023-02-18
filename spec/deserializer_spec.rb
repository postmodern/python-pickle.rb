require 'spec_helper'
require 'python/pickle/deserializer'

describe Python::Pickle::Deserializer do
  module TestDeserializer
    class MyClass
    end
  end

  describe "#initialize" do
    it "must initialize #meta_stack to an empty Array" do
      expect(subject.meta_stack).to eq([])
    end

    it "must initialize #stack to an empty Array" do
      expect(subject.stack).to eq([])
    end

    it "must initialize #memo to an empty Array" do
      expect(subject.memo).to eq([])
    end

    describe "#constants" do
      it "must contain 'copy_reg._reconstructor' for protocol 0 support" do
        expect(subject.constants['copy_reg']['_reconstructor']).to eq(
          subject.method(:copyreg_reconstructor)
        )
      end

      it "must contain '__builtin__.object' for Python 2.x support" do
        expect(subject.constants['__builtin__']['object']).to be(described_class::OBJECT_CLASS)
      end

      it "must contain '__builtin__.set' for Python 2.x support" do
        expect(subject.constants['__builtin__']['set']).to be(Set)
      end

      it "must contain '__builtin__.bytearray' for Python 2.x support" do
        expect(subject.constants['__builtin__']['bytearray']).to be(Python::Pickle::ByteArray)
      end

      it "must contain 'builtins.object' for Python 3.x support" do
        expect(subject.constants['builtins']['object']).to be(described_class::OBJECT_CLASS)
      end

      it "must contain 'builtins.set' for Python 2.x support" do
        expect(subject.constants['builtins']['set']).to be(Set)
      end

      it "must contain 'builtins.bytearray' for Python 2.x support" do
        expect(subject.constants['builtins']['bytearray']).to be(Python::Pickle::ByteArray)
      end
    end

    it "must initialize #extensionsto an empty Hash" do
      expect(subject.extensions).to eq({})
    end

    context "when initialized with the `extensions:` keyword argument" do
      let(:extensions) do
        {
          0x41 => Object.new,
          0x42 => Object.new,
          0x43 => Object.new
        }
      end

      subject { described_class.new(extensions: extensions) }

      it "must add the extensions: values to #extensions" do
        expect(subject.extensions).to eq(extensions)
      end
    end

    context "when initialized with the `constants:` keyword argument" do
      let(:constants) do
        {
          '__main__' => {
            'MyClass' => TestDeserializer::MyClass
          }
        }
      end

      subject { described_class.new(constants: constants) }

      it "must merge the constants: keyword argument with the default constants" do
        expect(subject.constants).to eq(
          {
            'copy_reg' => {
              '_reconstructor' => subject.method(:copyreg_reconstructor)
            },

            '__builtin__' => {
              'object'    => described_class::OBJECT_CLASS,
              'set'       => Set,
              'bytearray' => Python::Pickle::ByteArray
            },

            'builtins' => {
              'object'    => described_class::OBJECT_CLASS,
              'set'       => Set,
              'bytearray' => Python::Pickle::ByteArray
            },

            '__main__' => {
              'MyClass' => TestDeserializer::MyClass
            }
          }
        )
      end
    end

    context "when initialized with the `buffers:` keyword argument" do
      let(:buffer1) { "hello world" }
      let(:buffer2) { "foo bar"     }
      let(:buffers) do
        [
          buffer1,
          buffer2
        ]
      end

      subject { described_class.new(buffers: buffers) }

      it "must set #buffers to an Enumerator of the buffers" do
        expect(subject.buffers).to be_kind_of(Enumerator)
        expect(subject.buffers.to_a).to eq(buffers)
      end
    end
  end

  describe "#push_meta_stack" do
    before do
      subject.stack << 1 << 2 << 3

      subject.push_meta_stack
    end

    it "must push #stack onto #meta_stack and set #stack to a new empty Array" do
      expect(subject.meta_stack).to eq([ [1,2,3] ])
      expect(subject.stack).to eq([])
    end
  end

  describe "#pop_meta_stack" do
    before do
      subject.stack << 3 << 4 << 5
      subject.meta_stack << [1,2,3]
    end

    it "must pop #meta_stack and reset #stack, and then return the previous #stack value" do
      expect(subject.pop_meta_stack).to eq([3,4,5])
      expect(subject.stack).to eq([1,2,3])
      expect(subject.meta_stack).to eq([])
    end
  end

  describe "#execute" do
    context "when given a Python::Pickle::Instructions::Proto object" do
      let(:instruction) { Python::Pickle::Instructions::Proto.new(4) }

      it "must return nil" do
        expect(subject.execute(instruction)).to be(nil)
      end
    end

    context "when given a Python::Pickle::Instructions::Frame object" do
      let(:instruction) { Python::Pickle::Instructions::Frame.new(16) }

      it "must return nil" do
        expect(subject.execute(instruction)).to be(nil)
      end
    end

    [
      Python::Pickle::Instructions::Get,
      Python::Pickle::Instructions::BinGet,
      Python::Pickle::Instructions::LongBinGet
    ].each do |instruction_class|
      context "when given a #{instruction_class} object" do
        let(:instruction1) { instruction_class.new(1) }
        let(:instruction2) { instruction_class.new(2) }

        before do
          subject.memo << 'A' << 'B' << 'C'
          subject.execute(instruction1)
          subject.execute(instruction2)
        end

        it "must push the value from #memo at the given index onto #stack" do
          expect(subject.stack).to eq(['B', 'C'])
        end
      end
    end

    context "when given a Python::Pickle::Instructions::MARK object" do
      let(:instruction) { Python::Pickle::Instructions::MARK }

      before do
        subject.stack << 1 << 2 << 3
        subject.execute(instruction)
      end

      it "must push #stack onto #meta_stack and reset #stack" do
        expect(subject.meta_stack).to eq([ [1,2,3] ])
        expect(subject.stack).to eq([])
      end
    end

    context "when given a Python::Pickle::Instructions::POP_MARK object" do
      let(:instruction) { Python::Pickle::Instructions::POP_MARK }

      before do
        subject.meta_stack << [1,2,3]
        subject.stack << 'A' << 'B' << 'C'
        subject.execute(instruction)
      end

      it "must push #stack onto #meta_stack and reset #stack" do
        expect(subject.meta_stack).to eq([])
        expect(subject.stack).to eq([1,2,3])
      end
    end

    context "when given a Python::Pickle::Instructions::DUP object" do
      let(:instruction) { Python::Pickle::Instructions::DUP }

      before do
        subject.stack << 1 << 2 << 3
        subject.execute(instruction)
      end

      it "must push a copy of the last element on #stack back onto the #stack" do
        expect(subject.stack).to eq([1,2,3,3])
      end
    end

    [
      Python::Pickle::Instructions::Put,
      Python::Pickle::Instructions::BinPut
    ].each do |instruction_class|
      context "when given a #{instruction_class} object" do
        let(:instruction) { instruction_class.new(1) }

        before do
          subject.stack << 1 << 2 << 3
          subject.execute(instruction)
        end

        it "must set the index in #memo with the last element in the #stack" do
          expect(subject.memo).to eq([nil, 3])
        end
      end
    end

    context "when given a Python::Pickle::Instructions::POP" do
      let(:instruction) { Python::Pickle::Instructions::POP }

      before do
        subject.stack << 1 << 2 << 3
        subject.execute(instruction)
      end

      it "must pop the last element off of the #stack" do
        expect(subject.stack).to eq([1,2])
      end
    end

    context "when given a Python::Pickle::Instructions::MEMOIZE" do
      let(:instruction) { Python::Pickle::Instructions::MEMOIZE }

      before do
        subject.stack << 1 << 2 << 3
        subject.execute(instruction)
      end

      it "must push the last element of the #stack onto #memo" do
        expect(subject.memo).to eq([3])
      end
    end

    [
      Python::Pickle::Instructions::Ext1,
      Python::Pickle::Instructions::Ext2,
      Python::Pickle::Instructions::Ext4
    ].each do |instruction_class|
      context "when given a #{instruction_class} object" do
        let(:ext_id) { 0x42 }
        let(:instruction) { instruction_class.new(ext_id) }

        context "when #extensions contains the extension ID" do
          let(:ext_object) { double('extension object') }
          subject do
            described_class.new(extensions: {ext_id => ext_object})
          end

          before do
            subject.stack << 1 << 2 << 3
            subject.execute(instruction)
          end

          it "must push the extension object onto the #stack" do
            expect(subject.stack).to eq([1,2,3, ext_object])
          end
        end

        context "when #extensions does not contain the extension ID" do
          it do
            expect {
              subject.execute(instruction)
            }.to raise_error(Python::Pickle::DeserializationError,"unknown extension ID: #{ext_id.inspect}")
          end
        end
      end
    end

    context "when given a Python::Pickle::Instructions::NONE" do
      let(:instruction) { Python::Pickle::Instructions::NONE }

      before do
        subject.execute(instruction)
      end

      it "must push nil onto the #stack" do
        expect(subject.stack).to eq([nil])
      end
    end

    context "when given a Python::Pickle::Instructions::NEWTRUE" do
      let(:instruction) { Python::Pickle::Instructions::NEWTRUE}

      before do
        subject.execute(instruction)
      end

      it "must push true onto the #stack" do
        expect(subject.stack).to eq([true])
      end
    end

    context "when given a Python::Pickle::Instructions::NEWFALSE" do
      let(:instruction) { Python::Pickle::Instructions::NEWFALSE}

      before do
        subject.execute(instruction)
      end

      it "must push false onto the #stack" do
        expect(subject.stack).to eq([false])
      end
    end

    [
      Python::Pickle::Instructions::Float.new(1.234),
      Python::Pickle::Instructions::BinFloat.new(1.234),
      Python::Pickle::Instructions::Int.new(42),
      Python::Pickle::Instructions::BinInt1.new(42),
      Python::Pickle::Instructions::Long.new(42),
      Python::Pickle::Instructions::Long1.new(1,42),
      Python::Pickle::Instructions::Long4.new(1,42),
      Python::Pickle::Instructions::BinBytes.new(3,"ABC"),
      Python::Pickle::Instructions::ShortBinBytes.new(3,"ABC"),
      Python::Pickle::Instructions::BinBytes8.new(3,"ABC"),
      Python::Pickle::Instructions::String.new("ABC"),
      Python::Pickle::Instructions::BinString.new(3,"ABC"),
      Python::Pickle::Instructions::ShortBinString.new(3,"ABC"),
      Python::Pickle::Instructions::BinUnicode.new(3,"ABC"),
    ].each do |instruction|
      context "when given a #{instruction.class} object" do
        let(:instruction) { instruction }

        before do
          subject.execute(instruction)
        end

        it "must push the instruction's value onto the #stack" do
          expect(subject.stack).to eq([instruction.value])
        end
      end
    end

    context "when given a Python::Pickle::Instructions::ByteArray8 object" do
      let(:bytes) { "ABC" }
      let(:instruction) { Python::Pickle::Instructions::ByteArray8.new(3,bytes) }

      before do
        subject.execute(instruction)
      end

      it "must push a Python::Pickle::ByteArray object onto the #stack" do
        expect(subject.stack).to eq([Python::Pickle::ByteArray.new(bytes)])
      end
    end

    context "when given a Python::Pickle::Instructions::EMPTY_LIST" do
      let(:instruction) { Python::Pickle::Instructions::EMPTY_LIST }

      before do
        subject.execute(instruction)
      end

      it "must push an empty Array onto the #stack" do
        expect(subject.stack).to eq([ [] ])
      end
    end

    context "when given a Python::Pickle::Instructions::EMPTY_TUPLE" do
      let(:instruction) { Python::Pickle::Instructions::EMPTY_TUPLE }

      before do
        subject.execute(instruction)
      end

      it "must push an empty Python::Pickle::Tuple object onto the #stack" do
        expect(subject.stack).to eq([ Python::Pickle::Tuple.new ])
      end
    end

    context "when given a Python::Pickle::Instructions::TUPLE " do
      let(:instruction) { Python::Pickle::Instructions::TUPLE }

      before do
        subject.stack << 4 << 5 << 6
        subject.meta_stack << [1,2,3]
        subject.execute(instruction)
      end

      it "must pop the #meta_stack, convert the items into a Python::Pickle::Tuple object, and push it onto the #stack" do
        expect(subject.meta_stack).to eq([])
        expect(subject.stack).to eq([ 1,2,3, Python::Pickle::Tuple[4,5,6] ])
      end
    end

    context "when given a Python::Pickle::Instructions::EMPTY_DICT" do
      let(:instruction) { Python::Pickle::Instructions::EMPTY_DICT }

      before do
        subject.execute(instruction)
      end

      it "must push an empty Hash object onto the #stack" do
        expect(subject.stack).to eq([ {} ])
      end
    end

    context "when given a Python::Pickle::Instructions::EMPTY_SET" do
      let(:instruction) { Python::Pickle::Instructions::EMPTY_SET }

      before do
        subject.execute(instruction)
      end

      it "must push an empty Set object onto the #stack" do
        expect(subject.stack).to eq([ Set.new ])
      end
    end

    context "when given a Python::Pickle::Instructions::FROZENSET" do
      let(:instruction) { Python::Pickle::Instructions::FROZENSET }

      before do
        subject.meta_stack << []
        subject.stack << 1 << 2 << 3
        subject.execute(instruction)
      end

      it "must pop the #meta_stack and create a frozen Set from the previous #stack and push the frozen Set onto the new #stack" do
        expect(subject.stack.length).to eq(1)

        set = subject.stack[-1]

        expect(set).to be_frozen
        expect(set).to eq(Set[1,2,3])
      end
    end

    context "when given a Python::Pickle::Instructions::APPEND" do
      context "and when the previous element on the stack is an Array" do
        let(:instruction) { Python::Pickle::Instructions::APPEND }

        before do
          subject.stack << [] << 2
          subject.execute(instruction)
        end

        it "must pop the last element from the #stack and push it onto the next list element" do
          expect(subject.stack).to eq([ [2] ])
        end
      end

      context "and when the previous element on the stack is a Set" do
        let(:instruction) { Python::Pickle::Instructions::APPEND }

        before do
          subject.stack << Set.new << 2
          subject.execute(instruction)
        end

        it "must pop the last element from the #stack and push it onto the next list element" do
          expect(subject.stack).to eq([ Set[2] ])
        end
      end

      context "but when the previous element on the stack is not an Array" do
        let(:instruction) { Python::Pickle::Instructions::APPEND }
        let(:item) { 2 }
        let(:list) { "XXX" }

        before do
          subject.stack << list << item
        end

        it do
          expect {
            subject.execute(instruction)
          }.to raise_error(Python::Pickle::DeserializationError,"cannot append element #{item.inspect} onto a non-Array: #{list.inspect}")
        end
      end
    end

    context "when given a Python::Pickle::Instructions::APPENDS" do
      context "and when the previous element on the stack is an Array" do
        let(:instruction) { Python::Pickle::Instructions::APPENDS }

        before do
          subject.meta_stack << [ [1,2,3] ]
          subject.stack << 4 << 5 << 6
          subject.execute(instruction)
        end

        it "must pop the #meta_stack, store the #stack, and concat the previous #stack onto the last element of the new #stack" do
          expect(subject.stack).to eq([ [1,2,3,4,5,6] ])
        end
      end

      context "and when the previous element on the stack is a Set" do
        let(:instruction) { Python::Pickle::Instructions::APPENDS }

        before do
          subject.meta_stack << [ Set[1,2,3] ]
          subject.stack << 4 << 5 << 6
          subject.execute(instruction)
        end

        it "must pop the #meta_stack, store the #stack, and concat the previous #stack onto the last element of the new #stack" do
          expect(subject.stack).to eq([ Set[1,2,3,4,5,6] ])
        end
      end

      context "but when the previous element on the stack is not an Array" do
        let(:instruction) { Python::Pickle::Instructions::APPENDS }
        let(:items) { [3,4,5] }
        let(:list) { "XXX" }

        before do
          subject.meta_stack << [ list ]
          subject.stack << items[0] << items[1] << items[2]
        end

        it do
          expect {
            subject.execute(instruction)
          }.to raise_error(Python::Pickle::DeserializationError,"cannot append elements #{items.inspect} onto a non-Array: #{list.inspect}")
        end
      end
    end

    context "when given a Python::Pickle::Instructions::ADDITEMS" do
      context "and when the previous element on the stack is a Set" do
        let(:instruction) { Python::Pickle::Instructions::ADDITEMS }

        before do
          subject.meta_stack << [ Set[1,2,3] ]
          subject.stack << 4 << 5 << 6
          subject.execute(instruction)
        end

        it "must pop the #meta_stack, store the #stack, and concat the previous #stack onto the last element of the new #stack" do
          expect(subject.stack).to eq([ Set[1,2,3,4,5,6] ])
        end
      end

      context "but when the previous element on the stack is not a Set" do
        let(:instruction) { Python::Pickle::Instructions::ADDITEMS }
        let(:items) { [3,4,5] }
        let(:set)   { [] }

        before do
          subject.meta_stack << [ set ]
          subject.stack << items[0] << items[1] << items[2]
        end

        it do
          expect {
            subject.execute(instruction)
          }.to raise_error(Python::Pickle::DeserializationError,"cannot add items #{items.inspect} to a non-Set object: #{set.inspect}")
        end
      end
    end

    context "when given a Python::Pickle::Instructions::LIST" do
      let(:instruction) { Python::Pickle::Instructions::LIST }

      before do
        subject.meta_stack << [ [1,2,3] ]
        subject.stack << 4 << 5 << 6
        subject.execute(instruction)
      end

      it "must pop the #meta_stack, restore the #stack, and push the previous #stack onto the new #stack as a new Array" do
        expect(subject.stack).to eq([ [1,2,3], [4,5,6] ])
      end
    end

    context "when given a Python::Pickle::Instructions::TUPLE1" do
      let(:instruction) { Python::Pickle::Instructions::TUPLE1 }

      before do
        subject.stack << 1 << 2 << 3
        subject.execute(instruction)
      end

      it "must pop one element from the #stack nad push a new Python::Pickle::Tuple onto the #stack" do
        expect(subject.stack).to eq([ 1, 2, Python::Pickle::Tuple[3] ])
      end
    end

    context "when given a Python::Pickle::Instructions::TUPLE2" do
      let(:instruction) { Python::Pickle::Instructions::TUPLE2 }

      before do
        subject.stack << 1 << 2 << 3
        subject.execute(instruction)
      end

      it "must pop two elements from the #stack nad push a new Python::Pickle::Tuple onto the #stack" do
        expect(subject.stack).to eq([ 1, Python::Pickle::Tuple[2, 3] ])
      end
    end

    context "when given a Python::Pickle::Instructions::TUPLE3" do
      let(:instruction) { Python::Pickle::Instructions::TUPLE3 }

      before do
        subject.stack << 1 << 2 << 3
        subject.execute(instruction)
      end

      it "must pop three elements from the #stack nad push a new Python::Pickle::Tuple onto the #stack" do
        expect(subject.stack).to eq([ Python::Pickle::Tuple[1, 2, 3] ])
      end
    end

    context "when given a Python::Pickle::Instructions::DICT" do
      let(:instruction) { Python::Pickle::Instructions::DICT }

      before do
        subject.meta_stack << []
        subject.stack << 'a' << 1 << 'b' << 2
        subject.execute(instruction)
      end

      it "must pop the #meta_stack, create a new Hash using the key:value pairs on the previous #stack, and push the new Hash onto the new #stack" do
        expect(subject.stack).to eq([ {'a' => 1, 'b' => 2} ])
      end
    end

    context "when given a Python::Pickle::Instructions::Global object" do
      let(:namespace)   { '__main__' }
      let(:name)        { 'MyClass'  }
      let(:instruction) { Python::Pickle::Instructions::Global.new(namespace,name) }

      before do
        subject.execute(instruction)
      end

      context "when the constant can be resolved" do
        module TestGlobalInstruction
          class MyClass
          end
        end

        subject do
          described_class.new(
            constants: {
              '__main__' => {
                'MyClass' => TestGlobalInstruction::MyClass
              }
            }
          )
        end

        it "must push the constant onto the #stack" do
          expect(subject.stack).to eq([ TestGlobalInstruction::MyClass ])
        end
      end

      context "but the constant cannot be resolved" do
        it "must push a new Python::Pickle::PyClass object onto the #stack" do
          constant = subject.stack[-1]

          expect(constant).to be_kind_of(Python::Pickle::PyClass)
          expect(constant.namespace).to eq(namespace)
          expect(constant.name).to eq(name)
        end
      end
    end

    context "when given a Python::Pickle::Instructions::STACK_GLOBAL" do
      let(:namespace)   { '__main__' }
      let(:name)        { 'MyClass'  }
      let(:instruction) { Python::Pickle::Instructions::STACK_GLOBAL }

      before do
        subject.stack << namespace << name
        subject.execute(instruction)
      end

      context "when the constant can be resolved" do
        module TestStackGlobalInstruction
          class MyClass
          end
        end

        subject do
          described_class.new(
            constants: {
              '__main__' => {
                'MyClass' => TestStackGlobalInstruction::MyClass
              }
            }
          )
        end

        it "must pop off the namespace and name from the #stack, and push the constant onto the #stack" do
          expect(subject.stack).to eq([ TestStackGlobalInstruction::MyClass ])
        end
      end

      context "but the constant cannot be resolved" do
        it "must push a new Python::Pickle::PyClass object onto the #stack" do
          constant = subject.stack[-1]

          expect(constant).to be_kind_of(Python::Pickle::PyClass)
          expect(constant.namespace).to eq(namespace)
          expect(constant.name).to eq(name)
        end
      end
    end

    context "when given a Python::Pickle::Instructions::NEWOBJ" do
      let(:instruction) { Python::Pickle::Instructions::NEWOBJ }

      context "and when the constant on the #stack is a Ruby class" do
        module TestNewObjInstruction
          class MyClass
          end
        end

        context "and the second argument is nil" do
          before do
            subject.stack << TestNewObjInstruction::MyClass << nil
            subject.execute(instruction)
          end

          it "must pop off the two last elements, and initialize a new instance of the constant, and push the new instance onto the #stack" do
            expect(subject.stack.length).to eq(1)
            expect(subject.stack[-1]).to be_kind_of(TestNewObjInstruction::MyClass)
          end
        end

        context "and the second argument is Python::Pickle::Tuple" do
          context "but it's empty" do
            let(:tuple) { Python::Pickle::Tuple.new }

            before do
              subject.stack << TestNewObjInstruction::MyClass << tuple
              subject.execute(instruction)
            end

            it "must pop off the two last elements, and initialize a new instance of the constant, and push the new instance onto the #stack" do
              expect(subject.stack.length).to eq(1)
              expect(subject.stack[-1]).to be_kind_of(TestNewObjInstruction::MyClass)
            end
          end

          context "but it's not empty" do
            module TestNewObjInstruction
              class MyClassWithArgs
                attr_reader :x, :y

                def initialize(x,y)
                  @x = x
                  @y = y
                end
              end
            end

            let(:tuple) { Python::Pickle::Tuple[1,2] }

            before do
              subject.stack << TestNewObjInstruction::MyClassWithArgs << tuple
              subject.execute(instruction)
            end

            it "must call #initialize with the splatted tuple's arguments" do
              object = subject.stack[-1]

              expect(object.x).to eq(tuple[0])
              expect(object.y).to eq(tuple[1])
            end
          end
        end
      end

      context "and when the constant on the #stack is a PyClass" do
        let(:namespace) { '__main__' }
        let(:name)      { 'MyClass'  }
        let(:py_class)  { Python::Pickle::PyClass.new(namespace,name) }

        context "and the second argument is nil" do
          before do
            subject.stack << py_class << nil
            subject.execute(instruction)
          end

          it "must pop off the two last elements and push the new Python::Pickle::PyObject onto the #stack" do
            expect(subject.stack.length).to eq(1)
            expect(subject.stack[-1]).to be_kind_of(Python::Pickle::PyObject)
          end
        end

        context "and the second argument is Python::Pickle::Tuple" do
          context "but it's empty" do
            let(:tuple) { Python::Pickle::Tuple.new }

            before do
              subject.stack << py_class << tuple
              subject.execute(instruction)
            end

            it "must pop off the two last elements and push the new Python::Pickle::PyObject onto the #stack" do
              expect(subject.stack.length).to eq(1)
              expect(subject.stack[-1]).to be_kind_of(Python::Pickle::PyObject)
            end
          end

          context "but it's not empty" do
            let(:tuple) { Python::Pickle::Tuple[1,2] }

            before do
              subject.stack << py_class << tuple
              subject.execute(instruction)
            end

            it "must set the object's #init_args to the tuple's elements" do
              object = subject.stack[-1]

              expect(object.init_args).to eq(tuple)
            end
          end
        end
      end
    end

    context "when given a Python::Pickle::Instructions::NEWOBJ_EX" do
      let(:instruction) { Python::Pickle::Instructions::NEWOBJ_EX }

      context "and when the constant on the #stack is a Ruby class" do
        module TestNewObjExInstruction
          class MyClass
          end
        end

        context "and the second argument is nil" do
          before do
            subject.stack << TestNewObjExInstruction::MyClass << nil << nil
            subject.execute(instruction)
          end

          it "must pop off the two last elements, and initialize a new instance of the constant, and push the new instance onto the #stack" do
            expect(subject.stack.length).to eq(1)
            expect(subject.stack[-1]).to be_kind_of(TestNewObjExInstruction::MyClass)
          end
        end

        context "and the second argument is Python::Pickle::Tuple" do
          context "but it's empty" do
            let(:tuple) { Python::Pickle::Tuple.new }

            before do
              subject.stack << TestNewObjExInstruction::MyClass << tuple << nil
              subject.execute(instruction)
            end

            it "must pop off the two last elements, and initialize a new instance of the constant, and push the new instance onto the #stack" do
              expect(subject.stack.length).to eq(1)
              expect(subject.stack[-1]).to be_kind_of(TestNewObjExInstruction::MyClass)
            end
          end

          context "but it's not empty" do
            module TestNewObjExInstruction
              class MyClassWithArgs
                attr_reader :x, :y

                def initialize(x,y)
                  @x = x
                  @y = y
                end
              end
            end

            let(:tuple) { Python::Pickle::Tuple[1,2] }

            before do
              subject.stack << TestNewObjExInstruction::MyClassWithArgs << tuple << nil
              subject.execute(instruction)
            end

            it "must call #initialize with the splatted tuple's arguments" do
              object = subject.stack[-1]

              expect(object.x).to eq(tuple[0])
              expect(object.y).to eq(tuple[1])
            end
          end
        end

        context "and the third argument is nil" do
          before do
            subject.stack << TestNewObjExInstruction::MyClass << [] << nil
            subject.execute(instruction)
          end

          it "must pop off the two last elements, and initialize a new instance of the constant, and push the new instance onto the #stack" do
            expect(subject.stack.length).to eq(1)
            expect(subject.stack[-1]).to be_kind_of(TestNewObjExInstruction::MyClass)
          end
        end

        context "and the third argument is a Hash" do
          context "but it's empty" do
            let(:tuple) { Python::Pickle::Tuple.new }

            before do
              subject.stack << TestNewObjExInstruction::MyClass << [] << {}
              subject.execute(instruction)
            end

            it "must pop off the two last elements, and initialize a new instance of the constant, and push the new instance onto the #stack" do
              expect(subject.stack.length).to eq(1)
              expect(subject.stack[-1]).to be_kind_of(TestNewObjExInstruction::MyClass)
            end
          end

          context "but it's not empty" do
            module TestNewObjExInstruction
              class MyClassWithKWArgs
                attr_reader :x, :y

                def initialize(x: , y: )
                  @x = x
                  @y = y
                end
              end
            end

            let(:hash) { {"x" => 1, "y" => 2} }

            before do
              subject.stack << TestNewObjExInstruction::MyClassWithKWArgs << [] << hash
              subject.execute(instruction)
            end

            it "must call #initialize with the splatted tuple's arguments" do
              object = subject.stack[-1]

              expect(object.x).to eq(hash['x'])
              expect(object.y).to eq(hash['y'])
            end
          end
        end
      end

      context "and when the constant on the #stack is a PyClass" do
        let(:namespace) { '__main__' }
        let(:name)      { 'MyClass'  }
        let(:py_class)  { Python::Pickle::PyClass.new(namespace,name) }

        context "and the second argument is nil" do
          before do
            subject.stack << py_class << nil << nil
            subject.execute(instruction)
          end

          it "must pop off the two last elements and push the new Python::Pickle::PyObject onto the #stack" do
            expect(subject.stack.length).to eq(1)
            expect(subject.stack[-1]).to be_kind_of(Python::Pickle::PyObject)
          end
        end

        context "and the second argument is Python::Pickle::Tuple" do
          context "but it's empty" do
            let(:tuple) { Python::Pickle::Tuple.new }

            before do
              subject.stack << py_class << tuple << nil
              subject.execute(instruction)
            end

            it "must pop off the two last elements and push the new Python::Pickle::PyObject onto the #stack" do
              expect(subject.stack.length).to eq(1)
              expect(subject.stack[-1]).to be_kind_of(Python::Pickle::PyObject)
            end
          end

          context "but it's not empty" do
            let(:tuple) { Python::Pickle::Tuple[1,2] }

            before do
              subject.stack << py_class << tuple << nil
              subject.execute(instruction)
            end

            it "must set the object's #init_args to the tuple's elements" do
              object = subject.stack[-1]

              expect(object.init_args).to eq(tuple)
            end
          end
        end
      end
    end

    context "when given a Python::Pickle::Instructions::REDUCE" do
      let(:instruction) { Python::Pickle::Instructions::REDUCE }

      context "when the first argument on the #stack is a PyClass" do
        let(:namespace) { '__main__' }
        let(:name)      { 'MyClass'  }
        let(:py_class)  { Python::Pickle::PyClass.new(namespace,name) }

        context "and the second argument is nil" do
          before do
            subject.stack << py_class << nil
            subject.execute(instruction)
          end

          it "must pop two elements off of the #stack, create a PyObject from the PyClass, and push the new PyObject onto the #stack" do
            expect(subject.stack.length).to eq(1)
            expect(subject.stack[-1]).to be_kind_of(Python::Pickle::PyObject)
            expect(subject.stack[-1].py_class).to eq(py_class)
          end
        end

        context "and the second argument is Python::Pickle::Tuple" do
          context "but it's empty" do
            let(:tuple) { Python::Pickle::Tuple.new }

            before do
              subject.stack << py_class << tuple
              subject.execute(instruction)
            end

            it "must pop two elements off of the #stack, create a PyObject from the PyClass, and push the new PyObject onto the #stack" do
              expect(subject.stack.length).to eq(1)
              expect(subject.stack[-1]).to be_kind_of(Python::Pickle::PyObject)
              expect(subject.stack[-1].py_class).to eq(py_class)
            end
          end

          context "but it's not empty" do
            let(:tuple) { Python::Pickle::Tuple[1,2] }

            before do
              subject.stack << py_class << tuple
              subject.execute(instruction)
            end

            it "must set #init_args" do
              object = subject.stack[-1]

              expect(object.init_args).to eq( [tuple[0], tuple[1]] )
            end
          end
        end
      end

      context "when the first argument on the #stack is a Ruby class" do
        module TestReduceInstruction
          class MyClass
          end
        end

        context "and the second argument is nil" do
          before do
            subject.stack << TestReduceInstruction::MyClass << nil
            subject.execute(instruction)
          end

          it "must pop two elements off of the #stack, initialize the Ruby class, and push the new instance onto the #stack" do
            expect(subject.stack.length).to eq(1)
            expect(subject.stack[-1]).to be_kind_of(TestReduceInstruction::MyClass)
          end
        end

        context "and the second argument is Python::Pickle::Tuple" do
          context "but it's empty" do
            let(:tuple) { Python::Pickle::Tuple.new }

            before do
              subject.stack << TestReduceInstruction::MyClass << tuple
              subject.execute(instruction)
            end

            it "must pop two elements off of the #stack, initialize the Ruby class, and push the new instance onto the #stack" do
              expect(subject.stack.length).to eq(1)
              expect(subject.stack[-1]).to be_kind_of(TestReduceInstruction::MyClass)
            end
          end

          context "but it's not empty" do
            module TestReduceInstruction
              class MyClassWithArgs
                attr_reader :x, :y

                def initialize(x,y)
                  @x = x
                  @y = y
                end
              end
            end

            let(:tuple) { Python::Pickle::Tuple[1,2] }

            before do
              subject.stack << TestReduceInstruction::MyClassWithArgs << tuple
              subject.execute(instruction)
            end

            it "must call #initialize with the arguments of the tuple" do
              object = subject.stack[-1]

              expect(object.x).to eq(tuple[0])
              expect(object.y).to eq(tuple[1])
            end
          end
        end
      end

      context "but the first argument on the #stack is a Ruby Method" do
        module TestReduceInstruction
          def self.func(x,y)
            x + y
          end
        end

        let(:tuple) { Python::Pickle::Tuple[1,2] }

        before do
          subject.stack << TestReduceInstruction.method(:func) << tuple
          subject.execute(instruction)
        end

        it "must pop the two arguments off of the stack, call the Method with the tuple arguments, and push the result back onto the #stack" do
          expect(subject.stack.length).to eq(1)
          expect(subject.stack[-1]).to eq(tuple[0] + tuple[1])
        end
      end

      context "when the first argument on the #stack is not a Class or a Method" do
        let(:callable) { Object.new }
        let(:tuple)    { Python::Pickle::Tuple[1,2] }

        before do
          subject.stack << callable << nil
        end

        it do
          expect {
            subject.execute(instruction)
          }.to raise_error(Python::Pickle::DeserializationError,"cannot execute REDUCE on a non-class: #{callable.inspect}")
        end
      end
    end

    context "when given a Python::Pickle::Instructions::BUILD" do
      let(:instruction) { Python::Pickle::Instructions::BUILD }

      context "when the first argument on the #stack is a Hash" do
        let(:hash1) { {'x' => 1} }
        let(:hash2) { {'y' => 2} }

        before do
          subject.stack << hash1 << hash2
          subject.execute(instruction)
        end

        it "must pop the last element off the #stack and merge the other Hash into the first Hash" do
          expect(subject.stack.length).to eq(1)
          expect(subject.stack[-1]).to eq(hash1.merge(hash2))
        end
      end

      context "when the first argument on the #stack is an Object" do
        context "and it defines a __setstate__ method" do
          module TestBuildInstruction
            class MyClass
              attr_reader :x, :y

              def __setstate__(attributes)
                @x = attributes['x']
                @y = attributes['y']
              end
            end
          end

          let(:object) { TestBuildInstruction::MyClass.new }
          let(:args)   { {'x' => 1, 'y' => 2} }

          before do
            subject.stack << object << args
            subject.execute(instruction)
          end

          it "must pop the last element off the #stack, call the #__setstate__ method on the first element on the #stack" do
            expect(subject.stack.length).to eq(1)
            expect(object.x).to eq(args['x'])
            expect(object.y).to eq(args['y'])
          end
        end

        context "but it does not define a __setstate__ method" do
          let(:object) { Object.new }
          let(:args)   { {'x' => 1, 'y' => 2} }

          before do
            subject.stack << object << args
          end

          it do
            expect {
              subject.execute(instruction)
            }.to raise_error(Python::Pickle::DeserializationError,"cannot execute BUILD on an object that does not define a __setstate__ method or is not a Hash: #{object.inspect}")
          end
        end
      end
    end

    context "when given a Python::Pickle::Instructions::SETITEM" do
      let(:instruction) { Python::Pickle::Instructions::SETITEM }

      let(:key)   { 'x' }
      let(:value) { 1   }

      context "and the first argument on the #stack is a Hash" do
        let(:hash) { {} }

        before do
          subject.stack << hash << key << value
          subject.execute(instruction)
        end

        it "must pop two elements off the #stack, and set the key vand value in the last element on the #stack" do
          expect(subject.stack).to eq([ {key => value} ])
        end
      end

      context "and the first argument on the #stack is not a Hash" do
        let(:object) { Object.new }

        before do
          subject.stack << object << key << value
        end

        it do
          expect {
            subject.execute(instruction)
          }.to raise_error(Python::Pickle::DeserializationError,"cannot set key (#{key.inspect}) and value (#{value.inspect}) into non-Hash: #{object.inspect}")
        end
      end
    end

    context "when given a Python::Pickle::Instructions::SETITEMS" do
      let(:instruction) { Python::Pickle::Instructions::SETITEMS }

      let(:key1)   { 'x' }
      let(:value1) { 1   }
      let(:key2)   { 'y' }
      let(:value2) { 2   }

      context "and the first argument on the #stack is a Hash" do
        let(:hash) { {} }

        before do
          subject.meta_stack << [hash]
          subject.stack << key1 << value1 << key2 << value2
          subject.execute(instruction)
        end

        it "must pop the #meta_stack and use the previous stack's values to populate the Hash at the end of the #stack" do
          expect(subject.stack).to eq([ {key1 => value1, key2 => value2} ])
        end
      end

      context "and the first argument on the #stack is not a Hash" do
        let(:object) { Object.new }
        let(:pairs)  { [key1, value1, key2, value2] }

        before do
          subject.meta_stack << [object]
          subject.stack << key1 << value1 << key2 << value2
        end

        it do
          expect {
            subject.execute(instruction)
          }.to raise_error(Python::Pickle::DeserializationError,"cannot set key value pairs (#{pairs.inspect}) into non-Hash: #{object.inspect}")
        end
      end
    end

    context "when given a Python::Pickle::Instructions::NEXT_BUFFER" do
      let(:instruction) { Python::Pickle::Instructions::NEXT_BUFFER }

      context "and the #{described_class} was initialized with the buffers: keyword argument" do
        let(:buffer1) { String.new("hello world") }
        let(:buffer2) { String.new("foo bar")     }
        let(:buffers) do
          [
            buffer1,
            buffer2
          ]
        end

        subject { described_class.new(buffers: buffers) }

        before do
          subject.execute(instruction)
        end

        it "must take the next element from #buffers and push it onto the #stack" do
          expect(subject.stack).to eq([buffer1])
        end

        it "must not modify the underlying buffers Array" do
          expect(buffers).to eq([buffer1, buffer2])
        end
      end

      context "but the #{described_class} was not initialized with the buffers: keyword argument" do
        it do
          expect {
            subject.execute(instruction)
          }.to raise_error(Python::Pickle::DeserializationError,"pickle stream includes a NEXT_BUFFER instruction, but no buffers were provided")
        end
      end
    end

    context "when given a Python::Pickle::Instructions::READONLY_BUFFER" do
      let(:instruction) { Python::Pickle::Instructions::READONLY_BUFFER }

      let(:buffer1) { String.new("hello world") }
      let(:buffer2) { String.new("foo bar")     }

      before do
        subject.stack << buffer1 << buffer2
        subject.execute(instruction)
      end

      it "must freeze the buffer at the top of the #stack" do
        expect(subject.stack[-1]).to be_frozen
      end
    end
  end

  describe "#copyreg_reconstructor" do
    let(:klass)       { double('class') }
    let(:super_class) { double('super class') }
    let(:instance)    { double('instance of class') }

    context "when the initialization argument is nil" do
      it "must call .new on the given class with no arguments" do
        expect(klass).to receive(:new).with(no_args).and_return(instance)

        expect(subject.copyreg_reconstructor(klass,super_class,nil)).to be(instance)
      end
    end

    context "when the initialization argument is not nil" do
      let(:value1)   { 1 }
      let(:value2)   { 2 }
      let(:init_arg) { Python::Pickle::Tuple[value1, value2] }

      it "must call .new on the given class with the given initialization argument" do
        expect(klass).to receive(:new).with(value1,value2).and_return(instance)

        expect(subject.copyreg_reconstructor(klass,super_class,init_arg)).to be(instance)
      end
    end
  end

  describe "#resolv_constant" do
    it "must lookup the constant with the given name in the given namespace" do
      expect(subject.resolve_constant('__builtin__','object')).to eq(
        subject.constants.fetch('__builtin__').fetch('object')
      )
    end

    context "when the constant does not exist in #constants" do
      let(:namespace) { '__main__' }
      let(:name)      { 'object'   }

      it "must return a new Python::Pickle::PyClass instance with the given namespace and name" do
        constant = subject.resolve_constant(namespace,name)
        
        expect(constant).to be_kind_of(Python::Pickle::PyClass)
        expect(constant.namespace).to eq(namespace)
        expect(constant.name).to eq(name)
      end
    end
  end
end
