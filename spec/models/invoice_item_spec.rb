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

  it 'checks if discount is applied' do 
    @merchant = Merchant.create!(name: 'Office Supplies')
    @merchant.discounts.create!(quantity: 20, percentage: 10)
    @item_1 = @merchant.items.create!(name: 'Pencil', unit_price: 500, description: 'Writes things.')
    @item_2 = @merchant.items.create!(name: 'Pen', unit_price: 375, description: 'Writes things, but dark.')
    @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Ondricka')
    @invoice_1 = @customer_1.invoices.create!(status: 'completed',
                                              created_at: 'Wed, 01 Jan 2022 21:20:02 UTC +00:00')
    @ii_1 = @item_1.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 3, unit_price: 400, status: 'packaged',
                                  created_at: Time.parse('2012-03-27 14:54:09 UTC'))
    @ii_2 = @item_2.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 20, unit_price: 375, status: 'packaged',
                                  created_at: Time.parse('2012-03-28 14:54:09 UTC'))

    expect(@ii_2.has_discount?).to eq(true)    
  end 

  it 'returns qualifying discount and not discount that isnt qualified for' do 
    @merchant = Merchant.create!(name: 'Office Supplies')
    @discount_1 = @merchant.discounts.create!(quantity: 20, percentage: 10)
    @discount_2 = @merchant.discounts.create!(quantity: 30, percentage: 2.0)
    @item_1 = @merchant.items.create!(name: 'Pencil', unit_price: 500, description: 'Writes things.')
    @item_2 = @merchant.items.create!(name: 'Pen', unit_price: 375, description: 'Writes things, but dark.')
    @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Ondricka')
    @invoice_1 = @customer_1.invoices.create!(status: 'completed',
                                              created_at: 'Wed, 01 Jan 2022 21:20:02 UTC +00:00')
    @ii_1 = @item_1.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 3, unit_price: 400, status: 'packaged',
                                  created_at: Time.parse('2012-03-27 14:54:09 UTC'))
    @ii_2 = @item_2.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 20, unit_price: 375, status: 'packaged',
                                  created_at: Time.parse('2012-03-28 14:54:09 UTC'))

    expect(@ii_2.best_discount).to eq(@discount_1)    
    expect(@ii_2.best_discount).to_not eq(@discount_2)    
  end 

  it 'applies best available discount' do 
    @merchant = Merchant.create!(name: 'Office Supplies')
    @discount_1 = @merchant.discounts.create!(quantity: 20, percentage: 10)
    @discount_2 = @merchant.discounts.create!(quantity: 10, percentage: 5)
    @item_1 = @merchant.items.create!(name: 'Pencil', unit_price: 500, description: 'Writes things.')
    @item_2 = @merchant.items.create!(name: 'Pen', unit_price: 375, description: 'Writes things, but dark.')
    @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Ondricka')
    @invoice_1 = @customer_1.invoices.create!(status: 'completed',
                                              created_at: 'Wed, 01 Jan 2022 21:20:02 UTC +00:00')
    @ii_1 = @item_1.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 3, unit_price: 400, status: 'packaged',
                                  created_at: Time.parse('2012-03-27 14:54:09 UTC'))
    @ii_2 = @item_2.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 20, unit_price: 375, status: 'packaged',
                                  created_at: Time.parse('2012-03-28 14:54:09 UTC'))

    expect(@ii_2.apply_discount).to eq(6750.0) # discount_1 is applied 
    expect(@ii_2.apply_discount).to_not eq(7125.0) #discount_2 is not applied 
  end 

  it 'doesnt apply discount if none are qualified for' do 
    @merchant = Merchant.create!(name: 'Office Supplies')
    @discount_1 = @merchant.discounts.create!(quantity: 20, percentage: 10)
    @discount_2 = @merchant.discounts.create!(quantity: 10, percentage: 5)
    @item_1 = @merchant.items.create!(name: 'Pencil', unit_price: 500, description: 'Writes things.')
    @item_2 = @merchant.items.create!(name: 'Pen', unit_price: 375, description: 'Writes things, but dark.')
    @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Ondricka')
    @invoice_1 = @customer_1.invoices.create!(status: 'completed',
                                              created_at: 'Wed, 01 Jan 2022 21:20:02 UTC +00:00')
    @ii_1 = @item_1.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 3, unit_price: 400, status: 'packaged',
                                  created_at: Time.parse('2012-03-27 14:54:09 UTC'))
    @ii_2 = @item_2.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 5, unit_price: 375, status: 'packaged',
                                  created_at: Time.parse('2012-03-28 14:54:09 UTC'))

    expect(@ii_2.apply_discount).to eq(1875)
    expect(@ii_2.apply_discount).to_not eq(1781.25) # discount_1 is not applied
    expect(@ii_2.apply_discount).to_not eq(1687.5) # discount_2 id not applied 
  end 

  it 'can apply discounts from different merchants' do 
    @merchant_1 = Merchant.create!(name: 'Office Supplies')
    @merchant_2 = Merchant.create!(name: 'Supplies 4 Offices')
    @discount_1 = @merchant_1.discounts.create!(quantity: 20, percentage: 20)
    @discount_2 = @merchant_2.discounts.create!(quantity: 10, percentage: 10)
    @item_1 = @merchant_1.items.create!(name: 'Pencil', unit_price: 500, description: 'Writes things.')
    @item_2 = @merchant_2.items.create!(name: 'Pen', unit_price: 375, description: 'Writes things, but dark.')
    @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Ondricka')
    @invoice_1 = @customer_1.invoices.create!(status: 'completed',
                                              created_at: 'Wed, 01 Jan 2022 21:20:02 UTC +00:00')
    @ii_1 = @item_1.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 20, unit_price: 400, status: 'packaged',
                                  created_at: Time.parse('2012-03-27 14:54:09 UTC'))
    @ii_2 = @item_2.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 10, unit_price: 375, status: 'packaged',
                                  created_at: Time.parse('2012-03-28 14:54:09 UTC'))
    expect(InvoiceItem.discounted_revenue).to eq(9775) 
    expect(InvoiceItem.discounted_revenue).to_not eq(9400) #discount_1 is not applied to both invoice_items
    expect(InvoiceItem.discounted_revenue).to_not eq(10575) #discount_2 is not applied to both items 
  end 

  it 'can apply discounts from different merchants and exclude items that dont qualify' do 
    @merchant_1 = Merchant.create!(name: 'Office Supplies')
    @merchant_2 = Merchant.create!(name: 'Supplies 4 Offices')
    @discount_1 = @merchant_1.discounts.create!(quantity: 10, percentage: 20)
    @discount_2 = @merchant_1.discounts.create!(quantity: 15, percentage: 30)
    @item_1 = @merchant_1.items.create!(name: 'Pencil', unit_price: 500, description: 'Writes things.')
    @item_2 = @merchant_1.items.create!(name: 'Pen', unit_price: 375, description: 'Writes things, but dark.')
    @item_3 = @merchant_2.items.create!(name: 'Eraser', unit_price: 100, description: 'Erases things.')
    @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Ondricka')
    @invoice_1 = @customer_1.invoices.create!(status: 'completed',
                                              created_at: 'Wed, 01 Jan 2022 21:20:02 UTC +00:00')
    @ii_1 = @item_1.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 12, unit_price: 400, status: 'packaged',
                                  created_at: Time.parse('2012-03-27 14:54:09 UTC'))
    @ii_2 = @item_2.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 15, unit_price: 375, status: 'packaged',
                                  created_at: Time.parse('2012-03-28 14:54:09 UTC'))
    @ii_2 = @item_3.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 15, unit_price: 100, status: 'packaged',
                                  created_at: Time.parse('2012-03-28 14:54:09 UTC'))

    expect(@ii_2.apply_discount).to eq(1500) # no discount is applied to ii_2 
    expect(@ii_1.apply_discount).to eq(3840.0) # dicount_1 is applied to item_1 & discount_2 is applied to item_2 
    
    # expect(InvoiceItem.discounted_revenue).to eq(8927) 
    # expect(InvoiceItem.discounted_revenue).to_not eq(9277) 
  end 

  it 'returns total revenue without discount' do 
    @merchant = Merchant.create!(name: 'Office Supplies')
    @discount_1 = @merchant.discounts.create!(quantity: 20, percentage: 10)
    @discount_2 = @merchant.discounts.create!(quantity: 30, percentage: 2.0)
    @item_1 = @merchant.items.create!(name: 'Pencil', unit_price: 500, description: 'Writes things.')
    @item_2 = @merchant.items.create!(name: 'Pen', unit_price: 375, description: 'Writes things, but dark.')
    @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Ondricka')
    @invoice_1 = @customer_1.invoices.create!(status: 'completed',
                                              created_at: 'Wed, 01 Jan 2022 21:20:02 UTC +00:00')
    @ii_1 = @item_1.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 3, unit_price: 400, status: 'packaged',
                                  created_at: Time.parse('2012-03-27 14:54:09 UTC'))
    @ii_2 = @item_2.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 20, unit_price: 375, status: 'packaged',
                                  created_at: Time.parse('2012-03-28 14:54:09 UTC'))
   
    expect(@ii_2.revenue).to eq(7500)
  end

  it 'can show total discounted revenue' do 
    @merchant = Merchant.create!(name: 'Office Supplies')
    @discount_1 = @merchant.discounts.create!(quantity: 20, percentage: 10)
    @item_1 = @merchant.items.create!(name: 'Pencil', unit_price: 500, description: 'Writes things.')
    @item_2 = @merchant.items.create!(name: 'Pen', unit_price: 375, description: 'Writes things, but dark.')
    @item_3 = @merchant.items.create!(name: 'Marker', unit_price: 400,
                                      description: 'Writes things, but dark, and thicc.')
    @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Ondricka')
    @invoice_1 = @customer_1.invoices.create!(status: 'completed',
                                              created_at: 'Wed, 01 Jan 2022 21:20:02 UTC +00:00')
    @invoice_7 = @customer_1.invoices.create!(status: 'completed')
    @ii_1 = @item_1.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 3, unit_price: 400, status: 'packaged',
                                  created_at: Time.parse('2012-03-27 14:54:09 UTC'))
    @ii_2 = @item_2.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 20, unit_price: 375, status: 'packaged',
                                  created_at: Time.parse('2012-03-28 14:54:09 UTC'))

    expect(InvoiceItem.discounted_revenue).to eq(7950)
  end
end
