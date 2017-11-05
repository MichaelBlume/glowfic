# frozen_string_literal: true
class TagsController < ApplicationController
  before_action :login_required, except: [:index, :show]
  before_action :find_tag, except: :index
  before_action :permission_required, except: [:index, :show]

  def index
    @page_title = "Tags"
    @tags = Tag.where.not(type: 'GalleryGroup').order('type desc, LOWER(name) asc').select('tags.*').with_item_counts.paginate(per_page: 25, page: page)
  end

  def show
    @posts = posts_from_relation(@tag.posts)
    @characters = @tag.characters.includes(:user)
    @galleries = @tag.galleries.with_icon_count.order('name asc')
    @page_title = @tag.name.to_s
    use_javascript('galleries/expander') if @tag.is_a?(GalleryGroup)
  end

  def edit
    @page_title = "Edit Tag: #{@tag.name}"
    build_editor
  end

  def update
    unless @tag.update_attributes(tag_params)
      flash.now[:error] = {}
      flash.now[:error][:message] = "Tag could not be saved because of the following problems:"
      flash.now[:error][:array] = @tag.errors.full_messages
      @page_title = "Edit Tag: #{@tag.name}"
      build_editor
      render action: :edit and return
    end

    flash[:success] = "Tag saved!"
    redirect_to tag_path(@tag)
  end

  def destroy
    @tag.destroy
    flash[:success] = "Tag deleted."
    redirect_to tags_path
  end

  private

  def find_tag
    unless (@tag = Tag.find_by_id(params[:id]))
      flash[:error] = "Tag could not be found."
      redirect_to tags_path
    end
  end

  def permission_required
    unless @tag.editable_by?(current_user)
      flash[:error] = "You do not have permission to edit this tag."
      redirect_to tag_path(@tag)
    end
  end

  def build_editor
    # n.b. this method is unsafe for unpersisted tags (in case we ever add tags#new)
    return unless @tag.is_a?(Setting)
    @canons = @tag.canons.order('tag_tags.id asc') || []
    use_javascript('tags/edit')
  end

  def tag_params
    permitted = [:type, :description, canon_ids: []]
    permitted.insert(0, :name) if current_user.admin?
    params.fetch(:tag, {}).permit(permitted)
  end
end
