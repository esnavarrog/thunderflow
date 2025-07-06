class UserAccess < ApplicationRecord

  belongs_to :company
  belongs_to :user, optional: true

  enum access_type: %i[owner read contact editor]

  validates :invitation_email, presence: {message: "Debe ingresar email de invitación"},
            uniqueness:{scope: :company_id, message: "Ya existe un acceso de este correo en esta empresa"}

  ## callbacks

  before_save :strip_invitation_email

  def strip_invitation_email
    self.invitation_email = self.invitation_email.strip
  end

end
