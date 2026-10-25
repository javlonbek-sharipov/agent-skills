# Platforms

Where a prototype runs is decided by what the app's runtime gives you, not by the device it ships on. An Electron desktop app behaves like a browser tab; a React Native phone app does not, though both are JavaScript. So: two classes, two checks, one table. Both branches use this file: [UI.md](UI.md) for every in-app prototype, [LOGIC.md](LOGIC.md) when a logic demo moves into the app.

## Two classes

- **DOM**: the app renders HTML in a browser engine. A browser tab, or a web renderer inside a shell (Electron, Tauri, Capacitor).
- **Native toolkit**: the app renders with the platform's own widgets. React Native and Expo, Flutter, SwiftUI and UIKit, Jetpack Compose, WinUI, Qt.

Recognise the class from the repo before asking: the markers are the first row of the table. In a repo with several apps, rule 1 in [SKILL.md](SKILL.md) picks one; classify that one.

## Two checks

Each cuts across both classes and changes one row:

- **Visible URL**: can the user see and edit the address? Only in a browser tab. If yes, the URL carries the variant.
- **Hardware keyboard**: desktops of either class; phones and tablets usually not. If yes, arrow keys cycle variants.

## Mechanics by class

| Mechanic | DOM | Native toolkit |
|---|---|---|
| Recognise by | A web framework in `package.json` (Next, Vite, React Router, Vue, Svelte) or server-rendered templates; a shell when `electron`, `@tauri-apps/*` or `@capacitor/*` is present | `react-native` or `expo` in `package.json`; a `pubspec.yaml`; an `.xcodeproj` or `Package.swift`; a `build.gradle` |
| Variant carrier | Visible URL: the `?variant=` search param, written through the router. In a shell: the router's own params (hash or memory router), else a launch override, else switcher memory | The router's params (expo-router, go_router, React Navigation), else a launch override (`--dart-define`, an Xcode scheme argument, a `BuildConfig` field, an `EXPO_PUBLIC_*` variable), else switcher memory |
| Entry point, for a new screen | A throwaway route in the app's routing convention, `/prototype/<name>`; in a shell, the same route reached through the launch override | The app's existing dev-only surface (the React Native dev menu via `DevSettings.addMenuItem`, an in-app debug screen); else a root swap; a deep link only when deep linking is already wired |
| Switcher | A fixed DOM overlay at the bottom centre; arrow keys with a hardware keyboard | A native overlay inside the safe area; arrow keys on desktop toolkits only |
| Debug flag | `process.env.NODE_ENV !== 'production'`, `import.meta.env.DEV`, `!app.isPackaged` in Electron | `__DEV__` in React Native, `kDebugMode` in Flutter, `#if DEBUG` in Swift, `BuildConfig.DEBUG` on Android |
| Launch | The dev server command the repo documents | The dev launch the repo documents: `expo start`, `flutter run`, the Xcode or Android Studio run action |
| Handover | In a browser tab, the URL with the variant in it; in a shell, the reach step from the run card | The reach step from the run card and which build to run |

## Definitions the table relies on

**Variant carrier.** The URL gives two properties for free: the chosen variant survives a reload, and it can be sent to someone. Elsewhere keep the properties and drop the mechanism, falling back in order: the app router's own params when it has any (then it behaves exactly like the URL); else a launch override; else the switcher's memory alone. Stop there: a prototype never earns new infrastructure such as deep linking or a dev menu.

**Launch override.** One line the developer sets when starting the app, read once by the switcher: an environment variable, a `--dart-define`, an Xcode scheme argument, a `BuildConfig` field. It sets the starting variant and, for a new screen, names the prototype to boot into.

**Root swap.** Behind the debug flag, when the launch override names a prototype, the app's root renders that prototype screen instead of its normal root. It is how a new screen is reached when the app has no dev-only surface. The normal UI shows no trace of the prototype: the ways in are the dev surface, the flag, or an already-wired deep link.

**Debug flag.** The platform's build-time debug check. It hides the switcher and the prototype entry from release builds. The throwaway branch is the real safeguard; the flag is the second layer for the day a prototype is merged by mistake.

**Launch and reach.** The launch is the project's own dev command, as its README, task runner or `CLAUDE.md` defines it; look it up rather than restating it. The reach step is the one action after launch that lands on the prototype: a URL, the launch override, a dev-menu entry. Both go in the run card.
