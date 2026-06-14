//
//  macOSextensionApp.swift
//  macOSextension
//
//  Created by piednes on 2026-06-14.
//

import SwiftUI

@main
struct macOSextensionApp: App {
    @StateObject private var whitelist: AppWhitelist
    @StateObject private var monitor: CornerClickMonitor

    init() {
        NSApplication.shared.setActivationPolicy(.accessory)
        let wl = AppWhitelist()
        _whitelist = StateObject(wrappedValue: wl)
        _monitor = StateObject(wrappedValue: CornerClickMonitor(whitelist: wl))
    }

    var body: some Scene {
        MenuBarExtra(monitor.isEnabled ? "已启用" : "已暂停",
                     systemImage: monitor.isEnabled ? "xmark.square.fill" : "xmark.square") {
            Toggle("启用右上角关闭", isOn: $monitor.isEnabled)
            Divider()
            Button("管理白名单...") {
                // 1) 临时切换到 .regular 以保证窗口能置前
                if NSApp.activationPolicy() != .regular {
                    NSApp.setActivationPolicy(.regular)
                }
                // 2) 激活 app（菜单关闭后生效）
                NSApp.activate(ignoringOtherApps: true)
                // 3) 打开 Settings 窗口
                if #available(macOS 14, *) {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                } else {
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                }
            }
            Divider()
            Button("退出") { NSApplication.shared.terminate(nil) }
                .keyboardShortcut("q")
        }
        .menuBarExtraStyle(.menu)

        Settings {
            WhitelistSettingsView(whitelist: whitelist)
        }
    }
}
