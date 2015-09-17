class Estado < ActiveRecord::Base
  self.table_name = 'estados'
  self.primary_key = 'cd_geocuf'

  has_many :regioes, foreign_key: 'estadoid', class_name: 'Regiao'
  has_many :urs, through: :regioes
  has_many :mps, through: :regioes
  has_many :pus, through: :regioes
end
