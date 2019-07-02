class ReformBase < Reform::Form
  # https://edgeguides.rubyonrails.org/active_storage_overview.html
  def attach_single_image property
    if self.try(property).present?
      self.model.try(property).attach self.try(property)
    elsif self.model.try(property).try(:attached?)
      self.model.try(property).purge_later
    end
    true
  end
end