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
    if apply_discount 
      true 
    else 
      false 
    end
  end 

  def apply_discount 
    self.discounts.where("quantity <= ?", self.quantity)
  end
  

end
