require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe 'relationships' do
    it { should belong_to(:invoice) }
    it { should have_many(:transactions).through(:invoice)}
    it { should belong_to(:item) }
    it { should have_many(:merchants).through(:item) }
    it { should have_many(:discounts).through(:merchants) }
  end

  describe 'validations' do
    it { should validate_presence_of(:status) }
  end

  describe 'class methods' do
    it '#incomplete_inv shows invoices that are incomplete' do
      @m1 = Merchant.create!(name: 'Merchant 1')
      @c1 = Customer.create!(first_name: 'Bilbo', last_name: 'Baggins')
      @c2 = Customer.create!(first_name: 'Frodo', last_name: 'Baggins')
      @c3 = Customer.create!(first_name: 'Samwise', last_name: 'Gamgee')

      @item_1 = Item.create!(name: 'Shampoo', description: 'This washes your hair', unit_price: 10, merchant_id: @m1.id)
      @item_2 = Item.create!(name: 'Conditioner', description: 'This makes your hair shiny', unit_price: 8, merchant_id: @m1.id)
      @item_3 = Item.create!(name: 'Brush', description: 'This takes out tangles', unit_price: 5, merchant_id: @m1.id)

      @i1 = Invoice.create!(customer_id: @c1.id, status: 2)
      @i2 = Invoice.create!(customer_id: @c1.id, status: 2)
      @i3 = Invoice.create!(customer_id: @c2.id, status: 2)
      @i4 = Invoice.create!(customer_id: @c3.id, status: 2)

      @ii_1 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 0,
                                  created_at: Time.parse('2012-03-27 14:54:09 UTC'))
      @ii_2 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_2.id, quantity: 1, unit_price: 8, status: 0,
                                  created_at: Time.parse('2013-03-27 14:54:09 UTC'))
      @ii_3 = InvoiceItem.create!(invoice_id: @i2.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 2,
                                  created_at: Time.parse('2012-03-27 14:54:09 UTC'))
      @ii_4 = InvoiceItem.create!(invoice_id: @i3.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 1,
                                  created_at: Time.parse('2011-03-27 14:54:09 UTC'))

      expect(InvoiceItem.incomplete_inv).to eq([@ii_4, @ii_1, @ii_2])
    end
  end
end
