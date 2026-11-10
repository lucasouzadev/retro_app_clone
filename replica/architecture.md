# Arquitetura do diário semanal para iPhone

## Stack e decisões de produto

| Camada | Escolha | Motivo |
|---|---|---|
| iPhone | SwiftUI e seletor nativo de fotos | O recorte é iOS e o seletor pode fornecer apenas os itens escolhidos. |
| Identidade | Sign in with Apple e sessão emitida pela API | Evita operação de SMS. Nome de exibição e identificador social são escolhidos no perfil. |
| API | Um serviço TypeScript hospedado em contêiner gerenciado | Centraliza autenticação, regras de audiência e emissão de credenciais temporárias. |
| Dados | Um PostgreSQL gerenciado e SQL parametrizado | Restrições de unicidade e transações cobrem amizade, semanas e publicação. |
| Mídia | Bucket privado compatível com S3 | Upload direto para área temporária. A API controla a publicação e a leitura. |
| Tarefas | Agendador do provedor executando comandos do mesmo serviço | Remove uploads abandonados e conclui exclusões com tentativas repetíveis. |

Busca por identificador exato, sem agenda de contatos. Feed cronológico. Semanas começam na segunda-feira e são escolhidas pelo autor. Curtidas, quando entrarem, são visíveis ao autor da foto e a quem curtiu. Essas são decisões para o produto novo.

## Dados e acesso

O [schema.sql](schema.sql) define cinco tabelas. Perfis guardam identidade, amizades formam pares únicos, semanas agrupam mídia, itens acompanham o estado de publicação e reações guardam uma curtida por pessoa e item. A semana é uma data civil. Instantes são gravados como timestamptz. O fuso IANA validado pela API determina a sugestão de semana atual. Alterar o fuso preserva os agrupamentos anteriores.

O banco fica em rede privada e é acessado somente pela API e pelo processo de manutenção. O papel da API é distinto do dono do schema. O cliente recebe sessão da aplicação, sem credenciais de banco. Toda consulta é parametrizada e aplica a regra de acesso na própria consulta ou em transação. Para ler mídia publicada, a conta deve ser dona ou ter amizade aceita com o autor ativo. Conteúdo pendente ou removido, fila de exclusão e chaves de objeto ficam fora das respostas. Só o dono altera suas semanas e mídias. Só o destinatário aceita o pedido. Somente participantes podem ver ou desfazer o vínculo. Busca exata retorna apenas identificador e nome de perfis ativos, com limite por sessão e IP.

## API do MVP

| Método e rota | Operação | Quem | Entrada → saída | Fluxo |
|---|---|---|---|---|
| POST /sessions/apple | Validar identidade e emitir sessão | Portador de credencial Apple válida | Token e nonce validado → sessão curta e estado de cadastro | F01 |
| PUT /me | Criar ou editar perfil | Titular autenticado | Nome, identificador, fuso → perfil | F01 |
| DELETE /me | Desativar conta e enfileirar exclusão | Titular com autenticação recente | Sessão → 202 | F01 |
| GET /me/weeks | Listar diário próprio | Titular | Cursor → semanas e itens publicados | F02/F03 |
| POST /me/uploads | Reservar item e autorizar upload temporário | Titular | Semana, tipo, tamanho, chave de repetição → id e destino temporário | F02/F03 |
| PUT /me/media/:id/publication | Validar objeto e publicar | Titular do item | id → item publicado | F02/F03 |
| PATCH /me/media/:id | Mover item entre semanas ou editar legenda | Titular do item | Semana ou legenda → item atualizado | F03 |
| DELETE /me/media/:id | Ocultar item e agendar remoção física | Titular do item | id → 204 | F03 |
| GET /people | Buscar perfil por identificador exato | Conta ativa | Identificador → perfil mínimo ou vazio | F04 |
| GET /me/friendships | Listar vínculos próprios | Participante | Cursor e estado → vínculos | F04 |
| POST /me/friendships | Solicitar amizade | Conta ativa | Destinatário → vínculo pendente ou existente | F04 |
| PUT /me/friendships/:id/acceptance | Aceitar amizade | Destinatário | id → vínculo aceito | F04 |
| DELETE /me/friendships/:id | Recusar, cancelar ou desfazer vínculo | Participante | id → 204 | F04 |
| GET /feed | Listar atividade de amigos | Conta ativa | Cursor opaco → autores e semanas com atividade | F05 |
| GET /people/:id/weeks/:weekStart | Abrir semana no visualizador | Autor ou amigo aceito | Autor e semana → mídia ordenada | F05 |
| GET /media/:id/content | Autorizar leitura de mídia | Autor ou amigo aceito | id → URL de leitura curta | F05 |
| PUT /media/:id/reaction | Curtir | Amigo autorizado | id → curtida própria | F05 |
| DELETE /media/:id/reaction | Remover curtida | Autor da reação | id → 204 | F05 |

