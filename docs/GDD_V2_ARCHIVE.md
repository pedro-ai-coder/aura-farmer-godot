# Aura Farmer — GDD V2.0 · Base consolidada para refactor

> **Approved platform amendment — 21 October 2026:** The Godot edition is a shared cross-platform product targeting **Web, Android and iOS with equal priority**. The new §23 below supersedes all earlier references to "browser-only" milestones, native applications as future/nice-to-have, and a Web-first platform sequence. Historical delivery reports remain historical facts. It does **not** expand the approved solo character, weapon, or passive roster, nor authorize release, extra costs or gameplay rule changes.

**Revisão:** 14 outubro 2026. **Estado:** base de design consolidada para o refactor do repositório existente. Direção visual A e primeiro lote de assets aprovados pelo criador; implementação e validação em runtime ainda pendentes. As decisões expressas pelo criador são requisitos. Em 14 outubro 2026, o criador aprovou todas as alterações propostas no ponto 20 da V1.1: catálogo final, nomenclatura, kits, valores iniciais, pausa co-op, revive, XP e oferta lendária operacional. Os valores ficam aprovados para implementação e sujeitos a balanceamento, ainda sem validação em jogo. Este documento não declara funcionalidades implementadas nem lançamento aprovado.


## Estado da implementação browser — 15 outubro 2026

Esta secção atualiza o estado técnico; as notas de entrega documental e arte estática mais abaixo descrevem a revisão de 14 outubro, não o runtime atual. A decisão mais recente do criador (15 outubro) exige um PR identificado por fase/iteração e aprovação explícita desse PR antes de merge; substitui a autorização anterior de integração autónoma. Mantêm-se a proibição de custos adicionais e de anúncio/publicidade.

A base solo da secção 17 foi integrada em `main` pelo PR #52: Ruin Alley, Sigma/Cool Kid/Alpha, nove armas no total, três por tipo, 3 slots de armas e 5 de passivas, escolhas com confirmação/substituição, progressão por XP, aura e Flex individuais, cinco waves de 180 s, eventos e Big Hater com berserk aos 180 s do encontro. Save v2 preserva IDs, desbloqueios e uma cópia dos dados v1, sem modificar a chave antiga.

Subset oferecido: as dez passivas common; No Cap Streak, W Wi-Fi, Let Him Cook, Homie Check e Big Chad Energy; It's So Over, Aura Goes Viral, We Are So Back e Six → Seven; e as quatro lendárias. Get Ratio'd, Ego Check, Uno Reverse, Brainrot Rain e Take the L ficam fora desta fatia. Não são oferecidos itens incompatíveis nem funcionalidades de equipa fictícias.

A apresentação usa o mapa e retratos PNG aprovados, com cobertura e limite de circulação explícitos. Os novos atlas em `public/assets/runtime/` acrescentam poses dos três heróis e silhuetas das famílias inimigas. **O acabamento de animação ainda não cumpre integralmente A.5**: direções de Alpha/Cool Kid precisam de revisão e os inimigos usam poses estáticas com avisos de ataque. Ícones funcionais tipográficos ainda não são o catálogo ilustrado final. Não apresentar este passe como aprovação artística final.

Correções de apresentação (15 outubro): HUD acompanha os limites reais do canvas, incluindo janelas largas; atlas dos heróis usa recortes individuais em vez de grelha uniforme, escala proporcional e pose de derrota correta. A animação de deslocação segue o movimento, independentemente da mira automática. Cool Kid reutiliza uma diagonal espelhada; Alpha continua sem poses traseiras dedicadas. Estas correções não completam A.5.

Validação organizada por iteração: os PRs #53 e #54 foram aprovados e integrados. A iteração 3 fecha a cobertura integrada de regras, resultados e saves; os resultados dos gates de cada commit ficam na descrição do respetivo PR. A revisão artística e a aceitação da primeira versão completa continuam nas fases 2–6. O balanço dos níveis-alvo, desempenho em máquina de referência e os detalhes de todos os ataques lendários ainda exigem playtest. Discord, mobile, seis personagens adicionais, restantes passivas, novos mapas, co-op, PvP, ranked e passe não estão implementados nesta entrega.

## Plano da primeira versão de testes web — decisão de 15 outubro

Mesmo jogo no browser de computador e telemóvel, sem aplicação nativa. Apenas Sigma, Cool Kid e Alpha Chad, nove armas e o subset explícito de 23 passivas acima. Discord, multiplayer, PvP, backend, contas e monetização ficam fora desta primeira versão de testes.

Fases: 1 — regras; 2 — sprites/animações; 3 — interface e controlos desktop/mobile; 4 — combate/dificuldade; 5 — estabilidade/desempenho; 6 — publicação e organização. A fase 1 tem três iterações, cada uma com PR próprio: (1) personagens/equipamento; (2) partida/progressão; (3) validação e fecho. Todos os merges dependem da aprovação explícita do criador.

### Fase 1 · Iteração 1 — Personagens e equipamento

Base: merge do PR #52, `f90f2a7`. Mantém IDs, saves, três personagens, nove armas e 23 passivas. Corrige escudos de armas por raridade/nível, efeitos e stacks ao substituir passivas (preservando cooldowns), ataques secundários lendários com bónus de arma sem procs, projéteis atrasados de Ratio, contagem de acertos de Chad Hands, dano direto no traço de Alpha e taunt solo. Regressões verificam compatibilidade, caps, promoções e efeitos do catálogo ativo.

Esta iteração não conclui as animações nem valida mobile ou o equilíbrio de uma partida inteira. Waves, XP e fluxo completo são objeto da iteração 2; persistência e validação integrada da fase são objeto da iteração 3. Os testes existentes desses fluxos continuam obrigatórios para detetar regressões.

### Fase 1 · Iteração 2 — Partida e progressão

Base: PR #53 integrado, `e06522b`. Corrige a cura de subida de nível para apenas 2 HP, a seleção de categoria antes da raridade nas ofertas normais e a pausa imediata das escolhas geradas nas transições. Mantém os valores de XP, aura, waves e a oferta lendária única, incluindo adiamento sem reroll e expiração às 14:55.

Temporizadores auxiliares dos eventos passam a ser independentes dos ataques principais: adds de Reply Guy a cada 12 s, linhas de Mod Supremo a cada 10 s e zonas de Doomscroll Prime a cada 7 s. Reforços de Mod Supremo reagem à vida sem esperar pelo próximo ataque. Limiares de Big Hater ficam desbloqueados após serem atingidos, mesmo que a regeneração aumente a vida. Vitória/derrota interrompem a resolução de combate e impedem XP ou dano posteriores ao resultado.

Cobertura desta iteração: fronteiras de XP/nível25, quatro transições e quatro eventos, prioridade/fila/expiração da lendária, recolha dos orbes e retirada de ameaças aos 15:00, adds sem XP, berserk recuperável e fim da run. São testes determinísticos e fluxos de browser com estado controlado; não comprovam o balanceamento de uma partida normal nem desempenho mobile. Validação integrada/persistência continua na iteração 3; animações, mobile e afinação aprofundada continuam nas fases seguintes. Merge deste PR depende de aprovação explícita.

### Fase 1 · Iteração 3 — Validação e fecho

Base: PR #54 integrado, `e694477`. Não expande o catálogo nem altera os valores de balanceamento. Resultados só podem ser registados depois de vitória/derrota; runs em curso ou abandonadas não aumentam contadores nem desbloqueios. Leitura do save v2 normaliza estatísticas incompletas/corrompidas e elimina IDs de resultado duplicados, mantendo os totais acumulados, IDs desbloqueados, preferências e snapshot v1. Mantém o esquema/chave v2; não há migração destrutiva nem gravação de equipamento permanente.

Escape na confirmação de saída cancela a confirmação e volta à pausa, sem retomar combate por trás da modal. Teclas de movimento premidas durante modais não ficam memorizadas para a retoma. Reinício limpa equipamento, aura, nível, escolhas, timers e estado de resultado; as preferências e o progresso de perfil persistem.

| Contrato da fase 1 | Evidência automatizada |
|---|---|
| Três personagens, nove armas, 23 passivas, slots e caps | `gdd.test.ts`, `equipment.test.ts` |
| XP/aura, waves, lendária, eventos e berserk | `progression.test.ts`, fluxos Chromium |
| Relógio contínuo desde o início pelas cinco waves com cada personagem | `run-lifecycle.test.ts`: seed 451, movimento/armas/drops/ofertas reais; proteção contra dano para isolar progressão; golpe final explícito se boss sobreviver |
| Vitória/derrota, resultados únicos e reinício sem poder herdado | `persistence.test.ts`, fluxos Chromium dos três personagens |
| Leitura v2, fallback v1 intacto, preferências e armazenamento indisponível | `persistence.test.ts`, fluxos Chromium |
| Uma modal, pausa e isolamento de inputs | Fluxo de confirmação de saída/Escape/retoma em Chromium |

**Limites de aceitação:** estes testes de regressão fecham a cobertura técnica prevista para a fase 1 quando os gates do PR passarem; não são uma partida humana sem assistência nem prova de diversão, equilíbrio ou qualidade visual. A fase 4 exige partidas normais e ajuste de dificuldade/viabilidade das builds; a fase 5 exige estabilidade e desempenho nos dispositivos reais identificados. Ainda faltam animações (fase 2), interface/controlos mobile (fase 3) e publicação final (fase 6). Só três personagens permanecem selecionáveis, embora desbloqueios históricos dos restantes sejam preservados. A primeira versão web desktop/mobile ainda não está concluída. Merge desta iteração apenas após aprovação explícita do criador.

### Fase 2 · Iteração 1 — Personagens

Base: PR #55 integrado (`c067678`). Esta iteração mantém catálogo, regras, hitboxes e saves. Acrescenta 12 desenhos traseiros de Alpha (NE/N/NW, quatro por direção) e quatro de Cool Kid (N), preservando os PNG anteriores. Os oito sentidos usam quatro frames; Sigma NW e deslocação lateral esquerda usam poses simétricas sem texto invertido. Cool Kid recebeu então oito desenhos para a **forma antiga** de Giga Chad Rampage (entrada, corrida e saída), com silhueta mais larga e máximo aproximado de 84 U, mantendo hitbox e dano inalterados. **Nota histórica: o Flex foi posteriormente reatribuído a Alpha em §7.2; estes frames não constituem arte de Alpha.** Novos atlas têm recortes explícitos e uma escala fixa por folha para cerca de 64 U de altura; não se estica individualmente cada desenho. Fontes e prompts: `docs/art/phase-2-1.md`.

Reprodução: corrida avança pela distância percorrida, ficando parada contra obstáculos; ataque e hurt seguem os temporizadores existentes. A derrota reproduz quatro poses e mantém a última sem avançar a simulação; nova run reinicia o relógio visual. Flex tem entrada, execução e recuperação; Alpha mostra os três impactos reais aos 0/2/4 s, sem inventar slams adicionais. Pausa e escolhas congelam as animações de combate. A morte usa um relógio visual separado apenas para concluir a queda.

Evidência: testes unitários de oito direções, ciclos, pausa/colisão, derrota/reinício e sincronização dos golpes; testes Chromium dos três personagens geram pranchas dos frames realmente carregados pelo Phaser e capturas de deslocação para norte. Resultados finais e commit ficam no PR desta iteração. Isto não valida balanceamento nem uma partida humana completa; inimigos/boss e efeitos são as iterações 2.2/2.3. A adaptação mobile continua na fase 3. Merge só após aprovação explícita.

### Fase 2 · Iteração 2 — Inimigos e boss

Base: PR #56 integrado (`669a1a5`). Integra quatro atlas transparentes já gerados, com 17 sequências de oito desenhos: todas as 16 famílias móveis da demo e uma variante própria de Big Hater em FULL HATER MODE. Cada sequência tem quatro poses de deslocação, preparação, impacto, dano/queda e morte no chão. São vistas laterais com orientação simétrica; não oito vistas desenhadas separadamente. Terminal continua estático, com desaparecimento gradual após destruição. Detalhes e proveniência em `docs/art/phase-2-2.md`.

Recortes e pivôs explícitos; escala fixa por família. Deslocação acompanha distância real. Preparação/impacto/recuperação usam deadlines e direção fixada dos ataques reais, sem alterar dano, cadências, hitboxes ou RNG. Pausa congela poses. Inimigos mortos deixam imediatamente a simulação e mantêm apenas uma queda visual limitada a 0,85 s; retirada aos 15:00 não cria mortes falsas. Boss pode concluir a queda depois da vitória sem avançar combate. Berserk usa desenhos próprios e um aviso sonoro distinto que respeita mute.

A evidência inclui regressões de temporização e lifecycle, quatro pranchas dos frames carregados pelo Phaser e capturas de preparação/impacto do boss. Resultados finais ficam no PR. Não declara validação de partida humana, balanceamento ou desempenho mobile. Efeitos específicos de armas/perigos continuam na fase 2.3, controlos mobile na fase 3 e otimização dos atlas na fase 5. Merge só após aprovação explícita deste PR.

## 0. Guia de utilização no refactor

Este GDD consolida o design acordado, os números iniciais aprovados e a arte da opção A. Deve orientar o refactor de `pedro-ai-coder/aura-farmer`; não implica reescrever todo o jogo ou criar outro repositório. Decisões posteriores do criador prevalecem e devem ser registadas aqui.

| Área | Fonte dentro deste documento | Estado |
|---|---|---|
| Combate, XP, aura e Flex | 3–7 | Regras aprovadas; tuning a validar |
| Nove armas, 28 passivas e lendária | 8–10 | Catálogo e cadências aprovados |
| Inimigos, eventos e berserk | 11–12 | Comportamentos definidos; conteúdo visual incompleto |
| Co-op, arena e persistência | 13–15, 20 | Visão definida; decisões específicas antes de cada fase |
| HUD, demo e qualidade | 16–19 | Critérios de entrega obrigatórios |
| Identidade e assets | Anexo A | Opção A e lote inicial aprovados; estáticos |
| Ordem do refactor e conclusão | Anexo B | Plano técnico de execução proposto a partir das decisões aprovadas |

**Decisões que substituem versões antigas:** uma única aura e um Flex próprio por personagem; sem Focus; tipos Ranged/Melee/Tank; nove armas (substituem o catálogo antigo de seis), três slots de armas e cinco de passivas; caps common4/rare3/epic2/legendary1; Wild fora do âmbito; opção A substitui os SVGs antigos como alvo visual. Os nove personagens e 28 passivas continuam o objetivo de conteúdo completo; a primeira fatia jogável usa Sigma, Cool Kid e Alpha.

**Estado real desta entrega:** documento consolidado e dez PNG produzidos, verificados e aprovados visualmente. Código de gameplay não alterado por esta revisão. Nenhuma alegação de PR integrado, testes de gameplay concluídos ou deploy. As pastas indicadas são locais ao workspace até publicação explícita num branch remoto.

## 1. Visão e identidade

Aura Farmer é um survival de ação cartoon com identidade brainrot: Six Seven, Sigma, Alpha, Beta, aura farming, poses absurdas e objetos de internet transformados em armas. Nove personagens, builds com três armas e cinco passivas e um Flex próprio por personagem criam partidas distintas. Carreira e co-op recompensam progressão; a arena mede execução e decisões sem poder acumulado fora da partida.

A direção visual aprovada é **A — Cartoon Arcade**: contornos fortes, personagens expressivos, cel shading e cenários urbanos vivos. Castle Crashers informa a expressividade; Brotato informa a legibilidade. O anexo A e os assets aprovados determinam o acabamento pretendido. O combate inspira-se no movimento, armas automáticas, escolhas de melhorias e pressão contínua de Swarm. O Flex deve ter o impacto de uma habilidade assinatura. Bosses combinam padrões legíveis, janelas de dano e uma fase berserk inspirada na pressão dos encontros de WoW e Lost Ark, adaptada às regras próprias abaixo.

**Distribuição:** uma demo web acessível diretamente por URL e como Discord Activity; aplicações dedicadas para a experiência completa. Browser independente de login Discord. Plataformas das aplicações ainda por escolher. **Sem anúncio de lançamento nem publicidade nesta fase.**

**Pilares:** humor com identidade; combate legível; personagens diferentes; suporte útil; builds limitadas; progressão clara; arena justa. Beta não significa personagem deliberadamente inferior. Alpha/Sigma/Beta são identidades, não diferentes moedas de aura.

## 2. Estado das decisões e âmbito

| Estado | Utilização |
|---|---|
| Confirmado | Instrução explícita do criador |
| Aprovado para implementação | Regra ou valor aceite; implementar e validar, sem pedir novamente a mesma aprovação |
| Proposta futura | Hipótese explicitamente assinalada fora do âmbito fechado |
| Em balanceamento | Valor inicial testável; não é promessa de equilíbrio |
| Por decidir | Falta decisão de produto, não preencher silenciosamente |

Confirmado: nove personagens, três por tipo; três armas e cinco passivas equipadas; 28 passivas como referência de catálogo; drops compatíveis; suporte/DPS por build; PvE common/rare/epic/legendary; uma lendária por run; escolha lendária com três armas e três buffs; **cinco waves de dois minutos (10 minutos até Big Hater), com berserk recuperável após dois minutos de boss**, conforme decisão posterior da secção 25.1; co-op até cinco; Normal/Ranked; arena 1v1/2v2/3v3 sem RNG e sem vantagens externas.

**Wild sai do âmbito ativo.** Fica apenas no backlog “nice to have”, sem matchmaking, fórmula de dificuldade, economia, UI ou testes obrigatórios nesta versão. Ajuda de veteranos e prevenção de serviços de carry pagos voltam a ser discutidas se essa funcionalidade regressar.

O termo antigo “DPS” como tipo é substituído por **Melee**, conforme aprovado. Os tipos ficam Ranged/Melee/Tank; a especialização fica DPS/Support. A nomenclatura Melee e a expansão de seis para nove armas foram aprovadas nesta revisão, pela aprovação do ponto 20 da V1.1.

## 3. Glossário — quatro progressões diferentes

| Sistema | Como avança | O que dá | Persiste? |
|---|---|---|---|
| XP e nível da run | Recolher XP de inimigos/eventos | Escolhas de armas/passivas e pequenos atributos base | Não |
| Wave / fase de ameaça | Relógio da partida: intervalos de três minutos | Inimigos, dificuldade, eventos e melhores raridades | Não |
| Aura / carga do Flex | Participar no combate, sobreviver e completar eventos | Disponibilidade do Flex manual | Não |
| Conta / battle pass / rank | Resultado e objetivos das partidas | Desbloqueios, recompensas e progressão externa | Sim, quando implementado |

Aura não compra níveis; XP não é consumido ao ativar Flex; mudar de wave não reinicia o nível da run. O nível da conta não se confunde com o nível temporário nem com rank. No HUD, XP/nível e aura têm barras separadas.

## 4. Controlo e regras comuns do combate

Movimento livre; armas atacam automaticamente em cadências próprias. Alternância entre direção de mira manual e automática para ataques direcionais. Auto-aim escolhe inimigo válido mais próximo; empates por identificador estável. Não dispara através de obstáculos. Ataque de área não precisa de clique por ativação. Flex é a única habilidade especial manual inicialmente; não reintroduzir Focus.

**Unidades:** U são unidades do mundo; personagem tem raio de colisão 16 U. Base de referência: 100 HP, velocidade 180 U/s, poder ofensivo P=100, poder de suporte S=100. Tabelas usam dano bruto antes de resistência. Dano das armas = coeficiente × P × multiplicadores aplicáveis.

**Cadência:** intervalo efetivo = máximo(0,20 s; intervalo base / (1 + bónus de frequência)). Frequência total limitada a +100%. A frequência modifica só a repetição das armas, não timers internos de passivas/Flex. Recarga começa quando o ataque é emitido. Sem alvo, arma fica pronta e reavalia a cada 0,10 s; não acumula rajadas. Pulsos de suporte podem ativar sem inimigo quando exista destinatário elegível.

**Vida e resistência:** resistência física base de personagem expressa em percentagem na ficha. Reduções independentes combinam multiplicativamente; limite normal de mitigação de jogador 60%. Escudos absorvem depois da mitigação. Invulnerabilidades especiais são explicitadas; nada implica imunidade automática a mecânicas de boss.

**Eventos de acerto:** um ataque primário gera no máximo um evento de proc por ativação da arma, mesmo que atinja dez alvos ou tenha vários projéteis. Efeitos secundários não geram procs, aura ou cadeias novas, salvo indicação expressa. Dano ao longo do tempo mantém o dano, mas não multiplica contadores de acertos.

**Suporte:** cura e escudos usam S, não P. Aumentos de dano não amplificam cura. Auto-buffs permitidos quando indicados. Buffs iguais de várias fontes usam o valor maior e renovam duração, sem somar. Escudos de fontes diferentes acumulam até 40% da vida máxima do destinatário; escudo normal dura no máximo seis segundos. Cura não excede vida máxima. Regeneração não reanima.

