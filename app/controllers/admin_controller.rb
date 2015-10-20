class AdminController < ApplicationController
  def index
  end

  def segmentos
    @segmentos = Estado.find_by(sigla: params['id']).segmentos
    @atu_seg = Atualizacao.find('segments')
  end
  
  def mapas
    @estado = Estado.all
  end

  def usuario
    @usuarios = Usuario.all.order('username')
    @editor = Editor.find_by(username: params['id'])
  end
end
