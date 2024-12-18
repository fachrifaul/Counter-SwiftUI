//
//  AppView.swift
//  Counter-SwiftUI
//
//  Created by Fachri Febrian on 18/12/2024.
//

import ComposableArchitecture
import SwiftUI

struct AppFeature: Reducer {
    
    @Reducer(state: .equatable)
    enum Path {
        case devices(DevicesFeature)
        case counter(CounterAppFeature)
        case contact(ContactsFeature)
    }

    struct State: Equatable {
        @PresentationState var path: Path.State?
    }

    enum Action {
        case path(PresentationAction<Path.Action>)
        case showDevices
        case showCounter
        case showContact
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .path:
                return .none
            case .showDevices:
                state.path = .devices(.init())
                return .none
            case .showCounter:
                state.path = .counter(.init())
                return .none
            case .showContact:
                state.path = .contact(ContactsFeature.State(
                    contacts: [
                        Contact(id: UUID(), name: "Blob"),
                        Contact(id: UUID(), name: "Blob Jr"),
                        Contact(id: UUID(), name: "Blob Sr"),
                    ]
                ))
                return .none
            }
        }
        .ifLet(\.$path, action: /Action.path) { }
    }
}

struct AppView: View {
    var store: StoreOf<AppFeature>

    @ObservedObject var viewStore: ViewStoreOf<AppFeature>

    init(store: StoreOf<AppFeature>) {
        self.store = store
        viewStore = ViewStore(store) { $0 }
    }

    var body: some View {
        NavigationView {
            List {
                NavigationLinkStore(
                    store.scope(state: \.$path, action: AppFeature.Action.path),
                    state: /AppFeature.Path.State.devices,
                    action: AppFeature.Path.Action.devices,
                    onTap: {
                        viewStore.send(.showDevices)
                    },
                    destination: DevicesView.init(store:),
                    label: {
                        Label("Devices", systemImage: "iphone")
                    }
                )
                NavigationLinkStore(
                    store.scope(state: \.$path, action: AppFeature.Action.path),
                    state: /AppFeature.Path.State.counter,
                    action: AppFeature.Path.Action.counter,
                    onTap: {
                        viewStore.send(.showCounter)
                    },
                    destination: AppCounterView.init(store:),
                    label: {
                        Label("Counter", systemImage: "timer")
                    }
                )
                NavigationLinkStore(
                    store.scope(state: \.$path, action: AppFeature.Action.path),
                    state: /AppFeature.Path.State.contact,
                    action: AppFeature.Path.Action.contact,
                    onTap: {
                        viewStore.send(.showContact)
                    },x
                    destination: ContactsView.init(store:),
                    label: {
                        Label("Contact", systemImage: "person")
                    }
                )
            }
            .navigationTitle("Settings")
            .frame(maxHeight: .infinity)
        }
    }
}

struct AppViewPreviewProvider: PreviewProvider {
    static var previews: some View {
        AppView(store: .init(initialState: .init()) {
            AppFeature()
                ._printChanges()
        })
    }
}
