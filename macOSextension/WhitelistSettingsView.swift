//
//  WhitelistSettingsView.swift
//  macOSextension
//
//  Created by piednes on 2026-06-14.
//

import SwiftUI
import AppKit
import Combine

struct WhitelistSettingsView: View {
    @ObservedObject var whitelist: AppWhitelist
    @State private var runningApps: [NSRunningApplication] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("仅勾选的App，在右上角右键点击时才会被关闭窗口")
                .font(.callout)
                .foregroundStyle(.secondary)

            List(runningApps, id: \.processIdentifier) { app in
                Toggle(isOn: Binding(
                    get: { whitelist.contains(app.bundleIdentifier ?? "") },
                    set: { _ in
                        if let bundleID = app.bundleIdentifier {
                            whitelist.toggle(bundleID)
                        }
                    }
                )) {
                    HStack(spacing: 8) {
                        if let icon = app.icon {
                            Image(nsImage: icon).resizable().frame(width: 20, height: 20)
                        }
                        Text(app.localizedName ?? "未知App")
                    }
                }
            }
            .frame(minHeight: 240)
        }
        .padding()
        .frame(width: 360)
        .onAppear(perform: refresh)
        .onAppear {
            DispatchQueue.main.async {
                if NSApp.activationPolicy() != .regular {
                    NSApp.setActivationPolicy(.regular)
                }
                NSApp.activate(ignoringOtherApps: true)
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)
                .receive(on: DispatchQueue.main)
        ) { notification in
            guard let window = notification.object as? NSWindow,
                  window.identifier?.rawValue.hasPrefix("com_apple_SwiftUI") == true
            else { return }
            NSApp.setActivationPolicy(.accessory)
        }
    }

    /// 只列出常规App（过滤掉后台辅助进程），按名称排序
    private func refresh() {
        runningApps = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular && $0.bundleIdentifier != nil }
            .sorted { ($0.localizedName ?? "") < ($1.localizedName ?? "") }
    }
}
