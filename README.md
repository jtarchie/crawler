# Usage

```ruby
crawler = Crawler.new('http://example.com')
crawler.process!

# JSON for D3
puts crawler.to_json
```

# Examples

```sh
bundle install
cd examples/
bundle exec ruby run.rb
```

Then load this [page](http://localhost:4567/results.html) in your
browser. Hover over the nodes to see their URL.

# Tests

```sh
bundle install
bundle exec rspec spec/
```