Lentidão não acumula: usa a mais forte, máximo 40%. Boss recebe metade da lentidão e não pode ser empurrado ou atordoado; interrupções contribuem para stagger. Ataques perigosos têm aviso de forma e som, não apenas cor.

## 5. XP, nível da run e progresso em cada wave

### 5.1 Obtenção e partilha

Todos começam no nível 1 com uma arma starter nível 1, que ocupa um dos três slots. Inimigos largam orbes: normal 5 XP, rápido 6, ranged 8, pesado/suporte 12; elites 60; mini-boss 120; major boss 240. Valores específicos do bestiário substituem estes defaults. Não há bónus por last hit.

No co-op há uma única barra de XP da equipa. Qualquer aliado recolhe um orbe uma vez e credita a barra uma vez; todos sobem simultaneamente, mas escolhem melhorias individualmente. Suporte não fica atrás por causar menos dano. Personagens podem ter raio de recolha diferente, nunca XP privado adicional. XP de conta e passe só é calculado no resultado e não usa diretamente esta barra.

XP necessário do nível L para L+1: **30 + 8L + L²**. Com n jogadores, multiplicar por **1 + 0,20(n−1)** para compensar densidade maior. XP excedente transita; vários níveis geram escolhas em fila. Nível máximo inicial 25. Depois do máximo, cada equivalente de XP necessário para 25 dá uma recuperação de 5% HP da equipa viva, com intervalo mínimo de 20 s; sem novas escolhas nem carga de Flex.

### 5.2 Recompensa por nível

Cada nível ganho dá uma escolha entre três cartas legais: adquirir arma/passiva, subir nível de uma existente ou substituir/promover raridade quando a wave permitir. Além da carta, cada nível acrescenta +2 HP máximos e +1% de dano base, até +48 HP e +24% no nível 25. Aumento de HP cura apenas os 2 HP adicionados. Bónus fixos não ocupam slots.

Se não houver três cartas legais distintas, preencher com recuperação de 8% HP ou escudo de 8% HP por seis segundos; sem oferecer item incompatível ou já maximizado. Ofertas são pessoais; todos recebem oportunidades, sem disputar loot da equipa. Não existe quarto slot implícito nem passiva starter gratuita fora dos cinco slots.

### 5.3 Curva por wave

| Wave | Tempo | Nível-alvo ao terminar | Ameaça e evento |
|---|---|---|---|
| 1 — First Post | 0:00–2:00 | 5–7 | NPCs, aprendizagem de mira/movimento; Hater aparece aos 1:00 |
| 2 — Comment Section | 2:00–4:00 | 9–11 | Charge e projéteis; mini-boss Reply Guy aos 2:15 |
| 3 — Going Viral | 4:00–6:00 | 13–16 | Zonas persistentes e suporte inimigo; major Mod Supremo aos 4:15 |
| 4 — Cancel Storm | 6:00–8:00 | 18–21 | Mistura de ameaças e elites; mini-boss Ohio Express aos 6:15; janela lendária |
| 5 — Final Ratio | 8:00–10:00 | 23–25 | Maior pressão; major Doomscroll aos 8:15; última oportunidade lendária |
| Boss | 10:00 em diante | 25 como objetivo, não requisito | Big Hater e adds do encontro; berserk após 120 s de combate |

Estes níveis são alvos de tuning, não níveis garantidos por relógio. XP acumulada para atingir níveis 5/10/15/20/25: 230/915/2.275/4.560/8.020 solo; ajustar orçamento de spawns e recolha a esta curva em playtests, sem subir automaticamente para cumprir a tabela. Cada mudança de wave acrescenta um orbe de equipa de 80/120/160/200 XP respetivamente nas transições aos **2/4/6/8 minutos**, multiplicado pelo fator de XP do tamanho da equipa; é creditado uma vez. Não força uma subida automática nem oferece carta adicional por fora do sistema. **A nova duração de 120 s por wave exige revalidar densidade de spawns, XP efetivamente obtida, número de escolhas, disponibilidade de cura/Aura e sobrevivência normal: os valores e níveis-alvo acima não constituem balanceamento já validado para o relógio mais curto.**

### 5.4 Dificuldade por wave e seleção

Multiplicadores de HP/dano/densidade de spawn relativamente à wave 1: **1/1/1; 1,30/1,15/1,20; 1,65/1,30/1,40; 2,05/1,50/1,65; 2,50/1,75/1,90**. Velocidade não cresce com wave; padrões e composição fazem a dificuldade. Dentro de cada wave, spawn sobe linearmente até +10% no final. Taxa inicial: 0,8 inimigos/s solo; tetos de ativos 100 solo e 160 com cinco, com interpolação por tamanho. Ao atingir teto, adiar spawns; não matar inimigos invisivelmente nem retirar XP já criado.

Solo, abrir escolha pausa simulação e relógio. Regra co-op aprovada: ao existir uma escolha pendente para qualquer jogador, cada 20 s abre uma pausa de equipa de até 12 s; termina quando todos confirmarem. O relógio é de simulação, não tempo real. Não criar imunidade individual explorável. Durante boss, mesmas regras; validação de ritmo obrigatória. HUD mostra fila e tempo da próxima seleção. Desconectado não bloqueia pausa; após 60 s, uma única pausa pendente pode aplicar automaticamente upgrade legal já equipado, sem nova escolha de item, com prioridade definida antes da run. Nunca escolher lendária automaticamente.

## 6. Aura e Flex

Uma aura comum com carga 0–100, máximo 100, sem overflow guardado. +0,5/s enquanto vivo e não em pausa; evento de acerto primário +1, limitado a 2/s por jogador. Cura/escudo efetivamente utilizado por outro aliado pode dar +1/s dentro do mesmo teto de 2/s, não além dele. Sobreviver à derrota de mini-boss/major dá +10. Support tem via de carga sem precisar de last hit; atingir alvos invulneráveis ou escudos já cheios não dá carga.

Ao chegar a 100, Flex READY fica destacado; jogador decide quando usar. Ativação consome 100, suspende geração durante o efeito e impõe 30 s mínimos entre ativações. Não gasta XP nem avança nível. A geração passiva continua no boss e berserk. Expectativa inicial: aproximadamente 45–90 s por Flex em combate, a verificar. Sem crit aleatório no protótipo.

## 7. Nove personagens — kits aprovados e identidades preservadas

Os oito IDs existentes são mantidos. O nono é novo. Mudanças de tipo/kit abaixo são decisões aprovadas da nova versão; não alterar silenciosamente saves. Transformações de afinidades antigas deixam de fazer parte do núcleo: Flex pode mudar pose/forma temporariamente, sem recurso Alpha/Sigma separado.

### 7.1 Base e starter

O anexo A prevalece nas descrições visuais; os kits e números desta tabela mantêm-se.

| ID / personagem | Tipo | HP / velocidade / P / mitigação base | Starter e identidade visual | Traço único, sem ocupar slot |
|---|---|---|---|---|
| sigma — The Sigma | Ranged | 100 / 180 / 100 / 0% | No Cap; capuz angular escuro, emblema dourado e pose confiante; o boné é a arma, não substitui o capuz | Lock In: após 2 s sem mudar de alvo prioritário, +10% dano nele; reset ao trocar/perder alvo por 1 s |
| nerd — Nerd | Ranged | 85 / 180 / 105 / 0% | Ratio Blaster; óculos quadrados, postura inclinada | Calculated: cada quinta ativação primária da starter dá +25% dano nessa ativação; sem crit |
| six-seven — Six Seven Kid | Ranged | 90 / 190 / 95 / 0% | Brainrot Feed, capa visual 67; mãos/placas 6 e 7 | Counter: sétima ativação da starter aumenta raio em 20%; contador visível, independente da passiva Six → Seven |
| cool-kid — Cool Kid | Melee | 110 / 190 / 95 / 5% | Keyboard Warrior; gorro azul com pompom, casaco em camadas e sneakers | Too Cool: após 3 s de movimento contínuo, +10% dano melee; termina após 1 s parado |
| ohio — Ohio Kid | Melee | 85 / 215 / 100 / 0% | Touch Grass; pose torcida e pernas muito móveis | Ohio Route: a cada 300 U percorridas em combate, próximo ataque primário abranda 20% durante 1 s; 3 s entre ativações |
| rizzler — The Rizzler | Melee | 95 / 190 / 90 / 5% | Keyboard Warrior, skin de pente/microfone; casaco roxo longo, óculos escuros e silhueta estreita | Good Vibes: a cada 10 s, cura próprio e aliado mais ferido até 160 U em 3% da HP do destinatário; S afeta efeito; não gera aura/procs |
| alpha — Alpha Chad | Tank | 140 / 160 / 90 / 15% | Cope Shield; ombros largos e maxilar quadrado | Certified Unit: tomar dano direto fortalece próxima pancada em +20%; intervalo 4 s, uma carga |
| fanum — Fanum Lord | Tank | 125 / 170 / 90 / 10% | Personal Space, saco TAX com snacks; casaco verde e silhueta redonda | Tax Collector: raio de recolha +50%; recolher dez orbes concede escudo próprio 5% HP/3 s; intervalo 8 s, sem XP extra |
| beta — Beta Bro | Tank | 120 / 180 / 85 / 10% | Chad Hands, visual de luvas de espuma; mochila e postura protetora | Homie First: a cada 12 s, escudo 6% HP do destinatário por 4 s no aliado mais ferido até 180 U; solo aplica ao próprio |

S=100 para todos como base. A build desenvolve suporte; o traço de Rizzler/Beta não obriga a ser healer. Preservar desbloqueios dos oito IDs. Para protótipo, um starter de cada tipo disponível: Sigma, Cool Kid e Alpha. Desbloqueios novos propostos: concluir wave 2 → Nerd; derrotar primeiro major → Rizzler; concluir wave 4 → Ohio; recolher 500 XP cumulativo → Fanum; completar run → Six Seven; realizar 1000 de proteção/cura efetiva cumulativa → Beta. Rever progressão para não bloquear jogadores solo.

### 7.2 Individual Flex abilities — approved Flex 2.0 solo PvE contract (22 October 2026)

**Approved owner decision:** The signature Flex redesign replaces the three original solo-starter kits, while retaining the stable hero IDs `sigma`, `cool-kid` and `alpha`. The approved public names are **Deadpan Verdict**, **CTRL + CHAOS** and **Giga Chad Rampage**, respectively. *Giga Chad Rampage* now belongs to **Alpha Chad**, not Cool Kid; the historical Cool Kid contact-immunity Flex and historical Alpha Hold kit are superseded. The other six characters' Flexes remain unchanged.

All nine heroes use the single **Aura** resource and common activation rules in §6: 100 Aura spent on a successful activation, no passive generation during the active Flex, at least 30 seconds between activations, normal pause semantics, no new ability button, and no carry-over between runs. The numbers below are **approved initial PvE implementation specifications**; they are not claims of validated balance. The Godot implementation may migrate after appropriate tests; Phaser remains an unchanged historical gameplay reference. Balance corrections require new recorded GDD decisions.

| Hero | Flex / active duration | Approved PvE effect and counterplay |
|---|---|---|
| **Sigma** | **Deadpan Verdict**, **6 s** | Lock one eligible priority enemy within **600 U**; activation without an eligible target does not spend Aura. During Flex, primary weapon hits against the locked target gain **+40% damage** and an applicable directional projectile gains **+1 pierce**. When **three successful primary weapon activations** hit the active marked target, deliver **one** focused Verdict hit worth **0.75P**, subject to all normal target defenses. The Verdict can trigger at most once per Flex. See §7.2.1 for retargeting and boss limits. |
| Nerd | **Spreadsheet Diff**, 6 s | One 600 U line in aim direction every 0.75 s, 0.45P per enemy, max eight strikes; aim refreshes before each shot; unaffected by weapon frequency. |
| Six Seven Kid | **SIX… SEVEN!**, 3.5 s | Six radial six-projectile bursts every 0.5 s at 0.10P each; a seventh 1.0P pulse at 3.5 s within 200 U. One hit per target per burst. |
| **Cool Kid** | **CTRL + CHAOS**, **5 s** | Gains **+25% movement speed** and performs **six** distinct keyboard-cone attack beats over the Flex, each for **0.20P** in **110° / 115 U**, with up to **five** eligible targets per beat. A directional **ENTER!** finisher at **4.50 s** deals **[0.45 + 0.10 × successful beats]P**, maximum **1.05P**, in **130° / 145 U**. Receives **15% less direct non-boss enemy contact damage** while active; **no contact-damage aura or complete immunity**. See §7.2.2. |
| Ohio Kid | **Only in Ohio**, 5 s | Leaves movement trails lasting 2 s; enemies take 0.12P every 0.5 s and 20% slow; +30% movement; overlapping trails do not double-tick. |
| Rizzler | **Unspoken Rizz**, 6 s | Mobile 180 U aura: 30% slow on normal enemies, +15% ally frequency, and 2% caster-max-HP × S/100 healing per second per recipient; half slow on bosses. |
| **Alpha Chad** | **Giga Chad Rampage**, **6 s** | Enters an unmistakable heavy shield stance, gains a **25% max-HP self-shield**, draws normal PvE enemies within **180 U** for **2 s**, and performs **three** 0.40P slams in **150 U** at **0/2/4 s**. Takes **20% less direct non-boss enemy contact damage** during the window. At **5.50 s**, one **180 U** shockwave deals **0.50P plus up to 0.50P** based on damage absorbed by this Flex's own shield (maximum **1.00P**). Knockback affects only non-boss enemies; boss receives **10 stagger** subject to the global stagger budget. See §7.2.3. |
| Fanum | **Fanum Tax**, 6 s | Pulses every 1 s for 0.15P in 160 U and 3% caster-max-HP × S/100 shields to allies. This shield source renews and stacks to 12% target max HP, under global caps. |
| Beta | **No Homie Left Behind**, 5 s | Redirects 20% post-mitigation ally damage within 200 U, max 30% self-HP per activation; 35% reduction on transferred/self damage without recursive transfers; solo keeps personal reduction. |

#### 7.2.1 Deadpan Verdict — deterministic precision and payoff

- **Target choice:** At activation, acquire the highest-priority eligible enemy within 600 U using the existing targeting priority and stable-ID tie-break. If none exists, remain READY and spend no Aura. Once locked, target cannot change while alive, even if other enemies become closer or it moves temporarily out of range. Targeting weapons retain their own legal range and line-of-sight checks.
- **Retarget:** If the marked enemy dies, the next successful primary weapon activation can lock the next eligible enemy in the same 600 U radius. Until it does, no bonus is applied; the 6 s timer still expires. A temporary loss of visibility does not teleport projectiles or grant bonus hits.
- **Damage:** +40% applies only to *primary weapon damage actually hitting the current locked target*; other targets and secondary areas do not inherit the damage bonus. +1 additional pierce applies only when a primary weapon has a directional, piercing projectile; do not grant fictitious pierce to melee/area attacks. The normal Lock In hero trait remains independent under §7.1.
- **Verdict counter:** Count at most **one qualifying success per primary weapon activation**, even when that activation sends multiple projectiles or hits more than one target. Maintain the count across legitimate death/retarget within a single Flex. On the third qualifying success, resolve a **single 0.75P** secondary hit on the marked target if still alive after the primary damage. If the primary hit defeats it, show the finisher confirmation but do not generate damage on another target. The finisher never auto-executes by percentage HP and never ignores boss mitigation, armor, shields or invulnerability.
- **Feedback:** Distinct character stare entry, clear marked-target frame and line, visible 1/3 → 3/3 build-up, one comic **VERDICT!** impact and a brief exit. *Visual* freeze-frame emphasis does **not** freeze simulation or enemy movement.

#### 7.2.2 CTRL + CHAOS — skillful keyboard melee combo

- **Activation:** The 5 s window begins immediately on a successful Aura activation. The +25% movement-speed bonus uses the existing movement-cap rules. The hero remains player-steered, not auto-dashed or teleported. Existing weapons keep their normal activation timers, weapon slots, and abilities.
- **Keyboard beats:** Schedule **six** independent, **secondary** 0.20P cone strikes at relative active times **0.35 / 1.05 / 1.75 / 2.45 / 3.15 / 3.85 s**. Each beat is **110°** wide and **115 U** long, starts at the hero's current position and uses the current manual aim if available, otherwise current movement facing (last non-zero facing while idle). Per beat, select up to **five** legal targets in range, ordered nearest first then by stable enemy ID. Each target is hit no more than once by that beat. A beat counts as **successful** if at least one real target receives damage; multiple targets count as one beat, not multiple combo stacks.
- **ENTER! finisher:** At **4.50 s**, hit legal targets in the currently aimed **130° / 145 U** cone once each for **0.45P + 0.10P per successful prior beat**, capped at **1.05P**. Successful-beat count is at most six, never carries to the next Flex and cannot be charged by normal weapon hits or passive procs. A missed finisher still plays a reduced, clear end-pose without dealing damage.
- **Protection and limits:** During Flex, apply **15% multiplicative reduction** to **direct non-boss enemy contact attacks only**, alongside existing mitigation. Boss attacks, enemy projectiles, scripted hazards and special zones still hit normally; no full immunity, contact-on-touch attack, iframes, movement stun or knockback from the Flex. Beat/finisher damage is Flex-secondary damage: **no extra Aura, on-hit passive procs, weapon cooldown refunds or recursive combo charges**. Use the current P from §4, not item-rarity multipliers.
- **Feedback:** Blue/teal keyboard trails, recognizable keystroke silhouettes and a six-step progress indicator; the finale visibly spells **ENTER!**. Use the approved Cartoon Arcade design and approved assets; missing dedicated art must go through art approval rather than reusing Alpha's silhouette. Reduced-motion mode retains readable attack outlines and timing.

#### 7.2.3 Giga Chad Rampage — heavy frontline shield and countershock

- **Entry:** For **6 s**, Alpha visibly anchors into a powerful stance, granting a self-shield of **25% max HP** for this window (subject to the global **40% max-HP total shield cap**). The shield is tracked as a **separate named Flex shield source** so absorption can be attributed correctly. Normal non-boss PvE enemies within **180 U** are taunted for the first **2 s**; the boss cannot be forcibly retargeted, stunned or interrupted.
- **Slam cadence:** Exactly **three** 0.40P impact pulses at elapsed **0.00 / 2.00 / 4.00 s** in **150 U**, once per target per slam. Keep the existing attack telegraphs and committed enemy/boss patterns intact. Slams do not move Alpha, create a fourth weapon or generate extra primary procs.
- **Protection:** Apply **20% multiplicative mitigation** only to direct non-boss enemy contact hits during Flex, in addition to the character's base mitigation. Boss contact, telegraphed attacks, hostile projectiles and hazardous ground effects remain dangerous. No invulnerability, passive Aura regeneration while active or forced boss facing.
- **Final countershock:** At **5.50 s**, pulse once within **180 U** for **[0.50 + min(0.50, 2 × absorbed_flex_shield_HP / max_HP)]P**, up to **1.00P** total per target. Count **actual damage absorbed only by the shield granted at this Flex activation**; do not count other shields, overkill, unused shield, healing or prevented damage from mitigation. Resolve against normal defenses and cap one shockwave hit per target. Push non-boss common/elite enemies up to **40 U** along a walkable path without clipping through solid covers. Against Big Hater, do not push, taunt or stun; contribute **10 stagger**, still subject to the shared **20 stagger/s** ceiling and existing stagger lock.
- **Feedback:** Gold/coral power-up silhouette, heavy shield border, **three** distinguishable earth-shaking but accessibility-safe slams, visible shield absorption feedback, and a single final **GIGA!** shockwave. Avoid long camera shakes and keep enemy danger telegraphs above friendly visual effects in readability priority.

#### 7.2.4 Shared implementation, UI, balancing and migration rules

- Damage of these Flex actions uses the existing player power **P** and standard damage/defense ordering from §4. Flex-generated beats, Verdict and shocks are **secondary**: do not count them as primary weapon activations, target-lock triggers, XP-generating events, passive on-hit events or Aura charge events. No random critical hits or new RNG streams.
- Scheduled effects advance exclusively on the **active simulation clock**, freeze on pause/choice menus, stop on defeat, and fully clear on victory, hero change, restart or new run. Simultaneous enemy deaths, target loss and weapon-hit ordering must be deterministic. No frame-rate-dependent repeated hits.
- Preserve hero IDs `sigma`, `cool-kid`, `alpha`, stable weapons/passives, three weapon slots, five passive slots, one legendary opportunity, saves/profile schema and the §6 Aura/30-second lock. Store new counters only in transient per-run state; they do not migrate as permanent upgrades.
- The **original Cool Kid Giga Chad sprite-sheet frames are historical approved artwork**: do not silently treat Cool Kid's widened silhouette as Alpha's asset, and do not claim the new Flex art is finished. A new approved visual brief/assets may be needed for each signature state. Use compatible existing assets for interim animation and report the gap honestly.
- UI: READY, activation, remaining seconds, countdown/beat progress, primary target, shield charge and finisher state must be readable on keyboard, touch and reduced-motion layouts without obscuring threats.
- Acceptance: deterministic timing boundaries; correct one-hit-per-target and one-proc-per-activation contracts; repeated activations; target loss/death; max five beat targets; shield attribution; special-hazard and boss counterplay; cover-safe knockback; no Aura/proc loops; paused and restarted lifecycle; ordinary-health three-hero full runs under the new ten-minute schedule; real mobile/desktop visual review.
- **Balance gate:** Start with the above approved *initial tuning values*; benchmark measured damage, survival, damage prevention, boss viability, readability and active-play Flex uses before release. Any changes to the approved numbers must be documented in the GDD rather than silently tuned in code.

