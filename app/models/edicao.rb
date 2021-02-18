class Edicao < ApplicationRecord
  self.table_name = 'vw_edicoes'
  self.inheritance_column = 'inherit'

  belongs_to :editor, foreign_key: :user_id, class_name: 'Editor'
  belongs_to :municipio, foreign_key: :municipioid, class_name: 'Municipio'

  def url
    "https://www.waze.com/pt-BR/editor/?env=row&lon=#{self.longitude}&lat=#{self.latitude}&zoom=5&#{self.type == 'S' ? 'segments=' + self.id : 'venues=' + self.id}"
  end
end
