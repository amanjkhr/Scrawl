import Cocoa
import Carbon

private func hotKeyHandler(_ nextHandler: EventHandlerCallRef?, _ theEvent: EventRef?, _ userData: UnsafeMutableRawPointer?) -> OSStatus {
    GlobalHotkeyManager.shared.toggleAction?()
    return noErr
}

final class GlobalHotkeyManager {
    static let shared = GlobalHotkeyManager()
    
    var toggleAction: (() -> Void)?
    private var hotKeyRef: EventHotKeyRef?
    
    private init() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetEventDispatcherTarget(), hotKeyHandler, 1, &eventType, nil, nil)
    }
    
    func register(keyCode: UInt32, carbonModifiers: UInt32) {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
        
        let hotKeyID = EventHotKeyID(signature: 12345, id: 1)
        RegisterEventHotKey(keyCode, carbonModifiers, hotKeyID, GetEventDispatcherTarget(), 0, &hotKeyRef)
    }
}
