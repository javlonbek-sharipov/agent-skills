# UI Prototype

Generate **several radically different UI variations** of one screen, inside the real app, switchable from a floating bar. The user flips between variants, picks one (or steals bits from each), then throws the rest away.

If the question is about logic/state rather than what something looks like or how it feels, this is the wrong branch. Use [LOGIC.md](LOGIC.md).

## When this is the right shape

- "What should this page look like?"
- "I want to see a few options for this dashboard before committing."
- "Try a different layout for the settings screen."
- "Does this swipe / transition / navigation feel right?" A variant may differ in interaction, not only in layout.
- Any time the user would otherwise spend a day picking between three vague mockups in their head.

## Where the variants live: four sub-shapes

A UI prototype is much easier to judge when it's **butting up against the rest of the app**: real header, real sidebar, real data, real density. A screen on its own is a **vacuum**: every variant looks fine in isolation. Default to sub-shape A whenever there's a plausible existing screen to host the variants.

The platform never picks the sub-shape. It only changes the mechanics (how the variant is carried, how a new screen is reached, what hides it from release), and [PLATFORMS.md](PLATFORMS.md) holds those for every runtime. Read it once the sub-shape is chosen.

### Sub-shape A: adjustment to an existing screen (default)

The screen already exists. Variants are rendered **on the same screen**, selected by the variant carrier. The existing data fetching, params, and auth all stay. Only the rendering swaps. Pick it unless there's a specific reason not to.

If the prototype is for something that doesn't yet have a screen but *would naturally live inside one* (a new section of the dashboard, a new card on the settings screen, a new step in an existing flow), it's still sub-shape A. Mount the variants inside the host screen.

When the question is the shell itself, navigation, sidebar or theme, the variant is the shell plus the two screens it is judged on: the home and the busiest list. Every other screen wears the shell with its current content.

A thin host screen hides design problems as surely as a vacuum does. Seed what the variants need through the project's own factories, in a seeder named as a prototype: enough rows to fill one screen and one of every state, no more. The seeder rides to the throwaway branch with the rest.

### Sub-shape B: a new screen (when there is no host)

Only use this when the thing being prototyped genuinely has no existing screen to live inside (an entirely new top-level surface, or a flow that can't be embedded anywhere sensible).

Create a **throwaway screen** following whatever routing convention the project already uses, named so it's obviously a prototype (the word `prototype` in the path or filename), reached through the entry point PLATFORMS.md gives for the app's class. Same carrier, same switcher.

Before committing to sub-shape B, sanity-check: is there really no existing screen this could be embedded in? An empty screen hides design problems that a populated one would expose.

### Sub-shape C: no app yet

When there is no codebase to host the variants, build a single self-contained HTML file with the same switcher: a browser-tab DOM prototype. Say in the run card that this is a vacuum: the variants are judged without real chrome, data or density, and the verdict is weaker for it. Move to sub-shape A as soon as a screen exists.

### Sub-shape D: preview canvas (opt-in)

SwiftUI `#Preview`, Compose `@Preview`, Storybook and Widgetbook render a component in isolation: fast, and a vacuum. A canvas hosts a prototype only when all four hold:

1. The project already develops components in previews or stories.
2. The thing being judged is one component, not a screen or a flow.
3. The question is about look, not feel: no gesture, transition or navigation to judge.
4. Judging it needs no real data or navigation.

Even then, reach for D when the project's convention is to develop components in previews, or the user asks for it; A stays the default. In a canvas, variants render side by side, one named preview per variant: no switcher, no carrier, and the run card's reach step names the file and preview to open. Name the preview file as a prototype like everything else. A screen, a flow or a feel question is judged in the running app, always.

## Process

### 1. Write the run card and pick N

Default to **3 variants**. More than 5 stops being radically different and starts being noise, so cap there.

Open the prototype with the run card from [SKILL.md](SKILL.md): the question, the launch, the reach step, the variant keys, and any assumption such as the sub-shape or the app chosen in a multi-app repo. One line of it is the plan:

> "Three variants of the settings screen, on the existing settings route, variant carried by `?variant=`."

### 2. Generate radically different variants

Draft each variant. Hold each one to:

- The screen's purpose and the data it has access to.
- The project's component library / styling system (TailwindCSS, shadcn, MUI, the app's design system or theme, plain CSS, whatever).
- A clear exported component name, e.g. `VariantA`, `VariantB`, `VariantC`.

