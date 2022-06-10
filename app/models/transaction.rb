class Transaction < ApplicationRecord
  enum result: { success: 0, failed: 1 }
  validates_presence_of :invoice_id, :credit_card_number, :result

  belongs_to :invoice
  has_many :invoice_items, through: :invoice 
  has_many :items, through: :invoice_items 
  has_many :merchants, through: :items 
  has_many :discounts, through: :merchants  
end
