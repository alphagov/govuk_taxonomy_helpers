# GovukTaxonomyHelpers

Parses the taxonomy of GOV.UK into a browsable tree structure.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'govuk_taxonomy_helpers'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install govuk_taxonomy_helpers

## Usage

This API is provisional and is likely to change for 0.x versions.

```ruby
require 'plek'
require 'gds_api/publishing_api'
require 'govuk_taxonomy_helpers'

publishing_api = GdsApi::PublishingApi.new(Plek.new.find('publishing-api'))
content_item = publishing_api.get_content("c75c541-403f-4cb1-9b34-4ddde816a80d")
expanded_links = publishing_api.get_expanded_links("c75c541-403f-4cb1-9b34-4ddde816a80d")

taxonomy = GovukTaxonomyHelpers.parse_publishing_api_response(
  content_item: content_item,
  expanded_links: expanded_links
)

puts taxonomy.tree.map(&:name) # All taxons
puts taxonomy.descendants(&:name) # All descendant taxons
puts taxonomy.children.map(&:name) # All direct children
```

## Nomenclature

- **Taxonomy**: The hierarchy of topics used to classify content by subject on GOV.UK. Not all content is tagged to the taxonomy. We are rolling out the taxonomy and navigation theme-by-theme.
- **Taxon**: Any topic within the taxonomy.


## Contributing

1. Fork it ( https://github.com/alphagov/govuk_taxonomy_helpers/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

[MIT License](LICENCE.txt)
