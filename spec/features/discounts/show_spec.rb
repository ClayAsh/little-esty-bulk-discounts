require 'rails_helper'

RSpec.describe 'discount show page' do 
  let!(:merchant_1) { Merchant.create(name: "Franks Fun Stuff") }
  let!(:discount_1) { merchant_1.discounts.create(percentage: 20 , quantity: 10 ) }
  let!(:discount_2) { merchant_1.discounts.create(percentage: 30 , quantity: 20 ) }
  let!(:discount_3) { merchant_1.discounts.create(percentage: 50 , quantity: 40 ) }

  it 'shows discounts quantity and percentage' do 
    visit merchant_discount_path(merchant_1.id, discount_1.id) 

    expect(page).to have_content(discount_1.percentage)
    expect(page).to have_content(discount_1.quantity)
  end


  it 'has a link to edit discount' do 
    visit merchant_discount_path(merchant_1.id, discount_1.id) 

    click_link "Edit Discount"

    expect(current_path).to eq(edit_merchant_discount_path(merchant_1.id, discount_1.id))
  end
end