module Monologue
  module Repos
    extend ORMivore::RepoFamily
  end
  Post::Repo.new(Post::StoragePort.new(Post::StorageArAdapter.new), family: Repos)
  User::Repo.new(User::StoragePort.new(User::StorageArAdapter.new), family: Repos)
  Tag::Repo.new(Tag::StoragePort.new(Tag::StorageArAdapter.new), family: Repos)
  Tagging::Repo.new(Tagging::StoragePort.new(Tagging::StorageArAdapter.new), family: Repos)
  Repos.freeze
end
