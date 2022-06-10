class DiscountsController < ApplicationController 
  def index
    @discounts = Discount.all 
    # require 'pry'; binding.pry
    @merchant = Merchant.find(params[:merchant_id])
  end 

  def show 
    @discount = Discount.find(params[:id])
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create 
    @merchant = Merchant.find(params[:merchant_id])
    @discount = @merchant.discounts.create(discount_params)
    redirect_to merchant_discounts_path(@merchant.id)
  end

  private 

  def discount_params 
    params.permit(:percentage, :quantity)
  end
end