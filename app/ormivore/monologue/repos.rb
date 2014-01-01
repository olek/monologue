module Monologue
  module Repos
    def repos
      @repos = {
        post: Post::Repo.new(Post::StoragePort.new(Post::StorageArAdapter.new), Post::Entity),
        tag: Tag::Repo.new(Tag::StoragePort.new(Tag::StorageArAdapter.new), Tag::Entity),
        user: User::Repo.new(User::StoragePort.new(User::StorageArAdapter.new), User::Entity)
      }
    end
  end
end
