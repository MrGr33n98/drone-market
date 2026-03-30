# Design System Strategy: The Orbital Lens

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"The Orbital Lens."** 

This system moves beyond standard marketplace aesthetics to create a high-precision, editorial experience that mirrors the vantage point of a drone: distant yet detailed, expansive yet surgical. We are not building a generic "SaaS dashboard"; we are crafting a sophisticated telemetry platform. 

The layout breaks the rigid "template" feel through **intentional asymmetry**. We use oversized typography, overlapping "glass" containers, and high-contrast tonal shifts to guide the user’s eye. The goal is to make data feel like a premium asset, utilizing the "breathing room" of vast whitespace (or "dark-space") to emphasize clarity and technical authority.

---

## 2. Colors: High-Voltage Contrast
The palette is built on a foundation of deep, ink-like voids contrasted against high-voltage accents.

### Color Tokens
- **Background (`surface`):** `#0c141c` — Our primary canvas.
- **On-Background:** `#dbe3ef` — Used for secondary text to maintain low-strain readability.
- **Primary (Accent):** `#ffffff` — Reserved for primary headlines and high-priority content.
- **Primary Container (Action):** `#b9f558` — Our "Neon Lime." Use this exclusively for high-conversion CTAs and critical data status.
- **Secondary (`secondary`):** `#c9bfff` — A technical lavender used for data visualization categories and secondary interactive elements.

### The "No-Line" Rule
Standard UI relies on 1px borders to separate content. **In this system, 1px solid borders are strictly prohibited for sectioning.** 
Boundaries must be defined through:
- **Background Shifts:** Placing a `surface-container-low` (`#141c24`) section against a `surface` background.
- **Tonal Transitions:** Using subtle shifts in the surface hierarchy to define edge cases.

### The "Glass & Gradient" Rule
To evoke a high-tech "cockpit" feel, use **Glassmorphism** for floating elements (like map overlays or mobile menus). 
- **Recipe:** Use `surface-container` with 60% opacity and a `20px` backdrop blur.
- **Gradients:** Use a subtle linear gradient on CTA buttons, transitioning from `primary_fixed` (`#b9f558`) to `primary_fixed_dim` (`#9ed83e`) at a 135-degree angle to provide a "machined" metallic sheen.

---

## 3. Typography: Editorial Authority
We utilize a hierarchy that balances the classic Swiss precision of **Inter/Neue Haas** with the technical, monospaced energy of **Space Grotesk**.

- **Display (Large/Med/Small):** `inter` | Bold. Use for hero sections with tight letter-spacing (-0.02em). These are the "headlines" of the mission.
- **Headline & Title:** `inter` | Semi-Bold. Used for feature cards and section starts.
- **Body (Lg/Md/Sm):** `inter` | Regular. High readability for technical descriptions. Use `body-md` (`0.875rem`) as the workhorse for platform data.
- **Labels (Md/Sm):** `spaceGrotesk`. This is our "Technical" font. Use it for metadata, drone telemetry, coordinates, and table headers. It signals to the user that they are looking at raw, accurate data.

---

## 4. Elevation & Depth: Tonal Layering
We do not use traditional drop shadows to indicate height. Depth is achieved through the physical stacking of surface tiers.

- **The Layering Principle:** 
    - Base Level: `surface` (`#0c141c`)
    - Card/Section Level: `surface-container-low` (`#141c24`)
    - Hover/Active Level: `surface-container-high` (`#232b33`)
- **Ambient Shadows:** When an element must "float" (e.g., a modal), use an ultra-diffused shadow: `box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4)`. The shadow should feel like an atmospheric occlusion, not a hard drop-shadow.
- **The "Ghost Border" Fallback:** If accessibility requires a container edge, use the `outline-variant` token at **15% opacity**. It should be felt, not seen.

---

## 5. Components

### Buttons
- **Primary:** Background: `primary_container` (#b9f558) | Text: `on_primary` (#223600). Roundedness: `md` (`0.375rem`).
- **Secondary:** Background: `transparent` | Border: `Ghost Border` | Text: `primary` (#ffffff).
- **Tertiary:** `label-md` uppercase text with a trailing "Orbital Arrow" icon.

### Cards & Feature Layouts
Cards must never have dividers. Group content using `Spacing Scale 4` (1.4rem) or `Spacing Scale 6` (2rem). Use `surface-container-lowest` for card backgrounds to create a "recessed" look into the platform.

### Data Tables (The Telemetry Grid)
- **Header:** Use `label-sm` in `spaceGrotesk`.
- **Rows:** Alternating background shifts between `surface` and `surface-container-lowest`. 
- **Status Indicators:** Use small, glowing pulses of `primary_container` for "Active" and `error` (#ffb4ab) for "Alerts."

### Inputs & Fields
- Use "Underline Only" styling for a more bespoke, editorial feel, or a fully enclosed `surface-container-highest` box with no border.
- **Focus State:** Transition the underline or subtle ghost border to `primary_container` (#b9f558).

---

## 6. Do's and Don'ts

### Do
- **DO** use asymmetric imagery. Let drone shots bleed off the edge of the screen to suggest scale.
- **DO** use `display-lg` typography that overlaps image containers slightly to create 3D depth.
- **DO** use the `primary_container` (Lime) sparingly. It is a laser pointer, not a bucket of paint.
- **DO** lean into "Dark Mode" as the default and only mode to preserve the "High-Tech" persona.

### Don't
- **DON'T** use standard 1px borders or dividers; they clutter the "Orbital" clarity.
- **DON'T** use generic icon sets. Use thin-stroke, technical icons that feel like architectural markups.
- **DON'T** center-align long blocks of text. Stick to editorial left-alignment to maintain the "grid-breaking" feel.
- **DON'T** use pure black (#000000). Always use our `surface` ink (#0c141c) to allow for depth layering.