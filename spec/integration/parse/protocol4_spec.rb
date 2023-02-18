require 'spec_helper'
require 'python/pickle'

describe Python::Pickle do
  let(:fixtures_dir) { File.join(__dir__,'..','..','fixtures') }

  describe ".parse" do
    context "when given a Pickle protocol 4 stream" do
      let(:io) { File.open(file) }

      context "and it contains a serialized None" do
        let(:file) { File.join(fixtures_dir,'none_v4.pkl') }

        it "must return a Python::Pickle::Instructions::NONE" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::NONE,
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::NONE,
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a serialized True" do
        let(:file) { File.join(fixtures_dir,'true_v4.pkl') }

        it "must return a Python::Pickle::Instructions::Int containing a true value" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::NEWTRUE,
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::NEWTRUE,
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a serialized False" do
        let(:file) { File.join(fixtures_dir,'false_v4.pkl') }

        it "must return a Python::Pickle::Instructions::Int with a false value" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::NEWFALSE,
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::NEWFALSE,
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a serialized integer" do
        let(:file) { File.join(fixtures_dir,'int_v4.pkl') }

        it "must return a Python::Pickle::Instructions::BinInt1 with the decoded number" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::BinInt1.new(42),
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::BinInt1.new(42),
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a long integer" do
        let(:file) { File.join(fixtures_dir,'long_v4.pkl') }

        it "must return a Python::Pickle::Instructions::Long with the decoded number" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::Frame.new(12),
              Python::Pickle::Instructions::Long1.new(9,18446744073709551615),
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::Frame.new(12),
              Python::Pickle::Instructions::Long1.new(9,18446744073709551615),
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a serialized floating-point number" do
        let(:float) { 3.141592653589793 }
        let(:file)  { File.join(fixtures_dir,'float_v4.pkl') }

        it "must return a Python::Pickle::Instructions::BinFloat with the decoded number" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::Frame.new(10),
              Python::Pickle::Instructions::BinFloat.new(float),
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::Frame.new(10),
              Python::Pickle::Instructions::BinFloat.new(float),
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a plain string" do
        let(:string) { "ABC" }
        let(:length) { string.bytesize }
        let(:file)   { File.join(fixtures_dir,'str_v4.pkl') }

        it "must return a Python::Pickle::Instructions::ShortBinUnicode with the decoded number" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::Frame.new(7),
              Python::Pickle::Instructions::ShortBinUnicode.new(length,string),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::Frame.new(7),
              Python::Pickle::Instructions::ShortBinUnicode.new(length,string),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a UTF string" do
        let(:string) { "ABC\u265E\u265F\u{1F600}" }
        let(:length) { string.bytesize }
        let(:file)   { File.join(fixtures_dir,'unicode_str_v4.pkl') }

        it "must return a Python::Pickle::Instructions::ShortBinUnicode with the decoded number" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::Frame.new(17),
              Python::Pickle::Instructions::ShortBinUnicode.new(length,string),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::Frame.new(17),
              Python::Pickle::Instructions::ShortBinUnicode.new(length,string),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a list type" do
        let(:file) { File.join(fixtures_dir,'list_v4.pkl') }

        it "must return an Array of parsed instructions" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::Frame.new(16),
              Python::Pickle::Instructions::EMPTY_LIST,
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::MARK,
              Python::Pickle::Instructions::NONE,
              Python::Pickle::Instructions::NEWTRUE,
              Python::Pickle::Instructions::NEWFALSE,
              Python::Pickle::Instructions::BinInt1.new(42),
              Python::Pickle::Instructions::ShortBinUnicode.new(3,"ABC"),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::APPENDS,
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::Frame.new(16),
              Python::Pickle::Instructions::EMPTY_LIST,
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::MARK,
              Python::Pickle::Instructions::NONE,
              Python::Pickle::Instructions::NEWTRUE,
              Python::Pickle::Instructions::NEWFALSE,
              Python::Pickle::Instructions::BinInt1.new(42),
              Python::Pickle::Instructions::ShortBinUnicode.new(3,"ABC"),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::APPENDS,
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a dict type" do
        let(:file) { File.join(fixtures_dir,'dict_v4.pkl') }

        it "must return an Array of parsed instructions" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::Frame.new(16),
              Python::Pickle::Instructions::EMPTY_DICT,
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::ShortBinUnicode.new(3,"foo"),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::ShortBinUnicode.new(3,"bar"),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::SETITEM,
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::Frame.new(16),
              Python::Pickle::Instructions::EMPTY_DICT,
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::ShortBinUnicode.new(3,"foo"),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::ShortBinUnicode.new(3,"bar"),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::SETITEM,
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains an object type" do
        let(:file) { File.join(fixtures_dir,'object_v4.pkl') }

        it "must return an Array of parsed instructions" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::Frame.new(44),
              Python::Pickle::Instructions::ShortBinUnicode.new(8,'__main__'),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::ShortBinUnicode.new(7,'MyClass'),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::STACK_GLOBAL,
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::EMPTY_TUPLE,
              Python::Pickle::Instructions::NEWOBJ,
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::EMPTY_DICT,
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::MARK,
              Python::Pickle::Instructions::ShortBinUnicode.new(1,'x'),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::BinInt1.new(65),
              Python::Pickle::Instructions::ShortBinUnicode.new(1,'y'),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::BinInt1.new(66),
              Python::Pickle::Instructions::SETITEMS,
              Python::Pickle::Instructions::BUILD,
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::Frame.new(44),
              Python::Pickle::Instructions::ShortBinUnicode.new(8,'__main__'),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::ShortBinUnicode.new(7,'MyClass'),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::STACK_GLOBAL,
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::EMPTY_TUPLE,
              Python::Pickle::Instructions::NEWOBJ,
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::EMPTY_DICT,
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::MARK,
              Python::Pickle::Instructions::ShortBinUnicode.new(1,'x'),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::BinInt1.new(65),
              Python::Pickle::Instructions::ShortBinUnicode.new(1,'y'),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::BinInt1.new(66),
              Python::Pickle::Instructions::SETITEMS,
              Python::Pickle::Instructions::BUILD,
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a bytearray type" do
        let(:file) { File.join(fixtures_dir,'bytearray_v4.pkl') }

        it "must return an Array of parsed instructions" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::Frame.new(36),
              Python::Pickle::Instructions::ShortBinUnicode.new(8,'builtins'),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::ShortBinUnicode.new(9,'bytearray'),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::STACK_GLOBAL,
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::ShortBinBytes.new(3,'ABC'),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::TUPLE1,
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::REDUCE,
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Proto.new(4),
              Python::Pickle::Instructions::Frame.new(36),
              Python::Pickle::Instructions::ShortBinUnicode.new(8,'builtins'),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::ShortBinUnicode.new(9,'bytearray'),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::STACK_GLOBAL,
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::ShortBinBytes.new(3,'ABC'),
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::TUPLE1,
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::REDUCE,
              Python::Pickle::Instructions::MEMOIZE,
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end
    end
  end
end
