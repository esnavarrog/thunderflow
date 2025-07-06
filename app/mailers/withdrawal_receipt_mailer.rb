class WithdrawalReceiptMailer < ApplicationMailer

  def new_withdrawal_receipt_email(withdrawal_receipt_id)
    @withdrawal_receipt = WithdrawalReceipt.find(withdrawal_receipt_id)
    @user = @withdrawal_receipt.user
    @company = @withdrawal_receipt.company
    emails = [@company.owner.email]
    emails << @company.email if @company.owner.email != @company.email
    staff_users_emails = manager_emails(@user) << @user.email

    mail(to: emails, cc: staff_users_emails, subject: "Comprobante de retiro ##{withdrawal_receipt_id}")
  end
end
