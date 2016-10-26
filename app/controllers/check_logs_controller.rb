class CheckLogsController < ApplicationController
  def index
    @check_logs = CheckLog.order(created_at: :desc)
  end

  def show
    @check_log = CheckLog.find(params[:id])
  end
end
