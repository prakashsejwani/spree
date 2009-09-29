class Admin::GoogleCheckoutsController < ApplicationController

  layout 'admin'
  def google_checkout_process
   @gateway = Gateway.find_by_clazz "Google4R::Checkout::Frontend"
    @gw = GatewayConfiguration.find_by_gateway_id(@gateway.id)
    if @gw.present? && @gw.gateway_option_values[0].value.present? && @gw.gateway_option_values[1].value.present?
    configuration = { :merchant_id =>@gw.gateway_option_values[0].value, :merchant_key => @gw.gateway_option_values[1].value, :use_sandbox => true }
    @frontend = Google4R::Checkout::Frontend.new(configuration)
      order = @frontend.create_cancel_order_command
       o = Order.find_by_number(params[:order])
      order.google_order_number = o.google_order_number if o.google_order_number.present? 
      order.reason = "Buyer cancelled the order."
      order.comment = "Buyer ordered another item."
      @orders = order.send_to_google_checkout
      puts "=-=-=-=-=-_+_+_+-#{@orders}"
    end
  end
end
