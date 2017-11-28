Rails.application.routes.draw do
  
  devise_for :users
    concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end


  mount Blacklight::Engine => '/'
  root to: "catalog#index"

    get '/catalog/:id/facsimile' => 'catalog#facsimile', as: 'facsimile_catalog'


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'periods' => 'catalog#periods'
  get 'authors' => 'catalog#authors'

end
