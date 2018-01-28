Rails.application.routes.draw do

  get 'meetup/' => 'meetup_groups#index', as: :meetup
  get 'meetup/:group_id' => 'meetup_groups#show', as: :meetup_group
  get 'meetup/:group_id/:event_id' => 'meetup_events#show', as: :meetup_event

  scope path: 'meetup/:group_id/:event_id' do
    resource :generated_document, only: [:create, :show]
  end

  root 'previews#show'
end
