import RealmSwift

extension Object {
    
    func incrementID(specificRealmInstance: Realm) -> Int {
        let realm = specificRealmInstance
        return (realm.objects(Self.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
}
