import SwiftUI

struct ShortcutDefinition: Identifiable {
    let id: String
    let title: LocalizedStringKey
    let defaultKey: String
    let defaultModifiers: EventModifiers
}

enum ShortcutCatalog {
    static let all: [ShortcutDefinition] = [
        .init(id: "toggle1", title: "Toggle Stopwatch1", defaultKey: "1", defaultModifiers: [.command]),
        .init(id: "lap1", title: "Lap Stopwatch1", defaultKey: "1", defaultModifiers: [.command, .shift]),
        .init(id: "reset1", title: "Reset Stopwatch1", defaultKey: "1", defaultModifiers: [.command, .option]),
        .init(id: "toggle2", title: "Toggle Stopwatch2", defaultKey: "2", defaultModifiers: [.command]),
        .init(id: "lap2", title: "Lap Stopwatch2", defaultKey: "2", defaultModifiers: [.command, .shift]),
        .init(id: "reset2", title: "Reset Stopwatch2", defaultKey: "2", defaultModifiers: [.command, .option]),
        .init(id: "resetAll", title: "Reset All", defaultKey: "0", defaultModifiers: [.command, .option])
    ]

    static func definition(_ id: String) -> ShortcutDefinition {
        all.first { $0.id == id }!
    }
}

struct UserShortcut {
    let key: KeyEquivalent
    let modifiers: EventModifiers

    init(_ definition: ShortcutDefinition) {
        let rawKey = UserDefaults.standard.string(forKey: "\(definition.id).key") ?? definition.defaultKey
        let modifiersKey = "\(definition.id).modifiers"
        let modifiers: EventModifiers

        if UserDefaults.standard.object(forKey: modifiersKey) == nil {
            modifiers = definition.defaultModifiers
        } else {
            modifiers = EventModifiers(rawValue: UserDefaults.standard.integer(forKey: modifiersKey))
        }

        self.key = KeyEquivalent(Character(rawKey.normalizedShortcutKey))
        self.modifiers = modifiers
    }
}

private extension String {
    var normalizedShortcutKey: String {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return String(trimmed.lowercased().first ?? " ")
    }
}

struct ShortcutSettingsView: View {
    @State private var refreshID = UUID()

    var body: some View {
        Form {
            Section("Keyboard Shortcuts") {
                ForEach(ShortcutCatalog.all) { definition in
                    ShortcutEditor(definition: definition)
                }
            }
        }
        .id(refreshID)
        .formStyle(.grouped)
        .frame(minWidth: 360, minHeight: 420)
        .toolbar {
            Button("Restore Defaults") {
                restoreDefaults()
            }
        }
    }

    private func restoreDefaults() {
        for definition in ShortcutCatalog.all {
            UserDefaults.standard.removeObject(forKey: "\(definition.id).key")
            UserDefaults.standard.removeObject(forKey: "\(definition.id).modifiers")
        }
        refreshID = UUID()
    }
}

private struct ShortcutEditor: View {
    let definition: ShortcutDefinition

    @AppStorage private var key: String
    @AppStorage private var storedModifiers: Int

    init(definition: ShortcutDefinition) {
        self.definition = definition
        _key = AppStorage(wrappedValue: definition.defaultKey, "\(definition.id).key")
        _storedModifiers = AppStorage(wrappedValue: definition.defaultModifiers.rawValue, "\(definition.id).modifiers")
    }

    var body: some View {
        HStack {
            Text(definition.title)
            Spacer()
            modifierToggle("⌘", .command)
            modifierToggle("⌥", .option)
            modifierToggle("⌃", .control)
            modifierToggle("⇧", .shift)
            TextField("Key", text: normalizedKey)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .frame(width: 46)
        }
    }

    private var modifiers: EventModifiers {
        get { EventModifiers(rawValue: storedModifiers) }
        nonmutating set { storedModifiers = newValue.rawValue }
    }

    private var normalizedKey: Binding<String> {
        Binding(
            get: { key },
            set: { newValue in
                key = String((newValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().first ?? Character(definition.defaultKey)))
            }
        )
    }

    private func modifierToggle(_ label: String, _ modifier: EventModifiers) -> some View {
        let isActive = modifiers.contains(modifier)

        return Button(label) {
            if isActive {
                modifiers.remove(modifier)
            } else {
                modifiers.insert(modifier)
            }
        }
        .modifier(ShortcutToggleStyle(isActive: isActive))
    }
}

private struct ShortcutToggleStyle: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        if isActive {
            content
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        } else {
            content
                .buttonStyle(.bordered)
                .controlSize(.small)
        }
    }
}
