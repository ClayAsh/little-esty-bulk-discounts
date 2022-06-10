class Discount < ApplicationRecord
  belongs_to :merchant 
  has_many :items, through: :merchant 
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items 
  has_many :transactions, through: :invoices 
  # has_many :customers, through: :invoices 

  validates_numericality_of :quantity
  validates_numericality_of :percentage, less_than_or_equal_to: 51
end
