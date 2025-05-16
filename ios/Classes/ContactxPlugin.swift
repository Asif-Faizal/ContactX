import Flutter
import UIKit
import Contacts

public class ContactxPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "contactx", binaryMessenger: registrar.messenger())
    let instance = ContactxPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "getContacts":
      getContacts { contactsList, error in
        if let error = error {
          result(FlutterError(code: "CONTACTS_ERROR", message: "Failed to get contacts: \(error.localizedDescription)", details: nil))
          return
        }
        result(contactsList)
      }
    case "checkPermission":
      checkContactPermission { status in
        result(status)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func checkContactPermission(completion: @escaping (String) -> Void) {
    let authStatus = CNContactStore.authorizationStatus(for: .contacts)
    
    switch authStatus {
    case .authorized:
      completion("authorized")
    case .denied:
      completion("denied")
    case .restricted:
      completion("restricted")
    case .notDetermined:
      completion("notDetermined")
    @unknown default:
      completion("unknown")
    }
  }
  
  private func cleanPhoneNumber(_ phoneNumber: String) -> String {
    let pattern = "[\\s\\-\\(\\)]"
    let regex = try? NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(location: 0, length: phoneNumber.utf16.count)
    return regex?.stringByReplacingMatches(in: phoneNumber, options: [], range: range, withTemplate: "") ?? phoneNumber
  }

  private func getContacts(completion: @escaping ([[String: String]]?, Error?) -> Void) {
    let contactStore = CNContactStore()
    var contacts: [[String: String]] = []
    
    // First check current authorization status
    let authStatus = CNContactStore.authorizationStatus(for: .contacts)
    
    switch authStatus {
    case .authorized:
      // Already authorized, proceed to fetch contacts
      fetchContacts(contactStore: contactStore, completion: completion)
    case .denied, .restricted:
      // Permission previously denied or restricted
      completion(nil, NSError(domain: "ContactxPlugin", code: 1, userInfo: [NSLocalizedDescriptionKey: "Permission denied to access contacts"]))
    case .notDetermined:
      // Need to request permission
      contactStore.requestAccess(for: .contacts) { granted, error in
        if let error = error {
          completion(nil, error)
          return
        }
        
        if granted {
          self.fetchContacts(contactStore: contactStore, completion: completion)
        } else {
          completion(nil, NSError(domain: "ContactxPlugin", code: 1, userInfo: [NSLocalizedDescriptionKey: "Permission denied to access contacts"]))
        }
      }
    @unknown default:
      completion(nil, NSError(domain: "ContactxPlugin", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unknown authorization status"]))
    }
  }
  
  private func fetchContacts(contactStore: CNContactStore, completion: @escaping ([[String: String]]?, Error?) -> Void) {
    var contacts: [[String: String]] = []
    
    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
    
    do {
      try contactStore.enumerateContacts(with: request) { contact, _ in
        if !contact.phoneNumbers.isEmpty {
          let name = [contact.givenName, contact.familyName].filter { !$0.isEmpty }.joined(separator: " ")
          let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
          let cleanedNumber = self.cleanPhoneNumber(phoneNumber)
          contacts.append(["name": name, "number": cleanedNumber])
        }
      }
      completion(contacts, nil)
    } catch let error {
      completion(nil, error)
    }
  }
}
