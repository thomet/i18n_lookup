ENV['I18N_DEBUG'] = 'true'
require File.expand_path('i18n_lookup')

class ActiveModelTest
  require 'active_model'
  extend ActiveModel::Translation
end

describe I18nLookup do
  let(:translations) do
    {}
  end

  before do
    I18n.backend.instance_variable_set(:@translations, translations)
  end

  subject { I18n::Backend::Simple.any_instance }

  context 'activemodel' do
    let(:translations) do
      {:en =>{:attributes => {:my_attribute => 'My Attribute'}}}
    end

    it 'should print the keys as group with a result' do
      expected_result = translations[:en][:attributes][:my_attribute]
      main_key        = [:en, :activemodel, :attributes, :active_model_test, :my_attribute]
      second_key      = [:en, :attributes, :my_attribute]

      subject.should_receive(:print_main_key).with(main_key)
      subject.should_receive(:print_keys).with(main_key, 31)
      subject.should_receive(:print_keys).with(second_key, 33)
      subject.should_receive(:print_result).with(expected_result)

      ActiveModelTest.human_attribute_name('my_attribute')
    end

    it 'should print the keys as group without a result' do
      main_key   = [:en, :activemodel, :attributes, :active_model_test, :my_attribute_2]
      second_key = [:en, :attributes, :my_attribute_2]

      subject.should_receive(:print_main_key).with(main_key)
      subject.should_receive(:print_keys).with(main_key, 31)
      subject.should_receive(:print_keys).with(second_key, 31)

      ActiveModelTest.human_attribute_name('my_attribute_2')
    end
  end

  context 'ruby' do
    let(:translations) do
      {:en => {:test => 'My Test'}}
    end

    it 'should print the key with a result' do
      expected_result = translations[:en][:test]
      main_key        = [:en, :test]

      subject.should_receive(:print_main_key).with(main_key)
      subject.should_receive(:print_keys).with(main_key, 33)
      subject.should_receive(:print_result).with(expected_result)

      I18n.t :test
    end

    context 'with a default' do
      let(:translations) do
        {:en => {:test2 => {:my_attr => 'My Test'}}}
      end

      it 'should print the key with a result' do
        expected_result = translations[:en][:test2][:my_attr]
        main_key        = [:en, :test, :my_attr]
        second_key      = [:en, :test2, :my_attr]

        subject.should_receive(:print_main_key).with(main_key)
        subject.should_receive(:print_keys).with(main_key, 31)
        subject.should_receive(:print_keys).with(second_key, 33)
        subject.should_receive(:print_result).with(expected_result)

        I18n.t :'test.my_attr', :default => :'test2.my_attr'
      end
    end
  end
end
