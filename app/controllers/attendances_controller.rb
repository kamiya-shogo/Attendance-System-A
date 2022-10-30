class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month]
  before_action :set_user_id, only: [:update, :edit_overtime_request, :update_overtime_request, :edit_overtime_notice, :update_overtime_notice, :edit_attendances_change_approval, :update_attendances_change_approval, :edit_one_month_approval, :update_one_month_approval, :attendance_log]
  before_action :logged_in_user, only: [:update, :edit_one_month, :attendance_log]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: [:edit_one_month]
  before_action :set_attendance, only: [:update, :edit_overtime_request, :update_overtime_request]

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  def update
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end

  # 勤怠変更申請
  def edit_one_month
    @superiors = User.where(superior: true).where.not(id: @user.id)
      
  end
  
  # 勤怠変更承認
  def update_one_month
    a_count = 0
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      attendances_params.each do |id, item|
        if item[:attendances_request_superior].present?
          if item[:edit_started_at].blank? && item[:edit_finished_at].present?
            flash[:danger] = "出勤時間が必要です。"
            redirect_to attendances_edit_one_month_user_url(date: params[:date])
            return
          elsif item[:edit_started_at].present? && item[:edit_finished_at].blank?
            flash[:danger] = "退勤時間が必要です。"
            redirect_to attendances_edit_one_month_user_url(date: params[:date])
            return
          end
          attendance = Attendance.find(id)
          attendance.attendances_approval_status = "申請中"
          a_count += 1
          attendance.update!(item)
        end
      end
      if a_count > 0
        flash[:success] = "勤怠編集を#{a_count}件、申請しました。"
        redirect_to user_url(date: params[:date])
        return
      else
        flash[:danger] = "上長を選択してください。"
        redirect_to attendances_edit_one_month_user_url(date: params[:date])
        return
      end
    end
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
    return
  end

  # 残業申請のモーダルウィンドウ表示
  def edit_overtime_request
    @superiors = User.where(superior: true).where.not(id: @user.id)
  end

  # 残業申請のモーダルウィンドウ更新
  def update_overtime_request
    if overtime_request_params[:scheduled_end_time].blank? || overtime_request_params[:business_process_content].blank? || overtime_request_params[:overtime_request_superior].blank?
      flash[:success] = "終了予定時間、業務処理内容、または、指示者確認㊞がありません"
    else
      if overtime_request_params[:scheduled_end_time].present? && overtime_request_params[:business_process_content].present? && overtime_request_params[:overtime_request_superior].present?
        params[:attendance][:overtime_request_status] = "申請中"
        @attendance.update(overtime_request_params)
        flash[:success] = "残業申請をしました"
      else
        flash[:danger] = "残業申請が正しくありません"
      end
    end
    redirect_to @user
  end

  # 残業申請のお知らせモーダルウィンドウ表示
  def edit_overtime_notice
    @attendances = Attendance.where(overtime_request_superior: @user.name, overtime_request_status: "申請中").order(:worked_on).group_by(&:user_id)
  end

  # 残業申請のお知らせモーダルウィンドウ更新
  def update_overtime_notice
    overtime_notice_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:overtime_check] == "1"
        if item[:overtime_request_status] == "なし"
          attendance.scheduled_end_time = nil
          attendance.overtime_next_day = nil
          attendance.business_process_content = nil
          attendance.overtime_request_superior = nil
        end
        attendance.update(item)
        flash[:success] = "残業申請を承認しました。"
      else
        flash[:danger] = "残業申請の承認に失敗しました。" 
      end
      redirect_to user_url(@user)
    end
  end

  # 勤怠変更申請のお知らせモーダル表示
  def edit_attendances_change_approval
    @attendances = Attendance.where(attendances_request_superior: @user.name, attendances_approval_status: "申請中").order(:worked_on).group_by(&:user_id)
  end

  # 勤怠変更申請のお知らせモーダル更新
  def update_attendances_change_approval
    a_count = 0
    attendances_approval_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:attendances_approval_check] == "1"
        unless item[:attendances_approval_status] == "申請中" || item[:attendances_approval_status] == "なし" 
          if item[:attendances_approval_status] == "承認"
            attendance.begin_started = attendance.started_at
            attendance.begin_finished = attendance.finished_at
            item[:started_at] =attendance.edit_started_at
            item[:finished_at] =attendance.edit_finished_at
          end
        a_count += 1
        attendance.update(item)
        end
        attendance.update(edit_started_at: nil, edit_finished_at: nil, note: nil, attendances_approval_status: nil, next_day: nil) if item[:attendances_approval_status] == "なし"
      end
    end
    if a_count > 0
      flash[:success] = "勤怠変更の承認に成功しました。"
    else
      flash[:danger] = "勤怠変更の承認に失敗しました。"
    end
    redirect_to user_url(@user)
  end

  # 1ヶ月分の勤怠申請 
  def update_one_month_request
    one_month_request_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:one_month_request_superior].present?
        item[:one_month_request_status] = "申請中"
        if attendance.update(item)
          flash[:success] = "#{attendance.one_month_request_superior}へ1ヶ月の勤怠を申請しました。"
        else
          flash[:danger] = "1ヶ月の勤怠変更に失敗しました。"
        end
      else
        flash[:danger] = "所属長を選択してください。"
      end
    end
    redirect_to user_url(date: params[:date])
  end


  #1ヶ月分の勤怠承認のお知らせモーダル表示
  def edit_one_month_approval
    @attendances = Attendance.where(one_month_request_superior: @user.name, one_month_request_status: "申請中").order(:worked_on).group_by(&:user_id)
  end
  
  #1ヶ月分の勤怠承認のお知らせモーダル更新
  def update_one_month_approval
    one_month_approval_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:one_month_approval_check] == "1"
        if item[:one_month_approval_status] == "なし"
          item[:one_month_approval_status] = nil
          item[:one_month_approval_check] = nil
        end 
        attendance.one_month_request_status = nil
        attendance.update(item)
        flash[:success] = "所属長承認申請の結果を送信しました。"
      else
        flash[:danger] = "承認確認のチェックを入れてください。" 
      end
    end
    redirect_to user_url(@user)
  end

  # 勤怠ログ
  def attendance_log
    #1iは年、2iは月
    if params["worked_on(1i)"].present? && params["worked_on(2i)"].present?
      year_month = "#{params["worked_on(1i)"]}/#{params["worked_on(2i)"]}"
      @day = DateTime.parse(year_month) if year_month.present?
      @attendances = @user.attendances.where(attendances_approval_status: "承認").where(worked_on: @day.all_month)
    else
      @attendances = @user.attendances.where(attendances_approval_status: "").order("worked_on ASC")
    end
  end

  private

    # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :edit_started_at, :edit_finished_at, :note, :next_day, :attendances_request_superior, :attendances_approval_status])[:attendances]
    end
    
    # 残業申請
    def overtime_request_params
      params.require(:attendance).permit([:scheduled_end_time, :overtime_next_day, :business_process_content, :overtime_request_superior, :overtime_request_status])
    end

    # 残業申請承認
    def overtime_notice_params
      params.require(:user).permit(attendances: [:overtime_request_status, :overtime_check])[:attendances]
    end

    # 勤怠変更申請・承認
    def attendances_approval_params
      params.require(:user).permit(attendances: [:attendances_approval_status, :attendances_approval_check])[:attendances]
    end

    # 1ヶ月の勤怠変更申請
    def one_month_request_params
      params.require(:user).permit(attendances: [:one_month_request_superior, :one_month_request_status])[:attendances]
    end

    # 1ヶ月の勤怠変更承認
    def one_month_approval_params
      params.require(:user).permit(attendances: [:one_month_approval_status, :one_month_approval_check])[:attendances]
    end

    def set_attendance
      @attendance = Attendance.find(params[:id])
    end
end