//
//  DevicesFeature.swift
//  Counter-SwiftUI
//
//  Created by Fachri Febrian on 18/12/2024.
//

import ComposableArchitecture
import IdentifiedCollections
import SwiftUI

struct DevicesFeature: Reducer {
    struct State: Equatable {
        var devices: IdentifiedArrayOf<Device> = []
        var deletionRunning = false
    }

    enum Action: Equatable {
        case load
        case devicesReceived([Device])
        case deleteDevices(IndexSet)
    }

//    @Dependency(\.trustService) var trustService

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .load:
                return .run { send in
                    do {
//                        let devices = try await trustService.getDevices(for: "X114428530")
                        await send(.devicesReceived([]))
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            case let .devicesReceived(devices):
                state.devices = IdentifiedArray(uniqueElements: devices)
                state.deletionRunning = false
                return .none
            case let .deleteDevices(indexSet):
                let devicesToDelete = indexSet.map { offset in
                    state.devices[offset]
                }
                state.devices.remove(atOffsets: indexSet)
                state.deletionRunning = true

                return .none
//                return .run { send in
//                    do {
//                        for device in devicesToDelete {
//                            let deviceIdentifier = device.registration.deviceIdentifier.replacingOccurrences(
//                                of: "+",
//                                with: "%2B"
//                            )
//                            try await trustService.deleteDevice(
//                                userIdentifier: "X114428530",
//                                deviceIdentifier: deviceIdentifier
//                            )
//                        }
//                    } catch {
//                        // Error Handling
//                    }
//
//                    do {
//                        let devices = try await trustService.getDevices(for: "X114428530")
//                        await send(.devicesReceived(devices))
//                    } catch {
//                        print(error.localizedDescription)
//                    }
//                }
            }
        }
    }
}

struct DevicesView: View {
    var store: StoreOf<DevicesFeature>

    @ObservedObject var viewStore: ViewStoreOf<DevicesFeature>

    init(store: StoreOf<DevicesFeature>) {
        self.store = store
        viewStore = ViewStore(store) { $0 }
    }

    var body: some View {
        VStack {
            List {
                ForEach(viewStore.devices) { device in
                    VStack {
                        Text(device.name)

                        Text(device.type)
                            .font(.footnote)
                            .foregroundColor(Color.black)

                        Text(device.createdAt.description)
                            .font(.footnote)
                            .foregroundColor(Color.black)
                    }
                }
                .onDelete(perform: delete(at:))
            }
            .disabled(viewStore.deletionRunning)
//            .overlay {
//                if viewStore.deletionRunning {
//                    VStack {
//                        Spacer()
//                        HStack(alignment: .bottom) {
//                            Spacer()
//                            VStack(spacing: 16) {
//                                ProgressView()
//                                Text("Lade Inhalte...")
//                            }
//                            .foregroundColor(Color.black)
//                            .font(.footnote)
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(16)
//                            Spacer()
//                        }
//                        Spacer()
//                    }
//                }
//            }
        }
        .navigationTitle("Devices")
        .onAppear {
            viewStore.send(.load)
        }
    }

    func delete(at offsets: IndexSet) {
        viewStore.send(.deleteDevices(offsets))
    }
}

struct Device: Identifiable, Equatable {
    let id: UUID

    init() {
        @Dependency(\.uuid) var uuidGenerator

        id = uuidGenerator()
    }

    var name: String {
        "registration.deviceIdentifier"
    }

    var type: String {
        ""
    }

    var createdAt: Date {
        Date()
    }
}
