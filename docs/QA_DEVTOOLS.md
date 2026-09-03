# Onda · QA no Firefox DevTools

> **Guia operacional de engenharia.** Padroniza como a equipe usa o Firefox DevTools
> para *verificar* (não prometer) acessibilidade, performance e responsividade —
> principalmente na **Fase 2b (Layout)** e na **Fase 5 (Homologação)**.
>
> **Belo no design. Fluido no uso. Sólido na segurança.** · **v1.0 · Setembro/2026**
> Fonte: <https://firefox-source-docs.mozilla.org/devtools-user/>

---

## 1. Setup único por máquina — Settings do DevTools

Abra qualquer página, `F12` para abrir o DevTools, depois `F1` para as configurações.
Marque uma vez; o Firefox mantém o estado.

| Seção | Ajuste | Estado | Por quê |
|---|---|---|---|
| Advanced | Disable HTTP Cache (when toolbox is open) | ✔ | Todo teste mede o *first-load* real. Vale só com o DevTools aberto. |
| Advanced | Enable Service Workers over HTTP | ✔ | Testar PWA/offline em `localhost` e URLs de preview sem HTTPS. |
| Advanced | Enable remote debugging | ✔ | Pré-requisito do `about:debugging` (seção 5). |
| Common Preferences | Enable Persistent Logs | ✔ | Não perder logs de redirect/login em fluxos de auth (perfis Sistema e SaaS). |
| Debugger | Enable Source Maps | ✔ | Stack traces e breakpoints legíveis em bundles minificados. |
| Style Editor | Show original sources | ✔ | Debugar Sass/PostCSS, não o CSS gerado. |
| Inspector | Default color unit → `HSL(A)` ou *as authored* | — | Bater com os `--tokens` do `./design/tokens.css`. |
| Editor Preferences | Indent using spaces ✔ · Tab size `2` · Autoclose brackets ✔ | — | Edições rápidas no painel saem já no code style do projeto. |

> Atalhos globais de painel **não** são configuráveis. Só o keybinding do editor de
> código interno (Vim/Emacs/Sublime/default) — preferência individual, não padronizar.

---

## 2. Acessibilidade AA — Fases 2b e 5

Regra de ouro do `onda-layout`: **Acessibilidade AA**. Esta é a verificação objetiva.

**Onde:** menu `···` do DevTools → **Accessibility**, ou `Ctrl+Shift+I` e escolher a aba.
O engine fica ligado até fechar o toolbox (consome memória — abra só para auditar).

**Rodar as 3 checagens do dropdown "Check for issues" e não deixar nenhum item:**

- [ ] **Contrast** — nenhum texto abaixo do limiar WCAG AA (4.5:1 normal · 3:1 grande).
- [ ] **Keyboard** — nenhum controle inacessível por teclado; foco visível; sem *tab trap*.
- [ ] **Text Labels** — todo `input`, `button`, `img` e ícone-link tem nome acessível.

**Apoio visual:**

- **Show Tabbing Order** — numera a ordem de tabulação sobre a página; conferir se segue a
  leitura visual.
- **Simular deficiência de visão de cor** (protanopia, deuteranopia, etc.) — a informação
  não pode depender só de cor.
- Hover na árvore de acessibilidade mostra `role` + `name` + razão de contraste de cada nó.

> Ferramenta automatiza ~40% do WCAG. Teste também com teclado de verdade (`Tab`/`Shift+Tab`/
> `Enter`/`Esc`) e, quando o projeto for crítico, com leitor de tela (NVDA/VoiceOver).

---

## 3. Performance / Core Web Vitals — Fase 5

Obrigatório nos perfis **LP** e **e-commerce**; recomendado nos demais.

### 3.1 · Perfil de execução (Firefox Profiler)

`Shift+F5` abre o Profiler. Grava um perfil, dá para aplicar **CPU throttling** e **network
throttling**, e mostra call tree, flame graph e waterfall de markers.
**Exportar/compartilhar o perfil por URL** (`profiler.firefox.com`) e anexar no PR/ticket
quando houver regressão ou *long task* > 50 ms.

### 3.2 · Análise de rede (Network Monitor → ícone de cronômetro)

Roda a página **com cache vazio** e **com cache populado** (1ª visita vs. recorrente),
agrupa recursos por tipo com tamanho e tempo, e mostra pizza por tipo.
Usar para fixar **orçamento de peso** por tipo de asset. Exportar **HAR** da lista de
requisições para anexar em bug de integração.

### 3.3 · Presets de throttling (Network Monitor e Responsive Design Mode)

| Preset | Download | Upload | Latência |
|---|---|---|---|
| Offline | 0 | 0 | 5 ms |
| GPRS | 50 Kbps | 20 Kbps | 500 ms |
| Regular 2G | 250 Kbps | 50 Kbps | 300 ms |
| Good 2G | 450 Kbps | 150 Kbps | 150 ms |
| Regular 3G | 750 Kbps | 250 Kbps | 100 ms |
| **Good 3G** | **1.5 Mbps** | **750 Kbps** | **40 ms** |
| **Regular 4G/LTE** | **4 Mbps** | **3 Mbps** | **20 ms** |
| DSL | 2 Mbps | 1 Mbps | 5 ms |
| Wi-Fi | 30 Mbps | 15 Mbps | 2 ms |

- [ ] Toda LP/loja abre e fica utilizável em **Good 3G** com cache desabilitado.
- [ ] Sem regressão perceptível em **Regular 4G/LTE**.

> É aproximação, não benchmark. Número oficial para o cliente: Lighthouse ou WebPageTest.

---

## 4. Responsive Design Mode — QA cross-device

`Ctrl+Shift+M` (`Cmd+Opt+M` no macOS).

