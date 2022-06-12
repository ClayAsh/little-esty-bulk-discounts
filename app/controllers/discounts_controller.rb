class DiscountsController < ApplicationController 
  before_action :upcoming_holidays, only: %i[index]

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
    if @discount.save 
    redirect_to merchant_discounts_path(@merchant.id)
    else  
      flash[:alert] = 
      "Error: Discount cannot exceed 50% off & values must be integers!"
      redirect_to new_merchant_discount_path(@merchant.id)
    end 
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
    @merchant = Merchant.find(params[:merchant_id])
    @discount = Discount.find(params[:id])
    @discount.update(discount_params)
    if @discount.save 
    redirect_to merchant_discount_path(@discount.merchant_id, @discount.id)
    else  
       flash[:alert] = 
      "Error: Discount cannot exceed 50% off & values must be integers!"
      redirect_to edit_merchant_discount_path(@merchant.id)
    end 
  end

  private 

  def discount_params 
    params.permit(:percentage, :quantity)
  end

  def upcoming_holidays
  @holidays = HolidayFacade.create_holidays
  end

end