//
//  Counter_SwiftUITests.swift
//  Counter-SwiftUITests
//
//  Created by Fachri Febrian on 17/12/2024.
//

import ComposableArchitecture
import Dependencies
import XCTest

@testable import Counter_SwiftUI

final class CounterTest: XCTestCase {
    
    func testIncrementAndDecrement() async {
        let store = await TestStore(initialState: Counter.State()) {
            Counter()
        }
        
        await store.send(.incrementButtonTapped) {
            $0.count = 1
        }
        
        await store.send(.decrementButtonTapped) {
            $0.count = 0
        }
    }
    
    func testFetchNumberFact() async {
        let store = await TestStore(initialState: Counter.State()) {
            Counter()
        } withDependencies: {
            $0.factClient = .testValue
        }
        
        // Fetch number fact
        await store.send(.numberFactButtonTapped)
        await store.receive(\.numberFactResponse) {
            $0.numberFact = "Number 0 is great!"
        }
    }
    
    func testTImer() async {
        let store = await TestStore(initialState: Counter.State()) {
            Counter()
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

