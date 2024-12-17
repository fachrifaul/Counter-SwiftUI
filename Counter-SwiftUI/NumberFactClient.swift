//
//  NumberFactClient.swift
//  Counter-SwiftUI
//
//  Created by Fachri Febrian on 17/12/2024.
//

import ComposableArchitecture
import Foundation

@DependencyClient
struct FactClient {
    var fetch: (Int) async throws -> String
}

extension DependencyValues {
    var factClient: FactClient {
        get { self[FactClient.self] }
        set { self[FactClient.self] = newValue }
    }
}


extension FactClient: DependencyKey {
    static let liveValue = Self(
        fetch: { number in
            try await Task.sleep(nanoseconds: 1000)
            // Simple live implementation
            let (data, _) = try await URLSession.shared.data(
                from: URL(string: "http://numbersapi.com/\(number)/trivia")!
            )
            return String(decoding: data, as: UTF8.self)
        }
    )
    
    static let testValue = Self { number in
        "Number \(number) is great!" // Mock response
    }
}
