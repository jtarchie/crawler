require 'spec_helper'
require 'sinatra'

describe Page do
  let(:page) { Page.new('http://www.example.com/page') }

  let(:server) do
    html_output = template
    Class.new(Sinatra::Base) do
      get '/page' do
        html_output
      end
    end
  end

  before do
    stub_request(:get, 'http://www.example.com/page').to_rack(server)
  end

  describe '#title' do
    context 'when there is a title tag' do
      let(:template) do
        %Q{<title>Test</title>}
      end

      it 'returns the content of the tag' do
        expect(page.title).to eq 'Test'
      end
    end

    context 'when there is no title tag' do
      let(:template) do
        %Q{}
      end

      it 'returns the requested URL' do
        expect(page.title).to eq 'http://www.example.com/page'
      end
    end
  end

  describe '#links' do
    let(:template) do
      %Q{
        <a href='/links'>Link</a>
        <a href='http://google.com'>Google</a>
        <a href='https://www.facebook.com/'>Facebook</a>
      }
    end

    it 'does not contain other domains' do
      expect(page.links).to_not include 'http://google.com'
    end

    it 'modifies relative links to include domain' do
      expect(page.links).to eq ['http://www.example.com/links']
    end

    context 'with none http links' do
      let(:template) do
        %Q{
          <a href='mailto:jt@example.com'>Link</a>
        }
      end

      it 'filters them out' do
        expect(page.links).to eq []
      end
    end

    context 'with links that cause URI parsing errors' do
      let(:template) do
        %Q{
          <a href='http://www.facebook.com/pages/São-Paulo-Brazil/112047398814697'>link</a>
        }
      end

      it 'does not include the URI' do
        expect(page.links).to eq []
      end
    end

    context 'when there are URL redirects to many times' do
      let(:server) do
        Class.new(Sinatra::Base) do
          get '/page' do
            redirect '/page'
          end
        end
      end

      it 'returns no links' do
        expect(page.links).to eq []
      end
    end
  end

  describe '#assets' do
    let(:template) do
      %Q{
        <script src='app.js'></script>
        <script src='http://google.com/search.js'></script>
        <link href='style.css'></link>
        <img src='image.jpg' />
      }
    end

    context 'returning a list' do
      it 'includes javascript files' do
        expect(page.assets).to include 'http://www.example.com/app.js'
      end

      it 'includes CSS files' do
        expect(page.assets).to include 'http://www.example.com/style.css'
      end

      it 'includes images' do
        expect(page.assets).to include 'http://www.example.com/image.jpg'
      end

      it 'does not include other domains' do
        expect(page.assets).to_not include 'http://google.com/search.js'
      end

      it 'only includes JS, CSS, and images' do
        expect(page.assets.length).to eq 3
      end
    end
  end
end
