//
//  AppCounterView.swift
//  Counter-SwiftUI
//
//  Created by Fachri Febrian on 17/12/2024.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct CounterAppFeature {

    struct State: Equatable {
        var tab1 = CounterFeature.State()
        var tab2 = CounterFeature.State()
    }
    
    enum Action {
        case tab1(CounterFeature.Action)
        case tab2(CounterFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(
            state: \.tab1,
            action: \.tab1, child: {
                return CounterFeature()
            }
        )
        Scope(
            state: \.tab2,
            action: \.tab2,
            child: {
                return CounterFeature()
            }
        )
        Reduce { state, action in
            return .none
        }
    }
}


struct AppCounterView: View {
    let store: StoreOf<CounterAppFeature>
    
    var body: some View {
        TabView {
            CounterView(store: store.scope(state: \.tab1, action: \.tab1))
                .tabItem {
                    Text("Counter 1")
                }
            CounterView(store: store.scope(state: \.tab2, action: \.tab2))
                .tabItem {
                    Text("Counter 2")
                }
        }.navigationTitle("Devices")
    }
}


#Preview {
    AppCounterView(
        store: Store(initialState: CounterAppFeature.State()) {
            CounterAppFeature()
        }
    )
}
