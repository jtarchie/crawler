require 'rubygems'
require 'active_support/cache'
require 'faraday'
require 'faraday_middleware'
require 'nokogiri'
require 'rack/cache'

Page = Struct.new(:url) do
  class << self
    attr_accessor :caching
  end

  def title
    title = document.css('title')[0]
    if title
      title.text
    else
      url
    end
  end

  def links
    @links ||= filter_relative_uris(all_tags_with_attr 'a', 'href')
  end

  def assets
    @assets ||= begin
      filter_relative_uris(
        all_tags_with_attr('script', 'src') +
        all_tags_with_attr('link', 'href') +
        all_tags_with_attr('img', 'src')
      )
    end
  end

  private

  def filter_relative_uris(uris)
    current_uri = URI(url)

    uris = uris.reject do |uri|
      uri.nil? || uri.empty?
    end.collect do |uri|
      URI(uri) rescue nil
    end.select do |uri|
      uri &&
        (uri.relative? ||
          (uri.host == current_uri.host &&
           ['http','https'].include?(uri.scheme)
          )
        )
    end.collect do |uri|
      uri = current_uri.merge uri if uri.relative?
      uri.to_s
    end
    puts "  > found uris #{uris.join(',')}" if $VERBOSE
    uris
  end

  def document
    @document ||= begin
      response = client.get(url)
      Nokogiri::HTML(response.body)
    rescue FaradayMiddleware::RedirectLimitReached
      Nokogiri::HTML('')
    end
  end

  def client
    @client ||= Faraday.new do |builder|
      builder.response :caching do
        ActiveSupport::Cache::FileStore.new 'tmp/cache', namespace: 'faraday', expires_in: 3600
      end if Page.caching
      builder.response :follow_redirects
      builder.adapter Faraday.default_adapter
    end
  end

  def all_tags_with_attr(tag, attr)
    document.css(tag).collect{ |tag| tag[attr] }
  end
end

