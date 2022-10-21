module AttendancesHelper

  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出勤' if attendance.started_at.nil?
      return '退勤' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    return false
  end

  # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
  end

  # 時間外計算を計算して返します。
  def overtime_calculation(finish, end_time, next_day)
    if  next_day == "1"
      format("%.2f", ((finish.hour - end_time.hour) + (finish.min - end_time.min) / 60.0) +24)
    else next_day == "0"
      format("%.2f", (finish.hour - end_time.hour) + (finish.min - end_time.min) / 60.0)
    end
  end

    #残業申請のステータス
    def overwork_status_text(status)
      case status
      when "申請中"
        "申請中"
      when "否認"
        "残業否認済"
      when "承認"
        "残業承認済"
      when "なし"
        "残業なし"
      else
      end
    end
end