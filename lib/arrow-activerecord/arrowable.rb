require 'arrow'

module ArrowActiveRecord
  module Arrowable
    def to_arrow
      @target_column_names = self.select_values.size.zero? ? self.column_names : self.select_values
      arrays = generate_columns
      fields = @target_column_names.collect.with_index do |name, i|
        Arrow::Field.new(name, arrays[i].value_data_type)
      end
      schema = Arrow::Schema.new(fields)

      Arrow::RecordBatch.new(schema, self.size, arrays)
    end

    private
    def generate_columns
      column_records = self.pluck(*@target_column_names).transpose

      @target_column_names.map.with_index do |column_name, idx|
        type = self.columns.find { |e| e.name == column_name.to_s }.type
        case type
        when :integer
          builder = Arrow::IntArrayBuilder.new
          builder.build(column_records[idx])
        when :float
          Arrow::FloatArray.new(column_records[idx])
        when :datetime
          data_type = Arrow::TimestampDataType.new(:nano)
          builder = Arrow::TimestampArrayBuilder.new(data_type)
          builder.build(column_records[idx])
        else
          Arrow::StringArray.new(column_records[idx])
        end
      end
    end
  end
end
