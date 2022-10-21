class UsersController < ApplicationController
  before_action :set_user, only: [:show, :show_confirmation, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info]
  before_action :admin_impossible, only: :show
  before_action :set_one_month, only: [:show, :show_confirmation]
  

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @superiors = User.where(superior: true).where.not(id: @user.id)
    @worked_sum = @attendances.where.not(started_at: nil).count
    @overtime_sum = Attendance.where(overtime_request_superior: @user.name, overtime_request_status: "申請中").count
    @attendances_sum = Attendance.where(attendances_request_superior: @user.name, attendances_approval_status: "申請中").count
    @one_month_approval_sum = Attendance.where(one_month_request_superior: @user.name, one_month_request_status: "申請中").count
  end

  def show_confirmation
    @worked_sum = @attendances.where.not(started_at: nil).count
    @overtime_sum = Attendance.where(overtime_request_superior: @user.name, overtime_request_status: "申請中").count
    @attendances_sum = Attendance.where(attendances_request_superior: @user.name, attendances_approval_status: "申請中").count
    @one_month_approval_sum = Attendance.where(one_month_request_superior: @user.name, one_month_request_status: "申請中").count
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "#{@user.name}の情報を更新しました。"
      redirect_to users_url
    else
      flash[:danger] = "#{@user.name}の情報を更新できませんでした。"
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  def edit_basic_info
  end

  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end

  def import
    if params[:file].blank?
      flash[:danger] = "CSVファイルが選択されていません。"
    redirect_to users_url
    else
      if User.import(params[:file])
        flash[:success] = "CSVファイルのインポートに成功しました。"
      else
        flash[:danger] = "CSVファイルのインポートに失敗しました。"
      end
      redirect_to users_url
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid,
                                  :password, :password_confirmation, :basic_work_time,
                                  :designated_work_start_time, :designated_work_end_time)
    end

    def basic_info_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid,
                                  :password, :password_confirmation, :basic_work_time,
                                  :designated_work_start_time, :designated_work_end_time)
    end


    # 取得できるものは以下と同じ @user = User.find(params[:id])
    # @user = User.find(params[:attendance][:user_id])
    # @attendance = @user.attendances.find(params[:attendance][:id])
end