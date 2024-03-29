class BasesController < ApplicationController
  before_action :set_base, only: %i(edit update destroy)
  before_action :admin_user

  def index
    @bases = Base.all.order(id: "DESC")
    @base = Base.new
  end

  def create    
    @base = Base.new(base_params)
    if @base.save     
      flash[:success] = '拠点を追加しました。'
      redirect_to bases_url
    else
      flash[:danger] = '拠点情報を追加できませんでした。'
      @bases = Base.all
      render :index
    end
  end

  def edit
  end

  def update    
    if @base.update_attributes(base_params)
      flash[:success] = "拠点の修正をしました。"
      redirect_to bases_url      
    else
      render :edit
    end
  end

  def destroy    
    @base.destroy
    flash[:success] = "#{@base.base_name}を削除しました。"
    redirect_to bases_url
  end
  private

    def base_params
      params.require(:base).permit(:base_number, :base_name, :base_type)
    end

    def set_base
      @base = Base.find(params[:id])
    end
end
