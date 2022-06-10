class Item < ApplicationRecord 

  enum status: { 'Enabled' => 0, 'Disabled' => 1 }

  belongs_to :merchant
  has_many :discounts, through: :merchant 
  has_many :invoice_items
  has_many :invoices, through: :invoice_items
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :unit_price

  def unit_price_to_dollars
    unit_price.to_s.rjust(3, "0").insert(-3, ".")
  end

  def self.most_popular_items
    joins(invoice_items: [:invoice])
    .where(invoices: {status: 2})
    .select("items.*, sum(invoice_items.quantity * invoice_items.unit_price)")
    .group(:id)
    .order(sum: :desc)
    .limit(5).to_a
  end

  def total_item_revenue
    invoice_items.sum("quantity * unit_price").to_s.rjust(3, "0").insert(-3, ".")
  end 

  def best_day
    invoices
    .joins(:invoice_items)
    .where(invoices: {status: 2})
    .select('invoices.*, sum(invoice_items.unit_price * invoice_items.quantity) as revenue')
    .group(:id)
    .order("revenue desc", "created_at desc")
    .first.created_at.strftime("%m/%d/%Y")
  end
end
