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
taxon.children
# => [LinkedContentItem(title: child-1-id, ...), LinkedContentItem(title: child-2, ...)]

taxon.parent
# => LinkedContentItem(title: root, ...)

taxon.breadcrumb_trail
# => [LinkedContentItem(title: root, ...), LinkedContentItem(title: taxon, ...)]
```

A `LinkedContentItem` built from an content_item that isn't a taxon can access all taxons associated with it.

```ruby
content_item.taxons
# => [LinkedContentItem(title: taxon, ...),
#     LinkedContentItem(title: another-taxon, ...)]

content_item.taxons_with_ancestors
# => [LinkedContentItem(title: root, ...),
#     LinkedContentItem(title: taxon-parent, ...),
#     LinkedContentItem(title: taxon, ...),
#     LinkedContentItem(title: another-taxon, ...)]
```

## Nomenclature

- **Taxonomy**: The hierarchy of topics used to classify content by subject on GOV.UK. Not all content is tagged to the taxonomy. We are rolling out the taxonomy and navigation theme-by-theme.
- **Taxon**: Any topic within the taxonomy.
- **Content Item**: A distinct version of a document. A taxon is also a type of content item.
- **Draft**: A content item which has not yet been published. Draft taxons do not appear on the live site but can have documents tagged to them.

## Documentation

To run a Yard server locally to preview documentation, run:

    $ bundle exec yard server --reload

## Contributing

1. Fork it ( https://github.com/alphagov/govuk_taxonomy_helpers/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

[MIT License](LICENCE.txt)
