class PU < ApplicationRecord
  self.table_name = 'vw_pu'

  belongs_to :municipio, foreign_key: 'municipioid'

  scope :nacional, -> { where("municipioid is not null") }
  scope :editaveis, -> { where("not staff")}
  scope :bloqueados, -> { where("staff")}
end
