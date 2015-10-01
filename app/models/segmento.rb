class Segmento < ActiveRecord::Base
  self.table_name = 'vw_segments'
  self.primary_key = 'id'
  
  belongs_to :rua, foreign_key: :primarystreetid, class_name: 'Rua'
  scope :sangrando, -> { where(primarystreetid: nil) }
end
