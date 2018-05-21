class Synchronizer
  class DefinitionError < StandardError
    def initialize(action, service)
      super("on :#{action} do
          to :#{service} do
            ...
          end
        end")
    end
  end

  class MissingService < StandardError
    def initialize(klass, action)
      super("need at least a service as argument: #{klass}.#{action.name}(#{action.services.keys.join(", ")})")
    end
  end

  attr :params

  def self.with(params)
    new(self, params)
  end

  def initialize(synchronizer, params)
    @synchronizer, @params = synchronizer, params
  end

  class Action
    attr_accessor :name

    def initialize(name, &block)
      @name = name
      instance_eval(&block)
    end

    def to name, &block
      services[name] = Service.new(name, &block)
    end

    def services
      @services ||= {}
    end

    def [](name)
      services[name]
    end
  end

  class Service
    def initialize(name, &block)
      @name = name
      @block = block
    end

    def run(method)
      method.instance_eval(&@block)
    end
  end

  private

  def self.on action_name, &block
    actions[action_name] = Action.new(action_name, &block)
  end

  def self.actions
    @actions ||= {}
  end

  def self.[](method_n)
    method_name, arg = method_n.to_s.split('_').map &:to_sym
    actions[method_name] && actions[method_name][arg]
  end

  def method_missing(method_name, *args)
    raise MissingService.new(self.class, self.class.actions[method_name.to_sym]) if args.empty?
    args.each do |arg|
      method_n = "#{method_name.to_s}_#{arg}".to_sym
      if respond_to? method_n
        send_action method_n
      else
        raise DefinitionError.new(method_name, arg)
        super(method_n, args)
      end
    end
  end

  def send_action method_n
    self.class[method_n].run(self)
  end

  # https://relishapp.com/rspec/rspec-mocks/docs/verifying-doubles/dynamic-classes
  def respond_to_missing?(method_name, private = false)
    super || self.class[method_name]
  end
end
