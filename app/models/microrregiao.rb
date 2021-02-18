class Microrregiao < ApplicationRecord
  self.table_name = 'microrregioes'
  self.primary_key = 'cd_geocmi'

  belongs_to :regiao, foreign_key: 'regiaoid', class_name: 'Regiao'
  has_many :municipios, foreign_key: 'microrregiaoid', class_name: 'Municipio'
  has_many :urs, through: :municipios
  has_many :mps, through: :municipios
  has_many :pus, through: :municipios
  has_many :comentarios, through: :municipios
  has_many :segmentos, through: :municipios
end
