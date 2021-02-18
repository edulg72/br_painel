class Rua < ApplicationRecord
  self.table_name = 'vw_ruas'
  self.primary_key = 'id'

  belongs_to :cidade, foreign_key: :cidadeid, class_name: 'Cidade'
  has_many :segmentos, foreign_key: :primarystreetid, class_name: 'Segmento'
end
