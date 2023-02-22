class TemplateAttestation < ApplicationRecord
    acts_as_tenant :company
end
