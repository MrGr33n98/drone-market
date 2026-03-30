# Guia de Estilo: A Identidade Visual da Inteligência Aérea

Este documento define as diretrizes fundamentais para a interface da nossa plataforma de dados de drones. O objetivo não é apenas fornecer componentes, mas estabelecer um padrão de excelência visual que transmita precisão técnica, autoridade editorial e uma experiência de usuário fluida e premium.

---

## 1. Estrela do Norte Criativa: "O Observador Analítico"

Nossa direção criativa é definida pelo conceito do **Observador Analítico**. Imagine a clareza de uma visão aérea em um dia de céu limpo: ampla, nítida e organizada. 

Para quebrar o visual de "template genérico", este sistema de design utiliza **assimetria intencional**, grandes espaços negativos e uma hierarquia tipográfica que remete a publicações editoriais de alto padrão. Evitamos grades rígidas e repetitivas em favor de composições que "respiram", onde a profundidade é sugerida por camadas de tons, não por linhas de contorno.

---

## 2. Cores e Texturas

O uso da cor aqui é cirúrgico. A paleta foi desenhada para reduzir o cansaço visual em análises de dados prolongadas, mantendo pontos de foco vibrantes para ações essenciais.

### A Regra "No-Line" (Sem Bordas)
**É estritamente proibido o uso de bordas sólidas de 1px para separar seções.** A delimitação de áreas deve ser feita exclusivamente através de:
1.  **Mudança de tom de fundo:** Um card em `surface_container_lowest` (#ffffff) repousando sobre um fundo `surface` (#f7f9fb).
2.  **Espaçamento Negativo:** Use a escala de `20` (5rem) ou `24` (6rem) para separar grandes blocos de conteúdo.

### Hierarquia de Superfícies e Camadas
Trate a interface como folhas de papel premium sobrepostas.
- **Base:** `surface` (#f7f9fb) para o fundo principal da aplicação.
- **Nível 1 (Containers):** `surface_container_low` (#f2f4f6) para áreas de conteúdo secundário.
- **Nível 2 (Destaque):** `surface_container_lowest` (#ffffff) para cards de dados e formulários principais.

### Glassmorphism & Gradientes de Assinatura
Para elementos flutuantes (como menus de ferramentas de mapa ou tooltips), utilize o efeito de vidro fosco:
- **Fundo:** `surface` com 80% de opacidade.
- **Efeito:** Backdrop-blur de 12px a 20px.
- **Ação Principal:** O token `primary` (#0058be) nunca deve ser totalmente plano em áreas grandes. Use um gradiente sutil de `primary` para `primary_container` (#2170e4) em um ângulo de 135° para adicionar "alma" e profundidade ao botão ou heros de destaque.

---

## 3. Tipografia Editorial

Utilizamos uma combinação de **Manrope** para displays e manchetes (personalidade moderna e técnica) e **Inter** para leitura funcional.

- **Display & Headlines (Manrope):** Devem ser usadas com generosidade. O `display-lg` (3.5rem) é sua ferramenta para criar impacto em dashboards de resumo.
- **Body & Labels (Inter):** Focadas em legibilidade absoluta. O `body-md` (0.875rem) é o padrão para dados densos.
- **Contraste de Tom:** Títulos em `on_surface` (#191c1e) garantem autoridade, enquanto labels em `on_secondary_container` (#5c647a) ajudam a organizar a hierarquia sem poluir o olhar.

---

## 4. Elevação, Profundidade e "Ghost Borders"

A tridimensionalidade neste sistema é atmosférica, não estrutural.

- **Layering Principle:** A profundidade nasce do empilhamento de tons. Um card `surface_container_highest` sobre um fundo `surface` cria uma elevação natural e sofisticada.
- **Sombras Ambiente:** Se precisar destacar um elemento flutuante, use sombras ultra-difusas: `blur: 40px`, `spread: -5px`, e opacidade entre 4% e 8%. A cor da sombra deve ser um matiz do `on_surface`, nunca um cinza neutro.
- **O Fallback "Ghost Border":** Se a acessibilidade exigir uma borda, use o token `outline_variant` com apenas **15% de opacidade**. Bordas 100% opacas são consideradas ruído visual.

---

## 5. Componentes Principais

### Botões (Buttons)
- **Primary:** Gradiente sutil entre `primary` e `primary_container`. Cantos com `DEFAULT` (8px).
- **Secondary:** Sem fundo, apenas texto em `primary` e um "Ghost Border" se necessário.
- **Estados:** O estado de hover deve aumentar a saturação do gradiente, não apenas escurecer a cor.

### Cards & Listas
- **Proibição de Divisores:** Nunca utilize linhas horizontais para separar itens de lista. Use o espaçamento `4` (1rem) e uma mudança sutil de cor de fundo (`surface_container_low`) no estado de hover para guiar o olhar.

### Campos de Entrada (Input Fields)
- Background em `surface_container_highest` para criar um "rebaixo" visual no formulário.
- Indicador de foco: Uma transição suave para `primary` no "Ghost Border" e um brilho (glow) externo de 2px com 10% de opacidade.

### Chips de Dados (Drones & Telemetria)
- Devem usar `secondary_container` (#dae2fd) com cantos `full` (9999px) para diferenciar metadados de ações de interface.

---

## 6. Do’s and Don’ts (O que fazer e o que não fazer)

### ✅ DO (Faça)
- Use **espaço em branco** como se fosse um elemento de design ativo. Se estiver em dúvida, aumente o padding.
- Alinhe elementos de texto de forma **assimétrica** em landing pages para criar um ritmo visual moderno.
- Utilize o token `tertiary` (#924700) apenas para alertas de sistema ou dados térmicos críticos, mantendo sua raridade visual.

### ❌ DON'T (Não faça)
- **Não use sombras pesadas.** Se o usuário "sentir" a sombra conscientemente, ela está forte demais.
- **Não use divisores de 1px.** Eles fragmentam a interface e reduzem a sensação de fluidez.
- **Não use cantos vivos (0px).** Todos os elementos devem respeitar a escala de arredondamento, preferencialmente `DEFAULT` (8px) para componentes e `lg` (16px) para grandes seções de container.

---

## Conclusão para Designers Juniores

Este sistema de design não é sobre seguir regras rígidas, mas sobre cultivar um **olhar intencional**. Cada pixel deve servir ao propósito de clareza e eficiência. Ao projetar, pergunte-se: "Eu posso separar estes elementos sem usar uma linha?". Se a resposta for sim, você está no caminho certo para criar uma experiência verdadeiramente premium.