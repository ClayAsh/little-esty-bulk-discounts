require 'rails_helper'

RSpec.describe 'Merchant Invoice Show page' do
  before :each do
    @merchant = Merchant.create!(name: 'Office Supplies')
    @discount_1 = @merchant.discounts.create!(quantity: 20, percentage: 10)
    @item_1 = @merchant.items.create!(name: 'Pencil', unit_price: 500, description: 'Writes things.')
    @item_2 = @merchant.items.create!(name: 'Pen', unit_price: 400, description: 'Writes things, but dark.')
    @item_3 = @merchant.items.create!(name: 'Marker', unit_price: 400,
                                      description: 'Writes things, but dark, and thicc.')

    @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Ondricka')
    @invoice_1 = @customer_1.invoices.create!(status: 'completed',
                                              created_at: 'Wed, 01 Jan 2022 21:20:02 UTC +00:00')
    @invoice_2 = @customer_1.invoices.create!(status: 'completed',
                                              created_at: 'Wed, 01 Jan 2022 21:20:02 UTC +00:00')

    @invoice_7 = @customer_1.invoices.create!(status: 'completed')
    @invoice_item_1 = @item_1.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 20, unit_price: 400, status: 'packaged',
                                                    created_at: Time.parse('2012-03-27 14:54:09 UTC'))
    @invoice_item_2 = @item_2.invoice_items.create!(invoice_id: @invoice_7.id, quantity: 5, unit_price: 375, status: 'pending',
                                                    created_at: Time.parse('2012-03-28 14:54:09 UTC'))
    @invoice_item_3 = @item_2.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 1, unit_price: 375, status: 'shipped',
                                                    created_at: Time.parse('2012-03-28 14:54:09 UTC'))
    @invoice_item_4 = @item_2.invoice_items.create!(invoice_id: @invoice_2.id, quantity: 1, unit_price: 375, status: 'shipped',
                                                    created_at: Time.parse('2012-03-28 14:54:09 UTC'))
  end

  it 'displays the invoice information in the show page', :vcr do
    visit merchant_invoice_path(@merchant, @invoice_1)

    within "#invoice-header-#{@invoice_1.id}" do
      expect(page).to have_content("Invoice ##{@invoice_1.id}")
    end

    within "#invoice-#{@invoice_1.id}" do
      expect(page).to have_content('Status: completed')
      expect(page).to have_content('Created on: Saturday, January 01, 2022 ')
      expect(page).to have_content('Joey Ondricka')
    end
  end

  it 'displays the invoice items information', :vcr do
    visit merchant_invoice_path(@merchant, @invoice_1)

    within "#invoice-items-#{@invoice_item_1.id}" do
      expect(page).to have_content('Pencil')
      expect(page).to have_content('20')
      expect(page).to have_content('5.00')
      expect(page).to have_content('packaged')
    end
  end

  it 'displays the total revenue of the items on the invoice', :vcr do
    visit merchant_invoice_path(@merchant, @invoice_1)

    within "#invoice-#{@invoice_1.id}" do
      expect(page).to have_content('Total Revenue: $83.75')
    end
  end

  it 'can update the status of a invoice item', :vcr do
    visit merchant_invoice_path(@merchant, @invoice_1)
    # invoice item 1
    within "#invoice-items-#{@invoice_item_1.id}" do
      expect(page).to have_content('packaged')
      select('shipped')
      click_on('Update Item Status')
    end

    expect(current_path).to eq(merchant_invoice_path(@merchant, @invoice_1))
    within "#invoice-items-#{@invoice_item_1.id}" do
      expect(page).to have_content('shipped')
    end
    # invoice item 3
    within "#invoice-items-#{@invoice_item_3.id}" do
      expect(page).to have_content('shipped')
      select('pending')
      click_on('Update Item Status')
    end

    expect(current_path).to eq(merchant_invoice_path(@merchant, @invoice_1))

    within "#invoice-items-#{@invoice_item_3.id}" do
      expect(page).to have_content('pending')
    end
  end

  it 'can update the status of a invoice item', :vcr do
    visit merchant_invoice_path(@merchant, @invoice_1)
    # invoice item 1
    within "#invoice-items-#{@invoice_item_3.id}" do
      expect(page).to have_content('shipped')
      select('packaged')
      click_on('Update Item Status')
    end

    expect(current_path).to eq(merchant_invoice_path(@merchant, @invoice_1))
    within "#invoice-items-#{@invoice_item_3.id}" do
      expect(page).to have_content('packaged')
    end
  end

  it 'displays the discounted revenue of the items on the invoice' do
    visit merchant_invoice_path(@merchant, @invoice_1)

    within "#invoice-#{@invoice_1.id}" do
      expect(page).to have_content('Discounted Revenue: $75.75')
    end
  end 

  it 'doesnt display discounted revenue if no discount was applied' do 
    visit merchant_invoice_path(@merchant, @invoice_2)
    expect(page).to_not have_content("Discounted Revenue:")
  end

  it 'has a link to applied discount' do 
    visit merchant_invoice_path(@merchant, @invoice_1)

    within "#invoice-items-#{@invoice_item_1.id}" do
      click_link "Applied Discount"
      expect(current_path).to eq(merchant_discount_path(@merchant, @discount_1))
    end
  end

  it 'doesnt have link if no discount was applied' do 
    visit merchant_invoice_path(@merchant, @invoice_1)

    within "#invoice-items-#{@invoice_item_3.id}" do
    expect(page).to_not have_content("Applied Discount")
    end
  end
end


