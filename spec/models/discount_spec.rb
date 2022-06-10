require 'rails_helper'

RSpec.describe Discount, type: :model do
  it { should belong_to(:merchant) }  
  it { should have_many(:items).through(:merchant) } 
  it { should have_many(:invoice_items).through(:items) }
  it { should have_many(:invoices).through(:invoice_items) }
  it { should have_many(:transactions).through(:invoices) } 
  # it { should have_many(:customers).through(:invoices) }

  it { should validate_numericality_of(:percentage).is_less_than_or_equal_to(51) } 
  it { should validate_numericality_of(:quantity) }   
end
