class Api::V1::PostsController < Api::ApiController
  resource_description do
    description 'Viewing and editing posts'
  end

  api :GET, '/posts/:id', 'Load a single post as a JSON resource'
  param :id, :number, required: true, desc: "Post ID"
  param :page, :number, required: false, desc: 'Page in results'
  param :per_page, :number, required: false, desc: 'Number of replies to load per page. Defaults to 25, accepts values from 1-100 inclusive.'
  error 403, "Post is not visible to the user"
  error 404, "Post not found"
  example "'errors': [{'message': 'Post could not be found.'}]"
  example "'errors': [{'message': 'You do not have permission to perform this action.'}]"
  example "'data': {
  'id': 1,
  'user': {
    'id': 1,
    'username': 'Marri1'
  },
  'board': {
    'id': 5,
    'name': 'Continuity'
  },
  'section': {
    'id': 6,
    'name': 'Subcontinuity',
    'order': 0
  },
  'subject': 'search',
  'description': 'example json',
  'content': 'Lorem ipsum...',
  'created_at': '2000-01-07T01:02:03Z',
  'edited_at': '2000-01-07T01:03:03Z',
  'tagged_at': '2000-01-08T01:02:03Z',
  'status': 0,
  'character': {
    'id': 3,
    'name': 'Character Example',
    'screenname': 'char-example'
  },
  'icon': null,
  'replies': [{
    'id': 1,
    'content': 'dolor sit amet',
    'created_at': '2000-01-07T01:05:03Z',
    'updated_at': '2000-01-07T01:05:03Z',
    'character': null,
    'icon': null,
    'user': {
      'id': 2,
      'username': 'Marri2'
    }
  }, {
    'id': 2,
    'content': 'consectetur adipiscing elit',
    'created_at': '2000-01-08T01:02:03Z',
    'updated_at': '2000-01-08T01:02:03Z',
    'character': null,
    'icon': {
      'id': 7,
      'url': 'http://www.example.com/image.png',
      'keyword': 'icon'
    },
    'user': {
      'id': 1,
      'username': 'Marri1'
    }
  }],
}"
  def show
    unless post = Post.find_by_id(params[:id])
      error = {message: "Post could not be found."}
      render json: {errors: [error]}, status: :not_found and return
    end

    access_denied and return unless post.visible_to?(current_user)

    replies = paginate(post.replies
      .select('replies.*, characters.name AS name, characters.screenname AS character_screenname, icons.keyword, icons.url, users.username, character_aliases.name as alias')
      .joins(:user)
      .joins("LEFT OUTER JOIN characters ON characters.id = replies.character_id")
      .joins("LEFT OUTER JOIN icons ON icons.id = replies.icon_id")
      .joins("LEFT OUTER JOIN character_aliases ON character_aliases.id = replies.character_alias_id")
      .order('id asc'), per_page: per_page)
    render json: {data: post.as_json(replies: replies)}
  end
end
