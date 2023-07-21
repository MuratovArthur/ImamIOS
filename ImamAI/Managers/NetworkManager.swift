//
//  NetworkManager.swift
//  ImamAI
//
//  Created by Muratov Arthur on 20.07.2023.
//

import Foundation
import Network

class NetworkMonitor: ObservableObject {
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")

    @Published var isConnected: Bool

    init() {
        self.monitor = NWPathMonitor()
        self.isConnected = true

        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }

        monitor.start(queue: queue)
    }
}


