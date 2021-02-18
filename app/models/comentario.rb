class Comentario < ApplicationRecord
  self.table_name = 'vw_comments'
  self.primary_key = 'id'

  belongs_to :criador, foreign_key: 'created_by', class_name: 'Editor'
  belongs_to :atualizador, foreign_key: 'updated_by', class_name: 'Editor'
  belongs_to :municipio, foreign_key: 'city_id'
  has_many :conversas, foreign_key: 'comment_id'

  scope :nacional, -> { where("city_id is not null") }
end
