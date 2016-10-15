require 'active_support'

require File.expand_path('../route_translator/extensions', __FILE__)
require File.expand_path('../route_translator/translator', __FILE__)
require File.expand_path('../route_translator/host', __FILE__)

module RouteTranslator
  extend RouteTranslator::Host

  TRANSLATABLE_SEGMENT = /^([-_a-zA-Z0-9]+)(\()?/

  Configuration = Struct.new(:force_locale, :hide_locale,
                             :generate_unlocalized_routes, :locale_param_key,
                             :generate_unnamed_unlocalized_routes, :available_locales,
                             :host_locales, :disable_fallback, :locale_segment_proc,
                             :default_locale)

  class << self
    private

    def resolve_host_locale_config_conflicts
      @config.generate_unlocalized_routes         = false
      @config.generate_unnamed_unlocalized_routes = false
      @config.force_locale                        = false
      @config.hide_locale                         = false
      @config.default_locale                      = nil
    end
  end

  module_function

  def config(&block)
    @config                                     ||= Configuration.new
    @config.force_locale                        ||= false
    @config.hide_locale                         ||= false
    @config.generate_unlocalized_routes         ||= false
    @config.locale_param_key                    ||= :locale
    @config.generate_unnamed_unlocalized_routes ||= false
    @config.host_locales                        ||= ActiveSupport::OrderedHash.new
    @config.available_locales                   ||= []
    @config.disable_fallback                    ||= false
    @config.locale_segment_proc                 ||= nil
	  @config.default_locale						          ||= nil
    yield @config if block
    resolve_host_locale_config_conflicts unless @config.host_locales.empty?
    @config
  end

  def default_locale
    if config.default_locale.is_a?(Proc)
	    config.default_locale.call
  	else
	    config.default_locale
    end
  end

  def locale_param_key
    if config.locale_param_key.is_a?(Proc)
      config.locale_param_key.call
    else
      config.locale_param_key
    end
  end

  def available_locales
    if config.available_locales.is_a?(Proc)
      locales = config.available_locales.call
    else
      locales = config.available_locales
    end

    if locales.any?
      locales.map(&:to_sym)
    else
      I18n.available_locales.dup
    end
  end
end
