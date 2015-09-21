class Rua < ActiveRecord::Base
  self.table_name = 'vw_ruas'
  self.primary_key = 'id'

  belongs_to :cidade, foreign_key: :cidadeid, class_name: 'Cidade'
  has_many :segmentos, foreign_key: :ruaid, class_name: 'Segmento' 

  scope :semnome, -> { where(semnome: true) }
  scope :sangrando, -> { where(semnome: false, nome: nil)}
end
