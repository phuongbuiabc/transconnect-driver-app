---
name: "VieGo Driver"
description: "Native Android location and account workspace; Điểm đến dẫn lối."
colors:
  crimson: "#D3171E"
  brand-gold: "#FFC72C"
  primary-dark: "#FFB4AB"
  surface-light: "#FFFFFF"
  surface-dark: "#202329"
  foreground-dark: "#F2F3F5"
  muted-light: "#545A65"
  muted-dark: "#C6C9D0"
  container-lowest-dark: "#17191E"
  container-low-light: "#F5F6F8"
  container-low-dark: "#272A30"
  container-light: "#EEF0F3"
  container-dark: "#2C2F35"
  container-high-light: "#E8EBF0"
  container-high-dark: "#31343B"
  container-highest-light: "#E1E4EA"
  container-highest-dark: "#383C43"
  outline-light: "#D7DAE0"
  outline-dark: "#454953"
  input-dark: "#292C33"
  tonal-container-dark: "#34373D"
typography:
  headline-medium:
    fontFamily: "Roboto"
    fontSize: "28sp"
    fontWeight: 400
    lineHeight: 1.29
    letterSpacing: "0sp"
  search-heading:
    fontFamily: "Roboto"
    fontSize: "28sp"
    fontWeight: 700
    lineHeight: 1.29
    letterSpacing: "0sp"
  auth-heading:
    fontFamily: "Roboto"
    fontSize: "28sp"
    fontWeight: 700
    lineHeight: 1.2
  title-large:
    fontFamily: "Roboto"
    fontSize: "22sp"
    fontWeight: 400
    lineHeight: 1.27
    letterSpacing: "0sp"
  title-medium:
    fontFamily: "Roboto"
    fontSize: "16sp"
    fontWeight: 500
    lineHeight: 1.5
    letterSpacing: "0.15sp"
  body-large:
    fontFamily: "Roboto"
    fontSize: "16sp"
    fontWeight: 400
    lineHeight: 1.5
    letterSpacing: "0.5sp"
  body-medium:
    fontFamily: "Roboto"
    fontSize: "14sp"
    fontWeight: 400
    lineHeight: 1.43
    letterSpacing: "0.25sp"
  label-large:
    fontFamily: "Roboto"
    fontSize: "14sp"
    fontWeight: 500
    lineHeight: 1.43
    letterSpacing: "0.1sp"
  label-medium:
    fontFamily: "Roboto"
    fontSize: "12sp"
    fontWeight: 500
    lineHeight: 1.33
    letterSpacing: "0.5sp"
rounded:
  control: "12dp"
  panel: "16dp"
spacing:
  step-8: "8dp"
  step-12: "12dp"
  step-16: "16dp"
  step-20: "20dp"
  step-24: "24dp"
  step-28: "28dp"
  step-32: "32dp"
components:
  button-primary:
    backgroundColor: "{colors.crimson}"
    textColor: "{colors.surface-light}"
    rounded: "{rounded.control}"
    typography: "{typography.label-large}"
    height: "52dp"
  button-outlined:
    textColor: "{colors.crimson}"
    rounded: "{rounded.control}"
    height: "48dp"
  button-tonal:
    backgroundColor: "{colors.container-low-light}"
    textColor: "{colors.surface-dark}"
    rounded: "{rounded.control}"
    height: "52dp"
  input:
    backgroundColor: "{colors.surface-light}"
    rounded: "{rounded.control}"
    padding: "16dp"
  panel:
    backgroundColor: "{colors.container-low-light}"
    rounded: "{rounded.panel}"
    padding: "20dp"
  navigation-bar:
    backgroundColor: "{colors.surface-light}"
    height: "80dp"
  result-row:
    typography: "{typography.title-medium}"
    padding: "10dp 0dp"
---
# Design System: VieGo Driver

## Overview

**Creative North Star: "Điểm đến dẫn lối"**

VieGo Driver uses the confirmed “Điểm đến dẫn lối” world: neutral white and graphite, crimson actions, a small gold route symbol, and native Material 3 structure. The feel is direct and readable, with clear task titles and flat, separated content. Brand expression lives inside Android controls rather than replacing their behavior.

This is a scan of the finished Flutter source, not a web style guide. Dimensions below use logical dp; type uses baseline sp and follows the system text scaler. The YAML preserves native units. HTML/CSS in the companion sidecar is a portable, illustrative panel translation only; it does not reproduce Flutter rendering, navigation, focus, or accessibility behavior.

**Key Characteristics:**
- Native Material 3 components and system light/dark themes.
- Neutral working surfaces with crimson action and selection.
- Readable rows, explicit field labels, generous task separation.

## Colors

### Primary

Transport crimson is the light-theme primary and secondary action role. In dark mode both resolve to the pale primary-dark token for legibility. Navigation selection remains crimson with white icons in both modes. Other seeded Material roles, including error and state overlays, remain framework-derived; do not freeze guessed values from screenshots.

### Secondary

Brand gold punctuates the route icon inside its crimson CircleAvatar. It is a brand accent, not the Material secondary action role.

### Neutral

Surface light is white; surface dark is graphite. Foreground is graphite in light mode and foreground-dark in dark mode. Muted text, outlined panel borders, tonal containers and dark inputs use the explicitly named tokens above. The standard tonal button uses container-low-light in light mode and tonal-container-dark in dark mode, with the current foreground. ColorScheme.fromSeed supplies roles not explicitly overridden.

**The Neutral Working Surface Rule.** Use the explicit neutral surface roles in both themes; gold belongs to the brand route symbol, not to the selected navigation indicator.

## Typography

**Display Font:** no custom display family is installed.
**Body Font:** Flutter's Android Material 2021 default, Roboto with platform glyph fallback.
**Label/Mono Font:** same Material family; coordinates are selectable body text, not a custom monospace face.

