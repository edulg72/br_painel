class Segmento < ActiveRecord::Base
  self.table_name = 'vw_segmentos'
  self.primary_key = 'id'
  
  belongs_to :rua, foreign_key: :ruaid, class_name: 'Rua'
end
