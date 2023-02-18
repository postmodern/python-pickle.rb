require 'spec_helper'
require 'python/pickle'

describe Python::Pickle do
  let(:fixtures_dir) { File.join(__dir__,'fixtures') }

  describe ".parse" do
    let(:path) { File.join(fixtures_dir,'dict_v4.pkl') }
    let(:file) { File.open(path,'rb') }

    it "must return an Array of parsed instructions" do
      expect(subject.parse(file)).to eq(
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
          subject.parse(file,&b)
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

  describe ".load" do
    let(:path) { File.join(fixtures_dir,'dict_v4.pkl') }
    let(:data) { File.binread(path) }

    it "must deserialize the Python Pickle data in the given file" do
      expect(subject.load(data)).to eq({"foo" => "bar"})
    end
  end

  describe ".load_file" do
    let(:path) { File.join(fixtures_dir,'dict_v4.pkl') }

    it "must deserialize the Python Pickle data in the given file" do
      expect(subject.load_file(path)).to eq({"foo" => "bar"})
    end
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
