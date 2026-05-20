import SwiftUI

struct ContentView: View {
    @StateObject private var leftStopwatch = StopwatchModel()
    @StateObject private var rightStopwatch = StopwatchModel()
    @State private var showsShortcutSettings = false

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    var body: some View {
        Group {
            if usesHorizontalLayout {
                HStack(spacing: 16) {
                    StopwatchPanel(title: "Stopwatch1", accent: .blue, stopwatch: leftStopwatch)
                    Divider()
                    StopwatchPanel(title: "Stopwatch2", accent: .orange, stopwatch: rightStopwatch)
                }
            } else {
                VStack(spacing: 16) {
                    StopwatchPanel(title: "Stopwatch1", accent: .blue, stopwatch: leftStopwatch)
                    Divider()
                    StopwatchPanel(title: "Stopwatch2", accent: .orange, stopwatch: rightStopwatch)
                }
            }
        }
        .safeAreaInset(edge: .top) {
            HeaderBar(
                canResetAll: canResetAll,
                resetAll: resetAll,
                showShortcutSettings: { showsShortcutSettings = true }
            )
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(platformBackground)
        .background(shortcutCommandButtons)
        .sheet(isPresented: $showsShortcutSettings) {
            NavigationStack {
                ShortcutSettingsView()
                    .navigationTitle("Shortcuts")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showsShortcutSettings = false
                            }
                        }
                    }
            }
        }
    }

    private var usesHorizontalLayout: Bool {
        #if os(macOS)
        return true
        #else
        return horizontalSizeClass == .regular
        #endif
    }

    private var canResetAll: Bool {
        leftStopwatch.elapsed > 0 ||
        rightStopwatch.elapsed > 0 ||
        !leftStopwatch.laps.isEmpty ||
        !rightStopwatch.laps.isEmpty
    }

    private func resetAll() {
        leftStopwatch.reset()
        rightStopwatch.reset()
    }

    @ViewBuilder
    private var shortcutCommandButtons: some View {
        HiddenShortcutButton(id: "toggle1") { leftStopwatch.toggle() }
        HiddenShortcutButton(id: "lap1") { leftStopwatch.recordLap() }
        HiddenShortcutButton(id: "reset1") { leftStopwatch.reset() }
        HiddenShortcutButton(id: "toggle2") { rightStopwatch.toggle() }
        HiddenShortcutButton(id: "lap2") { rightStopwatch.recordLap() }
        HiddenShortcutButton(id: "reset2") { rightStopwatch.reset() }
        HiddenShortcutButton(id: "resetAll") { resetAll() }
    }
}

private var platformBackground: Color {
    #if os(macOS)
    return Color(nsColor: .windowBackgroundColor)
    #else
    return Color(uiColor: .systemBackground)
    #endif
}

private struct HeaderBar: View {
    let canResetAll: Bool
    let resetAll: () -> Void
    let showShortcutSettings: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Spacer()

            Button {
                showShortcutSettings()
            } label: {
                Label("Shortcuts", systemImage: "keyboard")
            }
            .labelStyle(.iconOnly)
            .adaptiveGlassButton()

            Button(role: .destructive) {
                resetAll()
            } label: {
                Label("Reset All", systemImage: "arrow.counterclockwise.circle.fill")
            }
            .disabled(!canResetAll)
            .adaptiveProminentGlassButton()
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

private struct StopwatchPanel: View {
    let title: String
    let accent: Color
    @ObservedObject var stopwatch: StopwatchModel

    var body: some View {
        VStack(spacing: 18) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(stopwatch.elapsed.stopwatchText)
                .font(.system(size: 48, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.55)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            HStack(spacing: 12) {
                Button {
                    stopwatch.toggle()
                } label: {
                    Label(stopwatch.isRunning ? "Pause" : "Start",
                          systemImage: stopwatch.isRunning ? "pause.fill" : "play.fill")
                }
                .adaptiveProminentGlassButton()
                .tint(stopwatch.isRunning ? .red : accent)

                Button {
                    stopwatch.recordLap()
                } label: {
                    Label("Lap", systemImage: "flag.fill")
                }
                .adaptiveGlassButton()
                .disabled(stopwatch.elapsed == 0)

                Button(role: .destructive) {
                    stopwatch.reset()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                .adaptiveGlassButton()
                .disabled(stopwatch.elapsed == 0 && stopwatch.laps.isEmpty)
            }
            .labelStyle(.iconOnly)
            .font(.title3)

            LapList(laps: stopwatch.laps)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .adaptiveGlassPanel(accent: accent)
    }
}

private struct LapList: View {
    let laps: [StopwatchModel.Lap]

    var body: some View {
        Group {
            if laps.isEmpty {
                ContentUnavailableView("No Laps", systemImage: "timer")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(laps) { lap in
                    HStack {
                        Text("Lap \(lap.number)")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(lap.elapsed.stopwatchText)
                            .monospacedDigit()
                    }
                }
                .listStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct HiddenShortcutButton: View {
    let id: String
    let action: () -> Void

    var body: some View {
        let shortcut = UserShortcut(ShortcutCatalog.definition(id))

        Button("", action: action)
            .keyboardShortcut(shortcut.key, modifiers: shortcut.modifiers)
            .frame(width: 0, height: 0)
            .opacity(0)
            .accessibilityHidden(true)
    }
}

private extension View {
    @ViewBuilder
    func adaptiveGlassPanel(accent: Color) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self
                .glassEffect(.regular.tint(accent.opacity(0.12)).interactive(), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            self
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    @ViewBuilder
    func adaptiveGlassButton() -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self.buttonStyle(.bordered)
        }
    }

    @ViewBuilder
    func adaptiveProminentGlassButton() -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
