require 'spec_helper'

describe ProcessedLinks do
  let(:links) { ProcessedLinks.new }

  describe '#next' do
    context 'when there are more unprocessed links' do
      before do
        links.add(['http://google.com'])
      end

      it 'returns the next in the list' do
        expect(links.next).to eq 'http://google.com'
      end
    end

    context 'when there are no unprocesses links' do
      it 'returns nil' do
        expect(links.next).to eq nil
      end
    end
  end

  describe '#processed!' do
    context 'when finished processing a link' do
      before do
        links.add(['http://google.com'])
      end

      it 'gets marked as being processed' do
        links.processed!('http://google.com')
        expect(links.more?).to eq false
      end
    end
  end

  describe '#add' do
    context 'with a list of links' do
      it 'adds them to a list of unprocesses links' do
        expect(links.more?).to eq false
        links.add(['http://google.com'])
        expect(links.more?).to eq true
      end
    end
  end

  describe '#more?' do
    context 'when there are unprocessed links' do
      before do
        links.add(['http://google.com'])
      end

      it 'returns true' do
        expect(links.more?).to eq true
      end
    end

    context 'when there are no unprocessed links' do
      it 'returns true' do
        expect(links.more?).to eq false
      end
    end
  end
end
