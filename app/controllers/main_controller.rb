class MainController < ApplicationController
  def index
    @ur=UR.nacional
    @mp=MP.nacional.abertas
    @pu=PU.nacional
    @atu_ur = Atualizacao.find('ur')
    @atu_pu = Atualizacao.find('pu')
    @nav = [{ t('nav-first-page') => '/'}]
  end

  def municipio
    @mu= Municipio.find(params['id'])
    @atu_ur = Atualizacao.find('ur')
    @atu_pu = Atualizacao.find('pu')
    @nav = [{@mu.nm_municip => "#"},{@mu.microrregiao.nm_micro => "/microrregiao/#{@mu.microrregiao.cd_geocmi}"},{@mu.microrregiao.regiao.nm_meso => "/regiao/#{@mu.microrregiao.regiao.cd_geocme}"},{@mu.microrregiao.regiao.estado.nm_estado => "/estado/#{@mu.microrregiao.regiao.estado.sigla}"},{ t('nav-first-page') => '/'}]
  end

  def microrregiao
    @mr= Microrregiao.find(params['id'])
    @atu_ur = Atualizacao.find('ur')
    @atu_pu = Atualizacao.find('pu')
    @nav = [{@mr.nm_micro => "#"},{@mr.regiao.nm_meso => "/regiao/#{@mr.regiao.cd_geocme}"},{@mr.regiao.estado.nm_estado => "/estado/#{@mr.regiao.estado.sigla}"},{ t('nav-first-page') => '/'}]
  end

  def regiao
    @regiao= Regiao.find(params['id'])
    @atu_ur = Atualizacao.find('ur')
    @atu_pu = Atualizacao.find('pu')
    @nav = [{@regiao.nm_meso => "#"},{ @regiao.estado.nm_estado => "/estado/#{@regiao.estado.sigla}"},{ t('nav-first-page') => '/'}]
  end

  def estado
    @estado= Estado.find_by sigla: params['id']
    @atu_ur = Atualizacao.find('ur')
    @atu_pu = Atualizacao.find('pu')
    @nav = [{ @estado.nm_estado => "#"},{ t('nav-first-page') => '/'}]
  end

  def staff
    @places = PU.bloqueados.nacional
    @atu_pu = Atualizacao.find('pu')
    @nav = [{t('blocked-places') => "#"},{ t('nav-first-page') => '/'}]
  end

  def pendentes
    @places = PU.nacional.editaveis
    @estados = Estado.all
    @atu_pu = Atualizacao.find('pu')
    @nav = [{t('unapproved-places') => "#"},{ t('nav-first-page') => '/'}]
  end

  def mps
    @mps = MP.nacional
    @estados = Estado.all
    @atu_mp = Atualizacao.find('ur')
    @nav = [{t('mps') => "#"},{ t('nav-first-page') => '/'}]
  end

  def options
    @wme_url = (cookies[:wme_url].nil? ? 'https://www.waze.com/' : cookies[:wme_url])
    @wme_language = (cookies[:wme_language].nil? ? 'pt-BR/' : cookies[:wme_language])
    @nav = [{'Opções de visualização' => "#"},{ t('nav-first-page') => '/'}]
  end

  def save
    cookies.permanent[:wme_url] = params['wme_url']
    cookies.permanent[:wme_language] = params['wme_language']
    redirect_to action: 'index'
  end
end
