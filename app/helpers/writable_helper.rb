module WritableHelper
  def unread_warning
    return unless @replies.present?
    return if @replies.total_pages == page
    'You are not on the latest page of the thread ' + \
    content_tag(:a, '(View unread)', href: unread_path(@post, warn_id: @last_seen_id.to_i), class: 'unread-warning') + ' ' + \
    content_tag(:a, '(New tab)', href: unread_path(@post), class: 'unread-warning', target: '_blank')
  end

  def unread_path(post, **kwargs)
    post_path(post, page: 'unread', anchor: 'unread', **kwargs)
  end
end
