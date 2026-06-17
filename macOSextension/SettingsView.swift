//
//  SettingsView.swift
//  macOSextension
//
//  Created by piednes on 2026-06-17.
//

import SwiftUI
import AppKit
import Combine

/// 统一设置页：为每个 App 选择右上角手势行为
struct SettingsView: View {
    @ObservedObject var gestureConfig: AppGestureConfig
    @State private var runningApps: [NSRunningApplication] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择右上角右键单击手势行为")
                .font(.callout)
                .foregroundStyle(.secondary)

            List(runningApps, id: \.processIdentifier) { app in
                HStack {
                    HStack(spacing: 8) {
                        if let icon = app.icon {
                            Image(nsImage: icon).resizable().frame(width: 20, height: 20)
                        }
                        Text(app.localizedName ?? "未知 App")
                    }
                    Spacer()
                    Picker("", selection: Binding(
                        get: { gestureConfig.mode(for: app.bundleIdentifier ?? "") },
                        set: { gestureConfig.setMode($0, for: app.bundleIdentifier ?? "") }
                    )) {
                        ForEach(AppGestureConfig.Mode.allCases, id: \.self) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 240)
                }
            }
            .listStyle(.plain)
        }
        .padding()
        .frame(width: 440, height: 360)
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
    private func refresh() {
        runningApps = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular && $0.bundleIdentifier != nil }
            .sorted { ($0.localizedName ?? "") < ($1.localizedName ?? "") }
    }
}
