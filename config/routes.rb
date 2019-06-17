Rails.application.routes.draw do

  scope module: :wechat do
    resources :wechats, only: [:show, :update] do
      post '' => :create, on: :member
    end
  end

  scope :my, module: 'wechat/my', as: :my do
  end

  scope :admin, module: 'wechat/admin', as: 'admin' do
    resources :wechat_configs do
      get 'help' => :edit_help, on: :member
      get :info, on: :member
      resources :wechat_menus do
        collection do
          get :new_parent
          post :sync
        end
        get :edit_parent, on: :member
      end
      resources :wechat_responses do
        post :sync, on: :member
      end
      resources :wechat_feedbacks, except: [:new, :create]
    end
    resources :extractors
  end

end
