Sequel.migration do
  change do
    create_table(:follower) do
      Integer :who_id
      Integer :whom_id
    end

    create_table(:message) do
      primary_key :message_id
      Integer :author_id, null: false
      String :text, null: false
      Integer :pub_date
      Integer :flagged
    end

    create_table(:user) do
      primary_key :user_id
      String :username, null: false
      String :email, null: false
      String :pw_hash, null: false
    end
  end
end
