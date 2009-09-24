class GoogleCheckoutInGateways < ActiveRecord::Migration
  def self.up
    # create google checkout in gateways table
	merchant_id  = GatewayOption.create(:name => "merchant_id",
                                   :description => "Your merchant id")
    merchant_key   = GatewayOption.create(:name => "merchant_key",
                                    :description => "Your merchant key")
    gateway = Gateway.create(:name => "Google checkout",
                             :clazz => "Google4R::Checkout::Frontend",
                             :description => "Google's Checkout Gateway",
                             :gateway_options => [merchant_id, merchant_key])
  end

  def self.down
  end
end