**PvP boundary:** These are *solo PvE contracts*, not arena implementations. Competitive skill timing, damage and mitigation require their own future approved table. Boss taunts do not control human targets, and no PvE damage/immunity rule implicitly transfers to PvP.

### 7.3 Builds de referência

Ranged DPS: Sigma + No Cap/Ratio/Feed + Main Character Energy, Terminally Online, Get Ratio'd, It's So Over, Absolute Cinema. Ranged support: Nerd + armas do tipo + Certified W, W Wi-Fi, Aura Goes Viral, Take the L, W Squad. Melee DPS: Ohio + três melee + dano/frequência/combo/Six → Seven/lendária de dano. Melee support: Rizzler + Homie Check/Ego Check/Certified W/Take the L/W Squad. Tank DPS: Alpha + três tank + Retaliation equivalente Uno Reverse/dano/frequência/execução/lendária de dano. Tank support: Beta + Big Chad Energy/Cope Harder/Certified W/Take the L/Too Sigma to Fall. São objetivos de teste; não builds exclusivas ou garantidas.

## 8. Armas — nove fichas de ação e cadência

**Catálogo aprovado:** nove armas, três por tipo. Com só três opções por tipo, a escolha de longo prazo está sobretudo nas passivas e raridades; expandir para quatro ou mais por tipo é futuro, não requisito da demo. Sem arma duplicada. Starter ocupa slot normal; aparência assinatura não cria quarta arma.

| ID / arma | Trigger base / alvo / geometria | Ação nível 1 e detalhe operacional |
|---|---|---|
| ratio-blaster — Ratio Blaster | 0,65 s; alvo até 520 U; projétil 650 U/s | Um tiro 0,20P; para no primeiro alvo/obstáculo. Auto-aim ou mira manual; voo máximo 0,8 s |
| no-cap — No Cap | 1,60 s; direção; 600 U, linha 32 U | Boné 0,50P, perfura até quatro inimigos; cada alvo recebe uma vez. Não regressa causando dano extra; voo 750 U/s |
| brainrot-feed — Brainrot Feed | 3,00 s; inimigo mais próximo até 480 U | Marca posição atual, atraso 0,45 s, explosão de raio 100 U com 0,65P; alvo pode sair. Aviso não acompanha alvo |
| keyboard-warrior — Keyboard Warrior | 0,75 s; cone 100°, alcance 95 U | Duas tecladas a 0 e 0,12 s de 0,18P cada; no máximo um proc para o conjunto. Direção fixada no início |
| ban-hammer — Ban Hammer | 2,40 s; cone 120°, alcance 125 U | Preparação 0,30 s incluída no intervalo; impacto 0,90P. Empurra comuns 40 U e aplica 15 de stagger ao boss, máximo por alvo/ativação |
| touch-grass — Touch Grass | 1,50 s; arco 180°, alcance 145 U | Chicote 0,40P, aplica lentidão 15%/1,5 s. Não é arma ranged apesar do alcance maior que teclado |
| cope-shield — Cope Shield | 2,00 s; cone 100°, 100 U | Pancada 0,45P. Concede escudo próprio 4% HP por 2 s se acertar; esta fonte não acumula consigo. Sem inimigo não gera escudo infinito |
| chad-hands — Chad Hands | 1,20 s; cone 90°, 90 U | Dois socos de 0,22P a 0 e 0,18 s; cada terceira ativação que acerte substitui o segundo por slam 0,40P em 110 U. Um proc total |
| personal-space — Personal Space | 2,80 s; círculo centrado no jogador, 135 U | Pulso 0,40P; comuns causam −8% dano por 2 s. Um único hit por alvo, não tick contínuo; sem benefício defensivo se não acertar |

### 8.1 Níveis, raridade e evolução

Para evitar repetir o problema de epic nível 4, preservar como baseline de protótipo: **common níveis 1–4, rare 1–3, epic 1–2 e legendary nível 1**. Esta é a regra aprovada para ambos os catálogos; qualquer alteração futura exige atualização explícita da especificação. Progresso de item e raridade são campos distintos.

Dano e escudo próprios de arma multiplicam por R × [1+0,15(ℓ−1)], com R common=1; rare=1,50; epic=2; legendary=2,60. Intervalo base reduz 5% por nível acima do primeiro, antes do modificador global. Promoção preserva o nível legal mínimo entre nível antigo e cap novo; comparar valores antes de oferecer. Exemplo common4 → rare3 é superior em dano e reinicia apenas a diferença de nível necessária. Common4 com cadência melhor que rare1 não deve ser vendido como superior universal; UI mostra trade-off. Oferta da mesma arma sobe nível, não duplica slot.

Uma evolução visual/mecânica extra além de raridade não é obrigatória para a primeira demo; não importar receitas de Swarm sem decisão. Lendária é a transformação especial deste catálogo, com escolha e slot próprios.

**Substituição de passiva:** uma passiva diferente começa no nível 1 da sua raridade; remover a antiga retira atributos e timers, sem conservar stacks. Reequipar não pode contornar recarga: o estado de cooldown por ID é conservado até ao fim da run. Promover raridade da mesma arma preserva o progresso legal descrito acima. Armas e passivas distintas nunca partilham níveis.

### 8.2 Variantes lendárias — uma das três armas do tipo

Todas recebem R=2,60, sem níveis adicionais. Efeito extra não dispara procs:

| Arma lendária | Efeito exclusivo |
|---|---|
| Ratio — Comment Apocalypse | Cada quarta ativação lança mais dois tiros, 0,10P bruto cada antes de R, na mesma direção, com 0,08 s de separação |
| No Cap — Final Verdict | Boné deixa uma linha que explode após 0,7 s por 0,25P × R; máximo um hit secundário por alvo |
| Feed — Infinite Scroll | Explosão principal seguida de três impactos laterais fixos, espaçados 80 U, após 0,3 s; cada um 0,15P × R; um secundário máximo por alvo |
| Keyboard — Caps Lock | Cada terceira ativação termina com arco de 120 U de 0,25P × R |
| Hammer — Perma Ban | Após impacto, fissura frontal 220 U após 0,5 s, 0,30P × R; mantém aviso |
| Grass — Go Outside | Cada terceira ativação vira círculo 150 U, substitui o arco; dano ×1,25 e lentidão 25%/2 s |
| Shield — Unbothered | Cada terceira pancada concede escudo 5% HP do caster × S/100 a aliados em 140 U por 3 s |
| Hands — Gigachad Moment | Slam de terceira ativação causa mais 0,20P × R e atinge 140 U |
| Space — My Aura, My Rules | Cada segundo pulso acrescenta escudo 4% HP do caster × S/100 em 160 U por 3 s |

## 9. Passivas — 28 ações, triggers e limites

Corrigida a inconsistência de V1: **10 common, 8 rare, 6 epic e 4 legendary**. Mantém o baseline histórico 4/3/2/1 níveis máximos. Sit Down sai da pool rare: o debuff já existe em Personal Space; a quarta lendária No U acrescenta uma escolha de controlo. Três lendárias de buff são mostradas de uma pool de quatro, não é necessário reduzir o catálogo a três.

C=nível common 1–4; R=nível rare 1–3; E=nível epic 1–2. Bónus por nível somam dentro da mesma passiva, não reaplicam multiplicadores em cadeia. Fora de combate, efeitos periódicos ofensivos esperam alvo. On-hit significa evento primário da secção 4. Todas usam relógio de simulação; pausa congela timer. Valores de suporte abaixo multiplicam S/100 e bónus de Certified W, exceto quando já expresso como atributo.

### 9.1 Dez common — efeitos contínuos

| ID / nome | Compatibilidade | Ação por nível C | Trigger / duração / limite |
|---|---|---|---|
| main-character — Main Character Energy | Todos | +6%C dano de armas | Contínuo enquanto equipada; máximo +24%; não aumenta cura/escudo |
| terminally-online — Terminally Online | Todos | +5%C frequência | Contínuo; máximo +20%; respeita teto global e não acelera passivas |
| built-different — Built Different | Todos | +8%C HP máxima | Contínuo, até +32%; aquisição cura só diferença de HP máxima; remover reduz HP atual só se exceder novo máximo |
| thick-skin — Thick Skin | Todos | 3%C redução de dano | Contínuo, até 12%; combinação multiplicativa com outras fontes |
| caught-4k — Caught in 4K | Todos | +5%C movimento | Contínuo, até +20%; velocidade total por buffs limitada a +60% |
| big-meme — Big Meme Energy | Todos | +6%C raio de área | Contínuo, até +24% no raio; não aumenta comprimento de projétil nem alcance de cura automaticamente |
| timeline — Across the Timeline | Ranged | +8%C alcance de arma | Contínuo, até +32%; velocidade do projétil acompanha para preservar tempo máximo de voo |
| hands-on-sight — Hands On Sight | Melee | +7%C dano contra alvo até 150 U | Avaliado ao atingir; até +28%; não afeta alvo distante por extensão de área |
| cope-harder — Cope Harder | Tank | +8%C escudos concedidos | Contínuo, até +32%; respeita teto de escudos; sem geração própria |
| certified-w — Certified W | Todos | +6%C cura e escudos concedidos | Contínuo, até +24%; nenhuma cura automática; pode combinar com Cope Harder multiplicativamente |

### 9.2 Oito rare — condições e periodicidade

| ID / nome | Tipo | Ação | Trigger / duração / teto |
|---|---|---|---|
| get-ratiod — Get Ratio'd | Ranged | Alvo recebe +[4+2(R−1)]% dano da equipa | Três acertos primários no mesmo alvo em 4 s; marca dura 4 s; 6 s de intervalo por caster; marcas de vários casters não somam |
| no-cap-streak — No Cap Streak | Ranged | Próxima ativação tem +R perfurações e +10% dano | Cada quinta ativação de arma direcional; contador por jogador; explosões sem trajeto ganham só dano; uma ativação reforçada, não uma por projétil |
| w-wifi — W Wi-Fi | Ranged | Zona fixa 160 U, +[8+4(R−1)]% frequência para próprio/aliados | Cada 12 s em combate, dura 4 s; primeiro trigger após 12 s; zonas iguais não somam |
| let-him-cook — Let Him Cook | Melee | +[2+R]% dano por stack | Um stack por acerto primário, máximo cinco; dura 3 s desde último acerto; tudo expira sem renovar |
| ego-check — Ego Check | Melee | Alvo recebe +[4+2(R−1)]% dano | Quatro acertos primários no mesmo alvo em 5 s; dura 4 s; intervalo 8 s/caster. Partilha categoria Exposed com Get Ratio'd: só o maior |
| homie-check — Homie Check | Melee | Cura próprio e aliados em 140 U: [2+R]% HP máxima do caster | A cada oito acertos primários, intervalo mínimo 6 s; acertos durante intervalo não acumulam; pulso não causa dano |
| uno-reverse — Uno Reverse | Tank | Próximo ataque causa +[15+10(R−1)]% dano | Sofrer 10% HP máxima de dano pré-mitigação de ataques diretos em 6 s; arma preparada por 4 s; intervalo 6 s; dano transferido e hazards não contam |
| big-chad — Big Chad Energy | Tank | Escudo de [5+2(R−1)]% HP máxima do caster em 160 U | Cada 10 s em combate; dura 4 s; próprio e aliados; primeiro pulso após 10 s; valor igual renova, não soma |

### 9.3 Seis epic

| ID / nome | Tipo | Ação | Trigger / duração / teto |
|---|---|---|---|
| its-over — It's So Over | Todos | +[15+10(E−1)]% dano a alvos abaixo de 30% HP | Condicional contínuo; não execução automática nem dano percentual de HP do boss |
| brainrot-rain — Brainrot Rain | Todos, só PvE | Quatro impactos de [0,25+0,10(E−1)]P, raio 65 U | Cada 10 s; área elegível até 320 U com pelo menos um inimigo; posições RNG visíveis 0,8 s antes; impactos separados 0,2 s; máximo dois por alvo/cast |
| aura-viral — Aura Goes Viral | Todos | Próprio/aliados em 180 U recebem +[12+6(E−1)]% frequência | Ao ativar Flex; dura 5 s; não acumula consigo ou W Wi-Fi, aplica maior; sem reduzir recarga do Flex |
| take-l — Take the L | Todos | Redireciona [10+5(E−1)]% dano de um aliado para caster | Verifica a cada 1 s, escolhe aliado com menor percentagem HP até 180 U; vínculo dura até próxima verificação; máximo transferido 15% HP do caster por 5 s; desliga abaixo de 25% HP do caster |
| so-back — We Are So Back | Todos | Cura gradual [10+5(E−1)]% HP máxima e escudo 10% HP | Cruza de ≥30% para <30% HP por dano; cura em 5 ticks/5 s; escudo 3 s; intervalo 45 s; não reanima nem impede hit já fatal |
| six-to-seven — Six → Seven | Todos | No sétimo acerto, explosão [0,35+0,15(E−1)]P em 90 U | Contador global de acertos primários das três armas; alvo do sétimo acerto recebe a explosão; mínimo 2 s entre explosões; contador congela durante esse intervalo; sexto sinaliza mãos 6/7; explosão não alimenta novo contador |

Take the L e Flex de Beta partilham regra: só uma transferência por dano, usando a maior percentagem elegível. Dano transferido não gera aura, procs, escudos reativos nem nova transferência; não pode matar por recursão. Dano absorvido conta no painel de suporte, não como dano recebido do boss para contadores ofensivos.

### 9.4 Quatro legendary — nível único

| ID / nome | Ação | Trigger / duração / teto |
|---|---|---|
| absolute-cinema — Absolute Cinema | +25% dano de armas; durante Flex, +20% adicional de dano de armas | Parte contínua e janela de Flex; não amplifica suporte nem dano do próprio Flex; só uma lendária total |
| w-squad — W Squad | +25% cura/escudos concedidos; Flex concede +10% dano de armas a próprio/aliados em 200 U | Buff de equipa 6 s após ativação; não acumula entre casters; não recarrega Flex |
| too-sigma — Too Sigma to Fall | Escudo 25% HP máxima do caster para próprio/aliados em 200 U | Dano cruza HP do caster de ≥25% para <25%; dura 5 s; intervalo 60 s; não impede golpe fatal nem revive |
| no-u — No U | Pulso de controlo 200 U: 0,30P de dano e inimigos causam −20% dano | Cada 15 s em combate; debuff 4 s; primeiro aos 15 s; boss recebe −10% por 2 s. Não reflete dano nem encadeia procs; mantém identidade tank/control mesmo disponível a todos |

**Especialização real:** empilhar suporte deve melhorar dano/prevenção/recuperação da equipa, não dar todos esses benefícios mais o dano de uma build DPS. Medir dano amplificado, cura efetiva, escudo absorvido e aliados protegidos; não avaliar utilidade apenas pelo top damage.

## 10. Raridades, ofertas e lendária

Nas cartas normais, primeiro escolher categoria legal (upgrade de equipado / nova opção / promoção) e depois raridade. Probabilidades iniciais de rarity roll:

| Wave | Common | Rare | Epic | Legendary em cartas normais |
|---|---|---|---|---|
| 1 | 90% | 10% | 0% | 0% |
| 2 | 70% | 28% | 2% | 0% |
| 3 | 45% | 45% | 10% | 0% |
| 4 | 25% | 50% | 25% | 0% |
| 5 | 10% | 50% | 40% | 0% |

Passivas têm raridade fixa; armas têm variantes. Se uma raridade não tiver opção compatível, redistribuir pesos pelas opções legais, sem inventar versão rare de passiva common. Favorecer upgrades de equipado em pelo menos uma das três cartas se existirem. Não garantir uma carta de suporte/ataque/defesa em todas as ofertas: garantir compatibilidade e variedade ao longo da run. A preferência de especialização no lobby pode ponderar ofertas PvE; não cria RNG no PvP.

**Janela lendária:** waves 4 e 5, aos **6:00 e 8:00**. Aos 6:00, cada jogador vê seis cartas: as três armas lendárias do seu tipo e três buffs distintos da pool de quatro. Pode escolher ou adiar. Aos 8:00, repete exatamente a mesma oferta a quem adiou, sem reroll. Se ainda adiar, pode abrir o mesmo ecrã até **9:55**; depois expira sem atribuição automática. Todos têm a oportunidade, sem obrigação de equipar.

Uma seleção consome o direito da run. Não substituir por uma segunda lendária, mesmo descartando a primeira. Se arma escolhida já existe, promove no mesmo slot; se não existe, usa slot livre ou pede substituição. Buff usa slot de passiva; trocar destrói a escolha anterior, com confirmação e comparação. Não oferece botão de confirmação sem operação legal. Ecrã especial tem prioridade sobre fila normal, mas uma só modal; escolhas não param só o jogador em co-op.

## 11. Bestiário — leitura visual e comportamento

Inspiração de composição: inimigos com funções simples que, combinados, criam pressão; silhuetas distinguem função antes de ler nomes. Preservar IDs antigos npc/hater/beta/boss na migração. O inimigo antigo beta apresenta nome **Beta Bot**, para distinguir de Beta Bro jogável.

Valores abaixo são wave 1 solo; aplicar escalas de wave e equipa apenas a comuns/elites. XP não é multiplicado por vida. Dano de contacto tem intervalo mínimo de 0,75 s por inimigo; dano de contacto global concede 0,25 s de proteção contra novos contactos. Projéteis/áreas perigosas respeitam seus avisos e não são todos anulados por esse intervalo.

| ID / inimigo | HP / velocidade / dano / XP | Introdução | IA, ataque e forma de responder |
|---|---|---|---|
| npc — NPC | 35 / 75 / 8 / 5 | Wave 1 | Persegue mais próximo; portador de telemóvel distraído, silhueta arredondada cinza, contacto; abrir caminho com AoE |
| hater — Hater | 50 / 60 / 10 / 8 | Wave 1 após 1:30 | Mantém 260 U; dispara comentário em linha cada 3 s, aviso 0,6 s, projétil 180 U/s, dano 10; silhueta coral/rosa dentada e megafone; aproximar/flanquear |
| reply-goblin — Reply Goblin | 25 / 125 / 6 / 6 | Wave 2 | Corre em grupos, contacto; pequeno e inclinado, pouco HP; punir com área, sem spawn sobre jogador |
| beta — Beta Bot | 120 / 45 / 16 / 12 | Wave 2 | Pesado com placa frontal; recebe −40% dano vindo de cone frontal 100°; traseira normal; volta no máximo 90°/s; contornar |
| ratio-ram — Ratio Ram | 80 / 60 / 20 / 10 | Wave 2 | A cada 5 s, trava direção durante aviso de 0,9 s e carrega 280 U a 320 U/s; não curva; cornos/teclado; sair da linha |
| doomscroller — Doomscroller | 70 / 50 / 8 por tick / 12 | Wave 3 | Cada 6 s marca chão sob um alvo, aviso 1 s, zona 70 U dura 3 s com tick 1 s; telemóvel alto; sair da zona |
| hype-bot — Hype Bot | 65 / 55 / 6 contacto / 12 | Wave 3 | A cada 8 s escudo em até três mobs até 160 U, 15% HP deles por 4 s; antena circular; não protege boss; eliminar antes de pesados |
| fanum-leech — Fanum Leech | 90 / 70 / 10 / 12 | Wave 3 | Cada 5 s liga fio a jogador até 200 U após aviso 0,8 s; 3 ticks de 5 dano; quebrar além de 240 U. Não rouba XP, itens nem moeda; saco com tubo visível |
| ping-sniper — Ping Sniper | 60 / 40 / 24 / 12 | Wave 4 | Tenta ficar a 400 U; cada 6 s laser fixa direção, aviso 1,2 s, tiro único; tripé fino; usar cobertura ou deslocamento lateral |
| copium-puffer — Copium Puffer | 90 / 45 / 12 por tick / 12 | Wave 4 | Ao morrer, aviso 1 s e nuvem 80 U por 3 s, tick 1 s; balão inchado; não explodir colado à equipa |
| comment-mod — Comment Mod | 100 / 50 / 10 / 14 | Wave 5 | A cada 8 s cura 8% HP máxima de até três mobs em 180 U; não cura bosses nem outros Mods; apito retangular; prioridade ofensiva |

