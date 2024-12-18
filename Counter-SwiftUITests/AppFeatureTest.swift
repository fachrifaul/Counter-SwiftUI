//
//  CounterAppFeatureTest.swift
//  Counter-SwiftUITests
//
//  Created by Fachri Febrian on 17/12/2024.
//

import ComposableArchitecture
import XCTest
@testable import Counter_SwiftUI

final class CounterAppFeatureTest: XCTestCase {

    func testIncrementInFirstTab() async {
        let store = await TestStore(initialState: CounterAppFeature.State()) {
            CounterAppFeature()
        }
        
        await store.send(\.tab1.incrementButtonTapped) {
            $0.tab1.count = 1
        }
        
        await store.send(\.tab2.incrementButtonTapped) {
            $0.tab2.count = 1
        }
    }

}
