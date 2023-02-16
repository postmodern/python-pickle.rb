require 'spec_helper'
require 'python/pickle'

describe Python::Pickle do
  let(:fixtures_dir) { File.join(__dir__,'..','..','fixtures') }

  describe ".parse" do
    context "when given a Pickle protocol 0 stream" do
      let(:io) { File.open(file) }

      context "and it contains a serialized None" do
        let(:file) { File.join(fixtures_dir,'none_v0.pkl') }

        it "must return a Python::Pickle::Instructions::NONE" do
          expect(subject.parse(io)).to eq(
            [
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
              Python::Pickle::Instructions::NONE,
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a serialized True" do
        let(:file) { File.join(fixtures_dir,'true_v0.pkl') }

        it "must return a Python::Pickle::Instructions::Int containing a true value" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Int.new(true),
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Int.new(true),
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a serialized False" do
        let(:file) { File.join(fixtures_dir,'false_v0.pkl') }

        it "must return a Python::Pickle::Instructions::Int with a false value" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Int.new(false),
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Int.new(false),
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a serialized integer" do
        let(:file) { File.join(fixtures_dir,'int_v0.pkl') }

        it "must return a Python::Pickle::Instructions::Int with the decoded number" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Int.new(42),
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Int.new(42),
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a long integer" do
        let(:file) { File.join(fixtures_dir,'long_v0.pkl') }

        it "must return a Python::Pickle::Instructions::Long with the decoded number" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Long.new(18446744073709551615),
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Long.new(18446744073709551615),
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a serialized floating-point number" do
        let(:float) { 3.141592653589793 }
        let(:file)  { File.join(fixtures_dir,'float_v0.pkl') }

        it "must return a Python::Pickle::Instructions::Float with the decoded number" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Float.new(float),
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::Float.new(float),
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a plain string" do
        let(:string) { "ABC" }
        let(:file)   { File.join(fixtures_dir,'str_v0.pkl') }

        it "must return a Python::Pickle::Instructions::String with the decoded number" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::String.new(string),
              Python::Pickle::Instructions::Put.new(0),
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::String.new(string),
              Python::Pickle::Instructions::Put.new(0),
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a string with backslash-escaped characters" do
        let(:string) { "ABC\t\n\r\\'\"" }
        let(:file)   { File.join(fixtures_dir,'escaped_str_v0.pkl') }

        it "must return a Python::Pickle::Instructions::String with the decoded number" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::String.new(string),
              Python::Pickle::Instructions::Put.new(0),
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::String.new(string),
              Python::Pickle::Instructions::Put.new(0),
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a string with hex-escaped characters" do
        let(:string) { (0..255).map(&:chr).join }
        let(:file)   { File.join(fixtures_dir,'bin_str_v0.pkl') }

        it "must return a Python::Pickle::Instructions::String with the decoded number" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::String.new(string),
              Python::Pickle::Instructions::Put.new(0),
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::String.new(string),
              Python::Pickle::Instructions::Put.new(0),
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a UTF string" do
        let(:string) { "ABC\u265E\u265F\u{1F600}" }
        let(:file)   { File.join(fixtures_dir,'unicode_str_v0.pkl') }

        it "must return a Python::Pickle::Instructions::String with the decoded number" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::String.new(string),
              Python::Pickle::Instructions::Put.new(0),
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::String.new(string),
              Python::Pickle::Instructions::Put.new(0),
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a list type" do
        let(:file) { File.join(fixtures_dir,'list_v0.pkl') }

        it "must return an Array of parsed instructions" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::MARK,
              Python::Pickle::Instructions::LIST,
              Python::Pickle::Instructions::Put.new(0),
              Python::Pickle::Instructions::NONE,
              Python::Pickle::Instructions::APPEND,
              Python::Pickle::Instructions::Int.new(true),
              Python::Pickle::Instructions::APPEND,
              Python::Pickle::Instructions::Int.new(false),
              Python::Pickle::Instructions::APPEND,
              Python::Pickle::Instructions::Int.new(42),
              Python::Pickle::Instructions::APPEND,
              Python::Pickle::Instructions::String.new("ABC"),
              Python::Pickle::Instructions::Put.new(1),
              Python::Pickle::Instructions::APPEND,
              Python::Pickle::Instructions::STOP
            ]
          )
        end

        context "and when a block is given" do
          it "must yield each parsed instruction" do
            expect {|b|
              subject.parse(io,&b)
            }.to yield_successive_args(
              Python::Pickle::Instructions::MARK,
              Python::Pickle::Instructions::LIST,
              Python::Pickle::Instructions::Put.new(0),
              Python::Pickle::Instructions::NONE,
              Python::Pickle::Instructions::APPEND,
              Python::Pickle::Instructions::Int.new(true),
              Python::Pickle::Instructions::APPEND,
              Python::Pickle::Instructions::Int.new(false),
              Python::Pickle::Instructions::APPEND,
              Python::Pickle::Instructions::Int.new(42),
              Python::Pickle::Instructions::APPEND,
              Python::Pickle::Instructions::String.new("ABC"),
              Python::Pickle::Instructions::Put.new(1),
              Python::Pickle::Instructions::APPEND,
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains a dict type" do
        let(:file) { File.join(fixtures_dir,'dict_v0.pkl') }

        it "must return an Array of parsed instructions" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::MARK,
              Python::Pickle::Instructions::DICT,
              Python::Pickle::Instructions::Put.new(0),
              Python::Pickle::Instructions::String.new("foo"),
              Python::Pickle::Instructions::Put.new(1),
              Python::Pickle::Instructions::String.new("bar"),
              Python::Pickle::Instructions::Put.new(2),
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
              Python::Pickle::Instructions::MARK,
              Python::Pickle::Instructions::DICT,
              Python::Pickle::Instructions::Put.new(0),
              Python::Pickle::Instructions::String.new("foo"),
              Python::Pickle::Instructions::Put.new(1),
              Python::Pickle::Instructions::String.new("bar"),
              Python::Pickle::Instructions::Put.new(2),
              Python::Pickle::Instructions::SETITEM,
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end

      context "and it contains an object type" do
        let(:file) { File.join(fixtures_dir,'object_v0.pkl') }

        it "must return an Array of parsed instructions" do
          expect(subject.parse(io)).to eq(
            [
              Python::Pickle::Instructions::Global.new('copy_reg','_reconstructor'),
              Python::Pickle::Instructions::Put.new(0),
              Python::Pickle::Instructions::MARK,
              Python::Pickle::Instructions::Global.new('__main__','MyClass'),
              Python::Pickle::Instructions::Put.new(1),
              Python::Pickle::Instructions::Global.new('__builtin__','object'),
              Python::Pickle::Instructions::Put.new(2),
              Python::Pickle::Instructions::NONE,
              Python::Pickle::Instructions::TUPLE,
              Python::Pickle::Instructions::Put.new(3),
              Python::Pickle::Instructions::REDUCE,
              Python::Pickle::Instructions::Put.new(4),
              Python::Pickle::Instructions::MARK,
              Python::Pickle::Instructions::DICT,
              Python::Pickle::Instructions::Put.new(5),
              Python::Pickle::Instructions::String.new('y'),
              Python::Pickle::Instructions::Put.new(6),
              Python::Pickle::Instructions::Int.new(66),
              Python::Pickle::Instructions::SETITEM,
              Python::Pickle::Instructions::String.new('x'),
              Python::Pickle::Instructions::Put.new(7),
              Python::Pickle::Instructions::Int.new(65),
              Python::Pickle::Instructions::SETITEM,
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
              Python::Pickle::Instructions::Global.new('copy_reg','_reconstructor'),
              Python::Pickle::Instructions::Put.new(0),
              Python::Pickle::Instructions::MARK,
              Python::Pickle::Instructions::Global.new('__main__','MyClass'),
              Python::Pickle::Instructions::Put.new(1),
              Python::Pickle::Instructions::Global.new('__builtin__','object'),
              Python::Pickle::Instructions::Put.new(2),
              Python::Pickle::Instructions::NONE,
              Python::Pickle::Instructions::TUPLE,
              Python::Pickle::Instructions::Put.new(3),
              Python::Pickle::Instructions::REDUCE,
              Python::Pickle::Instructions::Put.new(4),
              Python::Pickle::Instructions::MARK,
              Python::Pickle::Instructions::DICT,
              Python::Pickle::Instructions::Put.new(5),
              Python::Pickle::Instructions::String.new('y'),
              Python::Pickle::Instructions::Put.new(6),
              Python::Pickle::Instructions::Int.new(66),
              Python::Pickle::Instructions::SETITEM,
              Python::Pickle::Instructions::String.new('x'),
              Python::Pickle::Instructions::Put.new(7),
              Python::Pickle::Instructions::Int.new(65),
              Python::Pickle::Instructions::SETITEM,
              Python::Pickle::Instructions::BUILD,
              Python::Pickle::Instructions::STOP
            )
          end
        end
      end
    end
  end
end
