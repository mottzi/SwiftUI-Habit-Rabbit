import Foundation

//extension UserDefaults {
//    func set<T: Codable>(_ object: T, forKey key: String) {
//        guard let data = try? JSONEncoder().encode(object) else { return }
//        set(data, forKey: key)
//    }
//    
//    func object<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
//        guard let data = data(forKey: key) else { return nil }
//        return try? JSONDecoder().decode(type, from: data)
//    }
//}
