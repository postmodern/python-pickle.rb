require 'spec_helper'
require 'python/pickle'

describe Python::Pickle do
  let(:fixtures_dir) { File.join(__dir__,'..','..','fixtures') }

  describe ".load" do
    context "when given a Pickle protocol 1 stream" do
      let(:io) { File.open(file) }

      context "and it contains a serialized None" do
        let(:file) { File.join(fixtures_dir,'none_v1.pkl') }

        it "must return nil" do
          expect(subject.load(io)).to be(nil)
        end
      end

      context "and it contains a serialized True" do
        let(:file) { File.join(fixtures_dir,'true_v1.pkl') }

        it "must return true" do
          expect(subject.load(io)).to be(true)
        end
      end

      context "and it contains a serialized False" do
        let(:file) { File.join(fixtures_dir,'false_v1.pkl') }

        it "must return false" do
          expect(subject.load(io)).to be(false)
        end
      end

      context "and it contains a serialized integer" do
        let(:file) { File.join(fixtures_dir,'int_v1.pkl') }

        it "must return an Integer object" do
          expect(subject.load(io)).to eq(42)
        end
      end

      context "and it contains a long integer" do
        let(:file) { File.join(fixtures_dir,'long_v1.pkl') }

        it "must return an Integer object" do
          expect(subject.load(io)).to eq((2 ** 64) - 1)
        end
      end

      context "and it contains a serialized floating-point number" do
        let(:float) { 3.141592653589793 }
        let(:file)  { File.join(fixtures_dir,'float_v1.pkl') }

        it "must return a Float object" do
          expect(subject.load(io)).to eq(float)
        end
      end

      context "and it contains a plain string" do
        let(:string) { "ABC" }
        let(:file)   { File.join(fixtures_dir,'str_v1.pkl') }

        it "must return a String object" do
          expect(subject.load(io)).to eq(string)
        end

        context "and it contains a UTF string" do
          let(:string) { "ABC\u265E\u265F\u{1F600}" }
          let(:file)   { File.join(fixtures_dir,'unicode_str_v1.pkl') }

          it "must return a UTF-8 encoded String object" do
            expect(subject.load(io).encoding).to be(Encoding::UTF_8)
          end
        end
      end

      context "and it contains a bytearray type" do
        let(:string) { "ABC" }
        let(:file)   { File.join(fixtures_dir,'bytearray_v1.pkl') }

        it "must return a Python::Pickle::ByteArray object" do
          expect(subject.load(io)).to eq(Python::Pickle::ByteArray.new(string))
        end
      end

      context "and it contains a list type" do
        let(:file) { File.join(fixtures_dir,'list_v1.pkl') }

        it "must return an Array object" do
          expect(subject.load(io)).to eq(
            [nil, true, false, 42, "ABC"]
          )
        end

        context "but the list object contains other list objects" do
          let(:file) { File.join(fixtures_dir,'nested_list_v1.pkl') }

          it "must return a nested Array object" do
            expect(subject.load(io)).to eq(
              [1, [2, [3, [4]]]]
            )
          end
        end
      end

      context "and it contains a set type" do
        let(:file) { File.join(fixtures_dir,'set_v1.pkl') }

        it "must return a Set object" do
          expect(subject.load(io)).to eq(
            Set[1, 2, 3, 4]
          )
        end
      end

      context "and it contains a dict type" do
        let(:file) { File.join(fixtures_dir,'dict_v1.pkl') }

        it "must return an Array object" do
          expect(subject.load(io)).to eq(
            {"foo" => "bar"}
          )
        end

        context "but the dict object contains other dict objects" do
          let(:file) { File.join(fixtures_dir,'nested_dict_v1.pkl') }

          it "must return a nested Hash object" do
            expect(subject.load(io)).to eq(
              {"a" => {"b" => {"c" => "d"}}}
            )
          end
        end
      end

      context "and it contains a function type" do
        let(:file) { File.join(fixtures_dir,'function_v1.pkl') }

        context "but there is no constant mapping for the function name" do
          it "must return a Python::Pickle::PyClass object of the given name" do
            object = subject.load(io)

            expect(object).to be_kind_of(Python::Pickle::PyClass)
            expect(object.namespace).to eq('__main__')
            expect(object.name).to eq('func')
          end
        end

        context "but there is a constant mapping for the function name" do
          module TestPickleLoad
            def self.func
            end
          end

          it "must return a mapped Ruby method" do
            object = subject.load(io, constants: {
              '__main__' => {
                'func' => TestPickleLoad.method(:func)
              }
            })

            expect(object).to eq(TestPickleLoad.method(:func))
          end
        end
      end

      context "and it contains a class type" do
        let(:file) { File.join(fixtures_dir,'class_v1.pkl') }

        context "but there is no constant mapping for the class name" do
          it "must return a Python::Pickle::PyClass object of the given name" do
            object = subject.load(io)

            expect(object).to be_kind_of(Python::Pickle::PyClass)
            expect(object.namespace).to eq('__main__')
            expect(object.name).to eq('MyClass')
          end
        end

        context "but there is a constant mapping for the class name" do
          module TestPickleLoad
            class MyClass
            end
          end

          it "must return a new Ruby object for the mapped class" do
            object = subject.load(io, constants: {
              '__main__' => {
                'MyClass' => TestPickleLoad::MyClass
              }
            })

            expect(object).to be(TestPickleLoad::MyClass)
          end
        end
      end

      context "and it contains an object type" do
        let(:file) { File.join(fixtures_dir,'object_v1.pkl') }

        context "but there is no constant mapping for the class name" do
          it "must return a Python::Pickle::PyObject object of the given name" do
            object = subject.load(io)

            expect(object).to be_kind_of(Python::Pickle::PyObject)
            expect(object.py_class).to be_kind_of(Python::Pickle::PyClass)
            expect(object.py_class.namespace).to eq('__main__')
            expect(object.py_class.name).to eq('MyClass')
            expect(object.attributes).to eq(
              {
                'x' => 0x41,
                'y' => 0x42
              }
            )
          end
        end

        context "but there is a constant mapping for the class name" do
          context "and the Ruby class defines a __setstate__ method" do
            module TestPickleLoad
              class MyClassWithSetState
                attr_reader :x
                attr_reader :y

                def __setstate__(attributes)
                  @x = attributes['x']
                  @y = attributes['y']
                end
              end
            end

            it "must return a new Ruby object for the mapped class" do
              object = subject.load(io, constants: {
                '__main__' => {
                  'MyClass' => TestPickleLoad::MyClassWithSetState
                }
              })

              expect(object).to be_kind_of(TestPickleLoad::MyClassWithSetState)
              expect(object.x).to eq(0x41)
              expect(object.y).to eq(0x42)
            end
          end

          context "but the Ruby class does not define a __setstate__ method" do
            module TestPickleLoad
              class MyClassWithoutSetState
              end
            end

            it do
              expect {
                subject.load(io, constants: {
                  '__main__' => {
                    'MyClass' => TestPickleLoad::MyClassWithoutSetState
                  }
                })
              }.to raise_error(Python::Pickle::DeserializationError).with_message(
                /\Acannot execute BUILD on an object that does not define a __setstate__ method or is not a Hash: #<TestPickleLoad::MyClassWithoutSetState:0x[0-9a-f]+>\z/
              )
            end
          end
        end
      end
    end
  end
end
