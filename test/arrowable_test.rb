class ArrowableTest < Test::Unit::TestCase
  class Data < ActiveRecord::Base
  end

  setup do
    FileUtils.rm_rf(DB_PATH.dirname)
    FileUtils.mkdir_p(DB_PATH.dirname)
  end

  teardown do
    FileUtils.rm_rf(DB_PATH.dirname)
  end

  sub_test_case("#to_arrow") do
    setup do
      @datetime_value = Time.iso8601("2018-01-10T18:05:01.1Z")
      ActiveRecord::Base.connection.create_table(:data) do |table|
        table.string :string_column
        table.datetime :datetime_column
        table.boolean :boolean_column
      end
      Data.create(:string_column => "Hello",
                  :datetime_column => @datetime_value,
                  :boolean_column => false)
    end

    test "all" do
      assert_equal(<<-RECORD_BATCH, Data.all.to_arrow.to_s)
id: [1]
string_column: ["Hello"]
datetime_column: [#{@datetime_value.to_i * 1_000_000_000 + @datetime_value.nsec}]
boolean_column: [false]
      RECORD_BATCH
    end
  end
end
