require 'rails_helper'

def setup_knock(user)
  request.headers['authorization'] = 'Bearer JWTTOKEN'
  knock = double('Knock')
  allow(knock).to receive(:entity_for).and_return(user)
  allow(Knock::AuthToken).to receive(:new).and_return(knock)
end

RSpec.describe FactCategoriesController, type: :controller do
  # We only test create as authentication guidelines are the same for create, update, & destroy.
  describe 'POST create' do
    let (:organization) { FactoryBot.create(:organization) }
    let (:name) { 'name' }

    let (:creating_user) { nil }
    before do
      setup_knock(creating_user) if creating_user.present?
      post :create, params: {fact_category: {name: name}, organization_id: organization.id}
    end

    context 'for a logged out creator' do
      let (:creating_user) { nil }
      it { is_expected.to respond_with :unauthorized }
    end

    context 'for a logged in, non-member creator' do
      let (:creating_user) { FactoryBot.create(:user) }
      it { is_expected.to respond_with :unauthorized }
    end

    context 'for a logged in, member creator' do
      let (:creating_user) {
        user = FactoryBot.create(:user)
        FactoryBot.create(:user_organization_membership, user: user, organization: organization)
        user
      }
      it 'should successfully create the fact category' do
        expect(subject).to respond_with :ok
        expect(JSON.parse(response.body)['name']).to eq name
      end
    end
  end
end
