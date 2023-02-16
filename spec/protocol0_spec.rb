require 'spec_helper'
require 'python/pickle/protocol0'

describe Python::Pickle::Protocol0 do
  let(:pickle) { '' }
  let(:io) { StringIO.new(pickle) }

  subject { described_class.new(io) }

  describe "#read_instruction" do
  end

  describe "#read_hex_escaped_char" do
    let(:io) { StringIO.new("41") }
    subject { described_class.new(io) }

    it "must return the character represented by the hex byte value" do
      expect(subject.read_hex_escaped_char).to eq('A')
    end

    context "when the hex string starts with a non-hex character" do
      let(:io) { StringIO.new("G1") }

      it do
        expect {
          subject.read_hex_escaped_char
        }.to raise_error(Python::Pickle::InvalidFormat,"invalid hex escape character: \"\\xG1\"")
      end
    end

    context "when the hex string ends with a non-hex character" do
      let(:io) { StringIO.new("1G") }

      it do
        expect {
          subject.read_hex_escaped_char
        }.to raise_error(Python::Pickle::InvalidFormat,"invalid hex escape character: \"\\x1G\"")
      end
    end

    context "when the hex string ends prematurely" do
      let(:io) { StringIO.new("1") }

      it do
        expect {
          subject.read_hex_escaped_char
        }.to raise_error(Python::Pickle::InvalidFormat,"invalid hex escape character: \"\\x1\"")
      end
    end
  end

  describe "#read_escaped_char" do
    context "when the next character is 'x'" do
      let(:io) { StringIO.new("x41") }

      it "must decode the hex escaped character" do
        expect(subject.read_escaped_char).to eq('A')
      end
    end

    context "when the next character is 't'" do
      let(:io) { StringIO.new("t") }

      it "must return '\\t'" do
        expect(subject.read_escaped_char).to eq("\t")
      end
    end

    context "when the next character is 'n'" do
      let(:io) { StringIO.new("n") }

      it "must return '\\n'" do
        expect(subject.read_escaped_char).to eq("\n")
      end
    end

    context "when the next character is 'r'" do
      let(:io) { StringIO.new("r") }

      it "must return '\\r'" do
        expect(subject.read_escaped_char).to eq("\r")
      end
    end

    context "when the next character is '\\'" do
      let(:io) { StringIO.new("\\") }

      it "must return '\\'" do
        expect(subject.read_escaped_char).to eq("\\")
      end
    end

    context "when the next character is '\\''" do
      let(:io) { StringIO.new("'") }

      it "must return '\\''" do
        expect(subject.read_escaped_char).to eq("'")
      end
    end

    context "when the next character is another character" do
      let(:io) { StringIO.new("a") }

      it do
        expect {
          subject.read_escaped_char
        }.to raise_error(Python::Pickle::InvalidFormat,"invalid backslash escape character: \"\\a\"")
      end
    end
  end

  describe "#read_nl_string" do
    let(:string) { "foo" }
    let(:io)     { StringIO.new("#{string}\n") }

    it "must read the characters until a '\\n' character is encountered" do
      expect(subject.read_nl_string).to eq(string)
    end

    context "when the stream prematurely ends" do
      let(:io) { StringIO.new("#{string}") }

      it do
        expect {
          subject.read_nl_string
        }.to raise_error(Python::Pickle::InvalidFormat,"unexpected end of stream after the end of a newline terminated string")
      end
    end
  end

  describe "#read_string" do
    let(:string) { 'ABC' }
    let(:io)     { StringIO.new("'#{string}'\n") }

    it "must read the characters within the single-quotes and return the string" do
      expect(subject.read_string).to eq(string)
    end

    it "must return an ASCII 8bit encoded String" do
      expect(subject.read_string.encoding).to eq(Encoding::ASCII_8BIT)
    end

    context "when the string contains backslash escaped characters" do
      let(:string) { "ABC\\t\\n\\r\\\\\\'" }

      it "must decode the backslash escaped characters" do
        expect(subject.read_string).to eq("ABC\t\n\r\\'")
      end
    end

    context "when the string contains hex escaped characters" do
      let(:string) { "ABC\\x41\\x42\\x43" }

      it "must decode the hex escaped characters" do
        expect(subject.read_string).to eq("ABCABC")
      end
    end

    context "when the next character is not a \"'\"" do
      let(:io) { StringIO.new("#{string}'") }

      it do
        expect {
          subject.read_string
        }.to raise_error(Python::Pickle::InvalidFormat,"cannot find beginning single-quote of string")
      end
    end

    context "when the string does not end with a single-quote" do
      let(:io) { StringIO.new("'#{string}") }

      it do
        expect {
          subject.read_string
        }.to raise_error(Python::Pickle::InvalidFormat,"unexpected end of stream after the end of a single-quoted string")
      end
    end

    context "when the character after the ending single-quote is not a '\\n' character" do
      let(:io) { StringIO.new("'#{string}'XXX") }

      it do
        expect {
          subject.read_string
        }.to raise_error(Python::Pickle::InvalidFormat,"expected a '\\n' character following the string, but was \"X\"")
      end
    end
  end

  describe "#read_unicode_escaped_char16" do
    let(:io) { StringIO.new("1234") }
    subject { described_class.new(io) }

    it "must read four hex characters and represent the unicode character represented by them" do
      expect(subject.read_unicode_escaped_char16).to eq('ሴ')
    end

    context "when the hex string starts with a non-hex character" do
      let(:io) { StringIO.new("G234") }

      it do
        expect {
          subject.read_unicode_escaped_char16
        }.to raise_error(Python::Pickle::InvalidFormat,"invalid unicode escape character: \"\\uG234\"")
      end
    end

    context "when the hex string ends with a non-hex character" do
      let(:io) { StringIO.new("123G") }

      it do
        expect {
          subject.read_unicode_escaped_char16
        }.to raise_error(Python::Pickle::InvalidFormat,"invalid unicode escape character: \"\\u123G\"")
      end
    end

    context "when the hex string ends prematurely" do
      let(:io) { StringIO.new("123") }

      it do
        expect {
          subject.read_unicode_escaped_char16
        }.to raise_error(Python::Pickle::InvalidFormat,"invalid unicode escape character: \"\\u123\"")
      end
    end
  end

  describe "#read_unicode_escaped_char32" do
    let(:io) { StringIO.new("00001234") }
    subject { described_class.new(io) }

    it "must read eight hex characters and represent the unicode character represented by them" do
      expect(subject.read_unicode_escaped_char32).to eq('ሴ')
    end

    context "when the hex string starts with a non-hex character" do
      let(:io) { StringIO.new("G2345678") }

      it do
        expect {
          subject.read_unicode_escaped_char32
        }.to raise_error(Python::Pickle::InvalidFormat,"invalid unicode escape character: \"\\UG2345678\"")
      end
    end

    context "when the hex string ends with a non-hex character" do
      let(:io) { StringIO.new("1234567G") }

      it do
        expect {
          subject.read_unicode_escaped_char32
        }.to raise_error(Python::Pickle::InvalidFormat,"invalid unicode escape character: \"\\U1234567G\"")
      end
    end

    context "when the hex string ends prematurely" do
      let(:io) { StringIO.new("0000123") }

      it do
        expect {
          subject.read_unicode_escaped_char32
        }.to raise_error(Python::Pickle::InvalidFormat,"invalid unicode escape character: \"\\U0000123\"")
      end
    end
  end

  describe "#read_unicode_escaped_char" do
  end

  describe "#read_unicode" do
    let(:string) { 'ABC' }
    let(:io)     { StringIO.new("#{string}\n") }

    it "must read the characters within the single-quotes and return the string" do
      expect(subject.read_unicode_string).to eq(string)
    end

    it "must return a UTF-8 encoded String" do
      expect(subject.read_unicode_string.encoding).to eq(Encoding::UTF_8)
    end

    context "when the string contains unicode escaped characters" do
      let(:string) { "ABC\\u0041\\u0042\\u0043" }

      it "must decode the hex escaped characters" do
        expect(subject.read_unicode_string).to eq("ABCABC")
      end
    end

    context "when the string does not end with a '\\n' character" do
      let(:io) { StringIO.new("#{string}") }

      it do
        expect {
          subject.read_unicode_string
        }.to raise_error(Python::Pickle::InvalidFormat,"unexpected end of stream while parsing unicode string: #{string.inspect}")
      end
    end
  end

  describe "#read_float" do
    let(:float) { 1234.5678 }
    let(:io)  { StringIO.new("#{float}\n") }

    it "must read until the newline and decode the read digits" do
      expect(subject.read_float).to eq(float)
    end

    context "when a non-numeric character is read" do
      let(:io) { StringIO.new("12.3x4\n") }

      it do
        expect {
          subject.read_float
        }.to raise_error(Python::Pickle::InvalidFormat,"encountered a non-numeric character while reading a float: \"x\"")
      end
    end

    context "when the stream ends prematurely" do
      let(:string) { '123.' }
      let(:io)     { StringIO.new(string) }

      it do
        expect {
          subject.read_float
        }.to raise_error(Python::Pickle::InvalidFormat,"unexpected end of stream while parsing a float: #{string.inspect}")
      end
    end
  end

  describe "#read_int" do
    let(:int) { 1234 }
    let(:io)  { StringIO.new("#{int}\n") }

    it "must read until the newline and decode the read digits" do
      expect(subject.read_int).to eq(int)
    end

    context "when the next characters are '00\\n'" do
      let(:io) { StringIO.new("00\n") }

      it "must return false" do
        expect(subject.read_int).to be(false)
      end
    end

    context "when the next characters are '01\\n'" do
      let(:io) { StringIO.new("01\n") }

      it "must return true" do
        expect(subject.read_int).to be(true)
      end
    end

    context "when a non-numeric character is read" do
      let(:io) { StringIO.new("100x00\n") }

      it do
        expect {
          subject.read_int
        }.to raise_error(Python::Pickle::InvalidFormat,"encountered a non-numeric character while reading an integer: \"x\"")
      end
    end

    context "when the stream ends prematurely" do
      let(:string) { '1234' }
      let(:io)     { StringIO.new(string) }

      it do
        expect {
          subject.read_int
        }.to raise_error(Python::Pickle::InvalidFormat,"unexpected end of stream while parsing an integer: #{string.inspect}")
      end
    end
  end

  describe "#read_long" do
    let(:long) { (2**64) - 1 }
    let(:io)   { StringIO.new("#{long}L\n") }

    it "must read until a 'L' character and decode the read digits" do
      expect(subject.read_long).to eq(long)
    end

    context "when a non-numeric character is read" do
      let(:io) { StringIO.new("1234x678L\n") }

      it do
        expect {
          subject.read_long
        }.to raise_error(Python::Pickle::InvalidFormat,"encountered a non-numeric character while reading a long integer: \"x\"")
      end
    end

    context "when the stream ends prematurely" do
      let(:string) { '1234' }
      let(:io)     { StringIO.new(string) }

      it do
        expect {
          subject.read_long
        }.to raise_error(Python::Pickle::InvalidFormat,"unexpected end of stream while parsing a long integer: #{string.inspect}")
      end
    end

    context "when the stream ends just after the terminating 'L'" do
      let(:string) { '1234L' }
      let(:io)     { StringIO.new(string) }

      it do
        expect {
          subject.read_long
        }.to raise_error(Python::Pickle::InvalidFormat,"unexpected end of stream after the end of an integer")
      end
    end

    context "when there is no newline character after the terminating 'L'" do
      let(:string) { "1234Lx" }
      let(:io)     { StringIO.new(string) }

      it do
        expect {
          subject.read_long
        }.to raise_error(Python::Pickle::InvalidFormat,"expected a '\\n' character following the integer, but was \"x\"")
      end
    end
  end

  let(:fixtures_dir) { File.join(__dir__,'fixtures') }

  describe "#read_instruction" do
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

    context "when the opcode is 48" do
      let(:io) { StringIO.new(48.chr) }

      it "must return Python::Pickle::Instructions::POP" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::POP
        )
      end
    end

    context "when the opcode is 50" do
      let(:io) { StringIO.new(50.chr) }

      it "must return Python::Pickle::Instructions::DUP" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::DUP
        )
      end
    end

    context "when the opcode is 73" do
      let(:int) { 1234 }
      let(:io)  { StringIO.new("#{73.chr}#{int}\n") }

      it "must return a Python::Pickle::Instructions::Int object" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::Int.new(int)
        )
      end
    end

    context "when the opcode is 76" do
      let(:long) { (2**64)-1 }
      let(:io)   { StringIO.new("#{76.chr}#{long}L\n") }

      it "must return a Python::Pickle::Instructions::Long object" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::Long.new(long)
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

    context "when the opcode is 83" do
      let(:string) { 'ABC' }
      let(:io)     { StringIO.new("#{83.chr}'#{string}'\n") }

      it "must return a Python::Pickle::Instructions::String object" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::String.new(string)
        )
      end
    end

    context "when the opcode is 86" do
      let(:string) { 'ABC' }
      let(:io)     { StringIO.new("#{86.chr}#{string}\n") }

      it "must return a Python::Pickle::Instructions::String object" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::String.new(string)
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

    context "when the opcode is 100" do
      let(:io) { StringIO.new(100.chr) }

      it "must return Python::Pickle::Instructions::DICT" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::DICT
        )
      end
    end

    context "when the opcode is 103" do
      let(:index) { 1 }
      let(:io)    { StringIO.new("#{103.chr}#{index}\n") }

      it "must return a Python::Pickle::Instructions::Get object" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::Get.new(index)
        )
      end
    end

    context "when the opcode is 108" do
      let(:io) { StringIO.new(108.chr) }

      it "must return Python::Pickle::Instructions::LIST" do
        expect(subject.read_instruction).to be(
          Python::Pickle::Instructions::LIST
        )
      end
    end

    context "when the opcode is 112" do
      let(:index) { 1 }
      let(:io)    { StringIO.new("#{112.chr}#{index}\n") }

      it "must return a Python::Pickle::Instructions::Put object" do
        expect(subject.read_instruction).to eq(
          Python::Pickle::Instructions::Put.new(index)
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

    context "when the opcode isn't reocgnized" do
      let(:opcode) { 255 }
      let(:io)     { StringIO.new(opcode.chr) }

      it do
        expect {
          subject.read_instruction
        }.to raise_error(Python::Pickle::InvalidFormat,"invalid opcode (#{opcode.inspect}) for protocol 0")
      end
    end
  end
end