Spawns fora de 260 U dos jogadores, aviso de portal 0,8 s; nunca em parede/zona sem saída. Ranged respeita cobertura. Elites a partir da wave 3: ×2,5 HP, ×1,3 dano, XP 60, maior silhueta e um único modificador visível (velocidade +15% OU escudo inicial 20%). Sem combinações ocultas. Máximo dois elites simultâneos solo, quatro co-op.

## 12. Mini-bosses, major bosses e Big Hater

### 12.1 Encontros de evento

HP de evento são valores para o momento indicado, sem aplicar outra vez o multiplicador de wave. Aplicar apenas fator de boss por número de jogadores. Adds usam suas waves normalmente.

| Boss / entrada | HP solo / XP | Padrão e resposta |
|---|---|---|
| Reply Guy — 2:15 | 1.400 / 120 | Cone de comentários: 18 dano, aviso 0,8 s, cada 4 s; spawn de quatro NPCs cada 12 s; janela vulnerável de 1,5 s após cone |
| Mod Supremo — 4:15 | 3.200 / 240 | Ban Slam circular 130 U: 28 dano, aviso 1 s, cada 6 s; duas linhas de silêncio no chão cada 10 s, 15 dano, não bloqueiam controlos; ao chegar a 50% HP invoca dois Haters uma vez |
| Ohio Express — 6:15 | 2.800 / 120 | Três cargas retas, 22 dano cada, aviso 0,8 s por carga; sequência cada 9 s; 2 s de recuperação depois; não muda direção durante carga |
| Doomscroll Prime — 8:15 | 5.200 / 240 | Duas zonas 100 U cada 7 s, aviso 1 s, 12 dano/s por 3 s; rajada frontal cada 4 s com 18 dano; destruir dois terminais com 250 HP interrompe próxima sequência de zonas por 4 s |

Spawn não interrompe wave nem dá outra carta além do XP e eventual drop previsto. Se sobreviver até wave seguinte, continua sem nova multiplicação de HP. Aos **10:00**, eventos ainda vivos retiram-se sem XP/loot; derrota de evento era objetivo de recompensa, não requisito escondido para final boss.

### 12.2 Big Hater — boss final do primeiro mapa

Spawn automático aos **10:00** numa arena delimitada visível; mobs comuns remanescentes retiram-se sem XP. Recolher automaticamente orbes já largados, sem gerar XP novo. Equipa recebe aviso aos **9:30**. O boss tem 30.000 HP solo (proposta), sem multiplicador de wave adicional; dano base da tabela não volta a escalar pela wave 5. Cabeça/coroa enorme e braços claros, conforme asset aprovado; sem encobrir hitboxes. **A viabilidade do boss com uma build construída em 10 minutos deve ser revalidada antes de considerar o novo ritmo equilibrado; HP, loot e progressão não são ajustados implicitamente por esta alteração ao calendário.**

Ciclo inicial usa slots de seis segundos e repete: **Hate Slam → Ratio Beam → Comment Ring → Adds**, um ataque principal por slot. Preparação e execução cabem no slot; nunca inicia dois ataques principais incompatíveis. Contacto 12 dano a cada 1 s; não acumula contacto mais pancada principal no mesmo frame.

- **Hate Slam:** cone 120°, 200 U, aviso 1 s, 35 dano; posição/direção fixadas 0,3 s antes de acertar; recuperação 1,2 s.
- **Ratio Beam:** linha 600×60 U, aviso 1,2 s, 30 dano, atravessa arena mas respeita cobertura designada; sai da linha, não pode acompanhar alvo após fixação.
- **Comment Ring:** anel expande 80→280 U em 1,5 s; dano 25 uma vez por expansão, largura 25 U; aviso 1 s e uma abertura de 70° marcada no chão.
- **Adds:** invoca quatro NPCs e um Hype Bot; máximo oito adds vivos solo, 16 em cinco jogadores. Não beneficia de escudo/cura dos adds; matar Hype Bot cria janela +10% dano recebido pelo boss por 3 s, sem somar com Exposed.

A 70% HP, Comment Ring passa a duas expansões separadas por 0,8 s, mantendo abertura visível. A 35%, beam deixa zona residual durante 2 s com 8 dano/s; aviso anterior mantém-se. Cada limiar ativa só uma vez; sem cura total ou invulnerabilidade longa. Mecânicas não exigem múltiplos jogadores e são executáveis solo.

**Stagger:** barra 0–100; armas pesadas e efeitos explícitos contribuem, máximo 20/s de toda a equipa. Ao encher, boss fica exposto/parado 3 s e recebe +15% dano; barra volta a zero e bloqueia enchimento por 20 s. Interrompe ataque ainda em preparação; nunca apaga dano já resolvido. Bónus de exposição iguais usam maior, não somam. Stagger continua útil em berserk, mas não o remove.

### 12.3 Berserk — soft enrage recuperável, com pressão crescente

Requisito do criador, atualizado em 22 outubro 2026: depois de **120 s de combate**, o boss regenera, fica muito mais resistente e cada hit causa muito mais dano. Continua derrotável; não mata a equipa por script nem termina a partida aos **12 minutos**. Regeneração é regra de Aura Farmer, não alegação de comportamento universal de WoW/Lost Ark.

Avisos a 60/30/10 s do berserk; barra própria. Aos **120 s de combate**, ativa estado **FULL HATER MODE**, muda pose, som e contorno. Não cura instantaneamente, não aumenta HP máxima, não teleporta jogadores e não cancela um golpe já no ar. A partir desse instante:

| Propriedade | Valor inicial aprovado para balanceamento |
|---|---|
| Resistência adicional | Recebe 35% menos dano, multiplicativo com debuffs; não removível por Ego Check |
| Regeneração | 0,10% da HP máxima por segundo, tick 1 s, limitada a 100% HP |
| Dano por golpe | ×2 imediatamente; depois ×1,10 por cada 30 s em berserk, máximo ×3 do valor pré-berserk |
| Intervalo entre slots de ataques | 6 s → 4,8 s; manter avisos de pelo menos 0,8 s |
| Stagger | Continua; suspende regeneração durante os 3 s da exposição; não reinicia timer |

A resistência e regeneração não crescem sem limite: o boss não deve tornar-se matematicamente imortal. Com 30.000 HP solo, regen=30 HP/s. Sem exposição, DPS bruto sustentado superior a **30/0,65 ≈ 46,2** consegue reduzir HP; a viabilidade também depende de sobreviver aos padrões. Exemplo: 200 DPS bruto → 130 após resistência → 100 líquido/s; 10% HP restante demora cerca de 30 s sem contar movimento/stagger. É exemplo aritmético, não resultado de playtest.

Aos **240 s de combate** (dois minutos em berserk, por volta dos **14:00** de jogo), mostrar “último esforço”, sem wipe automático. Derrota só quando nenhum jogador pode continuar/ser reanimado. Recompensa de vitória não aumenta por prolongar o boss. Adds de Big Hater não largam XP nem aura de morte; geração de aura por participação continua. Assim não se pode farmar XP/recuperações de nível máximo indefinidamente no encontro.

## 13. Co-op Normal e Ranked

Máximo cinco. Normal usa nível de conta no matchmaking e dá menos XP de conta/passe. Ranked considera nível, rank e MMR, dá mais XP e progressão ranked. Fatores concretos de recompensa por decidir; não transformar o rank em multiplicador de dano.

Escalas iniciais para n jogadores: HP de comuns/elites ×[1+0,30(n−1)]; densidade ×[1+0,45(n−1)]; dano comum ×[1+0,05(n−1)], máximo 1,20. Boss HP ×[1+0,85(n−1)], dano de boss ×[1+0,08(n−1)], máximo 1,32. Cinco jogadores → boss HP ×4,4 e dano ×1,32. Não duplicar loot, XP ou mecânicas pelo número de hits.

Toda a escala é calculada ao começar, não cai quando alguém morre. Sem entrada a meio inicialmente; desconexão tem 60 s para regressar ao mesmo estado, sem restaurar vida/carga. Entrada tardia e ajuste dinâmico ficam para revisão multiplayer. Matchmaking Normal pode aceitar desequilíbrio de roles; sem exigência obrigatória de healer/tank.

Regra de morte e revive: solo, HP zero termina run. Co-op, fica caído até 20 s, aliado reanima com interação contínua de 4 s até 70 U; movimento/dano do reanimador interrompe. Volta com 30% HP, sem restaurar Flex. Ao expirar, permanece espectador até derrotar evento de boss; recuperação de equipa após evento precisa de tuning e não ocorre durante Big Hater. Se todos os restantes estiverem caídos e ninguém puder reanimar, derrota imediata. Revives limitados por jogador a dois por run como valor inicial; UI mostra restantes. Estes valores estão aprovados para implementação, mas não foram validados em jogo.

Wild permanece só no backlog nice to have. Não reservar progressão nem recompensas dependentes desse modo.

## 14. Arena — requisitos preservados

1v1, 2v2, 3v3. Sem nível/equipamento/buffs da conta a afetar poder. Todos acedem a opções competitivas equivalentes. Sem críticos aleatórios, procs probabilísticos, dispersão, drops RNG ou meteoritos aleatórios. Autotarget e resolução de empates determinísticos; intenção de mira pode ser manual.

Armas/passivas têm presets de arena próprios; números PvE deste documento não são preset PvP aprovado. Brainrot Rain fica indisponível ou recebe padrão fixo numa futura versão separada. Cool Kid sem imunidade a jogadores, taunt de Alpha sem controlo forçado, regen/escudos/transferências precisam de tetos competitivos próprios. Rank de arena separado do co-op é proposta.

Por decidir antes de implementar arena: duração, vitória, rondas, mapas, seleção inicial de build, respawn, matchmaking e regras anti-stall. A arena não herda waves, XP, lendária nem relógio **PvE de 10 minutos até ao boss**.

## 15. Economia e persistência

Primeiro guardar desbloqueios de níveis/personagens e preferências; itens e buffs da run desaparecem. Equipamento pré-partida continua hipótese futura: não introduzir mais uma camada de poder sem economia e balanceamento próprios. Demo pode usar save local versionado; não prometer sincronização de conta ou transferência para aplicação completa.

Visão comercial: freemium, seasons, battle pass com moeda de jogo para compras e ausência de pay-to-win. Fontes/destinos da moeda, loja, preços e faixas gratuita/paga por decidir. Proposta: cosméticos como monetização principal, poder ganho jogando e igualdade na arena. Sem loja/pagamentos reais na demo inicial. XP da run não se converte automaticamente em moeda comprável.

## 16. Arte, interface e acessibilidade

**Production visual authority:** Apply §26 and [the approved Hero Spotlight V5 handoff](art/HERO_SPOTLIGHT_V5.md) to all current Godot screens and UI elements. Annex A Option A Cartoon Arcade defines the original art/actor identities; §26 refines their production composition, typographic system, UI treatment, screen targets and export/acceptance rules. Dynamic labels, timers, skills, drops, balance and content remain controlled by the latest GDD sections, never by illustrative screenshots. Detailed precedence exceptions and rollout gates are in §§26.4–26.7.

Silhuetas reconhecíveis, personagens cartoon originais, objetos que materializam a piada. Não copiar sprites ou personagens das referências. As skins de starter partilham hitbox/timing da arma, sem texto mentir sobre função.

Um ecrã principal e no máximo uma modal. HUD sempre mostra HP, XP/nível da run, wave/relógio, aura/Flex e aviso do boss. Build completa fica em painel secundário. Cartas mostram: tipo, raridade, nível/cap, efeito atual→novo, cadência e slot que substituem. Não chamar a um buff contínuo “ativa de X em X segundos”.

Lendária apresenta duas linhas de três cartas (buffs e armas), adaptadas ao ecrã, sem esconder confirmação. Pausas de escolha usam relógio de simulação. Inputs de combate não atravessam modais. Perigos usam formas/ícones e áudio; efeitos de aliados têm opacidade inferior a inimigos. Opções de reduzir flashes/shake e prioridade de visualização do próprio Flex.

Validar layouts 1280×720, 1920×1080 e viewport 800×600 com scaling. Mobile/Discord mobile requer prova própria; não anunciar suporte sem teste de input, viewport e desempenho. Objetivo inicial: 60 FPS desktop de referência e mínimo estável 30 FPS em perfil reduzido, com máquina/perfil definidos na implementação.

## 17. Demo web e Discord — fases de entrega

Primeiro: um mapa com percurso/cobertura reais, Sigma/Cool Kid/Alpha, todas as nove armas aprovadas, subset de passivas representativo de DPS/suporte, lendária completa, cinco waves, eventos e Big Hater. Uma partida inteira solo, vitória, derrota e reinício. Subset deve continuar a cumprir 3+5 e todas as regras de compatibilidade; não fingir catálogo completo se só há parte.

Depois: restantes personagens, 28 passivas e validação de conteúdo; integração Discord através de adaptador independente. Mesma simulação e conteúdo nos dois acessos. Co-op na demo é marco específico, não consequência automática de estar no Discord. Arena, ranked, backend comercial e passes não bloqueiam o protótipo solo.

Verificar SDK, autenticação quando necessária, origens, proxy de recursos, storage e reconexão com documentação oficial Discord atual na implementação. Browser continua sem depender do Discord. Sem credenciais no cliente nem serviços pagos adicionais sem autorização. Sem anúncio/publicidade, sem merge ou deploy autónomo em produção.

## 18. Migração e reconciliação com o repositório

Auditoria inicial histórica: pedro-ai-coder/aura-farmer usa TypeScript/Phaser/Vite, Vitest e Playwright. Oito IDs de personagens existentes são os preservados na secção 7. Os documentos antigos com Focus e múltiplas auras são históricos quando entram em conflito com esta visão.

PRs #49 (arte/mapas) e #18 (schema backend) foram observados abertos em 14 outubro na auditoria anterior; não revalidado o estado nesta revisão documental. Respeitar ordem e dependências; nenhum PR é automaticamente incorporado por este documento. Backend #18 não é pré-requisito para demo solo.

Seguir AGENTS.md: branch própria, PR, validação e sem merge/deploy autónomo. Só decidir novo repositório após auditar conteúdo reutilizável. Preservar tag/ref da versão atual, IDs e desbloqueios; migração de saves com versão e fallback explícito. Não clonar regras em UI e simulação: uma fonte para caps, slots, triggers e compatibilidade.

## 19. Critérios de aceitação e validação

Esta revisão é design; não foram executados testes de gameplay. As fórmulas e tabelas são valores iniciais aprovados para implementação; não constituem balanceamento comprovado. Só declarar jogo pronto para testar após todos os testes previstos concluírem com sucesso; corrigir e revalidar falhas. Não confundir “documento revisto” com “demo pronta”.

| Sistema | Critério verificável |
|---|---|
| Catálogo | 9 personagens (3/tipo), 9 armas aprovadas, 28 passivas (10/8/6/4), IDs únicos e compatibilidade definida |
| Triggers | Testar tempo anterior/exato/posterior; pausa não avança; multi-hit não multiplica procs; sem recursão |
| Níveis | XP transita, filas preservadas, nível25 respeitado; conta/wave/aura independentes |
| Co-op XP | Uma recolha credita uma vez; todos sobem juntos e mantêm escolhas pessoais |
| Slots | Nunca >3 armas ou >5 passivas; starter e lendária contam |
| Raridade | Epic não sobe a 3/4; legendary só nível1; promoção respeita caps e comparação |
| Lendária | Seis opções legais, 3+3; só waves4/5; adiar não rerolla; uma seleção total |
| Waves | Transições aos **2/4/6/8 min**; eventos **2:15/4:15/6:15/8:15**; composição correta; metas de XP observadas em runs reais |
| Boss | Spawn **10:00**; aviso **9:30**; berserk **120 s de combate** (aos **12:00**); sem wipe automático; regen/resistência/dano corretos |
| Berserk | Aritmética de DPS líquido positiva em builds-alvo; possibilidade de vitória após enrage demonstrada em playtest |
| Personagens | Flexes visual/mecanicamente diferentes; oito IDs antigos preservados; suporte viável solo |
| Inimigos | Avisos respeitados; carga/beam fixam direção; sem spawn sobre jogador ou tiro através de cobertura |
| Interface | Uma modal; inputs bloqueados; XP e aura distintos; seis cartas cabem nos viewports |
| PvP | Quando implementado: nenhum RNG de combate, nenhum bónus externo; preset separado |
| Plataforma | Iniciar/evoluir/vencer/perder/reiniciar em browser e Discord; browser sem Discord |
| Qualidade | Typecheck, testes unitários, build e browser previstos todos verdes; riscos/unrun reportados |

Balancear com seeds representativas e composição de solo, duo e cinco; medir duração boss, utilização Flex, dano pessoal/assistido, cura efetiva, escudo absorvido e sobrevivência. Não basta passar testes de regras para afirmar que é divertido/equilibrado.

## 20. Aprovações, decisões futuras e backlog

**Aprovado pelo criador em 14 outubro 2026:** expansão 6→9 armas; termo Melee; redistribuição de kits preservando oito IDs; números iniciais das fichas; pausa de equipa; revive; progressão XP; oferta lendária operacional. A palavra “proposta” nas secções detalhadas descreve a origem e o caráter ajustável de tuning, não um bloqueio de aprovação. A implementação pode seguir estes valores, com alterações de regra documentadas. Aprovação registada nesta revisão: estas alterações podem avançar para implementação. Validação de equilíbrio e qualidade continua obrigatória.

**Antes de lançar co-op/arena:** política de desconexão, experiência de seleção, fórmula final de matchmaking e recompensas, presets competitivos, duração/vitória PvP e rede autoritativa.

**Futuro:** equipamento permanente pré-run, aplicações dedicadas, cross-save, temporadas/loja e **Wild (nice to have)**. Nenhuma destas funcionalidades cria dependência no protótipo solo.

## 21. Referências consultadas e limites da adaptação

Consulta: 14 outubro 2026. As referências fundamentam princípios; tempos, damage coefficients, XP, personagens e bestiário deste GDD são propostas originais, não números copiados dos jogos.

