class InvoiceItem < ApplicationRecord
  enum status: { 'pending' => 0, 'packaged' => 1, 'shipped' => 2 }

  belongs_to :invoice
  has_many :transactions, through: :invoice 
  belongs_to :item
  has_many :merchants, through: :item
  has_many :discounts, through: :merchants 

  validates_presence_of :status

  def self.incomplete_inv
    where(status: %w[pending packaged])
      .order(:created_at)
  end

  def has_discount?
    if best_discount 
      true 
    else 
      false 
    end
  end 

  def best_discount 
    discounts.where('discounts.quantity <= ?', quantity)
    .order(percentage: :desc)
    .first
  end
  
  def revenue 
    quantity * unit_price 
  end

  def apply_discount 
    if best_discount.nil?
      revenue
    else
    revenue * (1- (best_discount.percentage.to_f / 100) )
    end 
  end

  def self.discounted_revenue
     sum do |invoice_item|
      if invoice_item.best_discount
        invoice_item.apply_discount.to_i
      else
        invoice_item.revenue
      end
    end
  end
end
