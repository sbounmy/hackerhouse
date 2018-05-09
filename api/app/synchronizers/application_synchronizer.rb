class ApplicationSynchronizer
  attr :params

  def self.with(params)
    new(self, params)
  end

  def initialize(synchronizer, params)
    @synchronizer, @params = synchronizer, params
  end

  private

  def method_missing(method_name, *args)
    args.each do |arg|
      method_n = "#{method_name.to_s}_#{arg}".to_sym
      if respond_to? method_n
        send method_n
      else
        super(method_n, args)
      end
    end
  end
  # https://relishapp.com/rspec/rspec-mocks/docs/verifying-doubles/dynamic-classes
  def respond_to_missing?(method_name, private = false)
    super || @synchronizer.instance_methods.include?(method_name)
  end
end
