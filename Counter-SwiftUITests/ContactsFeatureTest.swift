//
//  ContactsFeatureTest.swift
//  Counter-SwiftUITests
//
//  Created by Fachri Febrian on 17/12/2024.
//

import ComposableArchitecture
import XCTest
@testable import Counter_SwiftUI

final class ContactsFeatureTest: XCTestCase {
    
    func testAddFlow() async {
        let store = await TestStore(initialState: ContactsFeature.State()) {
            ContactsFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        
        await store.send(.addButtonTapped) {
            $0.destination = .addContact(
                AddContactFeature.State(
                    contact: Contact(id: UUID(0), name: "")
                )
            )
        }
        await store.send(\.destination.addContact.setName, "Paul") {
            $0.destination?.addContact?.contact.name = "Paul"
        }
        await store.send(\.destination.addContact.saveButtonTapped)
        await store.receive(
            \.destination.addContact.delegate.saveContact,
             Contact(id: UUID(0), name: "Paul")
        ) {
            $0.contacts = [
                Contact(id: UUID(0), name: "Paul")
            ]
        }
        await store.receive(\.destination.dismiss) {
            $0.destination = nil
        }
    }
    
    func testDeleteFlow() async {
        let store = await TestStore(
            initialState: ContactsFeature.State(
                contacts: [
                    Contact(id: UUID(0), name: "Fachri"),
                    Contact(id: UUID(1), name: "Paul"),
                ]
            )
        ) {
            ContactsFeature()
        }
        
        await store.send(.deleteButtonTapped(id: UUID(1))) {
            $0.destination = .alert(.deleteConfirmation(id: UUID(1)))
        }
        await store.send(.destination(.presented(.alert(.confirmDeletion(id: UUID(1)))))) {
            $0.contacts.remove(id: UUID(1))
            $0.destination = nil
            
        }
    }
    
}
