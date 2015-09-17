class Usuario < ActiveRecord::Base
  self.table_name = 'usuario'
  self.primary_key = 'id'

  has_many :comentarios, class_name: 'UR', foreign_key: 'autor_comentario'
end
