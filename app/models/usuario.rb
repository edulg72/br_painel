class Usuario < ApplicationRecord
  self.table_name = 'usuario'
  self.primary_key = 'id'

  has_many :comentarios, class_name: 'UR', foreign_key: 'autor_comentario'
  has_many :segmentos_editados, class_name: 'Segmento', foreign_key: :updatedby
  has_many :segmentos_criados, class_name: 'Segmento', foreign_key: :createdby
end
