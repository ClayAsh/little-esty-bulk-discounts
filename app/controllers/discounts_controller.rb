class DiscountsController < ApplicationController 
  def index
    @discounts = Discount.all 
    @merchant = Merchant.find(params[:merchant_id])
  end 

  def show 
    @discount = Discount.find(params[:id])
    @merchant = Merchant.find(params[:merchant_id])
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create 
    @merchant = Merchant.find(params[:merchant_id])
    @discount = @merchant.discounts.create(discount_params)
    redirect_to merchant_discounts_path(@merchant.id)
  end

  def destroy 
    @discount = Discount.find(params[:id]).destroy 
    redirect_to merchant_discounts_path(@discount.merchant_id)
  end

  def edit 
    @discount = Discount.find(params[:id])
    @merchant = Merchant.find(params[:merchant_id])
  end

  def update 
    @discount = Discount.find(params[:id])
    @discount.update(discount_params)
    redirect_to merchant_discount_path(@discount.merchant_id, @discount.id)
  end

  private 

  def discount_params 
    params.permit(:percentage, :quantity)
  end
end