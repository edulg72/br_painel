module MainHelper

def tipo_ur(tipo)
  ur = {6 => "Conversão incorreta",7 => "Endereço incorreto",8 => "Rota incorreta",9 => "Rotatória inexistente",10 => "Erro geral",11 => "Conversão proibida",12 => "Junção incorreta",13 => "Viaduto/Ponte inexistente",14 => "Sentido de condução incorreto",15 => "Saída inexistente",16 => "Via inexistente",18 => "Faltando ponto de referência",19 => "Via bloqueada",21 => "Rua sem nome",22 => "Prefixo ou sufixo de rua incorreto",23 => "Limite de velocidade inválido ou ausente"}
  return ur[tipo]
end

def icone_ur(tipo)
  icone = {6 => "fa-share", 7 => "fa-envelope", 8 => "fa-code-fork", 9 => "fa-circle-o-notch", 10 => "fa-exclamation-triangle", 11 => "fa-minus-circle", 12 => "fa-arrows", 13 => "fa-exclamation-triangle", 14 => "fa-exchange", 15 => "fa-sign-out", 16 => "fa-eraser", 18 => "fa-tree", 19 => "fa-flag", 21 => "fa-exclamation-triangle", 22 => "fa-exclamation-triangle", 23 => "fa-dashboard"}
  return icone[tipo]
end

def tipo_mp(tipo)
  problema = { 1 => "Detectado segmento desalinhado", 2 => "Detectado segmento flutuante", 3 => "Detectado ausência de nó", 5 => "Detectado segmentos sobrepostos", 6 => "Detectado problema na rota (segmento sem saída)", 7 => "Detectado tipo de via inconsistente", 8 => "Detectado segmento curto", 10 => "Detectado muitos segmentos conectados ao nó", 11 => "Detectado inconsistência no sentido do segmento", 12 => "Detectado nós desnecessários", 13 => "Detectado conexão de rampa imprópria", 14 => "Detectado elevação de via errada", 15 => "Detectado conversão acentuada demais", 16 => "Detectada via com pedágio irregular", 17 => "Detectado segmento sem detalhes", 19 => "Detectado segmento irregular na rotatória", 20 => "Detectado segmento irregular na rotatória", 21 => "Detectado nome de rua errado", 22 => "Detectado terminação inválida", 50 => "Estacionamento inserido como ponto", 51 => "Local não alcançável", 52 => "Local faltando do mapa Waze", 53 => "Locais não correspondentes", 70 => "Estacionamento inexistente", 71 => "Estacionamento inexistente", 101 => "Sentido de condução incompatível", 102 => "Faltando junção", 103 => "Via inexistente", 104 => "Falta junção no cruzamento das vias", 105 => "Tipo de via incompatível", 106 => "Conversão restrita pode ser permitida", 200 => "Rota sugerida frequentemente ignorada", 300 => "Pedido de Interdição de Via"}
  return problema[tipo]
end

def tipo_pu(tipo,subtipo)
=begin
  "update_requests":{
    "panel":{
      "flag_title":{
        "IMAGE":"Foto marcada",
        "VENUE":"Local marcado"
      },
      "title":{
        "ADD_VENUE":"Novo local",
        "DELETE_VENUE":"Local removido",
        "UPDATE_VENUE":"Novas informações para o local",
        "ADD_IMAGE":"Nova imagem"
      },
      "action":{
        "open":"Aberto",
        "approve":"Aprovar",
        "reject":"Recusar",
        "reject_flag":"Ignorar marcação",
        "add_to_map":"Adicionar ao mapa",
        "solved":"Resolvido",
        "merge":"Mesclar locais",
        "delete":"Excluir local",
        "delete_picture":"Excluir imagem"
      },
      "place_deleted":"Local excluído",
      "flag_reason":"Motivo da marcação:"
    },
    "flags":{
      "CLOSED":"Local fechado",
      "MOVED":"Mudança de endereço",
      "RESIDENTIAL":"Residencial (casa)",
      "DUPLICATE":"Duplicado de",
      "INAPPROPRIATE":"Inapropriado",
      "WRONG_DETAILS":"Informações erradas",
      "LOW_QUALITY":"Baixa qualidade",
      "UNRELATED":"Sem relação",
      "OTHER":"Outro"
    }
  }
=end
end

end
