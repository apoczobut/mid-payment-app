# frozen_string_literal: true

Rails.application.routes.draw do
  post 'api/purchase', to: 'payments#create'
  post 'customer/returns', to: 'payments#return'
end
