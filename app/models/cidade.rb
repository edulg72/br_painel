class Cidade < ApplicationRecord
  self.table_name = 'vw_cidades'
  self.primary_key = 'id'

  belongs_to :estado_waze, foreign_key: :estadoid
  has_many :ruas, foreign_key: :cidadeid, class_name: 'Rua'
  has_many :segmentos, through: :ruas
end
