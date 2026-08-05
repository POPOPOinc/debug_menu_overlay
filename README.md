# debug_menu_overlay

[日本語](README_ja.md)

An in-app debug menu that opens with a four-finger tap.

| Opening the menu | Page transition | Dark mode toggle |
| --- | --- | --- |
| ![Opening the menu](doc/images/open_menu.gif) | ![Page transition](doc/images/page_transition.gif) | ![Dark mode toggle](doc/images/dark_mode.gif) |

## Usage

```dart
MaterialApp(
  builder: (context, child) => DebugMenuHost(
    enabled: !kReleaseMode,
    items: <DebugMenuItem>[
      DebugMenuItem(
        title: 'Version',
        keywords: const <String>['build', 'flavor'],
        builder: (context, scope) => const DebugMenuInfoTile(
          label: 'Version',
          value: '1.0.0+1',
        ),
      ),
      DebugMenuItem(
        title: 'Reset onboarding',
        builder: (context, scope) => ListTile(
          title: const Text('Reset onboarding'),
          onTap: () {
            resetOnboarding();
            scope.close();
          },
        ),
      ),
      DebugMenuItem(
        title: 'Android exit reasons',
        visibleWhen: () => Platform.isAndroid,
        builder: (context, scope) => ListTile(
          title: const Text('Android exit reasons'),
          // Pushed inside the debug window's own Navigator, not the app's router.
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ExitReasonsPage()),
          ),
        ),
      ),
    ],
    child: child!,
  ),
  home: const HomePage(),
);
```

Touch the screen with four fingers — or press Cmd+D / Ctrl+D — to open the menu. Tap outside it to close it.

A runnable app with all of the above wired up lives in [`example/`](example).

```sh
cd example && flutter run
```

## Advanced usage

### Where to put `DebugMenuHost` in the widget tree

`DebugMenuHost` needs to sit at a position that satisfies **both** of these:

- **Inside (below) `MaterialApp`** — either inside `MaterialApp.builder`, or wrapping whatever
  widget you pass to `home`. This lets the debug window inherit `MaterialApp`'s theme, text
  direction, MediaQuery, and material localizations.
- **Inside (below) any Provider, redux store, or service locator that your items need to read** —
  `DebugMenuScope.appContext` is the host's own `BuildContext`, and a `BuildContext` can only look
  up things above it (its ancestors). So anything an item wants to read through `scope.appContext`
  must already be above the host in the tree.

Widget tree shape:

```
MaterialApp
  └─ Provider / redux Store, etc. (whatever your items need to read)
      └─ DebugMenuHost   ← put it here
          └─ your actual app (home, etc.)
```

```dart
DebugMenuItem(
  title: 'Account',
  // AccountDebugTile uses this appContext to reach the Account provider,
  // which lives above the host.
  builder: (context, scope) => AccountDebugTile(appContext: scope.appContext),
);
```

### Opening it from your own state management

By default the activation gesture opens the window directly. If you need to open the menu from
somewhere else too — a deep link, a shake detector, a redux action — hold on to your own
`DebugMenuController` and route the gesture through the same path via `onActivate`.

```dart
DebugMenuHost(
  controller: _controller,          // call open() / close() from your own code
  onActivate: () => store.dispatch(OpenDebugMenuAction()),
  items: items,
  child: child,
);
```

### Registering items lazily

If each feature registers its own items on startup, pass a `DebugMenuRegistry` instead of `items`.

```dart
final registry = DebugMenuRegistry();

registry.register(
  DebugMenuItem(id: 'network', title: 'Network log', builder: ...),
);
registry.unregister('network');
```

An item registered with an `id` gets replaced in place when it's registered again. This keeps hot
reloads and re-initialization from producing duplicate entries.

`items` is only read once, when the host mounts — so entries registered at runtime survive the
app's next rebuild. If the set of items itself needs to change later, pass `registry` instead; if
you only need to show or hide items, use `visibleWhen`.

### Customization

```dart
DebugMenuHost(
  title: 'Internal tools',
  showFilterField: false,
  activation: const DebugMenuActivation(
    pointerCount: 3,
    keyboardShortcut: DebugMenuKeyboardShortcut(key: LogicalKeyboardKey.f12),
  ),
  theme: const DebugMenuWindowTheme(
    widthFactor: 0.9,
    heightFactor: 0.8,
    barrierColor: Color(0x66000000),
    borderRadius: BorderRadius.all(Radius.circular(12)),
  ),
  child: child,
);
```

`DebugMenuActivation.none` disables both the gesture and the keyboard shortcut, leaving the
controller as the only way in. Handy for integration tests.

## Known limitations

- Android's back button is handled by the app's own navigator, not the debug window. Pop debug
  sub-pages with the AppBar's back button, or tap outside the window to close the whole thing.
- The filter field only matches top-level items. Entries nested inside an item's sub-page aren't
  indexed.
- The window can't be dragged or resized, and its position isn't persisted.

## License

See [LICENSE](./LICENSE).
