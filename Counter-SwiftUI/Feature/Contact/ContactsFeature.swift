//
//  ContactsFeature.swift
//  Counter-SwiftUI
//
//  Created by Fachri Febrian on 17/12/2024.
//

import ComposableArchitecture
import SwiftUI

struct Contact: Equatable, Identifiable {
    let id: UUID
    var name: String
}

@Reducer
struct ContactsFeature {
    
    @ObservableState
    struct State: Equatable {
        @Presents var addContact: AddContactFeature.State?
        @Presents var alert: AlertState<Action.Alert>?
        var contacts: IdentifiedArrayOf<Contact> = []
    }
    
    enum Action {
        case addButtonTapped
        case addContact(PresentationAction<AddContactFeature.Action>)
        case deleteButtonTapped(id: Contact.ID)
        case alert(PresentationAction<Alert>)
        enum Alert: Equatable {
            case confirmDeletion(id: Contact.ID)
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
              state.addContact = AddContactFeature.State(
                contact: Contact(id: UUID(), name: "")
              )
              return .none
              
            case let .addContact(.presented(.delegate(.saveContact(contact)))):
              state.contacts.append(contact)
              return .none
              
            case .addContact:
              return .none
              
            case let .alert(.presented(.confirmDeletion(id: id))):
              state.contacts.remove(id: id)
              return .none
              
            case .alert:
              return .none
              
            case let .deleteButtonTapped(id: id):
              state.alert = AlertState {
                TextState("Are you sure?")
              } actions: {
                ButtonState(role: .destructive, action: .confirmDeletion(id: id)) {
                  TextState("Delete")
                }
              }
              return .none
            }
          }
          .ifLet(\.$addContact, action: \.addContact) {
            AddContactFeature()
          }
          .ifLet(\.$alert, action: \.alert)
    }
}


struct ContactsView: View {
    @State private var showAlert = false

    @Perception.Bindable var store: StoreOf<ContactsFeature>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.contacts) { contact in
                    HStack {
                      Text(contact.name)
                      Spacer()
                      Button {
                        store.send(.deleteButtonTapped(id: contact.id))
                      } label: {
                        Image(systemName: "trash")
                          .foregroundColor(.red)
                      }
                    }
                }
            }
            .navigationTitle("Contacts")
            .toolbar {
                ToolbarItem {
                    Button {
                        store.send(.addButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(
            store: store.scope(state: \.$addContact, action: \.addContact), 
            content: { addContactStore in
                NavigationView {
                    AddContactView(store: addContactStore)
                }
            }
        )
        .alert2($store.scope(state: \.alert, action: \.alert))
    }
}

#Preview {
    ContactsView(
        store: Store(
            initialState: ContactsFeature.State(
                contacts: [
                    Contact(id: UUID(), name: "Blob"),
                    Contact(id: UUID(), name: "Blob Jr"),
                    Contact(id: UUID(), name: "Blob Sr"),
                ]
            ), 
            reducer: {
                ContactsFeature()
            }
        )
    )
}
