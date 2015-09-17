class MP < ActiveRecord::Base
  self.table_name = 'vw_mp'

  belongs_to :operador, foreign_key: 'resolvida_por', class_name: 'Editor'
  belongs_to :municipio, foreign_key: 'municipioid'

  scope :nacional, -> { where("municipioid is not null") }
  scope :abertas, -> { where("resolvida_em is null")}
  scope :encerradas, -> { where("resolvida_em is not null")}
end
