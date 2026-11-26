//
//  ConfigLoader.swift
//  MeasureSDK
//
//  Created by Adwin Ross on 26/08/24.
//

import Foundation

/// A protocol that defines the methods for loading configuration data from the on-device cache.
protocol ConfigLoader {
    var isConfigLoaded: Bool { get }
    func loadDynamicConfig(onLoaded: @escaping (DynamicConfig) -> Void)
}

/// Loads dynamic config from the on-device cache/bundled file only.
///
/// This SDK runs in local-only mode and never contacts a server, so there is no remote config
/// refresh. If no config file is present, callers fall back to the built-in defaults.
struct BaseConfigLoader: ConfigLoader {
    private final class ConfigState {
        var isConfigLoaded: Bool = false
    }

    private let state = ConfigState()
    var isConfigLoaded: Bool { state.isConfigLoaded }
    private let fileManager: SystemFileManager
    private let decoder: JSONDecoder

    init(fileManager: SystemFileManager) {
        self.fileManager = fileManager
        self.decoder = JSONDecoder()
    }

    func loadDynamicConfig(onLoaded: @escaping (DynamicConfig) -> Void) {
        let cachedConfig = loadConfigFromDisk()
        state.isConfigLoaded = true
        onLoaded(cachedConfig ?? BaseDynamicConfig())
    }

    private func loadConfigFromDisk() -> BaseDynamicConfig? {
        guard let data = fileManager.retrieveFile(
            name: ConfigFileConstants.fileName,
            folderName: "\(ConfigFileConstants.folderName)/\(ConfigFileConstants.dynamicConfigFolderName)",
            directory: ConfigFileConstants.directory
        ) else {
            return nil
        }

        do {
            return try decoder.decode(BaseDynamicConfig.self, from: data)
        } catch {
            return nil
        }
    }
}
