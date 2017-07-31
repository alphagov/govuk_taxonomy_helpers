require_relative 'spec_helper'
require 'govuk_taxonomy_helpers'

RSpec.describe GovukTaxonomyHelpers::PublishingApiResponse do
  let(:content_item) do
    {
      "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      "base_path" => "/taxon",
      "title" => "Taxon",
      "details" => {
        "internal_name" => "My lovely taxon"
      }
    }
  end

  describe '#from_content_id - simple one child case' do
    let(:expanded_links) do
      child = {
        "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/child",
        "title" => "Child",
        "details" => {
          "internal_name" => "C",
        },
        "links" => {}
      }

      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {
          "child_taxons" => [child]
        }
      }
    end
    before :each do
      @publishing_api = double('publishing_api')
      allow(@publishing_api).to receive(:get_content).with('64aadc14-9bca-40d9-abb4-4f21f9792a05').and_return(content_item)
      allow(@publishing_api).to receive(:get_expanded_links).with('64aadc14-9bca-40d9-abb4-4f21f9792a05').and_return(expanded_links)
    end
    it 'loads the taxon' do
      expect(linked_content_item.title).to eq("Taxon")
      expect(linked_content_item.children.map(&:title)).to eq(["Child"])
      expect(linked_content_item.children.map(&:children)).to all(be_empty)
    end
  end

  let(:linked_content_item) do
    GovukTaxonomyHelpers::LinkedContentItem.from_publishing_api(
      content_item: content_item,
      expanded_links: expanded_links
    )
  end

  context "content item with multiple levels of descendants" do
    let(:expanded_links) do
      grandchild_1 = {
        "content_id" => "84aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/grandchild-1",
        "title" => "Grandchild 1",
        "details" => {
          "internal_name" => "GC 1",
        },
        "links" => {}
      }

      grandchild_2 = {
        "content_id" => "94aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/grandchild-2",
        "title" => "Grandchild 2",
        "details" => {
          "internal_name" => "GC 2",
        },
        "links" => {}
      }

      child_1 = {
        "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/child-1",
        "title" => "Child 1",
        "details" => {
          "internal_name" => "C 1",
        },
        "links" => {
          "child_taxons" => [
            grandchild_1,
            grandchild_2
          ]
        }
      }

      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {
          "child_taxons" => [child_1]
        }
      }
    end

    it "parses titles" do
      expect(linked_content_item.title).to eq("Taxon")
      expect(linked_content_item.children.map(&:title)).to eq(['Child 1'])
      expect(linked_content_item.children.first.children.map(&:title)).to eq(["Grandchild 1", "Grandchild 2"])
    end

    it "parses internal names" do
      expect(linked_content_item.internal_name).to eq("My lovely taxon")
      expect(linked_content_item.children.map(&:internal_name)).to eq(['C 1'])
      expect(linked_content_item.children.first.children.map(&:internal_name)).to eq(["GC 1", "GC 2"])
    end
  end

  context "content item with no descendants" do
    let(:expanded_links) do
      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {}
      }
    end

    it "parses each level of taxons" do
      expect(linked_content_item.title).to eq("Taxon")
      expect(linked_content_item.children).to be_empty
    end
  end

  context "content item with children but no grandchildren" do
    let(:expanded_links) do
      child_1 = {
        "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/child-1",
        "title" => "Child 1",
        "details" => {
          "internal_name" => "C 1",
        },
        "links" => {}
      }

      child_2 = {
        "content_id" => "84aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/child-2",
        "title" => "Child 2",
        "details" => {
          "internal_name" => "C 2",
        },
        "links" => {}
      }

      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {
          "child_taxons" => [child_1, child_2]
        }
      }
    end

    it "parses each level of taxons" do
      expect(linked_content_item.title).to eq("Taxon")
      expect(linked_content_item.children.map(&:title)).to eq(["Child 1", "Child 2"])
      expect(linked_content_item.children.map(&:children)).to all(be_empty)
    end
  end

  context "content item with parents and grandparents" do
    let(:expanded_links) do
      grandparent_1 = {
        "content_id" => "84aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/grandparent-1",
        "title" => "Grandparent 1",
        "details" => {
          "internal_name" => "GP 1",
        },
        "links" => {}
      }

      parent_1 = {
        "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/parent-1",
        "title" => "Parent 1",
        "details" => {
          "internal_name" => "P 1",
        },
        "links" => {
          "parent_taxons" => [
            grandparent_1
          ]
        }
      }

      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {
          "parent_taxons" => [parent_1]
        }
      }
    end

    it "parses the ancestors" do
      expect(linked_content_item.title).to eq("Taxon")
      expect(linked_content_item.parent.title).to eq("Parent 1")
      expect(linked_content_item.ancestors.map(&:title)).to eq(["Grandparent 1", "Parent 1"])
    end
  end


  context "content item with parents and no grandparents" do
    let(:expanded_links) do
      parent_1 = {
        "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/parent-1",
        "title" => "Parent 1",
        "details" => {
          "internal_name" => "P 1",
        },
        "links" => {}
      }

      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {
          "parent_taxons" => [parent_1]
        }
      }
    end

    it "parses the ancestors" do
      expect(linked_content_item.title).to eq("Taxon")
      expect(linked_content_item.parent.title).to eq("Parent 1")
      expect(linked_content_item.ancestors.map(&:title)).to eq(["Parent 1"])
    end
  end

  context "content item with no parents" do
    let(:expanded_links) do
      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {}
      }
    end

    it "parses the ancestors" do
      expect(linked_content_item.title).to eq("Taxon")
      expect(linked_content_item.parent).to be_nil
      expect(linked_content_item.ancestors.map(&:title)).to be_empty
    end
  end

  context "content item with multiple parents" do
    let(:expanded_links) do
      parent_1 = {
        "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/parent-1",
        "title" => "Parent 1",
        "details" => {
          "internal_name" => "P 1",
        },
        "links" => {}
      }

      parent_2 = {
        "content_id" => "84aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/parent-2",
        "title" => "Parent 2",
        "details" => {
          "internal_name" => "P 2",
        },
        "links" => {}
      }

      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {
          "parent_taxons" => [parent_1, parent_2]
        }
      }
    end

    it "uses only the first parent" do
      expect(linked_content_item.title).to eq("Taxon")
      expect(linked_content_item.parent.title).to eq("Parent 1")
      expect(linked_content_item.ancestors.map(&:title)).to eq(["Parent 1"])
    end
  end

  context "a content item tagged to multiple taxons" do
    let(:expanded_links) do
      grandparent_1 = {
        "content_id" => "22aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/grandparent-1",
        "title" => "Grandparent 1",
        "details" => {
          "internal_name" => "GP 1",
        },
        "links" => {}
      }

      parent_1 = {
        "content_id" => "11aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/parent-1",
        "title" => "Parent 1",
        "details" => {
          "internal_name" => "P 1",
        },
        "links" => {
          "parent_taxons" => [grandparent_1]
        }
      }

      taxon_1 = {
        "content_id" => "00aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/this-is-a-taxon",
        "title" => "Taxon 1",
        "details" => {
          "internal_name" => "T 1",
        },
        "links" => {
          "parent_taxons" => [parent_1]
        }
      }

      grandparent_2 = {
        "content_id" => "03aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/grandparent-2",
        "title" => "Grandparent 2",
        "details" => {
          "internal_name" => "GP 2",
        },
        "links" => {}
      }

      parent_2 = {
        "content_id" => "02aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/parent-2",
        "title" => "Parent 2",
        "details" => {
          "internal_name" => "P 2",
        },
        "links" => {
          "parent_taxons" => [grandparent_2]
        }
      }

      taxon_2 = {
        "content_id" => "01aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/this-is-also-a-taxon",
        "title" => "Taxon 2",
        "details" => {
          "internal_name" => "T 2",
        },
        "links" => {
          "parent_taxons" => [parent_2]
        }
      }

      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {
          "taxons" => [taxon_1, taxon_2]
        }
      }
    end

    it "parses the taxons and their ancestors" do
      expect(linked_content_item.parent).to be_nil
      expect(linked_content_item.taxons.map(&:title)).to eq(["Taxon 1", "Taxon 2"])
      expect(linked_content_item.taxons_with_ancestors.map(&:title).sort).to eq(
        [
          "Grandparent 1", "Grandparent 2",
          "Parent 1", "Parent 2",
          "Taxon 1", "Taxon 2",
        ]
      )
    end
  end

  context "minimal responses with missing links and details hashes" do
    let(:minimal_taxon) do
      grandchild_1 = {
        "content_id" => "84aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/grandchild-1",
        "title" => "Grandchild 1",
      }

      grandchild_2 = {
        "content_id" => "94aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/grandchild-2",
        "title" => "Grandchild 2",
      }

      child_1 = {
        "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/child-1",
        "title" => "Child 1",
        "links" => {
          "child_taxons" => [
            grandchild_1,
            grandchild_2
          ]
        }
      }

      content_item = {
        "content_id" => "aaaaaa14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/minimal-taxon",
        "title" => "Minimal Taxon",
      }

      expanded_links = {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {
          "child_taxons" => [child_1],
          "parent_taxons" => [
            {
              "content_id" => "ffaadc14-9bca-40d9-abb4-4f21f9792aff",
              "title" => "Parent Taxon",
              "base_path" => "/parent"
            }
          ]
        }
      }

      GovukTaxonomyHelpers::LinkedContentItem.from_publishing_api(
        content_item: content_item,
        expanded_links: expanded_links
      )
    end

    it "parses taxons with nil internal names" do
      expect(minimal_taxon.title).to eq("Minimal Taxon")
      expect(minimal_taxon.internal_name).to be_nil
      expect(minimal_taxon.parent.title).to eq("Parent Taxon")
      expect(minimal_taxon.parent.internal_name).to be_nil
      expect(minimal_taxon.descendants.map(&:title)).to eq(["Child 1", "Grandchild 1", "Grandchild 2"])
      expect(minimal_taxon.descendants.map(&:internal_name)).to all(be_nil)
    end
  end
end