- [Riot — Anima Squad 2024: Everything You Need To Know](https://www.leagueoflegends.com/en-gb/news/game-updates/anima-squad-2024-everything-you-need-to-know/): movimento, mira/manual-auto, melhorias e experiência cooperativa como inspiração.
- [Riot — Patch 14.15 Notes](https://www.leagueoflegends.com/en-us/news/game-updates/patch-14-15-notes/), secção Swarm: exemplos concretos de cooldown/duração de YuumiBot, frequência de T.I.B.B.E.R.S e mudanças ao enrage visível. Adaptamos timers claros; não copiamos o wipe final desse enrage, incompatível com a regra do criador.
- [Riot — The Tech Behind Swarm](https://www.riotgames.com/en/news/the-tech-behind-swarm): progressão entre runs e organização de sistemas; não usar para atribuir números de XP da nossa run ao Swarm.
- [Brotato — página oficial na Steam](https://store.steampowered.com/app/1942280/Brotato/?l=english): armas automáticas, personagens distintos e waves como referência. Os nossos inimigos/arte são originais.
- [Lost Ark — Vykas Inferno & Achates Trial Academy](https://www.playlostark.com/en-us/news/articles/vykas-achates-academy): exemplos de enrage, padrões mais rápidos, janelas de dano e coordenação. Achates pode voltar ao normal por stagger nessa referência; Big Hater não, por decisão de design deste GDD.
- [Blizzard — Hotfixes: April 17, 2026](https://news.blizzard.com/en-us/article/24266320/hotfixes-april-17-2026): referência primária da existência de fase berserk em encontro de WoW, sem atribuir à Blizzard os parâmetros aqui propostos.

## 22. Histórico e consolidação V2.0

**V2.0:** consolidação das regras aprovadas, identidade A, galeria dos dez assets, nomes atuais dos mapas, distinção master/runtime e plano de refactor do anexo B. Não altera os números de combate aprovados. Aprovação visual não equivale a integração nem a testes de jogo.

**Revisões anteriores:** Wild removido dos modos ativos. Separados nível da run, waves, aura e progressão externa. Adicionadas ações/cadências de nove armas, efeitos/triggers de 28 passivas, nove fichas de personagem com Flex, onze inimigos, quatro eventos de boss e Big Hater com soft enrage quantitativo. Corrigida distribuição de passivas para 10/8/6/4. Definidas propostas para XP partilhada, calendário das waves, janela lendária, pausa co-op e regras anti-recursão. Preservados sem anúncio/publicidade, demo web/Discord e contrato de testes antes de declarar pronto.


## 23. Approved platform and engine strategy — 21 October 2026 (Godot edition)

**Decision and precedence.** Aura Farmer's Godot edition has three **equally important target platforms: Web, Android and iOS**. No platform is a lesser tier, optional stretch goal or merely a wrapper assumed to work. This approved 21 October 2026 decision supersedes contradictory platform-priority wording in the 14–16 October historical sections (including the former browser-only demo plan in §17, native apps as future scope in §20/B.6, and the original browser/Discord-first delivery order). Those older records remain evidence of prior implementation and are not the new release contract. All other approved gameplay, catalog, artwork and balance rules remain unchanged.

### 23.1 Engine and independent codebase

The new edition uses **Godot 4, GDScript and a renderer compatible with Web export**; its source is maintained in `pedro-ai-coder/aura-farmer-godot`. The existing Phaser + TypeScript + Vite repository is the current reference implementation and migration source, **not** a dependency required at runtime or something to overwrite. The Godot repository must hold its own canonical `docs/GDD.md`. Keep identifiers, formulas, seeds and gameplay outcomes consistent with this GDD during the port. A future change of engine or parity contract requires a recorded GDD decision.

### 23.2 Common content and MVP scope

- The **first cross-platform solo playable slice** stays scoped to **Sigma, Cool Kid and Alpha Chad**, the approved **nine weapons**, **three weapon slots**, **five passive slots**, and the explicit **23-passive demo subset** until a separate content-expansion decision is approved. The full nine-character and 28-passive catalog remains a future content milestone, not an implicit requirement for the first solo slice.
- Retain a single Aura with each hero's own Flex, five waves, events, Big Hater, equipment rarity caps (common 4, rare 3, epic 2, legendary 1), meaningful pickups, victory, defeat, restart, the approved Cartoon Arcade identity and the current GDD's combat rules. Do not create or redesign characters during platform foundation work.
- All three targets use the **same simulation rules, content catalog, balance parameters, seeds and state transitions**. Platform adapters may change input handling, screen layout, rendering quality, audio integration and lifecycle without silently changing XP, damage, spawn rates or drop probabilities.
- Discord Activity, online co-op, ranked, PvP, account systems, monetization and additional maps/characters remain separate later milestones, not dependencies for the first playable three-platform slice.

### 23.3 Platform requirements

| Target | Mandatory support and verification |
|---|---|
| Web | Desktop and supported mobile browsers; viewport scaling, keyboard/touch support, pause/resume, sound, persistence, and a full playable run verified in a real browser |
| Android | Installable native build, touch controls, landscape/safe areas, focus/background lifecycle, sound, durable local saves, and a real-device full run |
| iOS | Installable signed native test build, touch controls, orientation and safe areas, suspend/resume, audio, durable local saves, and a real-device full run using macOS/Xcode signing where required |

The same gameplay must be accessible on each target; a successful Web export does not prove native support. Do not announce Android/iOS support on the basis of mockups or emulation alone. Input must remain usable if orientation lock or fullscreen is refused by the OS. Support reduced motion and effects budgets appropriate to each hardware profile.

### 23.4 Save migration and privacy

Preserve all existing stable character, weapon and passive identifiers. The legacy Phaser Web implementation stores `aura-farmer:profile:v2` (with a compatible v1 fallback at `aura-farmer:profile:v1`); a Godot save adapter must provide **versioned, tested conversion** preserving valid unlocks, selected hero, aggregated progress, settings and historical results. Do not destroy old browser data, fabricate missing records or carry in-run equipment into new runs. Browser localStorage is not automatically available to native Android/iOS installations: **cross-device/cloud sync is not implied**. If user-controlled import/export is added, validate integrity and require explicit user action for transfer; never silently upload private progress.

### 23.5 Equal-priority delivery gates

1. Maintain an independent, tested shared Godot core before platform-specific changes. Each iteration identifies GDD clauses, input/output contracts, and reproducible test evidence.
2. Validate content/rule parity in deterministic tests across the common core, including save migration, modal pause behavior, combat rules, XP, Aura, equipment caps, wave timing and boss outcomes.
3. Develop Web, Android and iOS export/input/lifecycle capabilities as **parallel first-class workstreams** once the shared slice is playable, rather than shipping an unfinished native build as a Web afterthought.
4. Each platform must demonstrate start, play, upgrade, use Flex, survive waves, reach boss, win/lose, pause/restart and preserve progress in a representative environment. Test both ordinary and reduced-performance settings; capture actual frame times and identify devices used. Apply §16's initial 60 FPS reference desktop / stable 30 FPS reduced-profile goals subject to profiling, not guessed hardware claims.
5. **Cross-platform private demo readiness** requires all three platform gates plus shared gameplay and visual acceptance. If one platform is blocked, report the individual status honestly; do not call the combined delivery complete. The first private test build does not automatically authorize store release, publicity, production deployment or paid services.

### 23.6 Migration execution and precedence

Source repository: `pedro-ai-coder/aura-farmer`; new repository: `pedro-ai-coder/aura-farmer-godot`. Preserve original assets/metadata, saves and IDs; make migration changes in isolated PRs; check all source branches/PRs before selecting source files (notably the Ruin Alley expansion work in PR #102). Keep the source project intact. Code, technical documents, PR descriptions and downstream external deliverables should be written in English. The GDD remains the sole authority for approved gameplay and platform requirements; migration inventory documents are **evidence**, not alternative specifications. All merges and release actions remain subject to the project's current authorized workflow and required test gates.

## 24. Approved roguelite design direction — 22 October 2026 (concept approval)

**Owner decision and scope.** The creator approved exploring a distinctive blend of Brotato-style meaningful build choices, Swarm-style optional arena objectives, Vampire Survivors-style memorable synergies, and original Aura Farmer Cartoon Arcade/brainrot identity. This is a **design-direction and scoped-prototype approval**, not blanket authorization to ship mechanics with unspecified numeric rules. §23 platform equality and the established GDD mechanics remain the production source of truth. The Phaser reference must stay unchanged.

### 24.1 Experience pillars

1. **Meaningful build choices:** three weapons and five passives remain the whole equipment capacity; every upgrade must show what it changes and why it synergizes. No second shop or currency is implied.
2. **An arena with opportunities:** movement serves route choice and risk/reward in addition to avoiding damage. Optional objectives must coexist with existing waves, the Safe Spot, collision covers, fixed event bosses and Big Hater.
3. **Signature, earned power spikes:** the single Aura/Flex, one legendary choice and approved rarity system remain the main peaks. Conditional combinations must not become compulsory or bypass these caps.
4. **Fast readable action:** attack danger, pickups, enemy priorities, recovery windows and rewards must remain clear on mobile and under high enemy density.
5. **Replayability without permanent combat advantage:** discoverable combinations, character identities, difficulty modifiers and cosmetic/account achievements can reward repeated runs, but account strength may not invalidate the first-run challenge or future PvP fairness.

### 24.2 Concept-approved prototype tracks

| Track | Prototype concept and purpose | Explicit production boundary |
|---|---|---|
| P4 — Street crates | Place a limited number of destructible, visually readable reward objects at authored, walkable-map-legal positions. Reward risk-taking with *already approved* XP, Street Snack or Aura Magnet; prototype destruction and loot telemetry. | Never turn the two existing static collision covers into destructibles. No new drop rates, wave resources, extra enemy spawns or unapproved artwork in the normal build. |
| P6 — Trend Challenges | Try **up to two optional short objectives per run** for an initial experiment: defend an area, defeat a marked roaming enemy or survive a timed danger zone. Show a clear start/finish/reward and allow players to ignore them. | No mandatory progression gates, penalty for ignoring, secondary mission currency, random PvP rewards, time freezes or displacement of authored boss events. Placement, 12–20 s duration ideas, reward values and eligibility require tuning. |
| P7 — Meme Combos | Prototype **three named weapon + passive pairings** for build variety: No Cap + No Cap Streak (directional mastery), Keyboard Warrior + Let Him Cook (momentum), and Cope Shield + Big Chad Energy (defensive timing). First implement card-preview/synergy highlighting of existing approved effects. | Do not add a fourth weapon, sixth passive, a second legendary, a new tier or an undocumented proc. Any additional damage, transformations or triggers are experiments pending explicit numeric approval. |
| Upgrade choice agency | Make existing comparisons, rarity upgrades and synergies immediately legible on cards and in a build panel. Trial **one optional reroll per run** in an isolated branch if comparison alone is insufficient. | Rerolls are **not** approved for normal offers yet; no shop, reroll economy, monetization or RNG changes in production without a GDD decision. |
| P5 — Viral Burst | Experiment with a rare, high-impact pickup to create a memorable common-enemy crowd-clearing moment and clear VFX/audio cue. | Never delete a boss or elite, grant extra XP for artificially removed enemies, bypass the Flex/legendary resource rules or exceed performance budgets. Spawn/strength/caps need a separate contract. |
| Boss game feel | Upgrade the *existing* Big Hater, event boss, telegraph, stagger and phase feedback: clearer windups, reactive hit confirmations, better audiovisual contrast and camera-safe boss information. | Approved numeric attacks, arena geometry and boss phases remain unchanged unless explicitly revised. Visual-only polish may proceed using approved assets. |
| Aura Archive | Later milestone: store discoverable combos, defeated foes, hero-specific feats, per-run records and cosmetic unlock milestones using versioned local profile data. | No default extra combat stats, cross-device account system, new purchasable power, compulsory grind or save incompatibility. Specific reward/content catalog awaits approval. |
| Hater Levels | Later milestone after a validated first victory: opt-in difficulty modifiers emphasizing new tactical constraints or more demanding enemy composition, with cosmetic/achievement rewards. | Do not silently scale baseline Normal difficulty or invent new PvP advantages. Modifiers, progression unlocks and rewards require individual balance approval. |

**P8 map-exclusive events:** still *not* concept-approved by this decision. Scope remains Ruin Alley and the three-hero solo slice until later content approvals. All original additional-map/character goals retain their separate roadmap status.

### 24.3 Development and review gates

- Stage A — Stabilize baseline Phaser parity, polished Cartoon Arcade UI, three starter Flexes, recoveries P1–P3, ordinary-health full-run balance and actual Web/mobile/native gates. The new tracks must not delay this acceptance.
- Stage B — Implement *feature-flagged or separate-branch* P4 and P6 experiments, with small predetermined map content, seeded outcomes, truthful loot and no new art presented as approved. Test usefulness, not just technical correctness.
- Stage C — Surface existing item synergies in the UI; then separately prototype P7 and a one-reroll variant. Compare diversity, fairness and boss viability.
- Stage D — Consider P5, Aura Archive and Hater Levels only after the core game is fun and performant. Build a separate GDD implementation specification per approved feature before enabling it by default.
- Test seeded reproducibility, no XP duplication/farming, player survival, objective participation, build variety, accessibility, mobile performance and boss-phase pressure. Preserve current saves or provide versioned migrations. Do not assert approval of new generated art or balance parameters from this conceptual decision.

## 25. Approved shorter run duration and Flex design exploration — 22 October 2026

**Decision and status:** On 22 October 2026 the owner **approved the new 10-minute survival clock and 120-second boss berserk delay**. The operational requirements in §§2, 5.3, 10, 12 and 19 have been amended accordingly. This **does not** imply the Godot/Phaser runtime has already migrated or that shortened-run balance is verified. The **Flex 2.0 identities and initial PvE mechanics are approved** and specified authoritatively in §7.2; they still require a distinct Godot implementation and balance/visual acceptance before they can be called shipped.

### 25.1 Approved shorter standard-run schedule

**Approved:** five waves of **120 seconds** each, then Big Hater at **10:00**, with recoverable Berserk after **120 seconds of boss combat (12:00)**. Aim for a typical successful encounter lasting about **one to three minutes**, implying **11–13 minutes of active simulation** as a *target, not a guaranteed run length or hard cutoff*. Upgrade/pause decisions increase real elapsed time; measure both.

| Milestone | Historical schedule (superseded) | Approved new schedule |
|---|---|---|
| Wave 1 | 0:00–3:00 | 0:00–2:00 |
| Wave 2 / Reply Guy | 3:00–6:00 / 3:15 | 2:00–4:00 / 2:15 |
| Wave 3 / Mod Supremo | 6:00–9:00 / 6:15 | 4:00–6:00 / 4:15 |
| Wave 4 / Ohio Express | 9:00–12:00 / 9:15 | 6:00–8:00 / 6:15 |
| Wave 5 / Doomscroll Prime | 12:00–15:00 / 12:15 | 8:00–10:00 / 8:15 |
| Legendary first / reprise / deadline | 9:00 / 12:00 / 14:55 | 6:00 / 8:00 / 9:55 |
| Boss warning / Big Hater | 14:30 / 15:00 | 9:30 / 10:00 |
| Berserk begins | 18:00 (180 seconds into boss) | **12:00** (120 seconds into boss); remains recoverable |

**Historical schedule is superseded, not removed from the decision record.** The approved 10-minute schedule is the *only* canonical clock for subsequent implementations and acceptance tests; the older 15/18-minute statements in historical audit notes at the top of this document describe completed older baselines, not current requirements. A further **8-minute survival + approximately 2-minute boss** variant is a separate, **unapproved** future experiment if measured sessions remain excessive. There is no hard kill timer or scripted automatic loss.

**Implementation and balance gate (mandatory):** This change authorizes the canonical clock and its explicitly dependent event/legendary deadlines, not unreviewed modifications to damage, HP, XP formulas, weapon/passive values, drop rates or hero Flexes. Apply new timings as one coherent Godot change (and document untouched Phaser as a legacy reference), migrate regression tests, then rebalance the run **in separate measured, GDD-recorded decisions** addressing enemy-spawn density, event overlap, XP pacing, rarity access, level-25 reachability, Aura/Flex opportunities, recovery, boss HP/DPS viability and device caps. Run repeated honest-health seeds for all three heroes; record median/P90 real time, active time, level/equipment at the boss, deaths by wave, recovery usage, meaningful choices, boss victory rate and rendered FPS. Compare old 15-minute and new 10-minute regimes fairly. **Do not ship the shortened run as fully balanced merely because timeline CI passes.**

### 25.2 Flex 2.0 — approved signature identities and implementation handoff

**Owner approval (22 October 2026):** The final starter-role identities and public names are **Deadpan Verdict (Sigma)**, **CTRL + CHAOS (Cool Kid)** and **Giga Chad Rampage (Alpha Chad)**. This is no longer a naming-only proposal. The complete, authoritative first-pass solo PvE timing, damage, mitigations, deterministic rules, audiovisual requirements and acceptance gates now appear in **§7.2 and §§7.2.1–7.2.4**. Phaser remains untouched; Godot should migrate these in a separate tested implementation PR.

| Hero | Approved action fantasy | Distinct audiovisual payoff |
|---|---|---|
| **Sigma — Deadpan Verdict** | Prioritize and focus down one dangerous target; deliberate lock-and-fire gameplay | Comic target lock, 3-hit build-up and a bounded **VERDICT!** single-target strike |
| **Cool Kid — CTRL + CHAOS** | Mobile keyboard fighter chaining timed directional melee beats, not a tank | Fast blue keyboard strokes, six clear beats and the directional **ENTER!** finisher |
| **Alpha Chad — Giga Chad Rampage** | Heavy protector controlling space with shield, taunt, slams and measured retaliation | Armored golden entry, three weighty impacts and a **GIGA!** shield-absorption shockwave |

**Why this overrides the old naming:** The previous Cool Kid's Giga Chad contact immunity was not a good fit for the slim, agile keyboard character. The Giga Chad fantasy now belongs to Alpha's heavyweight identity, *but the former Cool Kid immunity is not transferred to Alpha*. Cool Kid gains an active positioning/combination role; Alpha retains his existing shield/taunt/three-slams foundation and gains a bounded payoff. Sigma adds an earned finishing strike to his approved target-focus skill. The other six heroes' §7.2 rules remain unchanged.

**Art, implementation and balance constraints:** Do not redesign or invent artwork as an implementation shortcut. Source all characters, props and icons from approved inventories until further art approval. Restore readable READY/active/finisher phases, including mobile and reduced-motion cues, without hiding enemy warnings. Do not alter weapon/passive caps, Aura economy, PvP, saves, fixed event schedules or the shortened ten-minute run. The approved initial damage numbers need gameplay tuning evidence before declaring the Flex redesign balanced.

### 25.3 Decision gates

1. **Run-clock approved:** 10:00 boss / 12:00 recoverable berserk is now canonical and §§2, 5.3, 10, 12 and 19 are coordinated. Implement the new schedule and deterministic timing tests in Godot; run real-health balance tests before declaring the updated run tuned. Do not modify Phaser.
2. **Flex decision approved for solo PvE:** Implement **Deadpan Verdict**, **CTRL + CHAOS** and **Giga Chad Rampage** exactly as detailed in §7.2. Follow with deterministic regressions, all three honest-health runs, mobile/desktop visual comparison, and evidence-led balance review. Other six Flexes remain unchanged; PvP rules still require separate approval.
3. Cosmetic/readability work on these owner-approved new Flexes and existing bosses may advance under §16 and Annex A, **using only inventoried approved art**. Additional specialized Flex artwork requires explicit Art Bible review.
4. Track experiment results separately from normal runs and keep feature flags off by default until balance, save compatibility and platform acceptance are met.

## 26. Approved production visual identity — 23 October 2026 (Art Bible V5)

**Creator approval (23 October 2026):** The owner explicitly approved the **Aura Farmer — Production Visual Art Bible V5.0**, including its **Arcade Street Clean — Hero Spotlight** production-art direction, and authorized its integration into the Godot project. This is now the **required visual reference for the production version of the game**, building on the previously approved **Option A — Cartoon Arcade** visual identity in Annex A. The approval supersedes older v2/v3/v4 UI mockups, schematic UI diagrams, placeholder glyphs and inconsistent menu/card stylings **as visual targets**. It does not revert or supersede the GDD's authoritative gameplay, platform, character, balance, event, save or content rules.

**Creator-approved visual refinement (24 October 2026):** **Character Hype Broadcast — Clean Cut** is the selected production direction, evolving the approved Hero Spotlight V5 style. Preserve original Option A character/environment identities, existing approved masters, the V5 palette/typography/composition foundation and all canonical gameplay rules. The creator specifically approves the 37 exact PNG icon artworks enumerated in [the durable creator decision](art/CREATOR_ICON_APPROVAL_2026-10-24.md): eight V5 weapon PNGs, all 28 V5 passive PNGs, and **Touch Grass Clean Cut v2** PNG (`3b8635df874e611debfffcae0b1d409da7a97708a9d710bd69588fb298102eca`) instead of its V5 candidate. The matching v2 SVG is a nonblocking future art-production delivery; never pair it with the old V5 SVG. Known small-size/SVG-font/margin/silhouette refinements do not block these exact PNGs, but modifications require a new hash and separate creator approval. Maintain item names/labels for compact recognition. Art approval does not enable the five future-only passives or approve additional heroes, animations, Flex sprites, environments, UI backgrounds or future icon versions. Promotion remains hash-verified and export-isolated; gameplay, save and platform contracts are unchanged.

**Creator-approved corrected five-screen Clean Cut artwork (24 October 2026):** The owner has now explicitly approved integrating the exact corrected visual sources from Art PR #69, commit `c1e13cdca5e0645e5f809dc6453ee75f979c8d4e`, under `assets/art-production/character-hype-clean-cut/v2/creator-corrections-v1/`. The immutable decision and resource hashes are documented in [the Clean Cut V2 creator approval](art/CREATOR_CLEAN_CUT_V2_APPROVAL_2026-10-24.md) and `assets/runtime-clean-cut/v2/manifest.json`. For **Main Menu, Hero Selection, Gameplay HUD, three-card Upgrades, and six-card Legendary Selection**, these corrected street-poster/cut-paper compositions and independently reusable buttons, cards, HUD and circular mobile input layers supersede earlier V5 rounded/uniform screen composition guidance, **visuals only**. Existing original masters and 37 approved item PNGs retain their exact approvals; rejected older candidate variants remain non-shipping. All dynamic labels, timing, rarity, Flex effects, mouse/touch ownership and game rules remain governed by the latest GDD, including Annex C.1. Additional screen families and newly altered asset hashes still require independent approval and acceptance; approval of artwork is not equivalent to successful runtime/Web/mobile validation.

**Authoritative implementation contract:** [Hero Spotlight V5 — Production Art Direction and Developer Handoff](art/HERO_SPOTLIGHT_V5.md). The delivered 56-page illustrated Art Bible V5 PDF/DOCX and *Visual Production Handoff V5* archive are the visual source reference. This section records the approval and the main production constraints. The handoff archive's binary files are not assumed to be in the GitHub repository merely because the specification is merged; they must be imported, verified and integrated explicitly.

### 26.1 Visual design locked for production

- **Presentation:** expressive oversized illustrated hero portraits, recognizable Option A actor silhouettes, deep navy ink and bright urban environment accents; custom outlined *Aura Farmer* comic logo; warm-cream card/dialog surfaces; Aura-gold primary buttons; blue/navy secondary controls; crisp cel-shaded cartoon weapons and effect shapes. The finished-looking **22 V5 scene compositions** are the target for live Godot screens, not textures to be flattened over interactive elements.
- **Typography:** production UI targets **Inter Display Black 900** for major titles, **Inter Black 900** for buttons, **Inter ExtraBold 800–900** for item names, **Inter SemiBold 600** for numerical HUD text and **Inter Medium 500** for descriptive copy. Use a separate illustrated logo master. These selections supersede the earlier exploratory Barlow/Bangers fonts; properly license/bundle font files during implementation.
- **Palette tokens:** navy \`#253449\`, deep ink \`#13233A\`, panel blue \`#1F3E63\`, warm paper \`#F7EDCD\`, aura gold \`#F8C45F\`, sky blue \`#4EA3FF\`, Hater coral \`#E57461\`, support teal \`#6EAAB0\`, Cool Kid magenta \`#F04BA5\`, epic violet \`#A66BFF\`, healing green \`#78C85C\`. Colors communicate meaning alongside shapes and text, never instead of them.
- **Reference layout:** scene compositions use 1600×900 at 16:9, scaling to the GDD's 1280×720 reference. Responsive layouts must use Godot anchors/containers and mobile safe areas, not fixed screenshots. Use an 8 px spacing rhythm (4 px micro-adjustments).
- **Core components:** primary and secondary round-corner buttons target height 72 px, radius 15 px and a 4 px border at the 1600×900 reference; hero cards about 445×576 px; normal upgrade cards about 386×480 px; legendary cards about 430×300 px. These are visual reference dimensions and must scale accessibly on smaller screens.
- **Required scenes:** menu, hero select, gameplay HUD, three-card upgrades, six-card legendary choice, pause, settings, victory, defeat, boss encounter, mobile landscape, build panel, Flex effects, weapon icons, passive icons, bestiary, pickups, wave transitions, FULL HATER MODE, quit confirmation and Safe Spot presentation — all specified in the V5 handoff.
- **Icons:** the approved V5 iteration supplies visual targets for **nine weapon icons** and **28 passive icons**, with isolated transparent SVG/PNG source candidates. Preserve the catalogue's stable IDs. Rarity is a UI frame/style, not a different item identity. Validate icon legibility at 32×32 and consistency before accepting the exported binaries as runtime-ready.

### 26.2 Gameplay and asset precedence

1. **Existing game design still controls all behavior.** Where V5 visual examples include obsolete or illustrative values, titles, clocks, damage, equipment labels or abilities, correct the live UI labels and images to the **current GDD** instead of changing gameplay. In particular, **§7.2** defines Sigma's **Deadpan Verdict**, Cool Kid's **CTRL + CHAOS** and Alpha Chad's **Giga Chad Rampage**; the latter belongs to Alpha, not Cool Kid. Do not revive old Sigma Stare, Cool Kid Giga Chad Rampage or Alpha Hold behavior.
2. **§25 is authoritative for the approved shorter run:** five 120-second waves, Big Hater at **10:00** and berserk 120 seconds into the boss encounter. Do not restore the historical 15:00 / 180-second schedule from V5 sample pictures.
3. **Annex C.2** is authoritative for production-approved solo recovery: Street Snack, Aura Magnet and Safe Spot. P4–P7 are concept/prototype-scoped only; P8 is unapproved. Visualizing a possible future pickup does not enable its gameplay.
4. **§23 platform equality remains binding:** identical content/play rules across Web, Android and iOS, with platform-appropriate responsive UI, touch and lifecycle handling. The Phaser repository must remain unchanged.
5. Preserve creator-approved Option A static masters and existing imported runtime atlas provenance. This approval concerns the **target presentation and art direction**; generated composition previews are not proof of sprite animations, UI interactivity, collisions, navigation, FPS or native-device acceptance.

### 26.3 Integration and acceptance

- Implement the UI as **live Godot Controls and world sprites**, using V5 compositions for art direction and layout. Do not paint HUD text or buttons into a gameplay-map background.
- Import the V5 handoff deliverables from the approved source package. Verify the 22 scene visuals, 9 weapon icons and 28 passive icons, and record exact source paths/hashes. The historical original artwork import contract remains active.
- Audit each screen on desktop/Web, Android and iOS landscape (and any supported fallback orientation) for legibility, hit targets, focused/selected states, safe areas and reduced effects.
- Inspect the launch three heroes in real gameplay; compare boss/wave/telegraph readability and icon shape at actual rendering scale. No bright overlay may obscure a hostile telegraph.
- The **approval is for art direction and visual iteration**, not an assertion that all V5 exports are already in Godot, that the game has been tested visually, or that a store/release/production deployment is approved. Record actual implementation, visual QA and platform evidence separately.

### 26.4 Explicit Visual Art Bible V5 reconciliation register

The 56-page *Aura Farmer — Production Visual Art Bible V5.0* was authored using an **older gameplay snapshot**. Its illustrations, approved composition, interaction hierarchy and production visual tokens remain binding visual targets. Its old labels, timestamps, ability descriptions and screenshot counters **must not be transcribed as runtime rules**. The following reconciliation list is mandatory for the Godot UI and future visual asset briefs.

| V5 page / scene | Outdated or illustrative V5 content | Required live Godot content and behavior from canonical GDD |
|---|---|---|
| **p.2**, read-me / current timing; **p.24–25**, Scene 10 boss; **p.44–45**, Scene 20 berserk | Five 180-second waves, Big Hater at 15:00 and Berserk 180 seconds into the encounter | **§5.3 / §12 / §25:** five **120-second** waves; Big Hater at **10:00**; recoverable Berserk **120 seconds into boss combat (12:00)**; final-effort hint at **14:00**. All counters are data-bound. No hard run expiration. |
| **p.42–43**, Scene 19 wave transition; **p.10–11**, Scene 03 gameplay HUD | Example wave/time combinations and a 6:00 Wave 3 cue taken from an older simulation | **§5.3 / §12:** wave boundaries **2:00, 4:00, 6:00, 8:00**, event bosses **2:15, 4:15, 6:15, 8:15**, and initial Hater at **1:00**. Only real simulation state supplies banners, labels and clock. |
| **p.8–9**, Scene 02 hero selection; **p.30–31**, Scene 13 Sigma Flex; **p.32–33**, Scene 14 Cool Kid & Alpha Flex; **p.50**, hero/Flex catalog | Sigma Stare, Cool Kid Giga Chad Rampage, Alpha Hold; prohibition of the then-unapproved §25 finisher | **§7.2 (approved Flex 2.0):** **Deadpan Verdict** for Sigma (6 s target focus and one earned Verdict), **CTRL + CHAOS** for Cool Kid (5 s, six directional keyboard beats and ENTER!), **Giga Chad Rampage** for Alpha (6 s, shield, three slams and capped countershock). Use the current detailed timing/damage/counterplay contract; historical wider Cool Kid Rampage atlas is *not* Alpha's new artwork. |
| **p.14–15**, Scene 05 legendary; **p.12–13**, Scene 04 normal upgrades | Illustrative item names, levels and offers from the composition, plus potentially outdated legendary window captions | **§§8–10 / §25:** normal choices are **three legal cards**; the legendary displays **three compatible weapons + three legal passive buffs**, one selection per run. Initial/repeat/end times are **6:00 / 8:00 / 9:55**. No added reroll, fourth weapon, sixth passive or second legendary. |
| **p.40–41**, Scene 18 pickups; **p.48–49**, Scene 22 Safe Spot | Styled XP/Snack/Magnet/zone symbols and example progress counter | **Annex C.2:** Snack **5% normal / 20% elite**, heals **18% max HP**, pickup **56 U**; Magnet **2% / 8%**, pickup **72 U**, collects *existing XP only*; Safe Spot at **(1100,565)**, **68 U** radius, **2 s** charge, **25% max HP** heal, **90 s** active-time cooldown. All visuals reflect actual state; no extra Aura or XP. |
| **p.50 / p.54 / p.56**, artwork catalog and handoff index | Describes Flex 2.0 or the shorter run as experiment-only; depicts future crate/burst/challenge concepts | **§7.2 / §25:** starter Flex 2.0 kits and 10-minute clock are now approved PvE implementation contracts. **§24 / Annex C.2:** P4–P7 remain isolated prototype-only concepts; P8 remains unapproved. None becomes normal-build gameplay because of visual examples. |
| **All 22 composites, including victory/defeat pp.20–23** | Illustrative HP, XP, time, kill count, weapons, cards, premium-looking effects or simulated UI states | Actual run/profile values, legal catalog IDs, real pause/result state, and live, accessible Godot UI controls. No hardcoded screenshot counters, simulated rewards, baked click targets or decorative fake rarity. |

**Art direction wins on appearance; the GDD wins on behavior.** Do not edit combat numbers to match V5 example screenshots, move boss events for a visual animation, or reintroduce the outdated Flex names in character selection, HUD, help, saves or result screens. Do not silently modify the approved illustrated style just because an example's label is stale.

### 26.5 Screen implementation order and minimum owner-visible evidence

Treat the V5 page pairs as **specific production compositions**, not as a general style moodboard. All 22 scenes require a traceable **V5 source page → runtime scene → actual capture → discrepancy status** record. Prioritize by real player-flow impact, while preserving correct game state throughout.

| Delivery lane | V5 scenes / PDF composition pages | Minimum visual/functional evidence |
|---|---|---|
| **P0 — core shell and choices** | **01** Main Menu (p.6), **02** Hero Selection (p.8), **03** Gameplay/HUD (p.10), **04** Level-up (p.12), **05** Legendary (p.14) | Five side-by-side V5/Godot comparison captures, with real live navigation/offer interactions, selected/disabled/focus states and actual dynamic data. |
| **P0 — art and combat identity** | **10** Big Hater (p.24), **13–14** the three signature Flexes (pp.30,32), **15** nine weapons (p.34), **16** 28 passives (p.36), **17** enemy roster (p.38), **18** pickups (p.40), **19** wave transition (p.42), **20** berserk transition (p.44), **22** Safe Spot (p.48) | Isolated approved artwork/provenance, sprite/pose/VFX comparisons in real gameplay, all nine weapon silhouettes and the current 23 offered passives readable in the MVP, exact combat-event-linked VFX and the 10/12-minute boss clocks. Full 28 passive icon catalogue is future-art-ready; it does not enable unoffered passives. |
| **P1 — flows and responsive shell** | **06** Pause (p.16), **07** Settings (p.18), **08–09** Victory/Defeat (pp.20,22), **11** Mobile Landscape (p.26), **12** Build Inspection (p.28), **21** Leave Run Confirmation (p.46) | Working keyboard/mouse/touch paths, paused-state correctness, real result/build values, one-modal rule, mobile safe insets, **full-playfield floating joystick with enlarged control and exclusive interactive-UI hit areas per Annex C.1**, joystick release, accessible focus and choice navigation. |
| **P2 — non-MVP catalogue** | Other six hero art briefs, future environments and optional catalog extras (pp.50–54) | Audit/brief only until product and individual asset approvals; no false claim they are playable or present in the solo slice. |

**Priority means implementation order, not permission to ship partial scenes as finished.** Main menu, hero select, HUD, upgrade, legendary, pause, victory/defeat and gameplay must look like the *same authored game*. Build scenes from the §26 tokens and the illustrated V5 references. The target is the **Arcade Street Clean — Hero Spotlight** composition, not a generic AI/dashboard control library with the palette pasted over it.

### 26.6 Asset classification and safe handoff gates

The following classes must be distinguished in manifests, PRs and review notes:

1. **Approved original masters:** the existing Option A portraits, Ruin Alley/map masters, current approved enemy/boss runtime sheets, animation frames and independently approved source assets from the pinned Phaser provenance. Keep source hashes, identity, silhouettes and pivots intact.
2. **Approved V5 compositions:** 22 full-screen **visual references** with documented elements and layouts, not usable Godot screen sprites and not proof that isolated interactive components exist.
3. **Candidate V5 standalone art:** nine weapon and 28 passive SVG/PNG illustrations described in the complementary *Visual Production Handoff V5* archive. **Do not assert these binaries are included in the PDF or Godot repository.** Import the actual archive, verify 37 PNG/SVG pairs, their stable content IDs, transparency, manifest/hash provenance and legibility at 32×32/64×64; each new standalone icon remains subject to individual creator sign-off before being labeled an approved shipping master.
4. **Missing independent exports:** isolated illustrated logo, clean menu plate without baked buttons/text, Flex-specific unique sprite/VFX states, animation exports, component artwork and environment prop overlays may need dedicated production. Record each missing asset and ownership rather than cropping a composite into interactive art or silently generating a different style. Obtain owner approval for newly authored identity-bearing art.

**Fonts:** V5 selects Inter for live UI; the visual PDF does not supply font binaries or grant redistribution rights. Obtain a properly licensed font source and record the integration license. Never transfer font files merely to fill a missing-source gap.

**Godot delivery:** implement with live Controls and Godot resources, reusable theme/tokens, authentic world sprites and simulation-driven signals. Attach source filenames, hashes/manifest entries, source approval status and a 32/64-pixel review sheet for icons. Do not mutate gameplay RNG, camera physics, hitboxes, XP, Aura, save schema, or scene logic solely to achieve visual parity.

### 26.7 Cross-platform visual completion gate

The V5 review is not complete until:

- A **22-row visual-parity matrix** links the illustration, current Godot screenshot, implementation commit, discrepancies, asset status and visual reviewer decision for every scene.
- All **P0 player-facing flows** are interactive (not decorative): main menu → three-hero selection → run → upgrades/legendary/pause/quit/build → real boss/win/loss outcome; no overlapping UI or dead buttons.
- Actual **1600×900, 1280×720, 1920×1080** captures and representative small-landscape and portrait/fallback screenshots are compared to V5 framing. Responsive layouts use anchors/containers and at least approximately **48 px functional touch targets**, while respecting safe areas and keeping readable labels.
- Real game-state screenshots and video demonstrate **Deadpan Verdict / CTRL + CHAOS / Giga Chad Rampage** using current §7.2 timing, correct approved recovery objects, event warnings, cinematic feedback that does not obscure hitboxes, and the **10:00/12:00** boss/Berserk clock.
- All relevant automated checks, rendered-input/browser smoke tests, normal-health full runs, signed-off approved-asset provenance, paused/modal lifecycle and reproducible performance observations are recorded separately. **A CI pass or Vercel READY state is not a visual acceptance or balance sign-off.**
- Web, Android and iOS have **separate evidence gates** under §23. A tested browser layout, desktop simulator or emulator does not prove physical-device FPS, touch safe areas, native exports or app-store readiness.
- New art, icon candidates and final artistic acceptance require **owner review**; performance, visual comparison, asset readiness, simulated full runs and genuine human playtests are distinct checkboxes. If a V5 source export or device is missing, explicitly mark that gate blocked and continue independent approved work.

**Execution handoff:** [Hero Spotlight V5 Godot Work Plan](WORK_HERO_SPOTLIGHT_V5_PLAN.md) sequences the implementation without changing these authoritative GDD contracts.

# Anexo A — Identidade visual e contrato de produção

## A.1 Direção artística definitiva — opção A, Cartoon Arcade

**Production refinement (23 October 2026):** The approved **Arcade Street Clean — Hero Spotlight** system from §26 / Visual Art Bible V5 is the live screen-composition, UI-font, component, icon-family and layout target. The original **Option A Cartoon Arcade** illustration remains the unchanged actor/environment identity baseline; both approvals are complementary, not competing alternatives. This clarification overrides older exploratory font/UI style references below only where they conflict with §26. Gameplay and timings remain governed by §§2–12, 23 and 25, and the current approved recovery/Flex contracts.

**Escolha do criador em 14 outubro 2026: opção A — CARTOON ARCADE, para personagens, inimigos, mapas, menus e lettering.** Esta escolha é a referência principal e substitui a imagem de combate anterior enquanto alvo de acabamento. As opções B e C são alternativas não selecionadas; a sugestão de misturar personagens A com mapas C não foi adotada.

![Opção A — Cartoon Arcade, direção visual escolhida](references/exec-751c31ed-f3c5-4a5f-894e-92f42146c607.png)

Referência identificada nesta conversa: `exec-751c31ed-f3c5-4a5f-894e-92f42146c607.png`. A prancha mostra personagens compactos, contornos escuros fortes, expressões exageradas, sombras simples, cores vivas, bairro urbano ilustrado, menus em placas desenhadas e lettering comic azul/amarelo. É direção visual aprovada; não é captura de um jogo implementado.

**Compromisso de produção:** reproduzir esta linguagem com a maior fidelidade possível em assets reais. Usar a mesma referência para todas as famílias de sprites, props, mapas, UI e ícones; comparar a versão jogável à escala normal com a prancha. Não substituir personagens por figuras geométricas simples nem por outra linguagem artística durante integração.

A ilustração de conceito não define colisões, posições finais, tamanhos de hitbox ou regras do HUD. Arte deve ser convertida em camadas de terreno, obstáculos, decoração, sprites, efeitos e interface, com câmera coerente. A fidelidade desejada diz respeito ao desenho, proporções, paleta e acabamento; não é promessa de reprodução pixel a pixel da composição de conceito.

Os SVGs antigos e a primeira imagem “ART DIRECTION” ficam como histórico. Personagens mantêm os IDs/regras, mas o desenho é reconstruído segundo A. Não usar assets antigos como acabamento final. Sem anúncios ou publicidade.

## A.2 Estilo visual fechado

| Elemento | Especificação para produção |
|---|---|
| Linguagem | Ilustração 2D cartoon de ação, compacta e expressiva; exagero de cabeça/mãos/ombros, assimetria intencional, traço de tinta e detalhes autorais |
| Contornos | Tinta azul muito escura; exterior mais espesso que detalhes interiores; consistência de peso em escala de jogo |
| Cor e volume | Massas de cor claras, uma ou duas sombras desenhadas e textura de tinta controlada; volume cartoon como na imagem aprovada, sem brilho plástico ou glow permanente |
| Expressão | Poses e objetos tornam o meme reconhecível; nome/legenda não substituem desenho |
| Perspetiva | Vista elevada de arena; sprites frontais/diagonais com orientação consistente; props mostram volume suficiente para ler colisão |
| Personagens | Cada silhueta reconhecível sem cor e sem nome; cabeça e acessório assinatura preservados durante movimento/Flex |
| Cenário | Chão menos contrastado que atores; props com volume, sombra e desgaste discreto; zonas de combate legíveis |
| Interface | Papel comic, tinta forte, títulos curtos e botões funcionais; menus alinhados e espaçados, sem painéis sobrepostos |
| Humor | Six Seven, Sigma, Alpha/Beta, Ratio, Tax, Touch Grass e outros motivos em objetos/ações; evitar memes gigantes a tapar o combate |

As proporções não devem ser homogeneizadas: Alpha é largo, Fanum redondo, Rizzler estreito, Six Seven esguio. Não redesenhar todos como a mesma figura com camisola de outra cor.

## A.3 Paleta e semântica

| Cor | Hex | Utilização |
|---|---|---|
| Papel quente | #F7EDCD | Menus, superfícies claras e fundos neutros |
| Tinta | #253449 | Contorno, texto e molduras |
| Aura dourada | #F8C45F | Carga/Flex pronto e feedback de progresso |
| Hater coral | #E57461 | Dano e avisos de perigo; projéteis hostis |
| Teal | #6EAAB0 | Proteção e suporte |

Vestuário e mapas usam cores próprias compatíveis, não apenas estas cinco. Raridade tem texto e símbolo além de cor: common branco/osso, rare azul, epic roxo, legendary dourado. Ouro de rarity não deve ser confundido com alerta de Flex: forma/posição/ícone diferenciam. Telegraphs nunca dependem apenas de vermelho/verde.

## A.4 Personagens — identidade preservada, execução redesenhada

Acessórios, cores de identificação e formas gerais abaixo são âncoras. Não reproduzir a anatomia geométrica dos SVGs antigos: expressão, pose, mãos, vestuário e contornos devem atingir o acabamento da opção A aprovada.

| Personagem | Identidade existente a preservar | Acabamento de produção |
|---|---|---|
| The Sigma | Capuz angular escuro, emblema de peito dourado, pose contida | Olhar/ombros orientam mira; No Cap visível como arma lançada; Stare altera olhos/emblema sem apagar capuz |
| Alpha Chad | Ombros e braços largos, cabelo dourado, maxilar quadrado | Heavy silhouette and firm feet for **Giga Chad Rampage**: shield stance, three timed slams, separate final shockwave; previous Alpha Hold art is historical, not a second Flex |
| The Rizzler | Casaco roxo longo, óculos escuros, corpo estreito | Movimento do casaco e gesto de charme; aura de suporte discreta; efeitos hostis continuam prioritários |
| Ohio Kid | Boné frontal, fato azul, sneakers destacados | Corrida inclinada e travagem expressiva; rasto Ohio acompanha caminho real, não ocupa ecrã inteiro |
| Fanum Lord | Casaco verde, volume redondo, saco TAX | Saco balança e comunica recolha; Flex tem tax pulse legível, sem moedas fictícias na UI |
| Six Seven Kid | Jersey amarelo, marca 67 grande, corpo esguio | Gestos distintos de seis/sete e contador visível; rajadas têm abertura legível |
| Cool Kid | Gorro azul com pompom, casaco de rua em camadas, sneakers | **CTRL + CHAOS** retains the nimble blue-beanie silhouette; six directional keyboard attack beats, blue trails and an ENTER! finisher. The old enlarged Cool Kid Rampage form is a historical atlas, not Alpha artwork |
| Nerd | Óculos quadrados grandes, gravata, dispositivo de mão | Dispositivo comunica ataques; linhas de precisão têm desenho próprio e direção óbvia |
| Beta Bro — novo | Luvas de espuma, mochila, postura protetora do GDD | Novo desenho neste mesmo estilo; diferente de Beta Bot, Alpha e Fanum. Não reutilizar enemy sprite para o herói |

Fichas 7.1 e anexo têm de concordar. Escolher starter não altera roupa/silhueta base. Novas skins são futuras; não necessárias para esta entrega.

## A.5 Animação: requisito de produção, não bob/tilt como solução final

A referência existente tem seis estados por herói, com dois desenhos de corrida. É material reutilizável, mas não satisfaz sozinha a expectativa de acabamento desta versão.

Entrega visual pretendida: oito direções lógicas de deslocamento/mira; quatro frames de corrida por direção, dois de idle, três de ataque, quatro de hurt/derrota em sequência combinada e pelo menos seis desenhos/poses no Flex quando há transformação. Pode reutilizar espelhamento nas direções simétricas, desde que acessórios, letras 67/TAX e efeitos não fiquem invertidos. Esses números são mínimos de produção a implementar, não frames que já existam.

Masters aprovados são PNG de alta resolução com transparência nos atores; preservar esses originais. Para runtime, produzir exportações em canvas transparente 128×128 como ponto de partida, aumentando quando a leitura exigir, e retratos 256×256; runtime usa escala regular de aproximadamente 48–64 U de altura, hitbox separada. Chefes maiores, mas aviso/hitbox não pode ficar escondido atrás da ilustração. Atlas PNG+JSON deve preservar pivot e evitar recorte de mãos/armas; Os SVGs antigos são históricos; não substituem os masters aprovados da opção A. Novas fontes editáveis podem ser produzidas sem mudar o estilo.

Tempos de animação seguem a simulação: preparação/impacto/recuperação não causam hits diferentes da tabela. Run mostra deslocamento sem deslizar; hurt comunica dano sem bloquear input indevidamente; Flex tem arranque, execução e saída. Não mascarar falta de frames com tremor, zoom ou rotação procedural constantes.

## A.6 Inimigos e bosses

Preservar NPC cinza com telemóvel, Hater rosa/coral dentado, Beta Bot com headphones/armadura e Big Hater com coroa e corpo maior. Cada família nova tem silhueta própria: Ram com cornos, Doomscroller alto com telefone, Hype Bot com antena, Leech com tubo, Sniper com tripé, Puffer inchado e Mod com apito.

NPC pode ser simples, mas ataques de Hater/Ram/Sniper mostram preparação explícita. Arma/pose apontam para a direção fixada. Elites usam acessório ou contorno e dimensão; não só recolor. Mini-bosses e majors têm alterações estruturais, não comuns ampliados.

Big Hater normal segue o master aprovado: coroa, corpo rosa, camisola branca e punhos enormes. O megafone referido no design antigo não aparece no asset atual; se necessário para um ataque, produzir como prop/efeito separado sem alterar a silhueta base; em FULL HATER MODE, pose mais agressiva, olhos/contorno coral, batida de áudio distinta e animações mais tensas. Telegraphs ficam tão claros como antes. Resistência não é comunicada por invisibilidade; regen aparece na barra com feedback discreto. Nada de flash vermelho permanente sobre o ecrã todo.

## A.7 Mapas: resultado que se deve ver

| Mapa | Identidade | Props e composição esperados |
|---|---|---|
| Ruin Alley — primeira demo | Rua clara gasta, graffiti e cultura brainrot | Contentores, caixotes, barreiras, marcas de chão e pequenas placas autorais; espaço central livre, vias laterais e coberturas reais |
| Crown Court | Pátio urbano com motivo de coroa | Bancadas, escadas, vedações, cesto de basquete, emblema central e vegetação; usar o PNG aprovado |
| Toxic Garden | Jardim urbano e estufa recuperada | Vegetação exuberante, canos azuis, barris coral e canais verdes nas margens; usar o PNG aprovado, sem atribuir dano ao cenário por mera decoração |

Dimensão antiga de referência 1800×1320 U, câmara a seguir jogador. Os três masters novos medem 1448×1086 px (4:3); píxeis da imagem não são unidades de física. Definir a projeção/escala do mundo na integração sem deformar a arte. Crown Chamber e Toxic Rooftop são nomes/conceitos históricos substituídos visualmente por Crown Court e Toxic Garden; preservar IDs de saves por alias/migração explícita após auditoria, sem inventar IDs novos silenciosamente. Para produção, chão tem desenho de superfícies e desgaste com variação localizada, nunca apenas quadrícula vazia. Props têm contacto/sombra e densidade intencional. Cada obstáculo visível que pareça sólido tem colisão consistente; não mostrar parede atravessável como cobertura.

A miniatura de seleção e o mapa efetivo partilham arquitetura, paleta e landmarks; miniatura não promete um mapa diferente. Ruin Alley é compromisso inicial; outros mapas permanecem fases de conteúdo, não precisam de aparecer como jogáveis antes da integração/validação.

## A.8 Armas, buffs e efeitos — aparência definida

| Família | Visual em jogo |
|---|---|
| Ratio Blaster | Dispositivo/arma cartoon; tiros pequenos e nítidos, impactos curtos; reações negativas como detalhe do impacto |
| No Cap | Boné reconhecível em voo, trajetória limpa; linha lendária só na região realmente atingida |
| Brainrot Feed | Telemóvel e lançamento de meme; área de impacto visível antes da explosão, sem ecrãs/screenshots colados no mapa |
| Keyboard Warrior | Teclados físicos na mão/órbita curta; dois impactos separados acompanham timing do ataque |
| Ban Hammer | Martelo desproporcionado; arco/preparação, impacto de tinta e carimbo BANNED curto |
| Touch Grass | Chicote de relva; arco vivo com silhouette legível, sem textura realista de plantas |
| Cope Shield | Escudo cartoon com gesto de bloquear; absorção/expiração distintas de dano |
| Chad Hands | Luvas/punhos grandes; combos distinguem soco de slam |
| Personal Space | Anel de proximidade com segmentos discretos; pulso breve, sem glow contínuo ocultando telegraphs |
| Buffs de suporte | Ícone pequeno sobre aliado, linhas/aura teal discretas; indicam efeito/duração sem cinco anéis permanentes sobrepostos |
| Six → Seven | Aviso de 6 perto do jogador e impacto de 7 curto; sem texto gigante no centro do ecrã |
| Legendary | Contorno/ícone dourado e mudança específica de ataque; não só maior brilho da versão common |

Nove armas e 28 passivas têm ícones próprios, exportados pelo menos 64×64; leitura validada a 32×32. Variações de raridade usam moldura/badge, não quatro ícones sem relação. Tooltip e ícone identificam o mesmo efeito; cada carta mostra a imagem da arma real usada no combate.

## A.9 HUD e ecrãs de produção

Topo: vida e pequenos estados de proteção; XP/nível e wave/relógio claramente separados. Flex em posição fixa inferior/direita, carga legível, READY com alteração de forma e pulso breve. Boss tem barra própria e timer de berserk sem competir com barra de XP.

O campo de jogo tem prioridade: por defeito, painéis permanentes não ocupam mais de 15% da área útil num desktop 1280×720. Build detalhada recolhida num painel acionável; três armas e cinco passivas cabem com ícones pequenos e nível. Texto comic nos títulos; texto de efeitos em fonte limpa e legível, sem depender de font comercial. Corpo mínimo 16 px no layout de referência.

Home apresenta personagem/mapa e botão de jogar; detalhes adicionais entram em ecrãs próprios. Sem cartões falsos de moedas, ranked ou passe ainda indisponíveis. Seleção normal mostra três opções; lendária seis, em duas linhas. Hierarquia de raridade e comparação atual→novo são funcionais, sem janelas empilhadas. Focus de teclado e hit areas preservados.

## A.10 Entrega final e critérios de aceitação visual

| Entrega | Critério para a versão jogável |
|---|---|
| Personagens | Todos os disponíveis usam arte desta identidade; nenhum quadrado/círculo temporário, sprite pixel legado ou herói genérico como fallback silencioso |
| Animação | Estados e direções acima; ataques/Flex sincronizados; pivots estáveis; sem acessórios espelhados errados |
| Mapa da demo | Composição construída e coberturas reais; piso/props/sombras completos; miniatura corresponde ao jogo |
| Armas/passivas | Ícones e efeitos específicos; nenhuma arma com mesma aparência de outra salvo skin explícita |
| Encontro final | Boss legível, padrões avisados, berserk reconhecível e barra/regen corretas |
| HUD | Sem sobreposição/corte nos viewports definidos; XP e aura distintos; seis cartas lendárias funcionais |
| Densidade | Personagem e telegraphs identificáveis em combate normal e no teto de inimigos; efeitos de cinco aliados não ocultam perigo |
| Consistência | Menu, retratos, sprites e mapas pertencem ao mesmo estilo; não misturar paper cartoon com UI sci-fi/neon |
| Evidência | Capturas reais a 1280×720 e 1920×1080 de idle, wave carregada, escolha, Flex e berserk; vídeo curto de movimento/ataque; referência de commit de cada captura |

O anexo define um contrato de resultado, não declara o pack atual finalizado. Antes da versão jogável ser entregue, completar arte em falta, verificar em runtime e comparar capturas reais com esta referência. Não usar render promocional como prova de qualidade implementada. Assets incompletos ficam visíveis na lista de produção, sem declarar prontos.

## A.11 Fontes e diferenças de estado

[Spec Cartoon V3](https://github.com/pedro-ai-coder/aura-farmer/blob/9ef4de28624507d0c678d4f0580daf96fd90f726/docs/art/CARTOON_V3_PRODUCTION.md) · [Personagens](https://github.com/pedro-ai-coder/aura-farmer/tree/9ef4de28624507d0c678d4f0580daf96fd90f726/public/assets/cartoon/v1/characters) · [Poses](https://github.com/pedro-ai-coder/aura-farmer/tree/9ef4de28624507d0c678d4f0580daf96fd90f726/public/assets/cartoon/v1/characters/poses) · [Map previews](https://github.com/pedro-ai-coder/aura-farmer/tree/9ef4de28624507d0c678d4f0580daf96fd90f726/public/assets/cartoon/v1/arenas).

**Legado inspecionado (não é o alvo visual final):** oito heróis, poses de seis estados, quatro famílias inimigas, três miniaturas e paleta. **Novo lote aprovado:** os dez PNG inventariados em A.14, ainda sem integração; não confundir as poses antigas com animações prontas no estilo novo. **A produzir/adaptar:** Beta Bro jogável, novos inimigos/bosses, ícones/efeitos do catálogo aprovado, ciclos direcionais finais e interface reconciliada com novas regras. **A comprovar em runtime:** acabamento, densidade, sincronização, resolução e desempenho.


## A.12 Estudo de referências visuais e aplicação ao Aura Farmer

Consulta em 14 outubro 2026: páginas oficiais de produto e capturas de gameplay indexadas. Trata-se de análise qualitativa de arte, não de medição de animações em execução. Recomendações abaixo são decisões de direção para Aura Farmer; não se copiam personagens, sprites, cenários nem identidade dos outros jogos.

| Referência | Observação visual e papel na pesquisa | Aplicação concreta | Limite da adaptação |
|---|---|---|---|
| **Brotato — principal para leitura** | Formas compactas, contornos claros, cenário discreto e objetos reconhecíveis numa arena cheia | Validar heróis a 48–64 U, inimigos por silhueta e projéteis pelo contraste; manter chão com menos informação que os atores | Não reduzir personagens a batatas nem copiar a extrema simplicidade para os rostos/poses do novo estilo |
| **Lost Castle 2 — principal para acabamento cartoon** | Personagens desenhados, armas exageradas, cenários com materiais e volumes próprios | Dar peso a punhos/escudos, roupa desenhada e props com forma/sombra; observar como armas pertencem visualmente ao personagem | Não importar câmara lateral nem a escala de combate beat'em up |
| **Castle Crashers — principal para expressão** | Traço gráfico forte, caricatura, poses de ação e humor coerentes | Criar silhuetas memoráveis, gestos exagerados e impactos curtos; preservar leitura sem textura excessiva | Não reutilizar capacetes, cavaleiros ou linguagem medieval; Aura Farmer continua urbano/brainrot |
| **Cult of the Lamb — complementar para unidade visual** | Atores compactos destacados sobre ambientes enquadrados, paletas e símbolos consistentes | Separar personagem/fundo/perigo por valores e cor; usar a mesma linguagem nos ícones, mapas e UI | Não importar ocultismo, predominância de preto/vermelho nem cenário escuro para a demo |

### Síntese de direção

O resultado deve combinar **a legibilidade de Brotato, o acabamento cartoon de Lost Castle 2 e a expressividade de Castle Crashers**, com coerência entre cenário, atores e UI observada em Cult of the Lamb. A opção A — Cartoon Arcade decide o aspeto final quando houver divergência entre inspirações. Não misturar quatro estilos independentes por categoria de asset.

A opção A ganha personalidade pela forma e pelo traço, não pelo número de detalhes. Concentrar desgaste, graffiti e objetos nas margens/landmarks; limpar a zona central onde aparecem projéteis e telegraphs. Reduzir contraste de rachaduras no pavimento. Sombras simples ancoram os atores, sem ocultar a hitbox. A escolha de menor ruído no chão preserva o acabamento, não implica regressar aos SVGs simples.

### Regras práticas para produzir os novos sprites

1. Criar primeiro modelos de Cool Kid, Alpha e Sigma, usando a imagem aprovada como referência de estilo. São três massas/silhuetas diferentes: ágil, pesado e preciso. Mesmas proporções e acessórios entre idle, corrida, ataque e Flex.
2. Fazer desenhos base em resolução superior e reduzir para a escala real de jogo. Avaliar ambos: uma ilustração bonita ampliada pode perder a expressão a 48–64 U.
3. Usar poucos detalhes decisivos por personagem: gorro/pompom, maxilar/ombros, capuz/emblema. Não depender de microtextura, letras pequenas ou brilho para reconhecimento.
4. Nas animações, mostrar preparação, impacto e recuperação. Estudar o princípio de peso/expressão das referências, mas usar os tempos do sistema de combate aprovado.
5. Arma, personagem e sombra em camadas reutilizáveis; não recortar a cena de conceito para fingir um sprite completo. Exportar transparência limpa, pivot estável e atlas consistente.
6. Validar cada personagem com fundo claro, fundo do mapa e em silhueta preta. Validar também sem efeitos; o Flex reforça identidade, não a substitui.
7. Construir uma cena real de referência com os três personagens, NPC/Hater e um trecho de Ruin Alley. Comparar tamanho, peso de linha e contraste antes de produzir o resto do catálogo.
8. Integrar posteriormente as nove identidades, mantendo o mesmo acabamento. Assets antigos só podem servir temporariamente durante desenvolvimento; não constituem a entrega visual acordada.

### Verificação visual da nova direção

A referência visual aprovada é um alvo, não uma garantia automática de fidelidade. A entrega deve demonstrar em jogo: rostos/silhuetas reconhecíveis à escala normal; personagens consistentes entre frames; campos de perigo legíveis com alta densidade; mapa detalhado sem ruído competitivo; ícones relacionados com armas reais; ausência de contornos cortados e halos de transparência. Guardar comparações da cena de referência e runtime no mesmo enquadramento. Aprovação artística não dispensa testes funcionais.

### Fontes para consulta

- [Brotato — página oficial Steam](https://store.steampowered.com/app/1942280/Brotato/) e [captura de combate analisada](https://nichegamer.com/reviews/brotato-review/).
- [Lost Castle 2 — página oficial e galeria](https://store.steampowered.com/app/2445690/Lost_Castle_2/).
- [Castle Crashers — página oficial](https://store.steampowered.com/app/204360/Castle_Crashers/) e [captura Industrial Castle](https://www.mobygames.com/game/35927/castle-crashers/screenshots/windows/864611/).
- [Cult of the Lamb — página oficial](https://store.steampowered.com/app/1313140/Cult_of_the_Lamb/) e [capturas de combate](https://www.pcgames.de/Cult-of-the-Lamb-Spiel-73826/Tipps/tarot-tricks-hilfe-ritual-doktrin-glaube-loyalitaet-waffen-flueche-gold-1401214/).

**Revisão V1.3:** aprovação da imagem ilustrada; SVGs anteriores passam a histórico; estudo de quatro referências e regras de transposição para sprites integrados. Nenhuma alteração de gameplay, anúncio ou publicação do jogo nesta revisão.


## A.13 Fidelidade da opção A na implementação

### Elementos que não podem perder identidade

- **Cool Kid:** corpo compacto, gorro azul com pompom, expressão confiante e teclado visível; mãos/sapatos legíveis.
- **Alpha:** massa corporal larga, maxilar e cabelo dourado, shield improvisado; pose/peso claramente diferentes de Cool Kid.
- **Sigma:** capuz escuro angular, postura compacta e boné como projétil; não confundir com um cavaleiro de outro jogo.
- **Inimigos:** NPC cinza distraído, Hater coral dentado, Big Hater muito mais largo com coroa; antagonistas reconhecíveis por forma.
- **Mapas:** rua/bairro solarengo, fachadas coloridas, toldos, graffiti e vida periférica; piso de combate claro com espaços reais de circulação. Ruin Alley, Crown Chamber e Toxic Rooftop partilham o traço, não o mesmo layout.
- **Menus:** placas ilustradas, contorno forte e seleção amarela legível, sem UI genérica de dashboard.
- **Lettering:** logo comic de letras compactas, com contorno escuro e acentos azul/amarelo; texto funcional separado e legível.

### Sequência de produção e prova de fidelidade

1. Fixar modelo de personagem e paleta a partir da opção A; gerar/desenhar assets isolados com transparência e escala consistente.
2. Produzir primeiro um mapa completo e os três personagens de referência, com inimigos representativos, menu e HUD; usar o mapa efetivo, não uma ilustração de fundo com obstáculos falsos.
3. Integrar uma cena jogável e comparar enquadramento, tamanhos, contornos, expressão e contraste com A. Corrigir diferenças antes de multiplicar conteúdo.
4. Trabalhar animações em passes: primeiro poses coerentes de idle/move/attack/hurt/Flex, depois ciclos completos. Um passe inicial não reduz automaticamente os critérios de acabamento já definidos no anexo.
5. Expandir aos nove personagens e restantes mapas apenas mantendo consistência. Verificar animações, sombras, transparência, colisões e efeitos em movimento.
6. Concluir testes funcionais e visuais, corrigir falhas e só então declarar a versão pronta para o criador testar.

A dificuldade de animação não justifica alterar a identidade dos personagens. Favorecer movimentos simples, expressivos e consistentes, mantendo os limites de produção transparentes. O resultado só será declarado fiel quando existir evidência no jogo; esta revisão regista a escolha e os critérios, não a implementação.

**Revisão V1.4:** opção A aprovada integralmente; B/C e mistura A+C não selecionadas; contrato de fidelidade e sequência de produção definidos.


## A.14 Assets produzidos — opção A, lote inicial V1

**Estado: primeiro lote de arte estática produzido e aprovado visualmente pelo criador em 14 outubro 2026; ainda não integrado no jogo.** Esta entrega concretiza a referência A em 10 imagens individuais. Não representa o catálogo completo de assets nem uma versão jogável validada.

Pasta de trabalho: `public/assets/cartoon/option-a-v1/`.

Inclui 3 protagonistas (Cool Kid, Alpha, Sigma), 2 inimigos e 1 boss (Phone Guy, Hater, Big Hater), 3 mapas (Ruin Alley, Crown Court, Toxic Garden) e 1 composição de menu.

Os PNG dos atores têm canal alpha. Os mapas são imagens de cenário completas, sem colisões nem camadas de oclusão. O menu é uma composição raster com texto incorporado; não contém botões interativos nem uma fonte de lettering reutilizável.

Não estão integrados no jogo. Não são spritesheets animadas. Faltam os restantes personagens, inimigos, armas, ícones, efeitos e estados de UI do GDD completo. Antes de integração: normalizar escala/pivot e margens, separar arma/projétil quando necessário (o boné de Sigma ainda faz parte da pose), produzir animações e validar legibilidade no jogo. Não usar o alpha como hitbox. O cenário tem perspetiva ilustrada; ajustar colisões à área de chão visível.

Validação realizada: abertura e integridade dos 10 PNG; dimensões e hashes no manifest; transparência dos 6 atores; inspeção visual dos resultados. Testes de gameplay não executados porque esta entrega não altera o código nem carrega estes assets no runtime.

Gerado pela ferramenta integrada de imagens, a partir da opção A aprovada. Prompts finais em prompts.json. Abrir index.html para ver a galeria local.


### Galeria dos ficheiros produzidos

#### Cool Kid

Ficheiro: `public/assets/cartoon/option-a-v1/characters/cool-kid.png`

![Cool Kid](../public/assets/cartoon/option-a-v1/characters/cool-kid.png)

#### Alpha

Ficheiro: `public/assets/cartoon/option-a-v1/characters/alpha.png`

![Alpha](../public/assets/cartoon/option-a-v1/characters/alpha.png)

#### Sigma

Ficheiro: `public/assets/cartoon/option-a-v1/characters/sigma.png`

![Sigma](../public/assets/cartoon/option-a-v1/characters/sigma.png)

#### Phone Guy

Ficheiro: `public/assets/cartoon/option-a-v1/enemies/phone-guy.png`

![Phone Guy](../public/assets/cartoon/option-a-v1/enemies/phone-guy.png)

#### Hater

Ficheiro: `public/assets/cartoon/option-a-v1/enemies/hater.png`

![Hater](../public/assets/cartoon/option-a-v1/enemies/hater.png)

#### Big Hater

Ficheiro: `public/assets/cartoon/option-a-v1/enemies/big-hater.png`

![Big Hater](../public/assets/cartoon/option-a-v1/enemies/big-hater.png)

#### Ruin Alley

Ficheiro: `public/assets/cartoon/option-a-v1/maps/ruin-alley.png`

![Ruin Alley](../public/assets/cartoon/option-a-v1/maps/ruin-alley.png)

#### Crown Court

Ficheiro: `public/assets/cartoon/option-a-v1/maps/crown-court.png`

![Crown Court](../public/assets/cartoon/option-a-v1/maps/crown-court.png)

#### Toxic Garden

Ficheiro: `public/assets/cartoon/option-a-v1/maps/toxic-garden.png`

![Toxic Garden](../public/assets/cartoon/option-a-v1/maps/toxic-garden.png)

#### Menu principal

Ficheiro: `public/assets/cartoon/option-a-v1/ui/main-menu.png`

![Menu principal](../public/assets/cartoon/option-a-v1/ui/main-menu.png)


### A.14.1 Inventário técnico do lote aprovado

| Ficheiro relativo à pasta do lote | Dimensões | Formato | Uso atual |
|---|---|---|---|
| `characters/cool-kid.png` | 1374×1145 | RGBA, alpha | Arte estática aprovada |
| `characters/alpha.png` | 1374×1145 | RGBA, alpha | Arte estática aprovada |
| `characters/sigma.png` | 1374×1145 | RGBA, alpha | Arte estática aprovada |
| `enemies/phone-guy.png` | 1289×1220 | RGBA, alpha | Arte estática aprovada |
| `enemies/hater.png` | 1374×1145 | RGBA, alpha | Arte estática aprovada |
| `enemies/big-hater.png` | 1374×1145 | RGBA, alpha | Arte estática aprovada |
| `maps/ruin-alley.png` | 1448×1086 | RGB | Arte estática aprovada |
| `maps/crown-court.png` | 1448×1086 | RGB | Arte estática aprovada |
| `maps/toxic-garden.png` | 1448×1086 | RGB | Arte estática aprovada |
| `ui/main-menu.png` | 1672×941 | RGB | Arte estática aprovada |


# Anexo B — Plano de refactor e contrato de execução

## B.1 Objetivo e limites

Transformar a implementação existente numa base coerente com as regras e a arte aprovadas, começando por uma run solo completa no Ruin Alley. Reutilizar sistemas comprovados; substituir regras duplicadas e apresentação legada onde necessário. Preservar IDs, desbloqueios e saves compatíveis. Não aproveitar esta tarefa para alterar monetização, adicionar serviços pagos ou lançar o jogo.

## B.2 Ordem de execução e dependências

| Marco | Trabalho | Dependências | Evidência para concluir |
|---|---|---|---|
| R0 — Auditoria | Revalidar main e PRs em curso; mapear regras atuais vs. GDD; executar baseline; identificar IDs/saves; registar revisão de origem | Acesso ao repositório atual | Matriz de diferenças e falhas preexistentes; ordem de PRs definida sem perder trabalho em curso |
| R1 — Núcleo de regras | Catálogo tipado, relógio de simulação, XP, aura/Flex, caps, slots, compatibilidade, ofertas e timers numa fonte única | R0 | Testes das fronteiras e invariantes; nenhum epic acima de nível2; nenhum slot extra |
| R2 — Combate e run | Implementar nove armas, Flex de Sigma/Cool Kid/Alpha, passivas disponíveis, waves/eventos, boss/berserk, vitória/derrota/reinício | R1 | Run solo completa; lendária funcional; Flexes diferentes; boss ainda derrotável após berserk |
| R3 — Arte e HUD | Integrar opção A no Ruin Alley e três protagonistas, inimigos da fatia e interface; completar os assets necessários à run | Auditoria visual de R0; integrar sobre R2 | Capturas reais e vídeo; cartas legíveis; animações sincronizadas; assets ausentes declarados, sem fallback legado silencioso |
| R4 — Conteúdo PvE completo | Restantes seis personagens, 28 passivas completas, restantes inimigos/eventos e mapas; desbloqueios versionados | R2 e R3 | Catálogos completos e migração comprovada; balanço solo e suporte observado |
| R5 — Discord Activity | Adaptador Discord sobre o mesmo jogo web; testar arranque, recursos, input e limites do embed | Fatia web validada | Jogar em browser independente e Discord; nenhuma dependência de login Discord no browser |
| R6 — Co-op | Autoridade de rede, lobby até5, XP partilhada, pausas, revives, reconexão e escalas; Normal antes de Ranked | Base PvE estável; decisões de rede/matchmaking/recompensas fechadas | Testes solo/duo/cinco, desconexões e resultado sem duplicação de XP/recompensas |
| R7 — Arena e progressão externa | Presets determinísticos, regras PvP finais, 1v1/2v2/3v3; ranked/passe/economia em entregas próprias | Decisões específicas da secção20 | Nenhum poder externo ou RNG no PvP; progressão separada e auditável |

R3 pode ter preparação de assets em paralelo com R1/R2, mas a aprovação de integração exige o jogo real. R5 não precisa de esperar por todo o conteúdo de R4 se a mesma fatia validada for disponibilizada nos dois acessos. Nenhum destes marcos autoriza anúncios, publicidade ou publicação automática em produção.

## B.3 Organização técnica pretendida

Manter TypeScript e separar simulação de Phaser. Catálogos fornecem dados de personagens, armas, passivas, inimigos e waves; UI lê os mesmos caps, descrições e cadências usados pela simulação. Inputs geram comandos; a simulação emite eventos; render e áudio representam esses eventos. Efeitos visuais não decidem dano nem consomem RNG de gameplay.

Relógio único pausável para XP, ataques, passivas, waves e boss. Tratar duração de run e tempo de ligação/reconexão como relógios distintos. PvE usa RNG controlável por seed para reprodução de bugs; PvP não recebe aleatoriedade de combate. Modelo de save versionado preserva desbloqueios, migra IDs quando necessário e não inventa poder permanente.

Adaptador browser e adaptador Discord partilham núcleo e conteúdo. Multiplayer requer autoridade de servidor e contrato de comandos/estados antes de implementação; esta frase não escolhe fornecedor nem autoriza custos. Estrutura física de módulos será definida após R0, evitando impor nomes de ficheiros antes de inspecionar o código atual.

## B.4 Preparação e integração dos assets

Pasta fonte do primeiro lote: `public/assets/cartoon/option-a-v1/`. Preservar os masters e `manifest.json`, que contém dimensões e hashes. `prompts.json` regista os prompts finais de geração. `index.html` permite rever a galeria local. Não confundir este índice com um ecrã jogável.

Os seis atores são poses únicas, não ciclos de animação. Separar arma/projétil do corpo quando necessário; o boné de Sigma está incorporado na pose atual. Normalizar escala, pivot dos pés, margens e alpha; não usar contorno do PNG como hitbox. Produzir os estados e direções definidos em A.5 e verificar que mantém os rostos e proporções aprovados.

Os três mapas são imagens completas, ainda sem tiles, colisões, navegação ou camadas de oclusão. Construir os obstáculos sobre o chão visível, separar o primeiro plano onde ocultaria atores e distinguir decoração de perigo funcional. Validar leitura dos projéteis em movimento; não inferir dano apenas pela cor verde dos canais.

O menu atual é uma composição raster com lettering e texto incorporados. Reconstruir botões, estados de hover/focus/pressed, texto acessível e layout adaptável a partir da referência. O logo desenhado não constitui uma fonte tipográfica; escolher uma fonte de UI com licença compatível e manter lettering específico nos títulos. Não usar uma imagem inteira como substituto de interface acessível.

Assets em falta: seis heróis adicionais; animações de todos os atores; famílias inimigas e quatro eventos de boss ainda não produzidos no estilo novo; armas/projéteis separados; nove ícones de armas, 28 ícones de passivas, efeitos de Flex/ataque/berserk, HUD e estados de menus. Produzir o necessário à primeira run antes de a declarar visualmente concluída; não chamar ao lote atual catálogo completo.

## B.5 Critérios de conclusão por entrega

Cada PR identifica regras do GDD afetadas, comportamento anterior/novo, migração, comandos executados, resultados, limitações e passos de teste manual. Respeitar as instruções do repositório, a ordem do trabalho em curso e a aprovação do proprietário para merge. Não integrar automaticamente PRs só porque são mencionados neste documento.

Para alterações de implementação, cumprir os gates previstos pelo repositório: instalação reprodutível, typecheck, testes, build e browser quando aplicável. Registar o commit testado. Se falharem, corrigir a causa e revalidar antes de dizer “pronto para testar”; se houver bloqueio real, reportar explicitamente os testes pendentes/falhados. Não apresentar testes de ficheiros PNG como testes do jogo.

Aceitação funcional inclui: três armas e cinco passivas; caps por raridade; Flex próprio; relógios corretos; lendária apenas na janela permitida; nenhuma modal sobre outra; run completa com vitória/derrota/reinício; persistência sem perda de desbloqueios. Aceitação visual inclui: opção A reconhecível em runtime, ausência de halos/recortes, escala consistente, personagens e avisos legíveis, mapas com colisões coerentes e interface nos viewports da secção16.

## B.6 Decisões que não bloqueiam o início do refactor

Continuam por fechar antes das fases respetivas: fórmulas finais de matchmaking e recompensas Normal/Ranked; arquitetura/fornecedor de rede dentro do orçamento; presets, duração e condições de vitória da arena; economia e battle pass; equipamento pré-run; plataformas dedicadas e cross-save. Desbloqueios propostos na secção7.1 precisam de validação de ritmo. Wild é apenas nice to have.

O R0 e a fatia solo podem avançar com as decisões já aprovadas. Esta compilação não declara que o refactor começou ou que funcionalidades já passaram os testes.

## C. Revisão mobile e mecânicas de drops — pedidos de 16 outubro 2026

**Status and precedence (22 October 2026):** Mobile usability requirements remain approved. P1–P3 are approved for faithful Phaser parity under the decision below. P4–P7 are subsequently **concept-approved for controlled prototypes only** under §24, with their numerical rules, new art and production rollout still requiring separate acceptance. P8 remains an unapproved proposal. This annex does not override the three-weapon/five-passive limits, single Aura or hero-specific Flex.

### C.1 Correções de UX mobile (requisitos)

**Owner-approved mobile joystick revision — 23 October 2026 (Godot Web, Android and iOS):** This decision **supersedes the earlier left-side-only joystick activation rule** in this annex and any earlier test or implementation treating the left 48% of the viewport as the only valid movement area. The joystick is a floating movement control that may be activated **anywhere on unobstructed, visible gameplay terrain** while the run is actively playing. This does not enable movement input on interactive UI or create a separate right-handed control mode. Existing desktop keyboard and mouse behavior, simulation rules, hero speed, hitboxes, camera behavior and combat balance remain unchanged.

1. **Floating, full-playfield joystick:** An eligible touch-down on **any free part of the rendered playfield**, including its left, center and right, creates the joystick at that finger's initial contact (adjusted only as necessary to keep the enlarged visual within the usable viewport and safe-area margins). No fixed left-half, 48%-width, or arbitrary top/bottom gameplay band may restrict activation; exclusions must follow **actual interactive screen-space controls and obscured/non-playable regions**, not a nominal screen percentage. Button/menu hit areas take precedence: touches on Flex, Pause, contextual actions, cards, confirm/replacement choices, scrolling regions, dialogs, settings, results, or other active interactive elements must **never** activate movement or trigger a simultaneous movement-and-button action. Passive/transparent HUD decoration must not unnecessarily block otherwise playable terrain. Only the **first eligible finger** owns the movement axis until release/cancel; additional fingers may use interactive actions independently but cannot steal or redirect movement, and a touch beginning on a UI control must not turn into a joystick during a drag. Preserve pointer capture, prevent accidental page scroll and stuck movement, and clear movement/visuals immediately on owner release, pointercancel, focus loss, pause, mode change, run end or orientation/viewport invalidation. The joystick is hidden outside active gameplay and when no movement finger is held. Its center remains floating rather than fixed to a corner.

   **Larger control — approved first-pass size target:** Increase the visible joystick by approximately **40%** from the current Godot reference: outer ring radius **57 → approximately 80 reference canvas units**, inner thumb radius **25 → approximately 35**, and thumb travel/directional saturation distance **85 → approximately 119**, with the rendered thumb offset enlarged proportionally. Apply responsive sizing/clamping for constrained viewports and safe areas without reintroducing a left-only region or covering clickable controls. These are starting UI/input geometry targets subject to real mobile ergonomics validation, **not** a player movement-speed or balance change; maintain a normalized movement axis and the existing movement speed.
2. **Orientação:** em dispositivos móveis privilegiar paisagem (horizontal); solicitar fullscreen e orientation lock na primeira interação elegível. A plataforma pode recusar ambas as APIs, sobretudo no iOS; apresentar indicação não bloqueante para rodar o dispositivo e modo fallback funcional. Não prometer rotação automática garantida. Retrato permitido quando o viewport efetivo tem espaço suficiente para jogo, HUD e ações, aferido por dimensões úteis e testes, não apenas user agent.
3. **Legibilidade dos pickups:** cristais de Aura distinguíveis do pavimento e de projéteis por silhueta, contorno, brilho controlado, escala e movimento de atração. A indicação de Aura ganha deve ser breve e legível. Identidade visual separada para XP, Aura e futuros drops especiais; validar contraste sobre o mapa Ruin Alley e em movimento.
4. **Armas/habilidades:** diferenciação clara de projéteis, impactos, zonas perigosas e efeitos de Flex; comunicar origem, direção e duração dos ataques, sem efeitos que escondam inimigos. Redução de movimento e limites de partículas em mobile.
5. **HUD e modais:** não cortar título de evolução, cartas ou botão confirmar; respeitar safe areas, scroll dentro da modal, tamanhos mínimos de toque e layout em paisagem; reservar prioridade de input para botões e regiões interativas sobre o joystick de terreno inteiro, incluindo Flex e Pause, mesmo quando estão no lado direito ou próximo do centro do ecrã; evitar que o joystick aumentado tape ações ou avisos importantes; não perder a seleção ao mudar de orientação. O joystick não aceita novos toques em qualquer menu/modal nem continua a mover o herói ao abrir uma modal. Testar ecrãs de evolução, pausa, resultados e partida completa.
6. **Aceitação:** testes em browser mobile real quando disponível e emulação de múltiplos viewports; confirmar ativação em **zonas livres à esquerda, ao centro e à direita**, sem a antiga limitação dos 48%; verificar dimensões reais, área útil e conforto do joystick aproximadamente 40% maior em landscape e portrait/fallback; confirmar que um toque em Flex, Pause, cartas, scroll ou qualquer botão **não inicia o joystick**, que um segundo dedo pode premir Flex enquanto o primeiro mantém movimento sem o redirecionar, e que toques destinados ao UI nunca se transformam em movimento ao arrastar. Verificar libertação/cancelamento, pointer ownership, blur/pause/modal/restart, rotação, resize e safe areas sem stuck movement; teclado desktop intacto, orientation lock permitido e negado, fullscreen permitido e negado. Na implementação Godot, executar testes GDScript/CI e validação Web/touch reais; testes TypeScript/Vitest/Playwright históricos continuam aplicáveis à referência Phaser sem autorizar alterações naquele repositório. A aceitação em Web mobile, Android físico e iOS físico deve ser evidenciada separadamente conforme §23.

### C.2 Referência Swarm — drops e estrutura de recuperação

Referência de design: League of Legends *Swarm* tem objetos destrutíveis com drops de cura, recolha em massa de XP/recursos (vacuum) e explosões; a zona de cura de Warehouse District exige ativação e entra em recarga prolongada. Estes são **padrões de mecânica**, não autorização para copiar nomes, arte, mapas, efeitos ou valores exatos. Fontes de referência: https://leagueoflegends.fandom.com/wiki/Swarm_%28League_of_Legends%29 e https://mobalytics.gg/lol/guides/swarm-how-to-survive .

**Owner-approved Godot solo parity decision — 22 October 2026:** P1, P2 and P3 are **approved for Phaser parity**. The existing canonical Phaser solo implementation is the behavioral reference for all details not explicitly specified below. This approval applies only to the Godot solo scope and does not authorize new mechanics, artwork or balance changes.

- **P1 — Street Snack (approved):** Spawn probability is **5%** for eligible normal enemy kills and **20%** for eligible elite kills. Pickup radius is **56 world units**. Restores **18% of maximum HP**, capped at maximum HP. Preserve Phaser seeded drop generation and special-drop limits.
- **P2 — Aura Magnet (approved):** Spawn probability is **2%** for eligible normal enemy kills and **8%** for eligible elite kills. Pickup radius is **72 world units**. Collects **all currently available XP crystals**, without generating additional XP or duplicating rewards. Preserve original Phaser behavior and collection feedback. The name does not authorize additional Aura generation or collection effects beyond Phaser parity.
- **P3 — Safe Spot (approved):** Fixed at **(1100, 565)** in **Ruin Alley**, with **68 world-unit** activation radius. Requires **two continuous seconds** inside the zone while below maximum HP. Restores **25% of maximum HP**. Cooldown is **90 seconds of active gameplay**. Charge resets when the player leaves the zone or activation conditions cease to be met. Restore original world-space visuals and charge/cooldown feedback from Phaser.
- **P4 — Destructible street crates (prototype concept approved; not production-approved):** Trial a small number of readable destructible reward objects on legal Ruin Alley positions. Reuse existing approved XP/Snack/Magnet reward types; define spawn budgets, artwork, drop odds and fairness separately. The two existing static collision obstacles **remain unchanged and indestructible**.
- **P5 — Viral Burst (prototype concept approved; not production-approved):** Experiment with a rare, visually distinct common-enemy crowd-clear or knockback pickup. No instant boss/elite deletion, XP duplication or unbounded effects. Final rarity, AoE, damage, drops and visual assets are undecided.
- **P6 — Trend Challenges (prototype concept approved; not production-approved):** Experiment with brief, optional combat/map objectives and rewards drawn from already approved progression. They must not pause the main wave clock, become compulsory for victory or interrupt fixed boss/event timing. Scheduling, rewards and tuning are undecided.
- **P7 — Meme Combos / conditional weapon evolutions (prototype concept approved; not production-approved):** Trial a small number of readable weapon-plus-passive synergies without adding weapon/passive slots, extra legendary choices, new rarity tiers or recursive procs. Existing GDD weapon/passive effects stay authoritative until a specific synergy is approved.
- **P8 — Map-exclusive events (not approved):** Remains a future proposal, not authorized for implementation.

**Scope and compatibility contract:** Preserve the approved solo scope, equipment slots, rarity rules, Aura, Flex and save compatibility. Do not alter Phaser. P1–P3 retain exact Phaser parity contracts. Later concept approval in §24 authorizes **isolated, explicitly experimental prototypes of P4–P7**, but does **not** authorize shipping new rules, tuning values, art or player-facing default changes. Experimental content must be disabled in the normal production ruleset until separately accepted.

**Implementation order:** P1–P3 are approved parity features. §24 approves P4–P7 as directions for isolated prototypes only; detailed specifications and normal-build activation require follow-up acceptance. P8 still requires separate concept approval. Neither documentation approval nor a green prototype test constitutes gameplay balance or visual acceptance.
