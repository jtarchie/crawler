require_relative 'page'
require_relative 'processed_links'
require 'json'

Crawler = Struct.new(:base_url) do
  def process!
    current_page = process_page(base_url)

    processed_links = ProcessedLinks.new
    processed_links.processed!(base_url)
    processed_links.add(current_page.links)

    while processed_links.more?
      current_link = processed_links.next
      current_page = process_page(current_link)

      processed_links.processed!(current_link)
      processed_links.add(current_page.links)
    end
  end

  def to_json
    page_by_url = Hash[pages.each_with_index.collect{|p, index| [p.url, {page: p, index: index}]}]
    nodes, links = [], []

    pages.each do |page|
      nodes << {url: page.url, type: 1}
      page.links.each do |link|
        source, target = *[page_by_url[page.url][:index], page_by_url[link][:index]].sort
        links << {
          source: source,
          target: target
        }
      end
    end

    pages.each do |page|
      page.assets.each do |asset|
        node = {url: asset, type: 2}
        unless nodes.include?(node)
          nodes << node
        end
        asset_index = nodes.index(node)

        source, target = *[page_by_url[page.url][:index], asset_index].sort
        links << {
          source: source,
          target: target
        }
      end
    end

    {nodes: nodes, links: links.uniq}.to_json
  end
  private

  def pages
    @pages ||= []
  end

  def process_page(url)
    page = Page.new(url)
    pages << page
    page
  end
end
