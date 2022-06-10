require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'relationships' do
    it { should belong_to(:merchant) }
    it { should have_many(:discounts).through(:merchant)}
    it { should have_many(:invoice_items) }
    it { should have_many(:invoices).through(:invoice_items) } 
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:unit_price) }
  end

  it 'converts unit price to dollars' do
    merchant_1 = Merchant.create(name: "Ray's Handmade Jewelry")
    item_1 = merchant_1.items.create!(name: "Dangly Earings" , description: 'They tickle your neck.', unit_price: 1500 )

    expect(item_1.unit_price_to_dollars).to eq('15.00')
  end

  it 'shows top five popular items' do 
    merchant = Merchant.create!(name: 'Brylan')
    customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Ondricka')
    invoice_1 = customer_1.invoices.create!(status: 'completed',
                          created_at: Time.parse('2012-03-27 14:54:09 UTC'),
                          updated_at: Time.parse('2012-03-27 14:54:09 UTC'))
    item_1 = merchant.items.create!(name: 'Pencil', unit_price: 100, description: 'Writes things.')
    item_2 = merchant.items.create!(name: 'Eraser', unit_price: 200, description: 'Does things.')
    item_3 = merchant.items.create!(name: 'Pen', unit_price: 300, description: 'Helps things.')
    item_4 = merchant.items.create!(name: 'Calculator', unit_price: 400, description: 'Considers things.')
    item_5 = merchant.items.create!(name: 'Stapler', unit_price: 500, description: 'Wishes things.')
    item_6 = merchant.items.create!(name: 'Computer', unit_price: 600, description: 'Hopes things.')
    item_7 = merchant.items.create!(name: 'Backpack', unit_price: 700, description: 'Forgets things.')
    item_1.invoice_items.create!(invoice_id: invoice_1.id, quantity: 1, unit_price: 400, status: 2)
    item_2.invoice_items.create!(invoice_id: invoice_1.id, quantity: 2, unit_price: 500, status: 2)
    item_3.invoice_items.create!(invoice_id: invoice_1.id, quantity: 3, unit_price: 600, status: 2)
    item_4.invoice_items.create!(invoice_id: invoice_1.id, quantity: 4, unit_price: 700, status: 2)
    item_5.invoice_items.create!(invoice_id: invoice_1.id, quantity: 5, unit_price: 800, status: 2)
    invoice_1.transactions.create!(credit_card_number: '4654405418249632', result: 'success')

    customer_2 = Customer.create!(first_name: 'Osinski', last_name: 'Cecelia')
    invoice_2 = customer_2.invoices.create!(status: 'completed',
                            created_at: Time.parse('2012-03-26 09:54:09 UTC'),
                            updated_at: Time.parse('2012-03-26 09:54:09 UTC'))
    item_3.invoice_items.create!(invoice_id: invoice_2.id, quantity: 1, unit_price: 400, status: 2)
    item_4.invoice_items.create!(invoice_id: invoice_2.id, quantity: 2, unit_price: 500, status: 2)
    item_5.invoice_items.create!(invoice_id: invoice_2.id, quantity: 3, unit_price: 600, status: 2)
    item_6.invoice_items.create!(invoice_id: invoice_2.id, quantity: 4, unit_price: 700, status: 2)
    item_7.invoice_items.create!(invoice_id: invoice_2.id, quantity: 5, unit_price: 800, status: 2)
    invoice_2.transactions.create!(credit_card_number: '5654405418249632', result: 'success')

    expect(Item.most_popular_items).to eq([item_5, item_7, item_4, item_6, item_3])
  end

  it 'shows item total revenue' do 
    merchant = Merchant.create!(name: 'Brylan')
    customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Ondricka')
    invoice_1 = customer_1.invoices.create!(status: 'completed',
                          created_at: Time.parse('2012-03-27 14:54:09 UTC'),
                          updated_at: Time.parse('2012-03-27 14:54:09 UTC'))
    item_1 = merchant.items.create!(name: 'Pencil', unit_price: 100, description: 'Writes things.')
    item_2 = merchant.items.create!(name: 'Eraser', unit_price: 200, description: 'Does things.')
    item_3 = merchant.items.create!(name: 'Pen', unit_price: 300, description: 'Helps things.')
    item_4 = merchant.items.create!(name: 'Calculator', unit_price: 400, description: 'Considers things.')
    item_5 = merchant.items.create!(name: 'Stapler', unit_price: 500, description: 'Wishes things.')
    item_6 = merchant.items.create!(name: 'Computer', unit_price: 600, description: 'Hopes things.')
    item_7 = merchant.items.create!(name: 'Backpack', unit_price: 700, description: 'Forgets things.')
    item_1.invoice_items.create!(invoice_id: invoice_1.id, quantity: 1, unit_price: 400, status: 2)
    item_2.invoice_items.create!(invoice_id: invoice_1.id, quantity: 2, unit_price: 500, status: 2)
    item_3.invoice_items.create!(invoice_id: invoice_1.id, quantity: 3, unit_price: 600, status: 2)
    item_4.invoice_items.create!(invoice_id: invoice_1.id, quantity: 4, unit_price: 700, status: 2)
    item_5.invoice_items.create!(invoice_id: invoice_1.id, quantity: 5, unit_price: 800, status: 2)
    invoice_1.transactions.create!(credit_card_number: '4654405418249632', result: 'success')

    customer_2 = Customer.create!(first_name: 'Osinski', last_name: 'Cecelia')
    invoice_2 = customer_2.invoices.create!(status: 'completed',
                            created_at: Time.parse('2012-03-26 09:54:09 UTC'),
                            updated_at: Time.parse('2012-03-26 09:54:09 UTC'))
    item_3.invoice_items.create!(invoice_id: invoice_2.id, quantity: 1, unit_price: 400, status: 2)
    item_4.invoice_items.create!(invoice_id: invoice_2.id, quantity: 2, unit_price: 500, status: 2)
    item_5.invoice_items.create!(invoice_id: invoice_2.id, quantity: 3, unit_price: 600, status: 2)
    item_6.invoice_items.create!(invoice_id: invoice_2.id, quantity: 4, unit_price: 700, status: 2)
    item_7.invoice_items.create!(invoice_id: invoice_2.id, quantity: 5, unit_price: 800, status: 2)
    invoice_2.transactions.create!(credit_card_number: '5654405418249632', result: 'success')

    expect(item_7.total_item_revenue).to eq("40.00")
  end

  it 'shows best day for top item' do 
    merchant = Merchant.create!(name: 'Brylan')
    customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Ondricka')
    invoice_1 = customer_1.invoices.create!(status: 'completed',
                          created_at: Time.parse('2012-03-27 14:54:09 UTC'),
                          updated_at: Time.parse('2012-03-27 14:54:09 UTC'))
    item_1 = merchant.items.create!(name: 'Pencil', unit_price: 100, description: 'Writes things.')
    item_2 = merchant.items.create!(name: 'Eraser', unit_price: 200, description: 'Does things.')
    item_3 = merchant.items.create!(name: 'Pen', unit_price: 300, description: 'Helps things.')
    item_4 = merchant.items.create!(name: 'Calculator', unit_price: 400, description: 'Considers things.')
    item_5 = merchant.items.create!(name: 'Stapler', unit_price: 500, description: 'Wishes things.')
    item_6 = merchant.items.create!(name: 'Computer', unit_price: 600, description: 'Hopes things.')
    item_7 = merchant.items.create!(name: 'Backpack', unit_price: 700, description: 'Forgets things.')
    item_1.invoice_items.create!(invoice_id: invoice_1.id, quantity: 1, unit_price: 400, status: 2)
    item_2.invoice_items.create!(invoice_id: invoice_1.id, quantity: 2, unit_price: 500, status: 2)
    item_3.invoice_items.create!(invoice_id: invoice_1.id, quantity: 3, unit_price: 600, status: 2)
    item_4.invoice_items.create!(invoice_id: invoice_1.id, quantity: 4, unit_price: 700, status: 2)
    item_5.invoice_items.create!(invoice_id: invoice_1.id, quantity: 5, unit_price: 800, status: 2)
    invoice_1.transactions.create!(credit_card_number: '4654405418249632', result: 'success')

    customer_2 = Customer.create!(first_name: 'Osinski', last_name: 'Cecelia')
    invoice_2 = customer_2.invoices.create!(status: 'completed',
                            created_at: Time.parse('2012-03-26 09:54:09 UTC'),
                            updated_at: Time.parse('2012-03-26 09:54:09 UTC'))
    item_3.invoice_items.create!(invoice_id: invoice_2.id, quantity: 1, unit_price: 400, status: 2)
    item_4.invoice_items.create!(invoice_id: invoice_2.id, quantity: 2, unit_price: 500, status: 2)
    item_5.invoice_items.create!(invoice_id: invoice_2.id, quantity: 3, unit_price: 600, status: 2)
    item_6.invoice_items.create!(invoice_id: invoice_2.id, quantity: 4, unit_price: 700, status: 2)
    item_7.invoice_items.create!(invoice_id: invoice_2.id, quantity: 5, unit_price: 800, status: 2)
    invoice_2.transactions.create!(credit_card_number: '5654405418249632', result: 'success')

    expect(item_5.best_day).to eq("03/27/2012")
  end
end