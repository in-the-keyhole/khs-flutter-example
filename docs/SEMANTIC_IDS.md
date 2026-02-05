# Semantic IDs Reference

This document lists all semantic identifiers available in the application for testing purposes.

## Main View

### Scaffold & Navigation
- `view.main` - Main view container with bottom navigation
- `view.main.scaffold` - Main Scaffold widget
- `view.main.indexedStack` - IndexedStack containing pages
- `view.main.bottomNav` - Bottom navigation bar container
- `view.main.bottomNav.bar` - BottomNavigationBar widget
- `view.main.bottomNav.home.icon` - Home tab icon
- `view.main.bottomNav.settings.icon` - Settings tab icon

## Home Page

### Page Structure
- `view.home` - Home page container
- `view.home.appBar` - Home page app bar
- `view.home.template` - Centered template
- `view.home.greeting` - Greeting message container
- `view.home.greeting.text` - Greeting text widget

## Settings Page

### Page Structure
- `view.settings` - Settings page container
- `view.settings.appBar` - Settings page app bar (also has legacy key `view.settings.appBar`)
- `view.settings.template` - Column template

### Theme Section
- `view.settings.themeSection` - Theme section container
- `view.settings.themeSection.heading` - Theme section heading
- `view.settings.themeDropdown` - Theme mode dropdown

## Component Semantic IDs

### Pages
All pages accept optional `semanticsId` parameter:
```dart
HomePage(
  title: 'Home',
  semanticsId: 'view.home',
  child: ...,
)
```

### Templates
All templates accept optional `semanticsId` parameter:
```dart
CenteredTemplate(
  semanticsId: 'view.home.template',
  child: ...,
)

ColumnTemplate(
  semanticsId: 'view.settings.template',
  sections: [...],
)
```

### Organisms
```dart
Section(
  heading: 'Theme',
  semanticsId: 'view.settings.themeSection',
  children: [...],
)
```

### Molecules
```dart
Dropdown<T>(
  value: value,
  items: items,
  onChanged: callback,
  semanticsIdentifier: 'view.settings.themeDropdown',
  semanticsLabel: 'Theme selection',
)

ConfirmationDialog(
  title: 'Title',
  content: 'Content',
  testId: 'dialog.confirmation',
)
```

### Atoms
```dart
SectionHeading(
  'Theme',
  semanticsId: 'view.settings.themeSection.heading',
)

EmptyState(
  message: 'No items',
  testId: 'emptyState.items',
)

LoadingButton(
  onPressed: callback,
  child: Text('Submit'),
  testId: 'button.submit',
)
```

## Testing Examples

### Finding Widgets in Tests
```dart
// Find by semantic ID
find.bySemanticsLabel('view.home')
find.byKey(ValueKey('view.home'))

// Find bottom navigation
find.byKey(ValueKey('view.main.bottomNav.bar'))

// Find theme dropdown
find.byKey(ValueKey('view.settings.themeDropdown'))
```

### Integration Test Example
```dart
testWidgets('Navigate to settings and change theme', (tester) async {
  await tester.pumpWidget(MyApp());

  // Find and tap settings tab
  final settingsTab = find.byKey(ValueKey('view.main.bottomNav.settings.icon'));
  await tester.tap(settingsTab);
  await tester.pumpAndSettle();

  // Verify settings page is visible
  expect(find.byKey(ValueKey('view.settings')), findsOneWidget);

  // Find and interact with theme dropdown
  final dropdown = find.byKey(ValueKey('view.settings.themeDropdown'));
  expect(dropdown, findsOneWidget);
});
```

## Naming Convention

Semantic IDs follow this pattern:
- `{scope}.{feature}.{component}.{element}`

Examples:
- `view.main` - Main view scope
- `view.home.greeting` - Home view, greeting component
- `view.settings.themeSection.heading` - Settings view, theme section, heading element

This hierarchical naming makes it easy to:
1. Identify the scope of a widget
2. Understand the widget hierarchy
3. Write focused, maintainable tests