F06 a F08 ficam para uma revisão de arquitetura após o MVP. Não há webhooks de produto nesta fase. Ao integrar Apple, a exclusão deve incluir revogação da credencial conforme o fluxo oficial aplicável.

## Mídia, concorrência e manutenção

- **Upload e publicação.** Usar chave temporária distinta da chave publicada. Ao finalizar, validar bytes, tipo e limites e processar exatamente o conteúdo validado para a chave privada de publicação. Remover metadados de localização. Apenas o serviço escreve nessa chave. Marcar como publicado após confirmar a gravação. Repetir com a mesma chave de operação devolve o item anterior e parâmetros divergentes retornam conflito. Publicar e excluir disputam a mesma linha. Uma tentativa repetida após exclusão não republica.
- **Permissões e custo.** Começar com limites propostos de 20 MB por foto e 100 MB por vídeo, sujeitos a teste em rede móvel. Limitar reservas e rejeitar objetos inválidos antes da publicação. Negar novas URLs após revogação de amizade. URLs já emitidas podem valer até o vencimento, proposto em 60 segundos. Para revogação imediata, servir mídia pela API com autorização a cada requisição.
- **Corridas e ordenação.** A unicidade por par impede pedidos cruzados duplicados. O pedido inverso retorna o vínculo existente e o destinatário decide aceitar. Ordenar feed por publicação e ID com paginação por cursor. Criar semanas por inserção com resolução de conflito. Rascunho local pode sobreviver a interrupção de rede e repetir a operação pela mesma chave.
- **Limpeza.** A cada hora, invalidar reservas com mais de 24 horas e apagar objetos temporários e finais de itens marcados para exclusão. Apagar a linha só após confirmar remoção física e expiração da autorização de upload. O trabalho pode ser repetido após falha. Na exclusão de conta, desativar primeiro para fechar acesso, marcar mídia para limpeza e apagar perfil após concluir mídia e revogação de identidade. A retenção de backups fica a definir antes de produção.
- **Atualização.** Recarregar ao abrir o app ou puxar para atualizar. O primeiro recorte não exige entrega em tempo real nem edição offline.

## Ordem de implementação

1. **Fatia vertical.** S01–S06. Dois usuários entram, criam perfil, estabelecem amizade, publicam uma foto na semana atual e a abrem pelo feed. Usar perfis, vínculos, semanas e mídias. Cobrir sessões, perfil, busca, pedido, aceite, reserva, publicação, feed, detalhe e leitura de mídia. Aceite de segurança com três contas: A publica, B amigo lê e C não tem acesso. Após desfazer a amizade, B deixa de obter novas URLs.
2. **Completar itens essenciais.** S03–S06. Usar as mesmas quatro tabelas para semanas antigas, vídeo, movimentação e remoção de itens, listagem e remoção de vínculo, exclusão de conta e limpeza. Exercitar upload interrompido, tentativa repetida e seleção limitada de fotos.
3. **Melhorias.** S04 e S05. Ativar legenda e curtidas privadas, com a quinta tabela e rotas de reação. O visualizador apresenta o estado da curtida sem contagem pública.
4. **Extensões.** S07–S10 em rodada própria. Priorizar depois de validar o uso do diário semanal.

Próxima etapa: replica-design, com estados de primeiro uso, publicação em andamento, diário vazio e visualização sem acesso.
