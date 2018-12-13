class DocumentSerializer < ApplicationSerializer
  attributes :id

  private

  # DSL attachments
  #
  # Example:
  # class UserSerializer < ApplicationSerializer
  #   attachments :avatar
  # end
  # **keyword_arguments
  # https://www.justinweiss.com/articles/fun-with-keyword-arguments/
  def self.attachments(*attr_names, **options)
    url_names = attr_names.map { |name| "#{name}_url" }
    attributes url_names

    attr_names.each do |name|
      define_method "#{name}_url" do
        object.send(name).presence &&
        Refile.attachment_url(object, name, *options.first.flatten, format: 'jpeg')
        # Refile::FileSerializer.new(object, name).serializable_hash
        # object.send(name).presence
        # Refile::FileSerializer.new(object, name).serializable_hash
      end
    end
  end
end
