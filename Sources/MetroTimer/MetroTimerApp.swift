import SwiftUI
import AppKit

// MARK: - App Entry

@main
struct MetroTimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(WindowAccessor())
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - Window Accessor (floating + drag)

struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.styleMask = [.borderless, .fullSizeContentView]
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.isMovableByWindowBackground = true
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = true
            window.setContentSize(NSSize(width: 320, height: 70))
            window.center()
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

// MARK: - Metro Colors

extension Color {
    static let metroBg = Color(red: 0.102, green: 0.102, blue: 0.180)       // #1a1a2e
    static let metroAccent = Color(red: 0.914, green: 0.271, blue: 0.376)   // #e94560
    static let metroText = Color(red: 0.933, green: 0.933, blue: 0.957)     // #eeeeF4
    static let metroMuted = Color(red: 0.400, green: 0.400, blue: 0.480)    // #66667a
    static let metroHover = Color(red: 0.150, green: 0.150, blue: 0.250)    // #262640
}

// MARK: - Timer ViewModel

@MainActor
class TimerViewModel: ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    @Published var isRunning: Bool = false
    @Published var minutePulse: Bool = false
    private var timer: Timer?
    private var startDate: Date?
    private var accumulatedTime: TimeInterval = 0
    private var lastMinute: Int = 0

    var isHourMode: Bool {
        elapsedTime >= 3600
    }

    var mainDisplay: String {
        let total = elapsedTime
        let h = Int(total) / 3600
        let m = (Int(total) % 3600) / 60
        let s = Int(total) % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    var centiseconds: String {
        let cs = Int((elapsedTime - Double(Int(elapsedTime))) * 100)
        return String(format: ".%02d", cs)
    }

    var displayTime: String {
        mainDisplay + centiseconds
    }

    var currentMinute: Int {
        Int(elapsedTime) / 60
    }

    func toggle() {
        if isRunning {
            stop()
        } else {
            start()
        }
    }

    func reset() {
        stop()
        accumulatedTime = 0
        elapsedTime = 0
        lastMinute = 0
        minutePulse = false
    }

    private func start() {
        isRunning = true
        startDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let startDate = self.startDate else { return }
                self.elapsedTime = self.accumulatedTime + Date().timeIntervalSince(startDate)
                let newMinute = Int(self.elapsedTime) / 60
                if newMinute > self.lastMinute && newMinute > 0 {
                    self.lastMinute = newMinute
                    self.triggerMinutePulse()
                }
            }
        }
    }

    private func triggerMinutePulse() {
        minutePulse = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.minutePulse = false
        }
    }

    private func stop() {
        if let startDate {
            accumulatedTime += Date().timeIntervalSince(startDate)
        }
        isRunning = false
        timer?.invalidate()
        timer = nil
        startDate = nil
    }
}

// MARK: - Content View

struct ContentView: View {
    @StateObject private var vm = TimerViewModel()
    @State private var startHover = false
    @State private var resetHover = false
    @State private var closeHover = false
    @State private var isHoveringWindow = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background with minute pulse flash
            ZStack {
                Color.metroBg.opacity(0.85)
                Color.metroAccent
                    .opacity(vm.minutePulse ? 0.15 : 0.0)
                    .animation(.easeOut(duration: 0.8), value: vm.minutePulse)
            }

            // Main horizontal layout
            HStack(spacing: 0) {
                // Timer display
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(vm.mainDisplay)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                    Text(vm.centiseconds)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .opacity(0.5)
                }
                .foregroundColor(vm.isRunning ? .metroAccent : .metroText)
                .animation(.easeInOut(duration: 0.2), value: vm.isRunning)
                .scaleEffect(vm.minutePulse ? 1.12 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0), value: vm.minutePulse)
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityLabel("타이머")
                .accessibilityValue(vm.displayTime)

                // Buttons
                HStack(spacing: 6) {
                    // Start / Stop
                    Button(action: { vm.toggle() }) {
                        Image(systemName: vm.isRunning ? "stop.fill" : "play.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 34, height: 34)
                            .background(
                                vm.isRunning
                                    ? (startHover ? Color.metroMuted : Color.metroMuted.opacity(0.7))
                                    : (startHover ? Color.metroAccent.opacity(0.85) : Color.metroAccent)
                            )
                            .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                    .onHover { h in startHover = h }
                    .accessibilityLabel(vm.isRunning ? "중지" : "시작")

                    // Reset
                    Button(action: { vm.reset() }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.metroText)
                            .frame(width: 34, height: 34)
                            .background(resetHover ? Color.metroHover : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.metroMuted, lineWidth: 1)
                            )
                            .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                    .onHover { h in resetHover = h }
                    .accessibilityLabel("리셋")
                }
                .padding(.trailing, 10)
            }
            .frame(width: 320, height: 70)

            // Close button (top-left, visible on hover)
            Button(action: { NSApp.terminate(nil) }) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(closeHover ? .metroAccent : .metroMuted)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { h in closeHover = h }
            .accessibilityLabel("닫기")
            .padding(2)
            .opacity(isHoveringWindow ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.15), value: isHoveringWindow)
        }
        .frame(width: 320, height: 70)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onHover { h in isHoveringWindow = h }
    }
}