The app does not override ThemeData.textTheme or install web fonts. Material role metrics in the frontmatter are the installed Flutter SDK's English-like 2021 scale; Vietnamese content uses the app's vi locale. Font size and tracking are baseline sp values, not physical screen pixels. TextScaler may increase rendered dimensions.

### Hierarchy

- Headline medium: detail location name; search heading reuses it with weight 700.
- Title large: results heading; title medium: location rows and detail subsections.
- Body large: search introduction and location address; body medium: ordinary supporting copy.
- Label large: controls and account labels; label medium: supporting brand text.
- Auth heading: a local 28sp, weight 700, height 1.2 override; the auth form title is locally 22sp bold.

Driver renders VieGo at 19sp, weight 800, with the DRIVER identifier in labelMedium and the current primary color.

**The Native Type Roles Rule.** Use the inherited Material roles for work content and preserve system text scaling. Existing brand lettering and auth titles are local exceptions, not a new display-font system.

## Layout

The shell centers a vertically scrolling working column capped at 760dp, padded 24dp. Detail screens cap at 720dp with 24dp padding; auth caps at 540dp with 24dp padding. SafeArea protects native insets. Below 720dp the four destinations use a bottom NavigationBar; at 720dp and above they become a labeled NavigationRail. The bar's configured height is 80dp, with system safe-area space handled separately.

The spacing vocabulary is an observed set rather than a uniform grid: 8dp for small relationships, 12dp between form controls, 16dp inside related information, 20dp panel padding, 24dp between task blocks, 28dp after the brand header, and 32dp for larger auth/empty-state separation. Result rows have 10dp vertical content padding and address separation of 6dp. Map actions Wrap with 8dp spacing and run spacing. Filled buttons set minimum size 48×52dp; outlined and text buttons set 48×48dp minimums. Actual height can grow with text.

## Elevation & Depth

Shared panels use a low tonal container and a one-logical-pixel outline. App bars remove surface tint. No custom BoxShadow vocabulary exists in the shared theme. Native dialogs, routes, chips, menus and state overlays retain Flutter Material behavior; the system does not claim all native components have zero elevation.

**The Flat at Rest Rule.** Shared panels use a tonal fill and one outline, with no authored shadow. Keep standard Material elevation for native overlays.

## Shapes

Fields and filled/outlined controls share 12dp rounded corners; panels use 16dp. Material navigation indicators and the circular brand avatar keep their native silhouettes. Status notices locally use 14dp corners, but their hardcoded warm colors are incumbent exceptions rather than working-surface tokens. No shipping bitmap asset was introduced by this direction.

## Components

### Buttons

Filled buttons carry the primary action; the minimum height is 52dp. Outlined and text variants serve secondary tasks with minimum 48dp targets. The map directions action uses FilledButton.tonalIcon and neutral secondary-container roles. Disabled, focus, press, hover and ripple states are Flutter Material defaults, not custom CSS. Busy actions disable submission and retain a descriptive label.

### Inputs / Fields

Filled OutlineInputBorder fields use the control radius and 16dp content padding. Light fill is white; dark fill uses input-dark. Labels persist, search has a Material search icon and keyboard search action. Focus, disabled and validation styling are delegated to Material and the current scheme. Auth fields use autofill and a labeled password visibility control.

### Cards / Containers

Panel is the shared container: full available width, low surface fill, 20dp padding, 16dp radius and outlineVariant border. Location results use ListTile plus a divider rather than individual panels.

### Chips

The account verification chip is a standard Material Chip with a Material status icon and a descriptive text label. It is informational rather than an invented filter; shape, spacing, border and states remain framework defaults.

### Navigation

The four destinations are Địa điểm, Hồ sơ, Lời mời, Tài khoản. Selection uses the crimson indicator and white icon; unselected icons use muted text color. Labels, interaction feedback and rail/bar shape remain Material. Detail pages use a native AppBar and MaterialPageRoute with system Back behavior.

### Brand and Location Rows

The route icon in a crimson circle, gold icon color and compact wordmark distinguish the shared header. Driver renders VieGo at 19sp, weight 800, with the DRIVER identifier in labelMedium and the current primary color.

Results present the location name, address and chevron in a tappable ListTile. Detail continues the same name/address into selectable coordinates and wrapping map actions. Keep source distinctions visible: published VieGo locations carry their own identity/version; external map POIs and private addresses are separate product concepts.

## Do's and Don'ts

### Do:
- **Do** use Theme.of(context).colorScheme for new working surfaces and text.
- **Do** use Material navigation bar below 720dp and a navigation rail from 720dp.
- **Do** keep field labels, loading, empty and retry states visible in their task context.
- **Do** preserve native SafeArea, scrolling, system Back and system text scaling.
- **Do** use Material Icons and action labels from the Vietnamese product vocabulary.

### Don't:
- **Don't** turn gold into a navigation-selection or page-background color.
- **Don't** promote local legacy hardcoded status fills or isolated text overrides into new theme rules.
- **Don't** replace result rows with decorative cards or add marketing eyebrows above task headings.
- **Don't** treat panel HTML previews or fixture screenshots as native production or live-provider certification.

This document derives tokens from lib/shared/theme/app_theme.dart, shared widgets, the navigation shell, app MaterialApp, and sampled places/auth/account screens. The approved direction and provenance are in .impeccable/direction.md and .impeccable/provenance.md; the user-selected code sketch is composition reference, not an approved raster comp. Native review images under .impeccable/review are isolated tool/preview.dart fixtures. They do not certify production data, hardware, iOS, SQL/auth or the live external provider; a host-DNS provider failure remains a separate limitation. No browser detector certifies these native screens.
