module PagesHelper

  def nested_feeds(feeds)
    feeds.map do |post, sub_posts|
      render(feed_item) + content_tag(:li, nested_feeds(sub_posts))
    end.join.html_safe
  end

end
