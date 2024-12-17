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
    @Reducer(state: .equatable)
    enum Destination {
        case addContact(AddContactFeature)
        case alert(AlertState<ContactsFeature.Action.Alert>)
    }
    
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        var path = StackState<ContactDetailFeature.State>()
        
        var contacts: IdentifiedArrayOf<Contact> = []
    }
    
    enum Action {
        case addButtonTapped
        case deleteButtonTapped(id: Contact.ID)
        case destination(PresentationAction<Destination.Action>)
        case path(StackAction<ContactDetailFeature.State, ContactDetailFeature.Action>)
        enum Alert: Equatable {
            case confirmDeletion(id: Contact.ID)
        }
    }
    
    @Dependency(\.uuid) var uuid
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.destination = .addContact(
                    AddContactFeature.State(
                        contact: Contact(id: self.uuid(), name: "")
                    )
                )
                return .none
                
                
            case let .destination(.presented(.addContact(.delegate(.saveContact(contact))))):
                
                state.contacts.append(contact)
                return .none
                
            case let .destination(.presented(.alert(.confirmDeletion(id: id)))):
                
                state.contacts.remove(id: id)
                return .none
                
            case .destination:
                return .none
                
            case let .deleteButtonTapped(id: id):
                state.destination = .alert(.deleteConfirmation(id: id))
                return .none
                
            case let .path(.element(id: id, action: .delegate(.confirmDeletion))):
              guard let detailState = state.path[id: id]
              else { return .none }
              state.contacts.remove(id: detailState.contact.id)
              return .none
                
            case .path:
                return .none
                
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .forEach(\.path, action: \.path) {
            ContactDetailFeature()
        }
    }
    
}

extension AlertState where Action == ContactsFeature.Action.Alert {
    static func deleteConfirmation(id: UUID) -> Self {
        Self {
            TextState("Are you sure?")
        } actions: {
            ButtonState(role: .destructive, action: .confirmDeletion(id: id)) {
                TextState("Delete")
            }
        }
    }
}


struct ContactsView: View {
    @State private var showAlert = false
    
    @Perception.Bindable var store: StoreOf<ContactsFeature>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.contacts) { contact in
                    contactRow(contact: contact)
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
//        } destination: { store in
//            ContactDetailView(store: store)
//        }
        .sheet(
            item: $store.scope(state: \.destination?.addContact, action: \.destination.addContact),
            content: { addContactStore in
                NavigationView {
                    AddContactView(store: addContactStore)
                }
            }
        )
        .alert2($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
    
    private func contactRow(contact: Contact) -> some View {
        NavigationLink(
            destination: ContactDetailView(
                store: Store(
                    initialState: ContactDetailFeature.State(contact: contact)
                ) {
                    ContactDetailFeature()
                }
            ).onAppear {
//                store.
                print("#HAHAHA")
            }
        ) {
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
        }.buttonStyle(.borderless)
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
