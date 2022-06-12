require 'rails_helper'

RSpec.describe 'discount new page' do 
  let!(:merchant_1) { Merchant.create(name: "Franks Fun Stuff") }
  let!(:discount_1) { merchant_1.discounts.create(percentage: 20 , quantity: 10 ) }
  let!(:discount_2) { merchant_1.discounts.create(percentage: 30 , quantity: 20 ) }
  let!(:discount_3) { merchant_1.discounts.create(percentage: 50 , quantity: 40 ) }

  it 'can add a new discount' do 
    visit merchant_discounts_path(merchant_1.id)

    click_link "Create New Discount"

    expect(current_path).to eq(new_merchant_discount_path(merchant_1.id))

    fill_in "quantity", with: "10"
    fill_in "percentage", with: "10"
    click_button "Submit"

    expect(current_path).to eq(merchant_discounts_path(merchant_1.id))
    expect(page).to have_content("Buy 10 get 10% off")
  end 

  it 'has error message if input is not an integer' do 
    visit merchant_discounts_path(merchant_1.id)

    click_link "Create New Discount"

    expect(current_path).to eq(new_merchant_discount_path(merchant_1.id))

    fill_in "quantity", with: "a"
    fill_in "percentage", with: "b"
    click_button "Submit"

    expect(current_path).to eq(new_merchant_discount_path(merchant_1.id))
    expect(page).to have_content("Error: Discount cannot exceed 50% off & values must be integers!")
  end

  it 'has error message if discount percentage is over 50%' do 
    visit merchant_discounts_path(merchant_1.id)

    click_link "Create New Discount"

    expect(current_path).to eq(new_merchant_discount_path(merchant_1.id))

    fill_in "quantity", with: "10"
    fill_in "percentage", with: "100"
    click_button "Submit"

    expect(current_path).to eq(new_merchant_discount_path(merchant_1.id))
    expect(page).to have_content("Error: Discount cannot exceed 50% off & values must be integers!")
  end
end