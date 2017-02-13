require_relative 'spec_helper'
require_relative 'content_item_helper'
require 'govuk_taxonomy_helpers'

RSpec.describe GovukTaxonomyHelpers::PublishingApiLinkedEditionParser do
  let(:edition_response) do
    {
      "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      "base_path" => "/root",
      "title" => "Root",
      "internal_name" => "Root internal name"
    }
  end

  let(:linked_edition) do
    GovukTaxonomyHelpers.parse_publishing_api_response(
      content_item: edition_response,
      expanded_links: expanded_links_response
    )
  end

  context "content item with multiple levels of descendants" do

    let(:expanded_links_response) do
      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {
          "child_taxons" => [
            {
              "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
              "base_path" => "/child-1",
              "title" => "Child 1",
              "internal_name" => "Root > Child 1",
              "links" => {
                "child_taxons" => [
                    {
                      "content_id" => "84aadc14-9bca-40d9-abb4-4f21f9792a05",
                      "base_path" => "/grandchild-1",
                      "title" => "Grandchild 1",
                      "internal_name" => "Root > Child > Grandchild 1",
                      "links" => {}
                    },
                    {
                      "content_id" => "94aadc14-9bca-40d9-abb4-4f21f9792a05",
                      "base_path" => "/grandchild-2",
                      "title" => "Grandchild 2",
                      "internal_name" => "Root > Child > Grandchild 2",
                      "links" => {}
                    }
                  ]
                }
              }
            ]
          }
        }
    end

    it "parses each level of taxons" do
      expect(linked_edition.name).to eq("Root")
      expect(linked_edition.children.map(&:name)).to eq (['Child 1'])
      expect(linked_edition.children.first.children.map(&:name)).to eq(["Grandchild 1", "Grandchild 2"])
    end
  end

  context "content item with no descendants" do
    let(:expanded_links_response) do
      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {}
      }
    end

    it "parses each level of taxons" do
      expect(linked_edition.name).to eq("Root")
      expect(linked_edition.children).to be_empty
    end
  end

  context "content item with children but no grandchildren" do
    let(:expanded_links_response) do
      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {
          "child_taxons" => [
            {
              "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
              "base_path" => "/child-1",
              "title" => "Child 1",
              "internal_name" => "Root > Child 1",
              "links" => {}
            },
            {
              "content_id" => "84aadc14-9bca-40d9-abb4-4f21f9792a05",
              "base_path" => "/child-2",
              "title" => "Child 2",
              "internal_name" => "Root > Child 2",
              "links" => {}
            },
          ]
        }
      }
    end

    it "parses each level of taxons" do
      expect(linked_edition.name).to eq("Root")
      expect(linked_edition.children.map(&:name)).to eq(["Child 1", "Child 2"])
      expect(linked_edition.children.map(&:children)).to all(be_empty)
    end
  end
end
