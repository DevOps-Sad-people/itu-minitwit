Sequel.migration do
  transaction
  change do
    alter_table(:follower) do
      add_foreign_key [:who_id], :user
      add_foreign_key [:whom_id], :user
    end
    alter_table(:message) do
      add_foreign_key [:author_id], :user
    end
  end
end
