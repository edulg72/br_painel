class Municipio < ActiveRecord::Base
  self.table_name = 'municipios'
  self.primary_key = 'cd_geocmu'

  belongs_to :microrregiao, foreign_key: 'microrregiaoid', class_name: 'Microrregiao'
  has_many :urs, foreign_key: 'municipioid', class_name: 'UR'
  has_many :mps, foreign_key: 'municipioid', class_name: 'MP'
  has_many :pus, foreign_key: 'municipioid', class_name: 'PU'
  has_many :comentarios, foreign_key: 'city_id', class_name: 'Comentario'
  has_many :segmentos, foreign_key: 'municipioid', class_name: 'Segmento'
  has_many :edicoes, foreign_key: 'municipioid', class_name: 'Edicao'
end
