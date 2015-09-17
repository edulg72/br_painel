class Regiao < ActiveRecord::Base
  self.table_name = 'regioes'
  self.primary_key = 'cd_geocme'

  belongs_to :estado, foreign_key: 'estadoid', class_name: 'Estado'
  has_many :microrregioes, foreign_key: 'regiaoid', class_name: 'Microrregiao'
  has_many :urs, through: :microrregioes
  has_many :mps, through: :microrregioes
  has_many :pus, through: :microrregioes
end
