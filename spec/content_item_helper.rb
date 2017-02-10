module ContentItemHelper
  def content_item_with_details(title, other_fields: {})
    other_fields_with_details = other_fields.merge(
      "details" => {
        "internal_name" => "internal name for #{title}",
        "notes_for_editors" => "Editor notes for #{title}"
      }
    )
    basic_content_item(title, other_fields: other_fields_with_details)
  end

  def basic_content_item(title, other_fields: {})
    {
      "content_id" => title,
      "title" => title,
      "base_path" => '/path/' + title,
      "document_type" => "guidance",
    }.merge(other_fields)
  end

  def build_linkable(hash)
    default = {
      "content_id" => SecureRandom.uuid,
      "title" => SecureRandom.hex,
      "internal_name" => SecureRandom.hex,
      "base_path" => "/#{SecureRandom.hex}",
      "document_type" => SecureRandom.hex,
      "publication_state" => %w(live draft).sample,
    }

    default.merge(hash)
  end
end
