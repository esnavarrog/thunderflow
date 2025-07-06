class ApplicationCommand
  prepend SimpleCommand

  def success?
    errors.empty?
  end
end