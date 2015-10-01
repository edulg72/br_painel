class MainController < ApplicationController
  def index
    @ur=UR.nacional
    @mp=MP.nacional
    @pu=PU.nacional
    @atu_ur = Atualizacao.find('ur')
    @atu_pu = Atualizacao.find('pu')
  end
  
  def municipio
    @mu= Municipio.find(params['id'])
    @atu_ur = Atualizacao.find('ur')
    @atu_pu = Atualizacao.find('pu')
  end

  def microrregiao
    @mr= Microrregiao.find(params['id'])
    @atu_ur = Atualizacao.find('ur')
    @atu_pu = Atualizacao.find('pu')
  end

  def regiao
    @regiao= Regiao.find(params['id'])
    @atu_ur = Atualizacao.find('ur')
    @atu_pu = Atualizacao.find('pu')
  end

  def estado
    @estado= Estado.find_by sigla: params['id'] 
    @atu_ur = Atualizacao.find('ur')
    @atu_pu = Atualizacao.find('pu')
  end

  def segmentos
    @segmentos = Segmento.all
    @atu_seg = Atualizacao.find('segments')
  end
end
