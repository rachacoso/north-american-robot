require "rails_helper"

describe Order do
  # it { is_expected.to validate_numericality_of(:discount).is_less_than_or_equal_to(100).is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:discount).less_than_or_equal_to(100).greater_than_or_equal_to(0).on(:create, :update) }

  it { is_expected.to belong_to(:brand) }
  it { is_expected.to belong_to(:orderer) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to embed_many(:order_items) }
  it { is_expected.to embed_many(:order_additional_charges) }
  it { is_expected.to accept_nested_attributes_for(:order_items) }
  it { is_expected.to accept_nested_attributes_for(:order_additional_charges) }
  it { is_expected.to have_field(:status).with_default_value_of("open") }
  it { is_expected.to have_field(:discount).with_default_value_of(50) }

  it { is_expected.to have_field(:orderer_company_name).of_type(String) }
  it { is_expected.to have_field(:brand_company_name).of_type(String) }
  it { is_expected.to have_field(:submission_date).of_type(DateTime) }
  it { is_expected.to have_field(:pending_date).of_type(DateTime) }
  it { is_expected.to have_field(:completion_date).of_type(DateTime) }

  describe "get_current_order" do
    # let (:order) { FactoryGirl.create(:order, :from_retailer, status: "open") }
    # current_order = Order.
  end

  describe "get_submitted_order" do
  end

  describe "get_pending_order" do
  end


end

describe OrderItem do

  before(:each) do
    brand = FactoryGirl.create(:brand)
    @retailer = FactoryGirl.create(:retailer)
    @product1 = FactoryGirl.create(:product, brand: brand, price: 1000)
    @product2 = FactoryGirl.create(:product, brand: brand)
    order = Order.create(brand: brand, orderer: @retailer)
    @order_item = OrderItem.create(
      order: order,
      quantity: 12,
      product_id: @product1.id,
      price: @product1.price,
      name: @product1.name,
      item_id: @product1.item_id,
      item_size: @product1.item_size
      )
  end

  describe ".get_item" do

    context "with existing order item" do
      it "returns the order item" do
        expect(OrderItem.get_item(product: @product1, orderer: @retailer).product_id).to eq(@product1.id)
      end
    end

    context "with no existing order item" do
      it "returns a new blank order item" do
        expect(OrderItem.get_item(product: @product2, orderer: @retailer).product_id).to be_nil
      end
    end

  end

  describe "#product" do
    it "returns the product" do
      expect(@order_item.product).to eq(@product1)
    end
  end

  describe "#price_in_dollars" do
    context "with price set to 1000 cents" do
      it "returns the price in dollars (10)" do
        expect(@order_item.price_in_dollars).to eq(10)
      end
    end
  end

  describe "#tiered_price_in_dollars" do
    context "with price set to 1000 cents and default tiered discount of 0.5" do
      it "returns the price in dollars ($5) (default 50%)" do
        expect(@order_item.tiered_price_in_dollars).to eq(5)
      end
    end
  end

  describe "#total_price" do
    context "with price set to 1000 cents and default tiered discount of 0.5 and a quantity of 12" do
      it "returns the total price of 60 dollars" do
        expect(@order_item.total_price).to eq(60)
      end
    end
  end

end