Variants must be **structurally different**: different layout, different information hierarchy, different primary affordance, or a different interaction, not just different colours. Three slightly-tweaked card grids isn't a UI prototype, it's wallpaper. If two drafts come out too similar, redo one with explicit "do not use a card grid" guidance.

A variant is done when it renders with real data at one viewport in the OS's default colour scheme. Dark mode, other widths, wording and polish wait for the winner.

### 3. Wire them together

Create a single switcher on the screen. Pseudo-code; the carrier and the overlay come from the app's class in PLATFORMS.md:

```
variant = readVariant() ?? 'A'   // carrier: URL param, router param, launch override, or switcher memory
render(variants[variant], data)
render(PrototypeSwitcher, { keys: ['A', 'B', 'C'], current: variant, onChange: writeVariant })
```

For sub-shape A: keep all the existing data fetching above the switcher; only the rendered subtree changes per variant.

For sub-shape B: the throwaway screen mounts the same switcher.

### 4. Build the floating switcher

A small bar fixed at the bottom-centre of the screen, inside the safe area, with three pieces:

- **Left arrow**: cycles to the previous variant (wraps around).
- **Variant label**: shows the current variant key and, if the variant exports a name, that name too. e.g. `B (Sidebar layout)`.
- **Right arrow**: cycles forward (wraps around).

Behaviour:

- Tapping or clicking an arrow writes the variant through the carrier, so wherever the app has a URL or router param the choice is shareable and reload-stable.
- With a hardware keyboard, `←` and `→` also cycle. Leave the arrow keys alone when a text field or editable element is focused.
- The arrows are the only control. Variants may differ in interaction, so the bar claims no swipe, shake or long-press, and it stays clear of the variant's own touch targets.
- Visually distinct from the screen (e.g. high-contrast pill, subtle shadow) so it's obviously not part of the design being evaluated.
- Hidden in release builds: gate on the platform's debug flag from PLATFORMS.md, so a stray prototype merge can't ship the bar to users.

Put the switcher in a single shared component so every sub-shape can reuse it. Locate it wherever shared UI lives in the project.

### 5. Hand it over

Hand over as soon as all N render. The verdict decides where polish goes. Surface the run card: the launch, the reach step, and the variant keys. The user will flip through whenever they get to it. The interesting feedback is usually **"I want the header from B with the sidebar from C"**, which is the actual design they want.

### 6. Capture the answer and clean up

Once a variant has won, capture the answer (which variant and why), then capture the prototype the way the [SKILL](SKILL.md) describes: the fold on its own branch off main, the prototype branch frozen. Fold the winner into the real code and move the rest onto the throwaway branch, not into main:

- **Sub-shape A**: fold the winner into the existing screen; drop the losing variants and the switcher from main.
- **Sub-shape B**: promote the winning variant to a real screen; drop the throwaway screen and the switcher from main.
- **Sub-shape C**: the HTML file is the primary source; rebuild the winner in the app once it exists.
- **Sub-shape D**: fold the winner into the component; the preview file rides to the throwaway branch.

The full set of variants is the primary source, so it lands on the throwaway branch, not the bin, since variant components and the switcher left in the main branch rot fast and confuse the next reader.

## Anti-patterns

- **Variants that differ only in colour or copy.** That's a tweak, not a prototype. Real variants disagree about structure or interaction.
- **Sharing too much code between variants.** A shared `<Header>` is fine; a shared `<Layout>` defeats the point. Each variant should be free to throw out the layout.
- **Wiring variants to real mutations.** Read-only prototypes are fine. If a variant needs to mutate, point it at a stub: the question is "what should this look like", not "does the backend work".
- **Judging in a preview canvas outside sub-shape D.** A canvas is a vacuum; the verdict comes from the running app.
- **A visible prototype button in the normal UI.** It leaks into release and confuses the next reader. The ways in are the dev surface, the debug flag, or an already-wired deep link.
- **Building infrastructure for the prototype.** Deep linking, a dev menu, a launch script: when the app lacks one, the carrier falls back a step instead.
- **Promoting the prototype directly to production.** The variant code was written under prototype constraints (no tests, minimal error handling). Rewrite it properly when you fold it in.
