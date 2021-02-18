class UR < ApplicationRecord
  self.table_name = 'vw_ur'
  self.primary_key = 'id'

  belongs_to :comentarista, foreign_key: 'autor_comentario', class_name: 'Usuario'
  belongs_to :operador, foreign_key: 'resolvida_por', class_name: 'Editor'
  belongs_to :municipio, foreign_key: 'municipioid'

  scope :nacional, -> { where("municipioid is not null") }
  scope :sem_comentarios, -> { where("comentarios = 0")}
  scope :com_resposta, -> { where("comentarios > 0 and autor_comentario = -1")}
  scope :sem_resposta, -> { where("comentarios > 0 and autor_comentario > 0")}
  scope :abertas, -> { where("resolvida_em is null")}
  scope :encerradas, -> { where("resolvida_em is not null")}
end
