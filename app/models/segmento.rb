class Segmento < ActiveRecord::Base
  self.table_name = 'vw_segments'
  self.primary_key = 'id'
  
  belongs_to :rua, foreign_key: :primarystreetid, class_name: 'Rua'
  belongs_to :municipio, foreign_key: :municipioid
  belongs_to :criador, foreign_key: :createdby, class_name: 'Usuario'
  belongs_to :editor, foreign_key: :updatedby, class_name: 'Usuario'

  scope :brasil, -> { where.not(municipioid: nil)}
  scope :sangrando, -> { where(primarystreetid: nil ) }
end