- **Editar a lista de devices** / **Add Custom Device** (nome, dimensões, `devicePixelRatio`,
  User Agent, touch) → manter uma lista fixa de **devices oficiais de QA**:

  | Classe | Device | Viewport | DPR |
  |---|---|---|---|
  | Mobile pequeno | iPhone SE | 375 × 667 | 2 |
  | Mobile atual | iPhone 15 / Pixel 7 | 393 × 852 | 3 |
  | Tablet | iPad | 768 × 1024 | 2 |
  | Notebook | — | 1366 × 768 | 1 |
  | Desktop | — | 1920 × 1080 | 1 |

- Ligar **Reload when touch simulation is toggled** e **Reload when user agent is changed**
  para o teste ser fiel.
- **Touch simulation** (converte mouse em eventos touch), **troca de User Agent** (altera
  header HTTP + `navigator.userAgent`), **orientação** e **screenshot** do viewport.

- [ ] Layout íntegro nas 5 classes acima, retrato e paisagem.
- [ ] Sem scroll horizontal indevido; áreas de toque ≥ 44 px.

---

## 5. Remote debugging em Android real — `about:debugging`

Cobre **web mobile, PWA e conteúdo em WebView** no Firefox for Android.
**Não** debuga React Native/Flutter nativo (esses usam Flutter DevTools / Hermes+CDP) — para
esses, o valor do Firefox é a camada web e o Responsive Design Mode.

**Setup (site rodando num Android via USB):**

1. Celular: tocar **Build Number** 7× → **Opções do desenvolvedor** → ligar **Depuração USB**.
2. Firefox Android: **Settings → Remote debugging via USB**.
3. Desktop: `adb` instalado no PATH.
4. `about:debugging` → **Enable USB Devices** → **Connect** no aparelho → aba → **Inspect**.

**Sem fio (Android 11+):** *Wireless debugging* no celular → `adb pair <ip>:<port>` com o
código → `adb connect <ip>:<port>` → o aparelho aparece em `about:debugging`.

No mesmo painel: **service workers** (start / unregister / **push de teste**), **Load
Temporary Add-on** (extensão sem assinatura), shared/dedicated workers.

> Firefox for Android baseado na v68 não conversa com desktop ≥ 69. Usar versões atuais dos
> dois lados.

---

## 6. Application panel — PWA / offline / push

Relevante no **perfil App** (épicos de push e de sincronização offline/online).

- **Service Workers** — estado do ciclo de vida (registering/running/stopped), **unregister**
  forçado, **enviar push de teste** sem backend.
- **Manifest** — valida ícones, identidade, apresentação e **erros de instalabilidade** antes
  do deploy.

- [ ] Manifest sem erro; ícones 192 e 512; app instala.
- [ ] Service worker serve a *app shell* com a rede em **Offline**.

---

## 7. Network Monitor — validar contratos de API

Casa com os **contratos Request/Response** do `ROADMAP.md` (Fase 3) e o TDD da Fase 4.

- **Persistent Logs** ligado para sobreviver a navegações e redirects.
- **Filtrar** por método / tipo / status; coluna de *cause* para achar origem da chamada.
- **Block request** — simular endpoint fora do ar / degradação e conferir os estados de erro
  do layout.
- **Edit and Resend** — repetir uma requisição mudando header ou body (testar auth e
  validação sem sair do navegador).
- **Copy → cURL / HAR** para reproduzir num bug report.
- WebSocket e Server-Sent Events inspecionáveis na aba própria.

---

## 8. Atalhos essenciais

| Ação | Win/Linux | macOS |
|---|---|---|
| Toolbox | `Ctrl+Shift+I` | `Cmd+Opt+I` |
| Console | `Ctrl+Shift+K` | `Cmd+Opt+K` |
| Inspector / picker | `Ctrl+Shift+C` | `Cmd+Opt+C` |
| Debugger | `Ctrl+Shift+Z` | `Cmd+Opt+Z` |
| Network | `Ctrl+Shift+E` | `Cmd+Opt+E` |
| Style Editor | `Shift+F7` | `Shift+F7` |
| Profiler | `Shift+F5` | `Shift+F5` |
| Storage | `Shift+F9` | `Shift+F9` |
| Responsive Design Mode | `Ctrl+Shift+M` | `Cmd+Opt+M` |
| Debugger: resume / step over / in / out | `F8` / `F10` / `F11` / `Shift+F11` | idem |
| Console multilinha | `Shift+Enter` | `Shift+Return` |
| Buscar em arquivos (Debugger) | `Ctrl+Shift+F` | `Cmd+Opt+F` |

Outras ferramentas úteis: **Storage Inspector** (cookies/localStorage/IndexedDB — debug de
sessão e JWT), **Eyedropper** + **Style Editor** (conferir cor contra `tokens.css`), **Measure
Tool** / **Rulers**, **screenshot de nó** específico, **JavaScript Tracer** (log de todas as
chamadas de função).

---

## 9. Checklist de homologação — colar no PR da Fase 5

```markdown
### QA DevTools (Firefox)
- [ ] Acessibilidade: Check for issues — Contrast, Keyboard, Text Labels: zero itens
- [ ] Tabbing order segue a leitura visual; foco sempre visível
- [ ] Navegação completa só por teclado (Tab / Enter / Esc)
- [ ] Responsivo nas 5 classes de device (retrato + paisagem), sem scroll horizontal
- [ ] Good 3G + cache off: página utilizável; sem long task > 50 ms no Profiler
- [ ] Análise de rede (cache vazio): peso dentro do orçamento por tipo de asset
- [ ] Estados de erro/vazio conferidos com Block Request no Network Monitor
- [ ] [perfil App] Manifest sem erro; app instala; app shell abre em Offline
- [ ] Console limpo: zero erro e zero warning não justificado
```
