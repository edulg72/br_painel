class Editor < ActiveRecord::Base
  self.table_name = 'usuario'
  self.primary_key = 'id'

  has_many :atendimentos, class_name: 'UR', foreign_key: 'resolvida_por'
  has_many :mps, class_name: 'MP', foreign_key: 'resolvida_por'
  has_many :edicoes, class_name: 'Edicao', foreign_key: 'user_id'
end
