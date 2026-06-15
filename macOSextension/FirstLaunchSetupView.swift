//
//  FirstLaunchSetupView.swift
//  macOSextension
//
//  Created by piednes on 2026-06-17.
//

import SwiftUI
import AppKit

/// 首次启动引导界面：欢迎提示 + 白名单 App 选择 + 完成配置
struct FirstLaunchSetupView: View {
    @ObservedObject var whitelist: AppWhitelist
    @State private var runningApps: [NSRunningApplication] = []
    @State private var selectedCount = 0

    private let setupKey = "TopRightCloser.hasCompletedFirstLaunchSetup"

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            VStack(spacing: 8) {
                Image(systemName: "xmark.square.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)
                    .padding(.top, 24)

                Text("欢迎使用右上角关闭")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("选择你希望通过右上角右键快速关闭窗口的 App\n未被勾选的 App 将不受影响")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            .padding(.bottom, 16)

            Divider()
                .padding(.horizontal, 16)

            // MARK: - App List
            if runningApps.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "app.dashed")
                        .font(.system(size: 32))
                        .foregroundStyle(.tertiary)
                    Text("没有可用的 App\n请先打开一些应用程序")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(height: 260)
            } else {
                List(runningApps, id: \.processIdentifier) { app in
                    let bundleID = app.bundleIdentifier ?? ""
                    Toggle(isOn: Binding(
                        get: { whitelist.contains(bundleID) },
                        set: { _ in
                            whitelist.toggle(bundleID)
                            updateSelectedCount()
                        }
                    )) {
                        HStack(spacing: 10) {
                            if let icon = app.icon {
                                Image(nsImage: icon)
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            Text(app.localizedName ?? "未知 App")
                                .font(.body)
                        }
                    }
                    .toggleStyle(.checkbox)
                }
                .listStyle(.plain)
                .frame(height: 260)
            }

            Divider()
                .padding(.horizontal, 16)

            // MARK: - Footer
            VStack(spacing: 8) {
                if selectedCount > 0 {
                    Text("已选择 \(selectedCount) 个 App")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }

                Button(action: completeSetup) {
                    Text(selectedCount > 0 ? "开始使用" : "跳过，稍后设置")
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 32)
                .padding(.bottom, 20)
            }
            .padding(.top, 8)
        }
        .frame(width: 400, height: 480)
        .onAppear {
            refresh()
            updateSelectedCount()
        }
    }

    private func refresh() {
        runningApps = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular && $0.bundleIdentifier != nil }
            .sorted { ($0.localizedName ?? "") < ($1.localizedName ?? "") }
    }

    private func updateSelectedCount() {
        selectedCount = runningApps.filter { whitelist.contains($0.bundleIdentifier ?? "") }.count
    }

    private func completeSetup() {
        if selectedCount > 0 {
            UserDefaults.standard.set(true, forKey: setupKey)
        }
        if let window = NSApp.windows.first(where: { $0.title == "👋 欢迎使用" }) {
            window.close()
        }
        NSApp.setActivationPolicy(.accessory)
    }
}
