require 'spec_helper'
require 'python/pickle'

describe Python::Pickle do
  let(:fixtures_dir) { File.join(__dir__,'fixtures') }

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
    end
  end

  describe ".load" do
  end

  describe ".dump" do
  end

  describe ".infer_protocol_version" do
    context "when given a Pickle protocol 0 stream" do
      let(:file) { File.join(fixtures_dir,'dict_v0.pkl') }
      let(:io)   { File.open(file) }

      it "must return 0" do
        expect(subject.infer_protocol_version(io)).to eq(0)
      end

      it "must unread the read bytes" do
        subject.infer_protocol_version(io)

        expect(io.pos).to eq(0)
      end
    end

    context "when given a Pickle protocol 1 stream" do
      let(:file) { File.join(fixtures_dir,'dict_v1.pkl') }
      let(:io)   { File.open(file) }

      it "must return 1" do
        expect(subject.infer_protocol_version(io)).to eq(1)
      end

      it "must unread the read bytes" do
        subject.infer_protocol_version(io)

        expect(io.pos).to eq(0)
      end
    end

    context "when given a Pickle protocol 2 stream" do
      let(:file) { File.join(fixtures_dir,'dict_v2.pkl') }
      let(:io)   { File.open(file) }

      it "must return 2" do
        expect(subject.infer_protocol_version(io)).to eq(2)
      end

      it "must unread the read bytes" do
        subject.infer_protocol_version(io)

        expect(io.pos).to eq(0)
        expect(io.read(2)).to eq("\x80\x02".b)
      end
    end

    context "when given a Pickle protocol 3 stream" do
      let(:file) { File.join(fixtures_dir,'dict_v3.pkl') }
      let(:io)   { File.open(file) }

      it "must return 3" do
        expect(subject.infer_protocol_version(io)).to eq(3)
      end

      it "must unread the read bytes" do
        subject.infer_protocol_version(io)

        expect(io.pos).to eq(0)
        expect(io.read(2)).to eq("\x80\x03".b)
      end
    end

    context "when given a Pickle protocol 4 stream" do
      let(:file) { File.join(fixtures_dir,'dict_v4.pkl') }
      let(:io)   { File.open(file) }

      it "must return 4" do
        expect(subject.infer_protocol_version(io)).to eq(4)
      end

      it "must unread the read bytes" do
        subject.infer_protocol_version(io)

        expect(io.pos).to eq(0)
        expect(io.read(2)).to eq("\x80\x04".b)
      end
    end

    context "when given a Pickle protocol 5 stream" do
      let(:file) { File.join(fixtures_dir,'dict_v5.pkl') }
      let(:io)   { File.open(file) }

      it "must return 5" do
        expect(subject.infer_protocol_version(io)).to eq(5)
      end

      it "must unread the read bytes" do
        subject.infer_protocol_version(io)

        expect(io.pos).to eq(0)
        expect(io.read(2)).to eq("\x80\x05".b)
      end
    end
  end
end
