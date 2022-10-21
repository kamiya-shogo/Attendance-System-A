class AddColumnsToAttendances < ActiveRecord::Migration[5.1]
  def change

     # 勤怠申請
     add_column :attendances, :attendances_request_superior, :string
     add_column :attendances, :attendances_approval_status, :string
     add_column :attendances, :attendances_approval_check, :boolean, default: false
     add_column :attendances, :edit_started_at, :datetime
     add_column :attendances, :edit_finished_at, :datetime

     # 残業申請
     add_column :attendances, :scheduled_end_time, :datetime
     add_column :attendances, :next_day, :boolean, default: false
     add_column :attendances, :overtime_next_day, :boolean, default: false
     add_column :attendances, :business_process_content, :string
     add_column :attendances, :overtime_request_superior, :string
     add_column :attendances, :overtime_request_status, :string
     add_column :attendances, :overtime_check, :boolean, default: false

    # 1ヶ月の勤怠申請・承認
    add_column :attendances, :one_month_request_superior, :string
    add_column :attendances, :one_month_request_status, :string
    add_column :attendances, :one_month_approval_status, :string
    add_column :attendances, :one_month_approval_check, :boolean, default: false
  end
end
