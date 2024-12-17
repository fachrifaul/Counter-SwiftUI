//
//  ContentView.swift
//  DemoIncrement
//
//  Created by Fachri Febrian on 17/12/2024.
//

import ComposableArchitecture
import SwiftUI

@DependencyClient
struct FactClient {
    var fetch: (Int) async throws -> String
}

@Reducer
struct Counter {
    
    @ObservableState
    struct State: Equatable {
        var count = 0
        var numberFact: String?
    }
    
    enum Action {
        case decrementButtonTapped
        case incrementButtonTapped
        case numberFactButtonTapped
        case numberFactResponse(String)
    }
    
    @Dependency(\.factClient) var factClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                return .none
                
                
            case .incrementButtonTapped:
                state.count += 1
                return .none
                
                
            case .numberFactButtonTapped:
                return .run { [count = state.count] send in
                    let response = try await self.factClient.fetch(count)
                    await send(
                        .numberFactResponse(response)
                    )
                }
                
                
            case let .numberFactResponse(fact):
                state.numberFact = fact
                return .none
            }
        }
    }
    
}

struct ContentView: View {
    let store: StoreOf<Counter>
    
    var body: some View {
        Form {
            Section {
                Text("\(store.count)")
                Button("Decrement") { store.send(.decrementButtonTapped) }
                Button("Increment") { store.send(.incrementButtonTapped) }
            }
            
            Section {
                Button("Number fact") { store.send(.numberFactButtonTapped) }
            }
            
            if let fact = store.numberFact {
                Text(fact)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: Store(initialState: Counter.State()) {
                Counter()
            }
        )
    }
}
