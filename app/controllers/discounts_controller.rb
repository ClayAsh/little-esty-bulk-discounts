class DiscountsController < ApplicationController 
  def index
    @discounts = Discount.all 
  end 

  def show 
    @discount = Discount.find(params[:id])
  end
end