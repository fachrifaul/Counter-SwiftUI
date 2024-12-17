import ComposableArchitecture
import SwiftUI

@available(iOS 14, *)
extension View {
  /// Presents an alert when a piece of optional state held in a store becomes non-`nil`.
  public func alert2<Action>(_ item: Binding<Store<AlertState<Action>, Action>?>) -> some View {
    
    // For iOS 15 and later, use the new alert API with presenting parameter.
    if #available(iOS 15, *) {
        let store = item.wrappedValue
        let alertState = store?.withState { $0 }
      return self.alert(
        (alertState?.title).map(Text.init) ?? Text(verbatim: ""),
        isPresented: Binding(item),
        presenting: alertState,
        actions: { alertState in
          ForEach(alertState.buttons) { button in
            Button(role: button.role.map(ButtonRole.init)) {
              switch button.action.type {
              case let .send(action):
                if let action {
                  store?.send(action)
                }
              case let .animatedSend(action, animation):
                if let action {
                  store?.send(action, animation: animation)
                }
              }
            } label: {
              Text(button.label)
            }
          }
        },
        message: {
          $0.message.map(Text.init)
        }
      )
    } else {
      // For iOS 14, use the older alert API
        
        var store = item.wrappedValue
        let alertState = store?.withState { $0 }
      return self.alert(isPresented: Binding(
        get: { store != nil },
        set: { if !$0 { store = nil } }
      )) {
        Alert(
            title: (alertState?.title).map(Text.init) ?? Text(verbatim: ""),
          message: (alertState?.message).map(Text.init) ?? Text(verbatim: ""),
          primaryButton: .default((alertState?.buttons.first?.label).map(Text.init) ?? Text(verbatim: ""), action: {
            if let action = alertState?.buttons.first?.action {
                store?.send(action as! Action)
            }
          }),
          secondaryButton: .cancel()
        )
      }
    }
  }

  /// Presents a confirmation dialog when a piece of optional state held in a store becomes non-`nil`.
  public func confirmationDialog2<Action>(
    _ item: Binding<Store<ConfirmationDialogState<Action>, Action>?>
  ) -> some View {
    
    
    // For iOS 15 and later, use the new confirmationDialog API with presenting parameter.
    if #available(iOS 15, *) {
        let store = item.wrappedValue
        let confirmationDialogState = store?.withState { $0 }
      return self.confirmationDialog(
        (confirmationDialogState?.title).map(Text.init) ?? Text(verbatim: ""),
        isPresented: Binding(item),
        titleVisibility: (confirmationDialogState?.titleVisibility).map(Visibility.init)
          ?? .automatic,
        presenting: confirmationDialogState,
        actions: { confirmationDialogState in
          ForEach(confirmationDialogState.buttons) { button in
            Button(role: button.role.map(ButtonRole.init)) {
              switch button.action.type {
              case let .send(action):
                if let action {
                  store?.send(action)
                }
              case let .animatedSend(action, animation):
                if let action {
                  store?.send(action, animation: animation)
                }
              }
            } label: {
              Text(button.label)
            }
          }
        },
        message: {
          $0.message.map(Text.init)
        }
      )
    } else {
      // For iOS 14, fallback to an action sheet
        var store = item.wrappedValue
        let confirmationDialogState = store?.withState { $0 }
      return self.actionSheet(isPresented: Binding(
        get: { store != nil },
        set: { if !$0 { store = nil } }
      )) {
        ActionSheet(
          
          title: (confirmationDialogState?.title).map(Text.init) ?? Text(verbatim: ""),
        message: (confirmationDialogState?.message).map(Text.init) ?? Text(verbatim: ""),
          buttons: confirmationDialogState?.buttons.map { button in
            .default(Text(button.label)) {
                store?.send(button.action as! Action)
//              if let action = button.action {
//                  store?.send(action as! Action)
//              }
            }
          } ?? [.cancel()]
        )
      }
    }
  }
}
