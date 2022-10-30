Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :bases

  resources :users do
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month' # この行が追加対象です。
      patch 'attendances/update_one_month' # この行が追加対象です。
      # 1ヶ月の勤怠申請
      patch 'attendances/update_one_month_request'
      # 勤怠を確認する
      get 'show_confirmation'

      # 出勤社員 
      get 'list_of_employees'  
    end
    collection { post :import }
    resources :attendances, only: :update do 
      member do
        # 残業申請
        get 'edit_overtime_request'
        patch 'update_overtime_request'
        # 残業承認
        get 'edit_overtime_notice'
        patch 'update_overtime_notice'
        # 勤怠承認
        get 'edit_attendances_change_approval'
        patch 'update_attendances_change_approval'
        # 1ヶ月の勤怠承認
        get 'edit_one_month_approval'
        patch 'update_one_month_approval'
        # 勤怠ログ
        get 'attendance_log'
      end
    end
  end
end