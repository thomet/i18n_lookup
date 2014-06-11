# -*- coding: utf-8 -*-
namespace :i18n do
  desc 'Writes current default locale translations to a normalized file and deletes unused locale files'
  task :normalize => :environment do
    class Hash
      def to_hash_recursive
        result = self.to_hash

        result.each do |key, value|
          case value
          when Hash
            result[key] = value.to_hash_recursive
          when Array
            result[key] = value.to_hash_recursive
          end
        end

        result
      end

      def sort_by_key(recursive=false, &block)
        self.keys.sort(&block).reduce({}) do |seed, key|
          seed[key] = self[key]
          if recursive && seed[key].is_a?(Hash)
            seed[key] = seed[key].sort_by_key(true, &block)
          end
          seed
        end
      end
    end

    class Array
      def to_hash_recursive
        result = self

        result.each_with_index do |value,i|
          case value
          when Hash
            result[i] = value.to_hash_recursive
          when Array
            result[i] = value.to_hash_recursive
          end
        end

        result
      end
    end

    def current_i18n_yaml(locale)
      default_locale_translations = I18n.backend.send(:translations)[locale].with_indifferent_access.to_hash_recursive
      i18n_yaml = {locale.to_s => default_locale_translations}.sort_by_key(true).to_yaml
      process = i18n_yaml.split(/\n/).reject{|e| e == ''}[1..-1]  # remove "---" from first line in yaml

      # add an empty line if yaml tree level changes by 2 or more
      tmp_ary = []
      process.each_with_index do |line, idx|
        tmp_ary << line
        unless process[idx+1].nil?
          this_line_spcs = line.match(/\A\s*/)[0].length
          next_line_spcs = process[idx+1].match(/\A\s*/)[0].length
          tmp_ary << '' if next_line_spcs - this_line_spcs < -2
        end
      end

      tmp_ary * "\n"
    end

    generated_locale_yaml = {}

    I18n.backend.send(:translations).keys.each do |locale|
      generated_locale_yaml[locale] = current_i18n_yaml(locale)
    end

    # delete unused locale files
    repo_root = %x(git rev-parse --show-toplevel).strip
    repo_locales = I18n.load_path.dup.keep_if{|p| p.include?(repo_root)}
    repo_locales.each do |locale_file|
      FileUtils.rm locale_file
      puts "removed \"#{locale_file}\""
    end

    # write normalized locale to file
    generated_locale_yaml.keys.each do |locale|
      fn = File.join Rails.root, 'config', 'locales', locale.to_s + '.yml'
      f_size_before = File.exists?(fn) ? File.size(fn) : 0

      File.open(fn, 'w') { |file| file.puts generated_locale_yaml[locale]}
      f_size_after = File.size fn
      puts "\n(re)generated #{fn}\n"

      if f_size_before == 0
        puts "\"#{fn}\" created, file size: #{f_size_after} bytes.\n"
      elsif f_size_before != f_size_after
        puts "\"#{fn}\" changed from #{f_size_before} to #{f_size_after} bytes.\n"
      else
        puts "\"#{fn}\" is still #{f_size_after} bytes.\n"
      end
    end
  end
end
