require 'spec_helper'

describe Noid::Template do
  context 'with a valid template' do
    let(:template) { '.redek' }
    it 'initializes without raising' do
      expect { described_class.new(template) }.not_to raise_error
    end
  end
  context 'with a bogus template' do
    let(:template) { 'foobar' }
    it 'raises Noid::TemplateError' do
      expect { described_class.new(template) }.to raise_error(Noid::TemplateError)
    end
  end
end
