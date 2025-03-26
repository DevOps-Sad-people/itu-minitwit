Sequel.migration do
  transaction
  change do
    create_table(:request) do
      primary_key :request_id
      Integer :latest_id, null: false
      String :request, null: false
    end
  end
end
