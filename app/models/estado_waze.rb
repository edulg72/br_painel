class EstadoWaze < ActiveRecord::Base
  self.table_name = 'estados_waze'
  self.primary_key = 'id'

  has_many :cidades, foreign_key: :estadoid
  has_many :ruas, through: :cidades
end
