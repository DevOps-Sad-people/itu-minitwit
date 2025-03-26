Sequel.migration do
  transaction
  change do
    alter_table(:follower) do
      add_index :who_id
      add_index :whom_id
    end
    alter_table(:message) do
      add_index :author_id
    end
    alter_table(:user) do
      add_index :username
      add_index :email
    end
  end
end
