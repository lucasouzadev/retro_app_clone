# Sistema visual do diário semanal

A interface usa papel claro, superfícies brancas e um acento grafite provisório. A data organiza o diário, e a mídia tem prioridade visual. A escala é uma proposta original baseada nos fluxos do mapa. Não houve medição de telas do Retro porque o inventário não contém capturas.

## Aplicação dos tokens

- O catálogo SwiftUI usa fonte de sistema com estilos semânticos e Dynamic Type. Os tamanhos em tokens.json são referências nominais. No iPhone, usar pontos, respeitar áreas seguras e evitar alturas fixas em texto.
- Usar margens laterais de 16 pt, separação de 24 pt entre seções e largura de leitura de até 520 pt. A grade de mídia pode ter três colunas em largura regular e duas se os alvos não couberem. Usar alvos de pelo menos 44 × 44 pt.
- Separar superfícies por cor e espaço. Reservar elevação para apresentações modais. Manter texto e controles em fundos sólidos, inclusive no visualizador.
- Usar SF Symbols do sistema no iPhone. Apoiar ícones de estado com texto ou rótulo acessível. Aplicar preferência por movimento reduzido e manter tema claro no catálogo até validar uma paleta escura.
- tokens.css e tailwind.css são referências para um eventual consumidor web. O catálogo nativo fica em DiaryCatalog.swift. Para abrir, inclua o arquivo em um alvo iOS com SwiftUI e execute a prévia DiaryCatalog_Previews no Xcode.

## Componentes

| Componente | Variantes, estados e comportamento | Tokens e acessibilidade | Uso |
|---|---|---|---|
| Ação | Primária, secundária e destrutiva. Padrão, pressionada, foco, indisponível e em andamento. Envio mantém rótulo e bloqueia reenvio enquanto pendente. | accent/on-accent, surface/border-input ou danger com surface. Usar Button nativo, alvo de 44 pt e indicador de foco visível. A variante destrutiva usa confirmação. | S01–S06 |
| Campo | Nome, identificador, busca e legenda opcional. Vazio, preenchido, focado, inválido e indisponível. Erro abaixo do controle. | surface, text, border-input e danger. Rótulo persistente, ordem natural de foco e associação do erro à entrada. Busca com retorno do teclado e identificador sem autocapitalização. | S01, S04, S06 |
| Avatar e identidade | Foto própria ou iniciais, com fallback em falha. Avatar acompanhado de nome em listas. | surface/text. Avatar decorativo quando o nome já está no mesmo item acessível. | S01, S02, S05, S06, S08, S09 |
| Cabeçalho de período | Semana atual, passada ou seleção. Intervalo por extenso com ano quando necessário. | text/text-muted, tipo title2 e subheadline. Marcar como cabeçalho. Mudança de semana atualiza o título lido. | S03, S05, S10 |
| Miniatura e visualizador | Foto, vídeo, item selecionado, carregando, indisponível e removido. Expor voltar, anterior, próximo e reproduzir. | Raio md, controles com fundos sólidos. Anunciar posição, tipo e seleção. Permitir navegação por controles explícitos além de gestos. | S02–S05, S08, S10 |
| Seletor e confirmação | Sem seleção, itens escolhidos, acesso limitado, cancelado, confirmando e falha recuperável. Mostrar contagem e manter a seleção após falha. | Seletor nativo e sheet. Foco no título na abertura e de volta ao acionador ao fechar. Ação confirma o destino e número de itens. | S04, S07, S09, S10 |
| Convite e compartilhamento | Buscar, enviar, pendente, aceitar, recusar e desfazer. Usar folha nativa quando houver exportação ou link. | text-muted para metadados, texto explícito para cada estado. Anunciar conclusão sem depender de cor. | S06, S08, S10 |
| Feedback | Vazio com orientação, progresso, erro recuperável e confirmação. Barra ou rótulo de progresso junto à ação. | surface, text, text-muted, danger e success. Anunciar mudanças relevantes uma vez e manter a ação de recuperação disponível. | S02–S10 |

Os componentes compartilhados com S07–S10 registram variantes futuras. O catálogo isola seis primitivas do MVP. Seletor, confirmação, compartilhamento e reprodução usam controles de plataforma na integração.

## Aplicação ao primeiro fluxo

| Tela | Estrutura e estado prioritário |
|---|---|
| S01 · Perfil inicial | Título, botão oficial Sign in with Apple e formulário curto após autenticar. Informar identificador indisponível junto ao campo. |
| S02 · Atualizações | Lista de amigos e suas semanas com mídia nova, com avatar, intervalo e miniatura. Quando vazia, oferecer a busca de amigos. |
| S03 · Meu diário | Semana atual em primeiro lugar, seguida pelo histórico. Cada semana tem ação para adicionar lembranças. Exibir uma orientação curta na primeira semana vazia. |
| S04 · Escolher e publicar | Seletor do sistema, seguido da revisão da semana de destino e da seleção. Expor progresso por item e a ação de tentar de novo. |
| S05 · Ver lembranças | Cabeçalho com autor e semana, mídia central e navegação explícita. Em perda de acesso, apresentar um estado neutro e permitir voltar ao feed. |
| S06 · Amigos | Busca por identificador exato e seções para pedidos e amizades. Diferenciar pedido enviado de recebido em texto. |

## Verificação

contrast.txt registra 17 combinações e zero falhas AA. A verificação cobre as cores sólidas declaradas. A compilação e a captura do catálogo precisam de Xcode ou simulador iOS. Validar Dynamic Type, VoiceOver, teclado externo e estados de foco quando o alvo iOS estiver disponível.

Próxima etapa: replica-build, começando pela fatia vertical descrita em architecture.md.
