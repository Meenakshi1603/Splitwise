# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  resources :groups do
    resources :expenses
  end
  root to: 'home#index'
  get 'part_of', to: 'groups#part_of'
  get 'profile', to: 'users#profile', as: 'user_profile'


end
