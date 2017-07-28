class Conversa < ActiveRecord::Base
  self.table_name = 'vw_conversations'

  belongs_to :comentario, foreign_key: 'comment_id', class_name: 'Comentario'
  belongs_to :editor, foreign_key: 'user_id', class_name: 'Editor'
end
