//
//  CounterFeatureTest.swift
//  Counter-SwiftUITests
//
//  Created by Fachri Febrian on 17/12/2024.
//

import ComposableArchitecture
import Dependencies
import XCTest

@testable import Counter_SwiftUI

final class CounterFeatureTest: XCTestCase {
    
    func testIncrementAndDecrement() async {
        let store = await TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        }
        
        await store.send(.incrementButtonTapped) {
            $0.count = 1
        }
        
        await store.send(.decrementButtonTapped) {
            $0.count = 0
        }
    }
    
    func testFetchNumberFact() async {
        let store = await TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: {
            $0.factClient = .testValue
        }
        
        // Fetch number fact
        await store.send(.numberFactButtonTapped) {
            $0.isLoading = true
        }
        await store.receive(\.numberFactResponse) {
            $0.isLoading = false
            $0.numberFact = "Number 0 is great!"
        }
    }
    
    func testTImer() async {
        let store = await TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        }
        
        await store.send(.toggleTimerButtonTapped) {
          $0.isTimerRunning = true
        }
        await store.receive(\.timerTick, timeout: .seconds(2)) {
          $0.count = 1
        }
        await store.send(.toggleTimerButtonTapped) {
          $0.isTimerRunning = false
        }
    }
    
}

