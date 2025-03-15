Sequel.migration do
  transaction
    change do
        alter_table(:follower) do
            add_primary_key [:who_id, :whom_id]
        end
    end
end
