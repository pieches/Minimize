//
//  macOSextensionApp.swift
//  macOSextension
//
//  Created by piednes on 2026-06-14.
//

import SwiftUI

@main
struct macOSextensionApp: App {
    @StateObject private var gestureConfig: AppGestureConfig
    @StateObject private var monitor: CornerClickMonitor

    init() {
        NSApplication.shared.setActivationPolicy(.accessory)
        let gc = AppGestureConfig()
        _gestureConfig = StateObject(wrappedValue: gc)
        _monitor = StateObject(wrappedValue: CornerClickMonitor(gestureConfig: gc))

        let hasCompletedSetup = UserDefaults.standard.bool(
            forKey: "TopRightCloser.hasCompletedFirstLaunchSetup"
        )
        if !hasCompletedSetup {
            if gc.hasCustomConfig {
                UserDefaults.standard.set(true, forKey: "TopRightCloser.hasCompletedFirstLaunchSetup")
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    Self.openSetupWindow(with: gc)
                }
            }
        }
    }

    var body: some Scene {
        MenuBarExtra(monitor.isEnabled ? "已启用" : "已暂停",
                     systemImage: monitor.isEnabled ? "xmark.square.fill" : "xmark.square") {
            Toggle("启用右上角关闭", isOn: $monitor.isEnabled)
            Divider()
            SettingsLink {
                Text("设置...")
            }
            Button("重新引导设置") {
                Self.openSetupWindow(with: gestureConfig)
            }
            Divider()
            Button("退出") { NSApplication.shared.terminate(nil) }
                .keyboardShortcut("q")
        }
        .menuBarExtraStyle(.menu)

        Settings {
            SettingsView(gestureConfig: gestureConfig)
        }
    }

    // MARK: - 引导/设置窗口

    static func openSetupWindow(with gestureConfig: AppGestureConfig) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        let host = NSHostingController(
            rootView: FirstLaunchSetupView(gestureConfig: gestureConfig)
        )
        let window = NSWindow(contentViewController: host)
        window.title = "欢迎使用 Minimize"
        window.setContentSize(NSSize(width: 440, height: 480))
        window.styleMask = [.titled, .closable]
        window.center()
        window.makeKeyAndOrderFront(nil)
    }
}
