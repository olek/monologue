module Monologue
  class ApplicationController < ApplicationController

    layout Monologue.layout if Monologue.layout # TODO: find a way to test that. It was asked in issue #54 (https://github.com/jipiboily/monologue/issues/54)

    before_filter :recent_posts, :all_tags

    def storage_session
      @storage_session ||= ORMivore::Session.new(Repos, Associations)
    end

    def recent_posts
      @recent_posts = storage_session.repo.post.find_all_recent.map { |p| Post::ViewAdapter.new(p) }
    end

    def all_tags
      all_tags = storage_session.repo.tag.find_all
      frequencies_map = storage_session.repo.post.count_published_by_tags(all_tags)

      @tags = all_tags
        .reject { |t| frequencies_map[t.identity].nil? }
        .map { |t| Tag::ViewAdapter.new(t).tap { |va| va.frequency = frequencies_map[t.identity] } }

      #could use minmax here but it's only supported with ruby > 1.9'
      frequencies = frequencies_map.values
      @tags_frequency_min = frequencies.min
      @tags_frequency_max = frequencies.max
    end

    def not_found
      # fallback to the default 404.html page from main_app.
      file = Rails.root.join('public', '404.html')
      if file.exist?
        render file: file.cleanpath.to_s.gsub(%r{#{file.extname}$}, ''),
           layout: false, status: 404, formats: [:html]
      else
        render action: "404", status: 404, formats: [:html]
      end
    end

    private

      def monologue_current_user
        if session[:monologue_user_id]
          @monologue_current_user ||=
            Monologue::User::ViewAdapter.new(
              storage_session.repo.user.find_by_id(session[:monologue_user_id])
            )
        end
      end

      def monologue_page_cache_enabled?
        monologue_current_user.nil? && Monologue::PageCache.enabled
      end

    helper_method :monologue_current_user, :monologue_page_cache_enabled?
  end
end
