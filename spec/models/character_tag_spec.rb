require "spec_helper"

RSpec.describe CharacterTag do
  describe "callbacks" do
    context "when gallery group added" do
      it "does not add other users' galleries" do
        group = create(:gallery_group)
        gallery = create(:gallery, gallery_groups: [group])

        character = create(:character)
        character.gallery_groups << group
        character.save
        expect(character.reload.galleries).to match_array([])
      end

      it "does not add a gallery twice" do
        # tests a manually-attached gallery1
        # and a double-grouped gallery2
        group = create(:gallery_group)
        group2 = create(:gallery_group)
        user = create(:user)
        gallery1 = create(:gallery, user: user, gallery_groups: [group])
        gallery2 = create(:gallery, user: user, gallery_groups: [group, group2])

        character = create(:character, user: user, galleries: [gallery1])
        character.gallery_groups << group
        character.save
        character.reload
        expect(character.galleries).to match_array([gallery1, gallery2])
        expect(character.characters_galleries.find_by(gallery_id: gallery1.id)).not_to be_added_by_group
        expect(character.characters_galleries.find_by(gallery_id: gallery2.id)).to be_added_by_group

        character.gallery_groups << group2
        character.save
        character.reload
        expect(character.galleries).to match_array([gallery1, gallery2])
        expect(character.characters_galleries.find_by(gallery_id: gallery1.id)).not_to be_added_by_group
        expect(character.characters_galleries.find_by(gallery_id: gallery2.id)).to be_added_by_group
      end

      it "adds galleries from given group" do
        group = create(:gallery_group)
        user = create(:user)
        gallery1 = create(:gallery, user: user, gallery_groups: [group])
        gallery2 = create(:gallery, user: user, gallery_groups: [group])

        character = create(:character, user: user)
        character.gallery_groups << group
        character.save
        character.reload
        expect(character.galleries).to match_array([gallery1, gallery2])
        expect(character.characters_galleries.map(&:added_by_group?)).to eq([true, true])
      end

      it "does right things when gallery group removed" do
        # does not touch unrelated galleries
        # does not touch galleries that have been otherwise tethered
        # removes galleries that are not otherwise tethered
        group = create(:gallery_group)
        user = create(:user)
        other_gallery = create(:gallery, user: user)
        character = create(:character, user: user, gallery_groups: [group], galleries: [other_gallery])
        gallery_auto = create(:gallery, user: user, gallery_groups: [group])
        gallery_both = create(:gallery, user: user, gallery_groups: [group])
        character.reload
        character.characters_galleries.find_by(gallery_id: gallery_both.id).update_attributes(added_by_group: false)
        expect(character.galleries).to match_array([other_gallery, gallery_auto, gallery_both])
        expect(character.characters_galleries.find_by(gallery_id: gallery_auto.id)).to be_added_by_group

        character.update_attributes(gallery_groups: [])
        character.reload
        expect(character.galleries).to match_array([other_gallery, gallery_both])
        expect(character.characters_galleries.find_by(gallery_id: gallery_both.id)).not_to be_added_by_group
      end
    end
  end
end