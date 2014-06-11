require 'i18n'
require 'logger'

$logger = Logger.new(STDOUT)

# if ENV['I18N_DEBUG'] is set to true, all keys are printed on console
module I18nLookup
  require 'i18n_lookup/railtie' if defined?(Rails)

  protected

  def lookup(locale, key, scope = [], options = {})
    @@i18n_fallbacks ||= []
    @@last_key ||= nil

    result = super(locale, key, scope, options)
    keys = I18n.normalize_keys(locale, key, scope, options[:separator])

    if same_key?(keys) && (@@i18n_fallbacks.include?(key) || same_caller?)
      @@i18n_fallbacks << options[:default]
      @@i18n_fallbacks << key
      @@i18n_fallbacks.flatten!
    else
      @@last_key ||= keys.last
      @@i18n_fallbacks = [options[:default], key].flatten

      print_main_key(keys)
    end

    if result
      print_keys(keys, 33)
      print_result(result)
      @@last_key = nil
    else
      print_keys(keys, 31)
    end
    result
  end

  private

  def same_caller?
    @@last_caller ||= caller
    current_caller = caller
    lines = current_caller.length
    i18n_index = current_caller.reverse.index{|line| line =~ /i18n/}
    start_line = lines - i18n_index
    result = (current_caller[start_line..-1] - @@last_caller[start_line..-1]).empty?
    @@last_caller = current_caller
    result
  end

  def same_key?(keys)
    @@last_key && @@last_key.eql?(keys.last)
  end

  def print_main_key(keys, color_code = 34)
    $logger.debug %|--|
    $logger.debug %|Key: "\e[1;#{color_code}m#{keys.last}\e[0;0m"|
  end

  def print_keys(keys, color_code)
    $logger.debug %|\t"\e[1;#{color_code}m#{keys.map(&:to_s).join('.')}\e[0;0m"|
  end

  def print_result(result, color_code = 35)
    $logger.debug %|\t => "\e[1;#{color_code}m#{result.to_s}\e[0;0m"|
  end
end

I18n::Backend::Simple.send(:include, I18nLookup) if ENV['I18N_DEBUG'].eql?('true')
