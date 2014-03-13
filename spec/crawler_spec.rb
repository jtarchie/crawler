require 'spec_helper'

describe Crawler do

  context '#process' do
    let(:crawler) { Crawler.new('/') }

    it 'calls the base domain' do
      Page.stub(:new).and_return(double(:page, links: []))
      crawler.process!
      expect(Page).to have_received(:new).with('/')
    end

    context 'for all the links on the page' do
      let(:page) do
        double(:page,
                links: ['/links', '/images']
              )
      end

      before { Page.stub(new: page) }

      it 'parses all the links from that page' do
        crawler.process!
        expect(Page).to have_received(:new).with('/links')
        expect(Page).to have_received(:new).with('/images')
      end

      context 'when a link is found on more than one page' do
        it 'only parses that link once' do
          crawler.process!
          expect(Page).to have_received(:new).with('/links').once
        end
      end
    end
  end

  describe '#to_json' do
    let(:crawler) { Crawler.new('/links') }

    context 'when pages have been processed' do
      let(:json) { JSON.parse(crawler.to_json) }

      before do
        Page.stub(:new).and_return(
          double(:links, url: '/links', links:['/links','/faq'], assets: ['/image.jpg']),
          double(:faq, url: '/faq', links:['/links'], assets: [])
        )
        crawler.process!
      end

      it 'returns a list of nodes' do
        expect(json['nodes']).to eq [{"url"=>"/links", "type"=>1}, {"url"=>"/faq", "type"=>1}, {"url"=>"/image.jpg", "type"=>2}]
      end

      it 'returns a list of links between nodes' do
        expect(json['links']).to eq [
          {"source"=>0, "target"=>0},
          {"source"=>0, "target"=>1},
          {"source"=>0, "target"=>2},
        ]
      end
    end
  end
end
