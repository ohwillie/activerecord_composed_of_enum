require 'require_relative'
require 'active_record'

require_relative '../../lib/active_record/composed_of_enum'

describe ActiveRecord::ComposedOfEnum do
  let(:model_class) do
    Class.new(ActiveRecord::Base) do
      self.table_name = 'models'

      # Needed because this is an anonymous class.
      def self.model_name
        ActiveModel::Name.new(nil, nil, 'Model')
      end

      extend ActiveRecord::ComposedOfEnum
    end
  end

  before do
    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :database => ':memory:'
    )

    ActiveRecord::Base.connection.create_table(:models) do |t|
      t.integer(:enum_cd)
    end
  end

  after do
    ActiveRecord::Base.connection.disconnect!
  end

  context 'ArgumentErrors' do
    it 'should raise an ArgumentError if the :base option is missing' do
      expect {
        model_class.composed_of_enum(:enum, :enumeration => [Object])
      }.to raise_error(ArgumentError, /:base/)
    end

    it 'should raise an ArgumentError if the :enumeration option is missing' do
      expect {
        model_class.composed_of_enum(:enum, :base => Object)
      }.to raise_error(ArgumentError, /:enumeration/)
    end
  end

  context 'success' do
    let(:base) do
      # This hack is here because we need an anonymous class, but it has to
      # return itself when name.constantize is called.
      Class.new.tap { |c| c.stub(:name) { double(:constantize => c) } }
    end
    let(:enumeration) { 3.times.map { Class.new(base) } }

    context 'without a default' do
      before do
        model_class.composed_of_enum(
          :enum,
          :base => base,
          :enumeration => enumeration
        )
      end

      it 'should make an enum_cd method on base' do
        base.enum_cd.should be_nil
      end

      it 'should set enum_cds for all enumeration classes' do
        enumeration.each_with_index do |enum, index|
          enum.enum_cd.should == index
        end
      end

      it 'should not allow a model instance with a negative enum_cd value' do
        model_class.new(:enum_cd => -1).should_not be_valid
      end

      it 'should allow a model instance with a valid enum_cd value' do
        enumeration.each_with_index do |enum, index|
          model_class.new(:enum_cd => index).should be_valid
        end
      end

      it 'should not allow a model instance with too large an enum_cd value' do
        model_class.new(:enum_cd => enumeration.size).should_not be_valid
      end

      it 'should set the enum and enum_cd if fed an enum' do
        enumeration.each do |enum|
          model = model_class.create(:enum => enum)
          model.enum.should == enum
          model.enum_cd.should == enum.enum_cd
        end
      end
    end

    it 'should set a default after initialize if provided' do
      model_class.composed_of_enum(
        :enum,
        :base => base,
        :enumeration => enumeration,
        :default => enumeration.first
      )

      model = model_class.create
      model.enum.should == enumeration.first
      model.enum_cd.should == enumeration.first.enum_cd
    end
  end
end
