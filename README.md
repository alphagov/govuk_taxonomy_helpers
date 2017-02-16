# GovukTaxonomyHelpers

Parses the taxonomy of GOV.UK into a browseable tree structure.

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

The API is provisional and is likely to change for versions < 1.0.0.

To access the taxonomy, first request the content from the [publishing api](https://github.com/alphagov/publishing-api), then parse it to get a `LinkedContentItem` object.

```ruby
require 'govuk_taxonomy_helpers'

content_item = Services.publishing_api.get_content("c75c541-403f-4cb1-9b34-4ddde816a80d")
expanded_links = Services.publishing_api.get_expanded_links("c75c541-403f-4cb1-9b34-4ddde816a80d")

taxonomy = GovukTaxonomyHelpers::LinkedContentItem.from_publishing_api(
  content_item: content_item,
  expanded_links: expanded_links
)
```

A `LinkedContentItem` built from a taxon can access all *narrower term* taxons below it and all *broader term* taxons above it.

A taxon may have many child taxons, but can only have one or zero parents.

```ruby
puts taxonomy.tree             # All taxons in this branch of the taxonomy
puts taxonomy.descendants      # Just the taxons that fall under this one
puts taxonomy.children         # All direct children
puts taxonomy.parent           # The direct parent
puts taxonomy.ancestors        # The path from the root of the taxonomy to the parent taxon
puts taxonomy.breadcrumb_trail # The path from the root of the taxonomy to this taxon
```

A `LinkedContentItem` built from an content_item that isn't a taxon can access all taxons associated with it.

```ruby
puts taxonomy.taxons                # Directly tagged taxons
puts taxonomy.taxons_with_ancestors # All taxons that the content can be found in
puts taxonomy.parent                # nil
puts taxonomy.children              # []
```

## Nomenclature

- **Taxonomy**: The hierarchy of topics used to classify content by subject on GOV.UK. Not all content is tagged to the taxonomy. We are rolling out the taxonomy and navigation theme-by-theme.
- **Taxon**: Any topic within the taxonomy.
- **ContentItem**: A distinct version of a document. A taxon is also a type of content item.


## Contributing

1. Fork it ( https://github.com/alphagov/govuk_taxonomy_helpers/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

[MIT License](LICENCE.txt)
