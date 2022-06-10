require 'rails_helper'

RSpec.describe 'discount index page' do 
  let!(:merchant_1) { Merchant.create(name: "Franks Fun Stuff") }
  let!(:discount_1) { merchant_1.discounts.create(percentage: 20 , quantity: 10 ) }
  let!(:discount_2) { merchant_1.discounts.create(percentage: 30 , quantity: 20 ) }
  let!(:discount_3) { merchant_1.discounts.create(percentage: 50 , quantity: 40 ) }

  it 'lists all discounts and has a link to discount show page' do 
    visit merchant_discounts_path(merchant_1.id)

    expect(page).to have_content("Buy 10 get 20% off")
    expect(page).to have_content("Buy 20 get 30% off")
    expect(page).to have_content("Buy 40 get 50% off")

    within("##{discount_1.id}") do 
      click_link "Buy 10 get 20% off"
    end
    expect(current_path).to eq(merchant_discount_path(merchant_1.id, discount_1.id))
  end

  it 'has link to delete each discount' do 
    visit merchant_discounts_path(merchant_1.id)

    within("##{discount_1.id}") do 
    click_link "Delete Discount"
    end
    expect(current_path).to eq(merchant_discounts_path(merchant_1.id))
    expect(page).to_not have_content("Buy 10 get 20% off")
  end
end