require 'rails_helper'
require 'spec_helper'

def setup_knock(user)
  request.headers['authorization'] = 'Bearer JWTTOKEN'
  knock = double("Knock")
  allow(knock).to receive(:entity_for).and_return(user)
  allow(Knock::AuthToken).to receive(:new).and_return(knock)
end

RSpec.describe UserOrganizationMembershipsController, type: :controller do
  describe 'DELETE destroy' do
    let (:membership) { FactoryBot.create(:user_organization_membership) }
    let (:requesting_user) { nil }
    before do
      requesting_user && setup_knock(requesting_user)
      delete :destroy, params: { id: membership.id }
    end

    shared_examples 'delete failed' do
      it { is_expected.to respond_with :unauthorized }
      it 'should not have deleted the membership' do
        expect(UserOrganizationMembership.find(membership.id)).to eq membership
      end
    end

    context 'for logged out requester' do
      include_examples 'delete failed'
    end

    context 'for admin requester' do
      let (:requesting_user) {
        user = FactoryBot.create(:user)
        organization = membership.organization
        FactoryBot.create(:user_organization_membership, user: user, organization: organization)
        organization.update(admin: user)
        user
      }

      it { is_expected.to respond_with :no_content }
      it 'should have deleted the membership' do
        expect { UserOrganizationMembership.find(membership.id) }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    context 'for member (but not admin)' do
      let (:requesting_user) {
        user = FactoryBot.create(:user)
        organization = membership.organization
        FactoryBot.create(:user_organization_membership, user: user, organization: organization)
        user
      }
      include_examples 'delete failed'
    end

    context 'when not member' do
      let (:requesting_user) { FactoryBot.create(:user) }
      include_examples 'delete failed'
    end
  end
end
