class Refile::FileSerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :versions

  attr_reader :attachment_name

  def initialize(object, name)
    @attachment_name = name
    super(object)
  end

  delegate :id, to: :attachment
  def attachment
    object.send(attachment_name)
  end

  def name
    attachment_name
  end

  def url
    Refile.attachment_url(object, attachment_name, format: 'jpg')
  end

  def versions
    object.versions.inject({}) do |hash, (name, value)|
      hash["#{name}_url"] = url_for(*value)
      hash
    end
  end

  private

  def url_for(*args)
    Refile.attachment_url(object, attachment_name, *args, format: 'jpg')
  end

end