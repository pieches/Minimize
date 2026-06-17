//
//  FirstLaunchSetupView.swift
//  macOSextension
//
//  Created by piednes on 2026-06-17.
//

import SwiftUI
import AppKit

/// 首次启动引导 / 重新引导界面
struct FirstLaunchSetupView: View {
    @ObservedObject var gestureConfig: AppGestureConfig
    @State private var runningApps: [NSRunningApplication] = []

    private let setupKey = "TopRightCloser.hasCompletedFirstLaunchSetup"

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "xmark.square.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)
                    .padding(.top, 24)
                Text("欢迎使用 Minimize")
                    .font(.title2).fontWeight(.semibold)
                Text("选择右上角右键单击手势行为")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            .padding(.bottom, 16)

            Divider().padding(.horizontal, 16)

            // App list
            if runningApps.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "app.dashed")
                        .font(.system(size: 32)).foregroundStyle(.tertiary)
                    Text("没有可用的 App\n请先打开一些应用程序")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(height: 260)
            } else {
                List(runningApps, id: \.processIdentifier) { app in
                    HStack {
                        HStack(spacing: 10) {
                            if let icon = app.icon {
                                Image(nsImage: icon).resizable().frame(width: 20, height: 20)
                            }
                            Text(app.localizedName ?? "未知 App").font(.body)
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
                        .frame(width: 220)
                    }
                }
                .listStyle(.plain)
                .frame(height: 260)
            }

            Divider().padding(.horizontal, 16)

            // Footer
            Button(action: completeSetup) {
                Text("开始使用")
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)
            .padding(.vertical, 20)
        }
        .frame(width: 440, height: 480)
        .onAppear(perform: refresh)
        .onDisappear { NSApp.setActivationPolicy(.accessory) }
    }

    private func refresh() {
        runningApps = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular && $0.bundleIdentifier != nil }
            .sorted { ($0.localizedName ?? "") < ($1.localizedName ?? "") }
    }

    private func completeSetup() {
        UserDefaults.standard.set(true, forKey: setupKey)
        NSApp.keyWindow?.close()
    }
}
