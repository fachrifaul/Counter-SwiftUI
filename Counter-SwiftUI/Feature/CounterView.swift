//
//  CounterView.swift
//  Counter-SwiftUI
//
//  Created by Fachri Febrian on 17/12/2024.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct CounterFeature {
    
    @ObservableState
    struct State: Equatable {
        var count = 0
        var numberFact: String?
        var isLoading = false
        var isTimerRunning = false
    }
    
    enum Action {
        case decrementButtonTapped
        case incrementButtonTapped
        case numberFactButtonTapped
        case numberFactResponse(String)
        case timerTick
        case toggleTimerButtonTapped
    }
    
    @Dependency(\.factClient) var factClient
    
    enum CancelID { case timer }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                state.numberFact = nil
                return .none
                
                
            case .incrementButtonTapped:
                state.count += 1
                state.numberFact = nil
                return .none
                
                
            case .numberFactButtonTapped:
                state.isLoading = true
                
                return .run { [count = state.count] send in
                    let response = try await self.factClient.fetch(count)
                    await send(
                        .numberFactResponse(response)
                    )
                }
                
                
            case let .numberFactResponse(fact):
                state.isLoading = false
                state.numberFact = fact
                return .none
                
            case .timerTick:
               state.count += 1
               state.numberFact = nil
               return .none
                
            case .toggleTimerButtonTapped:
                state.isTimerRunning.toggle()
                if state.isTimerRunning {
                  return .run { send in
                    while true {
                      try await Task.sleep(nanoseconds: 100_000_000)
                      await send(.timerTick)
                    }
                  }
                  .cancellable(id: CancelID.timer)
                } else {
                  return .cancel(id: CancelID.timer)
                }
            }
        }
    }
    
}

struct CounterView: View {
    let store: StoreOf<CounterFeature>
    
    var body: some View {
        Form {
            Section {
                Text("\(store.count)")
                Button("Decrement") { store.send(.decrementButtonTapped) }
                Button("Increment") { store.send(.incrementButtonTapped) }
                Button("Toggle Timer") { store.send(.toggleTimerButtonTapped) }
            }
            
            Section {
                Button("Number fact") { store.send(.numberFactButtonTapped) }
            }
            
            if store.isLoading {
                ProgressView()
                    .padding()
                    .multilineTextAlignment(.center)
            } else if let fact = store.numberFact {
                Text(fact)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }
}

#Preview {
    CounterView(
        store: Store(initialState: CounterFeature.State()) {
            CounterFeature()
        }
    )
}
