# config/routes.rb
Rails.application.routes.draw do
  resources :projects, only: [] do
    member do
      get  'refresh_sheet/confirm', to: 'refresh_sheet#confirm',  as: 'refresh_sheet_confirm'
      get  'refresh_sheet/execute', to: 'refresh_sheet#execute',  as: 'refresh_sheet_execute'
    end
  end
end
