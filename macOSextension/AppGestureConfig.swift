//
//  AppGestureConfig.swift
//  macOSextension
//
//  Created by piednes on 2026-06-17.
//

import Foundation
import Combine

/// 每个 App 的手势行为配置，持久化到 UserDefaults
final class AppGestureConfig: ObservableObject {
    enum Mode: String, CaseIterable, Codable {
        case ignore   = "ignore"
        case minimize = "minimize"
        case close    = "close"

        var label: String {
            switch self {
            case .ignore:   return "不响应"
            case .minimize: return "最小化"
            case .close:    return "关闭"
            }
        }
    }

    @Published private(set) var config: [String: Mode] = [:]
    private let storageKey = "TopRightCloser.gestureConfig"

    init() {
        load()
    }

    /// 获取指定 bundleID 的手势模式（默认 .minimize）
    func mode(for bundleID: String) -> Mode {
        config[bundleID] ?? .minimize
    }

    /// 设置手势模式
    func setMode(_ mode: Mode, for bundleID: String) {
        config[bundleID] = mode
        save()
    }

    /// 重置为默认（最小化）
    func reset(for bundleID: String) {
        config.removeValue(forKey: bundleID)
        save()
    }

    /// 是否有任何自定义配置
    var hasCustomConfig: Bool { !config.isEmpty }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([String: String].self, from: data)
        else { config = [:]; return }
        config = decoded.compactMapValues { Mode(rawValue: $0) }
    }

    private func save() {
        let dict = config.mapValues { $0.rawValue }
        guard let data = try? JSONEncoder().encode(dict) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
