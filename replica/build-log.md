# Primeira fatia do diário no iPhone

O protótipo roda com perfis de demonstração e dados em memória na mesma instalação. Fechar o processo reinicia o estado. O seletor usa a galeria do iOS.

## Abrir em um Mac

Com Xcode e [XcodeGen](https://github.com/yonaskolb/XcodeGen) instalados, a partir da raiz do workspace:

```sh
cd ios
xcodegen generate
open DiarioSemanal.xcodeproj
```

Selecione o esquema DiarioSemanal e um simulador de iPhone com iOS 17 ou posterior. Adicione uma foto à galeria do simulador antes de executar o roteiro.

## Roteiro de verificação pendente

1. Entre como Lia. Em Amigos, busque caio e envie o pedido.
2. Troque para Caio. Em Amigos, aceite o pedido de Lia.
3. Troque para Lia. Em Diário, selecione e publique uma foto na semana atual.
4. Troque para Caio. Em Novidades, abra a foto publicada por Lia.
5. Troque para Noa. Confirme que a foto de Lia está ausente. Desfaça a amizade pela conta de Caio e confirme que ela também desaparece das novidades dele.

## Registro de telas

| Tela | Data | Estado | Implementação e pendências |
|---|---|---|---|
| S01 | 2026-11-10 | Parcial | Seleção e criação de perfis locais. Falta Sign in with Apple e edição de perfil. |
| S02 | 2026-11-10 | Parcial | Feed vazio ou preenchido conforme amizade local. Falta sincronização e paginação. |
| S03 | 2026-11-10 | Parcial | Semana atual e listagem por semana. Falta edição retroativa e persistência. |
| S04 | 2026-11-10 | Parcial | Escolha e prévia de uma foto, carregamento e erro. Falta vídeo, seleção múltipla e upload de rede. |
| S05 | 2026-11-10 | Parcial | Visualização individual de foto com verificação de amizade local. Falta sequência e reprodução de vídeo. |
| S06 | 2026-11-10 | Parcial | Busca exata, pedido, aceite, recusa, cancelamento e remoção locais. Falta API. |
| S07–S10 | 2026-11-10 | Fora do recorte | Álbuns, mensagens e resumos são extensões. |

Validação no Windows limitada à inspeção dos arquivos e da matriz. Compilação, execução, acessibilidade e capturas dependem de Xcode. O diretório de trabalho não contém repositório Git para commits por tela.

Próxima etapa técnica após verificar a fatia local: integrar identidade, banco e mídia privada com replica-backend.
