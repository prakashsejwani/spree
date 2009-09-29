class Admin::OrdersController < Admin::BaseController
  require 'spree/gateway_error'
  resource_controller
  before_filter :initialize_txn_partials
  before_filter :initialize_order_events
  before_filter :load_object, :only => [:fire, :resend]

  in_place_edit_for :user, :email

  def fire   
    # TODO - possible security check here but right now any admin can before any transition (and the state machine 
    # itself will make sure transitions are not applied in the wrong state)
    event = params[:e]
    Order.transaction do 
      @order.send("#{event}!")
    end
    flash[:notice] = t('order_updated')
  rescue Spree::GatewayError => ge
    flash[:error] = "#{ge.message}"
  ensure
    redirect_to :back
  end
  
  def resend
    OrderMailer.deliver_confirm(@order, true)
    flash[:notice] = t('order_email_resent')
    redirect_to :back
  end
  
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
     
    end
  end
  
  private

  def collection
   
    @charge = '<?xml version="1.0" encoding="UTF-8"?><charge-order xmlns="http://checkout.google.com/schema/2" google-order-number= #{order.google_order_number}></charge-order>'
      #request_http_basic_authentication Base64.b64encode('114190407551986:15DT8YcdHi_4Ns3_tefnxA')
 
    @search = Order.search(params[:search])
    @search.order ||= "descend_by_created_at"

    # QUERY - get per_page from form ever???  maybe push into model
    # @search.per_page ||= Spree::Config[:orders_per_page]

    # turn on show-complete filter by default
    unless params[:search] && params[:search][:checkout_completed_at_not_null]
      @search.checkout_completed_at_not_null = true 
    end
    
    @collection = @search.paginate(:include  => [:user, :shipments, {:creditcard_payments => {:creditcard => :address}}],
                                   :per_page => Spree::Config[:orders_per_page], 
                                   :page     => params[:page])
  end

  # Allows extensions to add new forms of payment to provide their own display of transactions
  def initialize_txn_partials
    @txn_partials = []
  end
  
  # Used for extensions which need to provide their own custom event links on the order details view.
  def initialize_order_events
    @order_events = %w{cancel resume}
  end
  
  

end
