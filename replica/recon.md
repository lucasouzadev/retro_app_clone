# Retro — mapa funcional para iPhone

| Fonte pública | Evidência usada |
|---|---|
| [A · App Store Brasil](https://apps.apple.com/br/app/retro-fotos-com-amigos/id6443709020) | Plataforma, diário semanal, edição retroativa, privacidade social, recursos adicionais e histórico de versões. |
| [B · App Store EUA](https://apps.apple.com/us/app/retro-photos-with-friends/id6443709020) | Seleção editorial sobre o feed entre amigos, widgets e relato de usuário sobre gestos no visualizador. |
| [C · Retro Ethos](https://retro.app/ethos) | Seleção de lembranças e incentivo à participação semanal. |
| [D · Política de privacidade](https://retro.app/privacy) | Dados do cadastro, perfil, busca de amigos e mensagens. |
| [E · Termos do Retro](https://retro.app/terms) | Restrições ao uso do serviço para competir e à engenharia reversa do software. |

## Escopo

iPhone, com foco em pequenos círculos de amigos e familiares como público presumido. O recorte inicial é selecionar fotos da galeria, publicá-las em uma semana do diário, revisitar semanas e acompanhar amigos. Álbuns, chat e resumos aparecem no mapa como extensões. Pesquisa documental, sem sessão autenticada ou inspeção técnica. Nenhuma captura foi arquivada nesta passagem.

## Inventário de telas e superfícies

IDs representam superfícies funcionais. A existência do recurso pode estar documentada mesmo quando a tela dedicada, os controles e o caminho são inferidos. Os casos na última coluna são pontos de validação, salvo quando indicados como documentados.

| ID | Superfície | Entrada provável e objetivo | Componentes e evidência | Estados |
|---|---|---|---|---|
| S01 | Cadastro e perfil inicial | Primeiro acesso, criar conta | Nome, usuário, telefone e foto opcional documentados em D. Ordem e verificação a confirmar. | Campos incompletos, número inválido, falha de verificação se houver |
| S02 | Início / atualizações de amigos | Após entrar, ver novidades | Feed entre amigos documentado em B. Cards por pessoa e indicação de novidade inferidos. | Sem amigos, sem novidades, carregando, preenchido |
| S03 | Diário pessoal / perfil | Pelo próprio perfil, revisitar semanas | Semanas editáveis e preenchimento retroativo em A. Cabeçalhos e miniaturas inferidos. | Semana atual ou passada (A), diário vazio |
| S04 | Seletor de mídia | A partir de uma semana, escolher itens da galeria | Fotos e vídeos existentes em A. Grade, seleção múltipla e confirmação na mesma superfície a validar. | Acesso limitado ou negado, seleção vazia, envio pendente ou falho |
| S05 | Visualizador semanal | De S02 ou S03, percorrer mídia | Mídia e curtida privada em A. Toque para avançar e gesto para trocar de amigo são relatados em B. | Último item, vídeo carregando, mídia removida, curtido |
| S06 | Encontrar amigos / convites | Acesso a confirmar, adicionar pessoas | Busca ou indicação apoiada por D. Busca por usuário, estados do convite e aceite são inferidos. | Sem resultados, convite pendente, aceite, contatos indisponíveis |
| S07 | Álbuns / criação | Entrada a confirmar, iniciar coleção privada | Criação de álbum privado com link em A/B. Lista e formulário como superfícies inferidas. | Nenhum álbum, criação pendente ou falha |
| S08 | Álbum privado | A partir de S07 ou de convite | Mídia, notas e link documentados em A/B. Grade e controles de membros inferidos. | Vazio, com contribuições, acesso negado ou link inválido |
| S09 | Mensagens | Área Mensagens, iniciar ou abrir grupo | Conversas em grupo em A/B. Lista, seleção de participantes e compositor inferidos. | Sem conversas, envio pendente ou falho |
| S10 | Criador de resumo | Entrada a confirmar, gerar e exportar lembrança | Períodos, colagem, vídeo e compartilhamento em A/B. Prévia inferida. | Sem mídia no período, renderização, exportação cancelada ou falha |

## Fluxos

As contagens são estimativas de ações deliberadas no caminho modelado, com uma mídia quando aplicável. Excluem digitação, navegação do sistema e permissões. Nenhuma contagem foi medida no app.

| ID | Objetivo e percurso | Ações estimadas | Casos a validar |
|---|---|---|---|
| F01 | Criar conta em S01 e chegar a S03 ou S02 | Indeterminável | Validação de telefone, recuperação, pular avatar |
| F02 | Publicar uma lembrança. S03 → escolher semana → S04 → selecionar → confirmar → S03 | 4 | Acesso parcial à galeria, upload interrompido, duplicação em nova tentativa, mudança de semana no fuso do usuário |
| F03 | Revisitar e editar semana anterior. S03 → semana → S05 ou S04 → alterar → salvar | 4–5 | Semana vazia, remoção do último item, edição simultânea |
| F04 | Adicionar amigo. S06 → localizar → enviar convite → destinatário aceita → S02 | 3–4 entre duas pessoas | Convite duplicado, cancelado, contatos negados |
| F05 | Ver e reagir. S02 → abrir amigo em S05 → avançar opcionalmente → curtir | 2–3 | Nenhuma mídia nova, fim da sequência, vínculo removido |
| F06 | Compartilhar álbum. S07 → criar → S08 → compartilhar link → convidado abre → contribui | 6–8 entre duas pessoas | Convite expirado, destinatário sem acesso, upload parcial |
| F07 | Conversar em grupo. S09 → novo grupo → selecionar membros → redigir → enviar | 4–5 | Grupo vazio, falha de envio, acesso removido |
| F08 | Exportar resumo. S10 → escolher período → escolher formato → gerar → compartilhar | 4–5 | Sem fotos, renderização interrompida, destino indisponível |

## Componentes recorrentes

| Componente | Superfícies | Variações e estados a cobrir |
|---|---|---|
| Avatar e identidade | S01, S02, S05, S06, S08, S09 | Com imagem, iniciais, imagem indisponível |
| Cabeçalho de período | S03, S05, S10 | Semana atual ou passada, seleção de semana/mês/ano em resumo |
| Miniatura e visualizador | S02–S05, S08, S10 | Foto, vídeo, seleção, carregamento e erro |
| Seletor e confirmação | S04, S07, S09, S10 | Seleção vazia, confirmação disponível, operação em andamento |
| Convite / compartilhamento | S06, S08, S10 | Convidar, copiar link, abrir menu do sistema, falha |
| Ações e feedback | S02–S10 | Estado vazio, progresso, falha recuperável e confirmação |

## Modelo de dados inferido

Campos são propostas conceituais. A confiança se refere à necessidade da entidade e de seus atributos observáveis, não ao esquema interno do Retro.

| Entidade | Campos candidatos e relações | Evidência e confiança |
|---|---|---|
| Conta / perfil | id, nome, usuário, telefone, avatar opcional. Uma conta possui várias semanas. | D documenta os dados. Alta. |
| Vínculo de amizade | solicitante, destinatário, estado. Liga duas contas. | A documenta amizades privadas, D menciona busca. Média para vínculo, baixa para estados. |
| Semana do diário | autor, início da semana, fuso ou regra de calendário. Agrupa itens. | A confirma agrupamento e preenchimento retroativo. Alta para agrupamento, baixa para calendário interno. |
| Item de mídia | autor, tipo, referência de mídia, data de captura, ordem, semana ou álbum. | A confirma fotos e vídeos em semanas e álbuns. Alta para mídia, média para relação e ordem. |
| Reação | ator, alvo, tipo, data. Alvo pode ser item ou publicação semanal. | A confirma curtida privada. Média, alvo exato e visibilidade a validar. |
| Álbum / membro / convite | álbum, criador, membros, papel, referência do link. Álbum reúne mídia e notas. | A/B confirmam álbum privado, link e contribuições. Média. |
| Conversa / mensagem | conversa, participantes, autor, conteúdo, data. | A/B confirmam chat em grupo. Média, tipos de mensagem do chat a validar. |
| Resumo | autor, período, formato, itens, referência de saída opcional. | A/B confirmam períodos e exportação. Alta para recurso, baixa para persistência. |

## Limites e porte

Marca, textos, imagens promocionais, fotos, contas, rede social e dados do Retro ficam excluídos. Impressão e envio de postais dependem de operação e parceiros próprios. Widgets, chat, álbuns e resumos ficam fora do primeiro recorte, mesmo quando documentados.

**M para o recorte inicial**, em ordem de algumas semanas para um MVP. **L para incluir as extensões**, dado o trabalho de mídia e sincronização, controle de audiência e convites, e renderização e exportação de resumos. O mapa tem 10 superfícies, 8 fluxos e 8 grupos de entidades. Os pontos mais incertos são a navegação real, as regras exatas de audiência e a atribuição das mídias à semana.

Próxima etapa, após validação do recorte: replica-architect.
