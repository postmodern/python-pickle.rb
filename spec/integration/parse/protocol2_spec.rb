require 'spec_helper'
require 'python/pickle'

describe Python::Pickle do
  let(:fixtures_dir) { File.join(__dir__,'..','..','fixtures') }

  describe ".parse" do
    context "when given a Pickle protocol 2 stream" do
      let(:io) { File.open(file) }

      context "and it contains a serialized None" do
        let(:file) { File.join(fixtures_dir,'none_v2.pkl') }

        it "must return a Python::Pickle::Instructions::NONE" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(2),
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
              Python::Pickle::Instructions::Proto.new(2),
              Python::Pickle::Instructions::NONE,
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a serialized True" do
        let(:file) { File.join(fixtures_dir,'true_v2.pkl') }

        it "must return a Python::Pickle::Instructions::Int containing a true value" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(2),
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
              Python::Pickle::Instructions::Proto.new(2),
              Python::Pickle::Instructions::NEWTRUE,
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a serialized False" do
        let(:file) { File.join(fixtures_dir,'false_v2.pkl') }

        it "must return a Python::Pickle::Instructions::Int with a false value" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(2),
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
              Python::Pickle::Instructions::Proto.new(2),
              Python::Pickle::Instructions::NEWFALSE,
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a serialized integer" do
        let(:file) { File.join(fixtures_dir,'int_v2.pkl') }

        it "must return a Python::Pickle::Instructions::BinInt1 with the decoded number" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(2),
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
              Python::Pickle::Instructions::Proto.new(2),
              Python::Pickle::Instructions::BinInt1.new(42),
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a long integer" do
        let(:file) { File.join(fixtures_dir,'long_v2.pkl') }

        it "must return a Python::Pickle::Instructions::Long with the decoded number" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(2),
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
              Python::Pickle::Instructions::Proto.new(2),
              Python::Pickle::Instructions::Long1.new(9,18446744073709551615),
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a serialized floating-point number" do
        let(:float) { 3.141592653589793 }
        let(:file)  { File.join(fixtures_dir,'float_v2.pkl') }

        it "must return a Python::Pickle::Instructions::BinFloat with the decoded number" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(2),
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
              Python::Pickle::Instructions::Proto.new(2),
              Python::Pickle::Instructions::BinFloat.new(float),
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a plain string" do
        let(:string) { "ABC" }
        let(:length) { string.bytesize }
        let(:file)   { File.join(fixtures_dir,'str_v2.pkl') }

        it "must return a Python::Pickle::Instructions::ShortBinString with the decoded number" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(2),
              Python::Pickle::Instructions::ShortBinString.new(length,string),
              Python::Pickle::Instructions::BinPut.new(0),
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Proto.new(2),
              Python::Pickle::Instructions::ShortBinString.new(length,string),
              Python::Pickle::Instructions::BinPut.new(0),
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a string with backslash-escaped characters" do
        let(:string) { "ABC\t\n\r\\'\"" }
        let(:length) { string.bytesize  }
        let(:file)   { File.join(fixtures_dir,'escaped_str_v2.pkl') }

        it "must return a Python::Pickle::Instructions::ShortBinString with the decoded number" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(2),
              Python::Pickle::Instructions::ShortBinString.new(length,string),
              Python::Pickle::Instructions::BinPut.new(0),
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Proto.new(2),
              Python::Pickle::Instructions::ShortBinString.new(length,string),
              Python::Pickle::Instructions::BinPut.new(0),
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a string with hex-escaped characters" do
        let(:string) { (0..255).map(&:chr).join }
        let(:length) { string.bytesize }
        let(:file)   { File.join(fixtures_dir,'bin_str_v2.pkl') }

        it "must return a Python::Pickle::Instructions::BinString with the decoded number" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(2),
              Python::Pickle::Instructions::BinString.new(length,string),
              Python::Pickle::Instructions::BinPut.new(0),
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Proto.new(2),
              Python::Pickle::Instructions::BinString.new(length,string),
              Python::Pickle::Instructions::BinPut.new(0),
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a UTF string" do
        let(:string) { "ABC\u265E\u265F\u{1F600}" }
        let(:length) { string.bytesize }
        let(:file)   { File.join(fixtures_dir,'unicode_str_v2.pkl') }

        it "must return a Python::Pickle::Instructions::BinUnicode with the decoded number" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(2),
              Python::Pickle::Instructions::BinUnicode.new(length,string),
              Python::Pickle::Instructions::BinPut.new(0),
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Proto.new(2),
              Python::Pickle::Instructions::BinUnicode.new(length,string),
              Python::Pickle::Instructions::BinPut.new(0),
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a list type" do
        let(:file) { File.join(fixtures_dir,'list_v2.pkl') }

        it "must return an Array of parsed instructions" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(2),
              Python::Pickle::Instructions::EMPTY_LIST,
              Python::Pickle::Instructions::BinPut.new(0),
              Python::Pickle::Instructions::MARK,
              Python::Pickle::Instructions::NONE,
              Python::Pickle::Instructions::NEWTRUE,
              Python::Pickle::Instructions::NEWFALSE,
              Python::Pickle::Instructions::BinInt1.new(42),
              Python::Pickle::Instructions::ShortBinString.new(3,"ABC"),
              Python::Pickle::Instructions::BinPut.new(1),
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
              Python::Pickle::Instructions::Proto.new(2),
              Python::Pickle::Instructions::EMPTY_LIST,
              Python::Pickle::Instructions::BinPut.new(0),
              Python::Pickle::Instructions::MARK,
              Python::Pickle::Instructions::NONE,
              Python::Pickle::Instructions::NEWTRUE,
              Python::Pickle::Instructions::NEWFALSE,
              Python::Pickle::Instructions::BinInt1.new(42),
              Python::Pickle::Instructions::ShortBinString.new(3,"ABC"),
              Python::Pickle::Instructions::BinPut.new(1),
              Python::Pickle::Instructions::APPENDS,
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a dict type" do
        let(:file) { File.join(fixtures_dir,'dict_v2.pkl') }

        it "must return an Array of parsed instructions" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(2),
              Python::Pickle::Instructions::EMPTY_DICT,
              Python::Pickle::Instructions::BinPut.new(0),
              Python::Pickle::Instructions::ShortBinString.new(3,"foo"),
              Python::Pickle::Instructions::BinPut.new(1),
              Python::Pickle::Instructions::ShortBinString.new(3,"bar"),
              Python::Pickle::Instructions::BinPut.new(2),
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
              Python::Pickle::Instructions::Proto.new(2),
              Python::Pickle::Instructions::EMPTY_DICT,
              Python::Pickle::Instructions::BinPut.new(0),
              Python::Pickle::Instructions::ShortBinString.new(3,"foo"),
              Python::Pickle::Instructions::BinPut.new(1),
              Python::Pickle::Instructions::ShortBinString.new(3,"bar"),
              Python::Pickle::Instructions::BinPut.new(2),
              Python::Pickle::Instructions::SETITEM,
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains an object type" do
        let(:file) { File.join(fixtures_dir,'object_v2.pkl') }

        it "must return an Array of parsed instructions" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Proto.new(2),
              Python::Pickle::Instructions::Global.new('__main__','MyClass'),
              Python::Pickle::Instructions::BinPut.new(0),
              Python::Pickle::Instructions::EMPTY_TUPLE,
              Python::Pickle::Instructions::NEWOBJ,
              Python::Pickle::Instructions::BinPut.new(1),
              Python::Pickle::Instructions::EMPTY_DICT,
              Python::Pickle::Instructions::BinPut.new(2),
              Python::Pickle::Instructions::MARK,
              Python::Pickle::Instructions::ShortBinString.new(1,'y'),
              Python::Pickle::Instructions::BinPut.new(3),
              Python::Pickle::Instructions::BinInt1.new(66),
              Python::Pickle::Instructions::ShortBinString.new(1,'x'),
              Python::Pickle::Instructions::BinPut.new(4),
              Python::Pickle::Instructions::BinInt1.new(65),
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
              Python::Pickle::Instructions::Proto.new(2),
              Python::Pickle::Instructions::Global.new('__main__','MyClass'),
              Python::Pickle::Instructions::BinPut.new(0),
              Python::Pickle::Instructions::EMPTY_TUPLE,
              Python::Pickle::Instructions::NEWOBJ,
              Python::Pickle::Instructions::BinPut.new(1),
              Python::Pickle::Instructions::EMPTY_DICT,
              Python::Pickle::Instructions::BinPut.new(2),
              Python::Pickle::Instructions::MARK,
              Python::Pickle::Instructions::ShortBinString.new(1,'y'),
              Python::Pickle::Instructions::BinPut.new(3),
              Python::Pickle::Instructions::BinInt1.new(66),
              Python::Pickle::Instructions::ShortBinString.new(1,'x'),
              Python::Pickle::Instructions::BinPut.new(4),
              Python::Pickle::Instructions::BinInt1.new(65),
              Python::Pickle::Instructions::SETITEMS,
              Python::Pickle::Instructions::BUILD,
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end
    end
  end
end
