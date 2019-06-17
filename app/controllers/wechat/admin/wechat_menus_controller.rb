class Wechat::Admin::WechatMenusController < Wechat::Admin::BaseController
  before_action :set_wechat_config
  before_action :set_wechat_menu, only: [:show, :edit, :edit_parent, :update, :destroy]
  before_action :prepare_form, only: [:new, :create, :edit, :update]
  
  def index
    @wechat_menus = @wechat_config.wechat_menus.order(parent_id: :desc, id: :asc).page(params[:page])
  end

  def new
    @wechat_menu = @wechat_config.wechat_menus.build
  end

  def create
    @wechat_menu = @wechat_config.wechat_menus.build(wechat_menu_params)

    respond_to do |format|
      if @wechat_menu.save
        format.html.phone
        format.html { redirect_to admin_wechat_config_wechat_menus_url(@wechat_config) }
        format.js { redirect_to admin_wechat_config_wechat_menus_url(@wechat_config) }
        format.json { render :show }
      else
        format.html.phone { render :new }
        format.html { render :new }
        format.js { redirect_to admin_wechat_config_wechat_menus_url(@wechat_config) }
        format.json { render :show }
      end
    end
  end
  
  def sync
    r = Wechat.api(@wechat_config.id).menu_create @wechat_config.menu
    redirect_to admin_wechat_config_wechat_menus_url(@wechat_config), notice: r.to_s
  end

  def show
  end

  def edit
  end

  def edit_parent
  end

  def update
    @wechat_menu.assign_attributes(wechat_menu_params)

    respond_to do |format|
      if @wechat_menu.save
        format.html.phone
        format.html { redirect_to admin_wechat_config_wechat_menus_url(@wechat_config) }
        format.js { redirect_to admin_wechat_config_wechat_menus_url(@wechat_config) }
        format.json { render :show }
      else
        format.html.phone { render :edit }
        format.html { render :edit }
        format.js { redirect_to admin_wechat_config_wechat_menus_url(@wechat_config) }
        format.json { render :show }
      end
    end
  end

  def destroy
    @wechat_menu.destroy
    redirect_to admin_wechat_config_wechat_menus_url(@wechat_config)
  end

  private
  def set_wechat_menu
    @wechat_menu = @wechat_config.wechat_menus.find(params[:id])
  end
  
  def prepare_form
    @parents = @wechat_config.wechat_menus.where(type: 'ParentMenu', parent_id: nil)
  end

  def wechat_menu_params
    params.fetch(:wechat_menu, {}).permit(
      :parent_id,
      :type,
      :name,
      :value,
      :appid,
      :pagepath
    )
  end

end
