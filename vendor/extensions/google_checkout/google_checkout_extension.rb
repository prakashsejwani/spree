# Uncomment this if you reference any of your controllers in activate
 require_dependency 'application'

class GoogleCheckoutExtension < Spree::Extension
  version "1.0"
  description "Provides google checkout payment gateway functionality.  User specifies an GoogleCheckout compatible gateway 
  to use in the aplication."
  #url "http://yourwebsite.com/google_checkout"

  # Please use google_checkout/config/routes.rb instead for extension routes.

  # def self.require_gems(config)
  #   config.gem "gemname-goes-here", :version => '1.2.3'
  # end
  
  def activate

    # Add your extension tab to the admin.
    # Requires that you have defined an admin controller:
    # app/controllers/admin/yourextension_controller
    # and that you mapped your admin in config/routes

    #Admin::BaseController.class_eval do
    #  before_filter :add_yourextension_tab
    #
    #  def add_yourextension_tab
    #    # add_extension_admin_tab takes an array containing the same arguments expected
    #    # by the tab helper method:
    #    #   [ :extension_name, { :label => "Your Extension", :route => "/some/non/standard/route" } ]
    #    add_extension_admin_tab [ :yourextension ]
    #  end
    #end

    # make your helper avaliable in all views
    # Spree::BaseController.class_eval do
    #   helper YourHelper
    # end
    
    Admin::OrdersController.class_eval do
      
    def charge_google_order
      @gateway = Gateway.find_by_clazz "Google4R::Checkout::Frontend"
      @gw = GatewayConfiguration.find_by_gateway_id(@gateway.id)
      if @gw.present? && @gw.gateway_option_values[0].value.present? && @gw.gateway_option_values[1].value.present?
      configuration = { :merchant_id =>@gw.gateway_option_values[0].value, :merchant_key => @gw.gateway_option_values[1].value, :use_sandbox => true }
      @frontend = Google4R::Checkout::Frontend.new(configuration)
        order = @frontend.create_charge_order_command
         o = Order.find_by_number(params[:id])
        order.google_order_number = o.google_order_number if o.google_order_number.present? 
        order.amount = Money.new(5017, "GBP")
         puts "=-=-=-=-=-_+_+_+-#{order.to_xml}"
        @orders = order.send_to_google_checkout
        flash[:notice] = t('charged_google_checkout_order')
        redirect_to :back
      end
    end
  
    def cancel_google_checkout_order
     @gateway = Gateway.find_by_clazz "Google4R::Checkout::Frontend"
      @gw = GatewayConfiguration.find_by_gateway_id(@gateway.id)
      if @gw.present? && @gw.gateway_option_values[0].value.present? && @gw.gateway_option_values[1].value.present?
      configuration = { :merchant_id =>@gw.gateway_option_values[0].value, :merchant_key => @gw.gateway_option_values[1].value, :use_sandbox => true }
      @frontend = Google4R::Checkout::Frontend.new(configuration)
        order = @frontend.create_cancel_order_command
         o = Order.find_by_number(params[:id])
        order.google_order_number = o.google_order_number if o.google_order_number.present? 
        order.reason = params[:reason]
        order.comment = params[:comment]
        @orders = order.send_to_google_checkout
        #puts "=-=-=-=-=-_+_+_+-#{@orders}"
      end
    end
  
  end
    
    
    OrdersController.class_eval do
      
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
          item.description = l.product.description
          item.unit_price = Money.new(l.price, "GBP")    
          item.quantity = l.quantity
         end
       end
      checkout_command.shopping_cart.private_data = { 'order_number' => @order.id } 
       checkout_command.edit_cart_url = edit_order_url(@order)
        checkout_command.continue_shopping_url = order_url(@order)
       #Create a flat rate shipping method
          i = 50
        ShippingMethod.all.each do |ship_method| 
       
        checkout_command.create_shipping_method(Google4R::Checkout::FlatRateShipping) do |shipping_method|    
         shipping_method.name = ship_method.name #"UPS Standard 3 Day"
      shipping_method.price = Money.new(i, "GBP")#Money.new(5000, "GBP")   
         shipping_method.create_allowed_area(Google4R::Checkout::UsCountryArea) do |area|
          area.area = Google4R::Checkout::UsCountryArea::ALL
        end 
         i += 50
        end
        
       end 
            @response = checkout_command.to_xml       #send_to_google_checkout    # 
      # puts "===========#{request.raw_post}"
         end
     end
     
     show.before do
       session[:order_id] = nil
     end
    end
    
  end
  
  
end
