class WithdrawalReceiptsController < ApplicationController
  before_action :authenticate_user!, only: [:index]
  before_action :set_withdrawal_receipt, only: [:show, :edit, :update, :destroy]

  def index
    authorize :withdrawal_receipt
    options = params
    options = options.merge({order: 'created_at', dir: :desc})
    @withdrawal_receipts = current_user.withdrawal_receipts.fetch(options) if current_user.delivery?
    if current_user.admin?
      @withdrawal_receipts = WithdrawalReceipt.fetch(options)
      @companies_deliveries = Company.all
    end
    @withdrawal_receipts = current_company&.withdrawal_receipts.fetch(options) if current_user.client? and current_company
  end

  def show
    authorize @withdrawal_receipt
  end

  def new
    @withdrawal_receipt = WithdrawalReceipt.new
    authorize @withdrawal_receipt
  end

  def create
    @withdrawal_receipt = WithdrawalReceipt.new(withdrawal_receipt_params)
    authorize @withdrawal_receipt
    @withdrawal_receipt.user = current_user
    if @withdrawal_receipt.save
      WithdrawalReceiptMailer.new_withdrawal_receipt_email(@withdrawal_receipt.id).deliver_later
      redirect_to withdrawal_receipts_path, notice: "Withdrawal receipt created successfully"
    else
      render :new
    end
  end

  def edit
    authorize @withdrawal_receipt
  end

  def update
    authorize @withdrawal_receipt
    if @withdrawal_receipt.update(withdrawal_receipt_params)
      redirect_to withdrawal_receipts_path, notice: "Withdrawal receipt updated successfully"
    else
      render :edit
    end
  end

  def destroy
    authorize @withdrawal_receipt
    @withdrawal_receipt.destroy
    redirect_to withdrawal_receipts_path, notice: "Withdrawal receipt deleted successfully"
  end

  def send_email
    @withdrawal_receipt = WithdrawalReceipt.find(params[:withdrawal_receipt_id])
    begin
      WithdrawalReceiptMailer.new_withdrawal_receipt_email(@withdrawal_receipt.id).deliver_now
      @message = "Comprobante de retiro reenviado"
    rescue ActiveRecord::RecordNotFound
      @message = "No se pudo reenviar el comprobante de retiro"
    end
  end

  private
  def set_withdrawal_receipt
    @withdrawal_receipt = WithdrawalReceipt.find(params[:id])
  end

  def withdrawal_receipt_params
    params.require(:withdrawal_receipt).permit(
      :sender_local_plain,
      :sender_local_check,
      :returned_amount,
      :name_client,
      :issued_at,
      :company_id,
      :withdrawal_receipt_type
    )
  end
end
