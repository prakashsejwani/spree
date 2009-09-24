class OrdersController < Spree::BaseController 
  prepend_before_filter :reject_unknown_object
  before_filter :prevent_editing_complete_order, :only => [:edit, :update, :checkout]            

  ssl_required :show

  resource_controller
  actions :all, :except => :index

  layout 'application'
  
  helper :products

  create.after do    
    params[:products].each do |product_id,variant_id|
      quantity = params[:quantity].to_i if !params[:quantity].is_a?(Array)
      quantity = params[:quantity][variant_id].to_i if params[:quantity].is_a?(Array)
      @order.add_variant(Variant.find(variant_id), quantity) if quantity > 0
    end if params[:products]
    
    params[:variants].each do |variant_id, quantity|
      quantity = quantity.to_i
      @order.add_variant(Variant.find(variant_id), quantity) if quantity > 0
    end if params[:variants]
    
    @order.save
    
    # store order token in the session
    session[:order_token] = @order.token
  end

  # override the default r_c behavior (remove flash - redirect to edit details instead of show)
  create do
    flash nil 
    wants.html {redirect_to edit_order_url(@order)}
  end     
  
  # override the default r_c flash behavior
  update.flash nil
  update.response do |wants| 
    wants.html {redirect_to edit_order_url(object)}
  end  
  
  #override r_c default b/c we don't want to actually destroy, we just want to clear line items
  def destroy
    flash[:notice] = I18n.t(:basket_successfully_cleared)
    @order.line_items.clear
    @order.update_totals!
    after :destroy
    set_flash :destroy
    response_for :destroy
  end

  destroy.response do |wants|
    wants.html { redirect_to(edit_object_url) } 
  end
  
  def edit
    # Use your own merchant ID and Key, set use_sandbox to false for production
    @gateway = Gateway.find_by_clazz "Google4R::Checkout::Frontend"
    @gw = GatewayConfiguration.find_by_gateway_id(@gateway.id)
	  if @gw.present? && @gw.gateway_option_values[0].value.present? && @gw.gateway_option_values[1].value.present?
		configuration = { :merchant_id =>@gw.gateway_option_values[0].value, :merchant_key => @gw.gateway_option_values[1].value, :use_sandbox => true }
		@frontend = Google4R::Checkout::Frontend.new(configuration)
		@frontend.tax_table_factory = TaxTableFactory.new
		checkout_command = @frontend.create_checkout_command
		# Adding an item to shopping cart
		@order.line_items.each do |l|
		 checkout_command.shopping_cart.create_item do |item|  
			  item.name = l.product.name
			  #puts "==================#{item.name.class}"
			  item.description = l.product.description
			  item.unit_price = Money.new(l.price, "GBP") # $35.00      
			  item.quantity = l.quantity
		   end
		 end
		checkout_command.shopping_cart.private_data = { 'order_number' => @order.id } 
		 checkout_command.edit_cart_url = edit_order_url(@order)
		  checkout_command.continue_shopping_url = products_url
		 #Create a flat rate shipping method
		checkout_command.create_shipping_method(Google4R::Checkout::FlatRateShipping) do |shipping_method|
		 shipping_method.name = "UPS Standard 3 Day"
		  shipping_method.price = Money.new(5000, "GBP")
		  shipping_method.create_allowed_area(Google4R::Checkout::UsCountryArea) do |area|
			area.area = Google4R::Checkout::UsCountryArea::ALL
			#area = 
		  end
		end
				@response = checkout_command.to_xml       #send_to_google_checkout    # 
        # puts "===========#{request.raw_post}"
   end
end

#  def google_checkout_feedback
#     @gateway = Gateway.find_by_clazz "Google4R::Checkout::Frontend"
#    @gw = GatewayConfiguration.find_by_gateway_id(@gateway.id)
#  if @gw.present? && @gw.gateway_option_values[0].value.present? && @gw.gateway_option_values[1].value.present?
#    configuration = { :merchant_id =>@gw.gateway_option_values[0].value, :merchant_key => @gw.gateway_option_values[1].value, :use_sandbox => true }
#    frontend = Google4R::Checkout::Frontend.new(configuration)
#    frontend.tax_table_factory = TaxTableFactory.new
#   handler = frontend.create_notification_handler
#  
#         # puts "====#{new-order-notification}"
#   
#     begin
#       notification = handler.handle(request.raw_post) # raw_post contains the XML
#       # puts "==============#{notification}"
#     rescue Google4R::Checkout::UnknownNotificationType => e
#       # This can happen if Google adds new commands and Google4R has not been
#       # upgraded yet. It is not fatal.
#       render :text => 'ignoring unknown notification type', :status => 200
#       return
#     end
#      notification_acknowledgement = Google4R::Checkout::NotificationAcknowledgement.new.to_xml
#    render :text => notification_acknowledgement, :status => 200
# end
#  end

  def can_access?
    return true unless order = load_object    
    session[:order_token] ||= params[:order_token]
    order.grant_access?(session[:order_token])
  end
    
  private
  def build_object        
    @object ||= find_order
  end
  
  def object 
    return Order.find_by_number(params[:id]) if params[:id]
    find_order
  end   
  
  def prevent_editing_complete_order      
    load_object
    redirect_to object_url if @order.checkout_complete
  end         
end
