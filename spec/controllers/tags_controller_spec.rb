require "spec_helper"

RSpec.describe TagsController do
  describe "GET index" do
    context "with views" do
      render_views
      def create_tags
        # set up sample tags, empty and not
        empty_tag = create(:label)
        tag = create(:label)
        create(:post, labels: [tag])

        empty_group = create(:gallery_group)
        group1 = create(:gallery_group)
        create(:gallery, gallery_groups: [group1])

        group2 = create(:gallery_group)
        create(:gallery, gallery_groups: [group2])
        create(:character, gallery_groups: [group2])

        group3 = create(:gallery_group)
        create(:character, gallery_groups: [group3])
        [empty_tag, tag, empty_group, group1, group2, group3]
      end

      it "succeeds when logged out" do
        tags = create_tags
        get :index
        expect(response.status).to eq(200)
        tags.reject! { |tag| tag.is_a?(GalleryGroup) }
        expect(assigns(:tags)).to match_array(tags)
      end

      it "succeeds when logged in" do
        tags = create_tags
        login
        get :index
        expect(response.status).to eq(200)
        tags.reject! { |tag| tag.is_a?(GalleryGroup) }
        expect(assigns(:tags)).to match_array(tags)
      end
    end
  end

  describe "GET show" do
    it "requires valid tag" do
      get :show, params: { id: -1 }
      expect(response).to redirect_to(tags_url)
      expect(flash[:error]).to eq("Tag could not be found.")
    end

    context "with views" do
      render_views
      it "succeeds with valid post tag" do
        tag = create(:label)
        post = create(:post, labels: [tag])
        get :show, params: { id: tag.id }
        expect(response.status).to eq(200)
        expect(assigns(:posts)).to match_array([post])
      end

      it "succeeds for logged in users with valid post tag" do
        tag = create(:setting)
        post = create(:post, settings: [tag])
        login
        get :show, params: { id: tag.id }
        expect(response.status).to eq(200)
        expect(assigns(:posts)).to match_array([post])
      end

      it 'succeeds for canons with settings' do
        tag = create(:canon)
        tag.settings << create(:setting)
        get :show, params: { id: tag.id }
        expect(response).to have_http_status(200)
      end

      it "succeeds with valid gallery tag" do
        group = create(:gallery_group)
        gallery = create(:gallery, gallery_groups: [group])
        get :show, params: { id: group.id }
        expect(response.status).to eq(200)
        expect(assigns(:galleries)).to match_array([gallery])
      end

      it "succeeds for logged in users with valid gallery tag" do
        group = create(:gallery_group)
        gallery = create(:gallery, gallery_groups: [group])
        login
        get :show, params: { id: group.id }
        expect(response.status).to eq(200)
        expect(assigns(:galleries)).to match_array([gallery])
      end

      it "succeeds with valid character tag" do
        group = create(:gallery_group)
        character = create(:character, gallery_groups: [group])
        get :show, params: { id: group.id }
        expect(response.status).to eq(200)
        expect(assigns(:characters)).to match_array([character])
      end

      it "succeeds for logged in users with valid character tag" do
        group = create(:gallery_group)
        character = create(:character, gallery_groups: [group])
        login
        get :show, params: { id: group.id }
        expect(response.status).to eq(200)
        expect(assigns(:characters)).to match_array([character])
      end
    end
  end

  describe "GET edit" do
    it "requires login" do
      get :edit, params: { id: -1 }
      expect(response).to redirect_to(root_url)
      expect(flash[:error]).to eq("You must be logged in to view that page.")
    end

    it "requires valid tag" do
      login
      get :edit, params: { id: -1 }
      expect(response).to redirect_to(tags_url)
      expect(flash[:error]).to eq("Tag could not be found.")
    end

    it "requires permission" do
      tag = create(:label)
      login
      get :edit, params: { id: tag.id }
      expect(response).to redirect_to(tag_url(tag))
      expect(flash[:error]).to eq("You do not have permission to edit this tag.")
    end

    it "allows admin to edit the tag" do
      tag = create(:label)
      login_as(create(:admin_user))
      get :edit, params: { id: tag.id }
      expect(response.status).to eq(200)
    end
  end

  describe "PUT update" do
    it "requires login" do
      put :update, params: { id: -1 }
      expect(response).to redirect_to(root_url)
      expect(flash[:error]).to eq("You must be logged in to view that page.")
    end

    it "requires valid tag" do
      login
      put :update, params: { id: -1 }
      expect(response).to redirect_to(tags_url)
      expect(flash[:error]).to eq("Tag could not be found.")
    end

    it "requires permission" do
      login
      tag = create(:label)
      put :update, params: { id: tag.id }
      expect(response).to redirect_to(tag_url(tag))
      expect(flash[:error]).to eq("You do not have permission to edit this tag.")
    end

    it "requires valid params" do
      tag = create(:label)
      login_as(create(:admin_user))
      put :update, params: { id: tag.id, tag: {name: nil} }
      expect(response.status).to eq(200)
      expect(flash[:error][:message]).to eq("Tag could not be saved because of the following problems:")
    end

    it "allows admin to update the tag" do
      tag = create(:label)
      name = tag.name + 'Edited'
      login_as(create(:admin_user))
      put :update, params: { id: tag.id, tag: {name: name} }
      expect(response).to redirect_to(tag_url(tag))
      expect(flash[:success]).to eq("Tag saved!")
      expect(tag.reload.name).to eq(name)
    end
  end

  describe "DELETE destroy" do
    it "requires login" do
      delete :destroy, params: { id: -1 }
      expect(response).to redirect_to(root_url)
      expect(flash[:error]).to eq("You must be logged in to view that page.")
    end

    it "requires valid tag" do
      login
      delete :destroy, params: { id: -1 }
      expect(response).to redirect_to(tags_url)
      expect(flash[:error]).to eq("Tag could not be found.")
    end

    it "requires permission" do
      tag = create(:label)
      login
      delete :destroy, params: { id: tag.id }
      expect(response).to redirect_to(tag_url(tag))
      expect(flash[:error]).to eq("You do not have permission to edit this tag.")
    end

    it "allows admin to destroy the tag" do
      tag = create(:label)
      login_as(create(:admin_user))
      delete :destroy, params: { id: tag.id }
      expect(response).to redirect_to(tags_path)
      expect(flash[:success]).to eq("Tag deleted.")
    end
  end
end
