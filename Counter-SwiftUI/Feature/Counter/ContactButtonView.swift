//
//  ContactButtonView.swift
//  Counter-SwiftUI
//
//  Created by Fachri Febrian on 17/12/2024.
//

import ComposableArchitecture
import SwiftUI

struct ContactButtonView: View {
    var body: some View {
        NavigationLink(
            destination: ContactsView(
                store: Store(
                    initialState: ContactsFeature.State(
                        contacts: [
                            Contact(id: UUID(), name: "Blob"),
                            Contact(id: UUID(), name: "Blob Jr"),
                            Contact(id: UUID(), name: "Blob Sr"),
                        ]
                    )
                ) {
                    ContactsFeature()
                }
            )
        ) {
            Text("Go to Contacts Screen")
                .padding()
        }.buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContactButtonView()
}
