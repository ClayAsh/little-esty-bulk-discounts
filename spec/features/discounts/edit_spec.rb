require 'rails_helper'

RSpec.describe 'discount edit page' do 
  let!(:merchant_1) { Merchant.create(name: "Franks Fun Stuff") }
  let!(:discount_1) { merchant_1.discounts.create(quantity: 10, percentage: 20 ) }
  let!(:discount_2) { merchant_1.discounts.create(quantity: 20, percentage: 30 ) }
  let!(:discount_3) { merchant_1.discounts.create(quantity: 40, percentage: 50 ) }

  it 'has form to edit discount information' do 
    visit merchant_discount_path(merchant_1.id, discount_1.id)

    expect(page).to have_content("Buy 10 get 20% off")
    expect(page).to_not have_content("Buy 10 get 10% off")

    click_link "Edit Discount"
    expect(current_path).to eq(edit_merchant_discount_path(merchant_1.id, discount_1.id)) 

    fill_in "quantity", with: "10"
    fill_in "percentage", with: "10"
    click_button "Submit"

    expect(current_path).to eq(merchant_discount_path(merchant_1.id, discount_1.id))
    expect(page).to have_content("Buy 10 get 10% off")
  end
end