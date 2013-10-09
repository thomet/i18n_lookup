# Default: only not founding translations are printed on console
# if ENV['I18N_DEBUG'] is set to true, all not founding keys are printed on console
class I18n::Backend::Simple
  module Implementation

  protected

    def lookup(locale, key, scope = [], options = {})
      init_translations unless initialized?
      keys = I18n.normalize_keys(locale, key, scope, options[:separator])

      keys.inject(translations) do |result, _key|
        _key = _key.to_sym
        unless result.is_a?(Hash) && result.has_key?(_key)
          print_debug_message(keys, caller)   # print key that was not found!
          return nil
        end
        result = result[_key]
        result = resolve(locale, _key, result, options.merge(:scope => nil)) if result.is_a?(Symbol)

        print_debug_message(keys, caller, false, result)

        result
      end
    end

    def print_debug_message(keys, caller, is_missing = true, result = nil)
      result = result.class == String ? result : nil

      caller_line = caller.detect{|f| f !~ /i18n/}
      (Gem.paths.path.clone << ENV['HOME']).each { |base| caller_line.sub!(base, '...') }

      if $key_end && is_missing && !keys.last.eql?($key_end)
        print_debug %|I18n: from #{caller_line}|
        print_debug %|\t Key: "\e[1;34m#{keys.last}\e[0;0m"|
        print_debug %|\t\tcouldn't find "\e[1;33m#{keys.map(&:to_s).join('.')}\e[0;0m"|
        print_debug %|\t\t => \e[1;31mNO MATCH FOUND\e[0;0m\n|, true
      end

      if is_missing
        if !caller_line.eql?($last_caller_line)
          print_debug %|I18n: from #{caller_line}|
          $last_caller_line = caller_line
          $key_end = nil
        elsif $last_missing.nil? && !ENV['I18N_DEBUG'].eql?('true')
          print_debug %|I18n: from #{caller_line}|
        end

        unless keys.last.eql?($key_end)
          print_debug %|\t Key: "\e[1;34m#{keys.last}\e[0;0m"|
          $key_end = keys.last
        end

        print_debug %|\t\tcouldn't find "\e[1;33m#{keys.map(&:to_s).join('.')}\e[0;0m"|
      elsif keys.last.eql?($key_end)
        print_debug %|\t\tMATCH "\e[1;35m#{keys.map(&:to_s).join('.')}\e[0;0m"|
        print_debug %|\t\t => #{result.to_s}\n|
        $key_end = nil
        reset_buffer
      else
        unless result.nil?
          print_debug %|I18n: from #{caller_line}|
          print_debug %|\t Key: "\e[1;34m#{keys.last}\e[0;0m"|
          print_debug %|\t\tMATCH "\e[1;35m#{keys.map(&:to_s).join('.')}\e[0;0m"|
          print_debug %|\t\t => #{result.to_s}\n|
        end
      end
    end

    def print_debug(msg, no_match = false)
      if ENV['I18N_DEBUG'].eql?('true')
        if no_match
          Rails.logger.warn msg
        else
          Rails.logger.debug msg
        end
      else
        $last_missing ||= StringIO.new
        $last_missing << msg
        print_buffer if no_match
      end
    end

    def print_buffer
      unless ENV['I18N_DEBUG'].eql?('true')
        Rails.logger.error $last_missing.string
        reset_buffer
      end
    end

    def reset_buffer
      $last_missing = nil
    end

  end

end if Rails.env.development?
