//
//  ContactDetailFeature.swift
//  Counter-SwiftUI
//
//  Created by Fachri Febrian on 17/12/2024.
//

import ComposableArchitecture
import SwiftUI


@Reducer
struct ContactDetailFeature {
    
    @ObservableState
    struct State: Equatable {
        @Presents var alert: AlertState<Action.Alert>?
        let contact: Contact
    }
    
    enum Action {
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)
        case deleteButtonTapped
        enum Alert {
          case confirmDeletion
        }
        enum Delegate {
          case confirmDeletion
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .alert(.presented(.confirmDeletion)):
          return .run { send in
            await send(.delegate(.confirmDeletion))
            await self.dismiss()
          }
        case .alert:
            print("ALERT")
          return .none
        case .delegate:
          return .none
        case .deleteButtonTapped:
          state.alert = .confirmDeletion
          return .none
        }
      }
      .ifLet(\.$alert, action: \.alert)
    }
}

extension AlertState where Action == ContactDetailFeature.Action.Alert {
  static let confirmDeletion = Self {
    TextState("Are you sure?")
  } actions: {
    ButtonState(role: .destructive, action: .confirmDeletion) {
      TextState("Delete")
    }
  }
}

struct ContactDetailView: View {
    @Perception.Bindable var store: StoreOf<ContactDetailFeature>
    
    var body: some View {
        Form {
            Button("Delete") {
               store.send(.deleteButtonTapped)
             }
        }
        .navigationTitle(Text(store.contact.name))
        .alert2($store.scope(state: \.alert, action: \.alert))
    }
}


#Preview {
    NavigationView {
        ContactDetailView(
            store: Store(
                initialState: ContactDetailFeature.State(
                    contact: Contact(id: UUID(), name: "Blob")
                )
            ) {
                ContactDetailFeature()
            }
        )
    }
}
