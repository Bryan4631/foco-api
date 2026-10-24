Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post   "auth/register", to: "auth#register"
      post   "auth/login",    to: "auth#login"
      delete "auth/logout",   to: "auth#logout"
      get    "me",            to: "auth#me"

      resources :areas,   except: %i[new edit]
      resources :tareas,  except: %i[new edit]
      resources :bloques, except: %i[new edit]
    end
  end
end
