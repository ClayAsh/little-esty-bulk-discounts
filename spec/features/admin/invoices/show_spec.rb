require 'rails_helper'

RSpec.describe 'Admin Invoice Show page' do
  before :each do
    @merchant = Merchant.create!(name: 'Brylan')
    @item_1 = @merchant.items.create!(name: 'Pencil', unit_price: 500, description: 'Writes things.')
    @item_2 = @merchant.items.create!(name: 'Pen', unit_price: 400, description: 'Writes things, but dark.')
    @item_3 = @merchant.items.create!(name: 'Marker', unit_price: 400,
                                      description: 'Writes things, but dark, and thicc.')

    @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Ondricka')
    @customer_2 = Customer.create!(first_name: 'Chael', last_name: 'Sonnen')
    @invoice_1 = @customer_1.invoices.create!(status: 'completed', created_at: 'Sat, 1 Jan 2022 21:20:02 UTC +00:00')
    @invoice_7 = @customer_1.invoices.create!(status: 'completed')
    @invoice_5 = @customer_2.invoices.create!(status: 'completed')
    @item_1.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 3, unit_price: 400, status: 'packaged',
                                  created_at: Time.parse('2012-03-27 14:54:09 UTC'))
    @item_2.invoice_items.create!(invoice_id: @invoice_7.id, quantity: 5, unit_price: 400, status: 'packaged',
                                  created_at: Time.parse('2012-03-28 14:54:09 UTC'))

    @invoice_1.transactions.create!(credit_card_number: '4654405418249632', result: 'success')
    @invoice_1.transactions.create!(credit_card_number: '4654405418249631', result: 'success')
    @invoice_1.transactions.create!(credit_card_number: '4654405418249633', result: 'success')
    @invoice_1.transactions.create!(credit_card_number: '4654405418249635', result: 'success')
    @invoice_1.transactions.create!(credit_card_number: '4654405418249635', result: 'success')
    @invoice_1.transactions.create!(credit_card_number: '4654405418249635', result: 'success')
  end

  it 'displays the invoice information' do
    visit admin_invoice_path(@invoice_1)
    save_and_open_page
    expect(page).to have_content("Invoice ##{@invoice_1.id}")
    expect(page).to have_content("Status: #{@invoice_1.status}")
    expect(page).to have_content("Created on: Saturday, January 01, 2022")
    expect(page).to have_content("#{@customer_1.first_name} #{@customer_1.last_name}")

  end
end