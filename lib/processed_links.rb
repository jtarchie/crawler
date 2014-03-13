require 'set'

class ProcessedLinks
  def next
    link = unprocessed_links.take(1).first
    puts "> next link #{link}" if $VERBOSE
    link
  end

  def processed!(link)
    puts "> finished processing link #{link}" if $VERBOSE
    processed_links.add(link)
    unprocessed_links.subtract(processed_links)
  end

  def add(links)
    unprocessed_links
      .merge(links)
      .subtract(processed_links)
  end

  def more?
    !unprocessed_links.empty?
  end

  private

  def processed_links
    @processed_links ||= Set.new
  end

  def unprocessed_links
    @unprocessed_links ||= Set.new
  end
end
