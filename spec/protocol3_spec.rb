require 'spec_helper'
require 'python/pickle/protocol3'

require 'protocol0_read_instruction_examples'
require 'protocol1_read_instruction_examples'
require 'protocol2_read_instruction_examples'
require 'protocol3_read_instruction_examples'

describe Python::Pickle::Protocol3 do
  let(:pickle) { '' }
  let(:io) { StringIO.new(pickle) }

  subject { described_class.new(io) }

  describe "#read_instruction" do
    include_context "Protocol0#read_instruction examples"
    include_context "Protocol1#read_instruction examples"
    include_context "Protocol2#read_instruction examples"
    include_context "Protocol3#read_instruction examples"

    context "when the opcode is not recognized" do
      let(:opcode) { 255 }
      let(:io)     { StringIO.new(opcode.chr) }

      it do
        expect {
          subject.read_instruction
        }.to raise_error(Python::Pickle::InvalidFormat,"invalid opcode (#{opcode.inspect}) for protocol 3")
      end
    end
  end
end
