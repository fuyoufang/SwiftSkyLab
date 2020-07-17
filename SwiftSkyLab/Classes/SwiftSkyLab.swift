
extension NSNotification.Name {
    public static let SkyLabWillRunTestNotification = NSNotification.Name(rawValue: "SwiftSkyLabWillRunTestNotification")
    public static let SkyLabDidRunTestNotification = NSNotification.Name(rawValue: "SwiftSkyLabDidRunTestNotification")
    public static let SkyLabDidResetTestNotification = NSNotification.Name(rawValue: "SwiftSkyLabDidResetTestNotification")
}

public let SkyLabConditionKey = "com.swiftskylab.condition"
public let SkyLabActiveVariablesKey = "com.swiftskylab.active-variables"
public let SkyLabChoiceKey = SkyLabConditionKey

public class SwiftSkyLab {

    public class func abTest(_ name: String,
                             A: () -> Void,
                             B: () -> Void) {
        splitTest(name, conditions: ["A", "B"]) { (choice) in
            if choice == "A" {
                A()
            } else {
                B()
            }
        }
    }
    
    /*
     原框架中 conditions 的类型为 NSFastEnumeration
     看能否将下面的两种情况合并为一个
     */
    public class func splitTest<Item: Hashable & Comparable>(
        _ name: String,
        conditions: [Item : Double],
        block: (Item?) -> Void) {
        var condition = UserDefaults.standard.object(forKey: UserDefaultsKey(name: name)) as? Item
        if condition == nil || conditions.keys.firstIndex(of: condition!) == nil {
            condition = RandomKeyWithWeightedValues(fromDictionary: conditions)
        }
        
        splitTest(name, choice: condition, block: block)
    }
    
    public class func splitTest<Item: Comparable>(
        _ name: String,
        conditions: [Item],
        block: (Item?) -> Void) {
        var condition = UserDefaults.standard.object(forKey: UserDefaultsKey(name: name)) as? Item
        if condition == nil || conditions.firstIndex(of: condition!) == nil {
            condition = RandomValue(fromArray: conditions)
        }
        
        splitTest(name, choice: condition, block: block)
    }
    
    class func splitTest<Item: Comparable>(_ name: String,
                                choice: Item?,
                                block: (Item?) -> Void) {
        let needsSynchronization = choice == (UserDefaults.standard.object(forKey: UserDefaultsKey(name: name)) as? Item)
        UserDefaults.standard.set(choice, forKey: UserDefaultsKey(name: name))
        if needsSynchronization {
            UserDefaults.standard.synchronize()
        }
        
        var userInfo = [String : Item]()
        userInfo[SkyLabConditionKey] = choice

        NotificationCenter.default.post(name: .SkyLabWillRunTestNotification, object: name, userInfo: userInfo)
        block(choice)
        NotificationCenter.default.post(name: .SkyLabDidRunTestNotification, object: name, userInfo: userInfo)
    }
        
    /*
    原框架中 conditions 的类型为 NSFastEnumeration
    看能否将下面的两种情况合并为一个
    */
    public class func multivariateTest<Item: Comparable>(
        _ name: String,
        variables: [Item : Double],
        block: (Set<Item>) -> Void) {
        var activeVariables: Set<Item>
        if let items = UserDefaults.standard.object(forKey: UserDefaultsKey(name: name)) as? [Item] {
            activeVariables = Set(items)
        } else {
            activeVariables = Set<Item>()
        }
        
        if activeVariables.intersection(Array(variables.keys)).count == 0 {
            for (key, weightedValues) in variables {
                if RandomBinaryChoice(withProbability: weightedValues) {
                    activeVariables.insert(key)
                }
            }
        }
        
        multivariateTest(name, choice: activeVariables, block: block)
    }
    
    
    public class func multivariateTest<Item: Comparable>(
        _ name: String,
        variables: [Item],
        block: (Set<Item>) -> Void) {
        var activeVariables: Set<Item>
        if let items = UserDefaults.standard.object(forKey: UserDefaultsKey(name: name)) as? [Item] {
            activeVariables = Set(items)
        } else {
            activeVariables = Set<Item>()
        }
        
        if activeVariables.intersection(Array(variables)).count == 0 {
            for variable in variables {
                if RandomBinaryChoice() {
                    activeVariables.insert(variable)
                }
            }
        }
        
        multivariateTest(name, choice: activeVariables, block: block)
    }
    
    class func multivariateTest<Item: Comparable>(
        _ name: String,
        choice: Set<Item>,
        block: (Set<Item>) -> Void) {
        
        var needsSynchronization = false
        if let items = (UserDefaults.standard.object(forKey: UserDefaultsKey(name: name)) as? [Item]) {
            needsSynchronization = choice == Set(items)
        }
        UserDefaults.standard.set(Array(choice), forKey: UserDefaultsKey(name: name))
        if needsSynchronization {
            UserDefaults.standard.synchronize()
        }
        
        var userInfo = [String : Set<Item>]()
        userInfo[SkyLabConditionKey] = choice

        NotificationCenter.default.post(name: .SkyLabWillRunTestNotification, object: name, userInfo: userInfo)
        block(choice)
        NotificationCenter.default.post(name: .SkyLabDidRunTestNotification, object: name, userInfo: userInfo)
    }

    public class func resetTest(_ name: String) {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey(name: name))
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: .SkyLabDidResetTestNotification, object: name)
    }
}

func UserDefaultsKey(name: String) -> String {
    let UserDefaultsKeyFormat = "SkyLab-"
    return "\(UserDefaultsKeyFormat)\(name)"
}

func RandomValue<Item>(fromArray array: [Item]) -> Item?{
    if array.count < 1 {
        return nil
    }
    
    return array[Int(arc4random_uniform(UInt32(array.count)))]
}

func RandomKeyWithWeightedValues<Key: Hashable>(fromDictionary dictionary: [Key : Double]) -> Key? {
    guard dictionary.count > 0 else {
        return nil
    }
    
    var weightedSums = [Double]()
    let keys: [Key] = Array(dictionary.keys)
    var total: Double = 0
    for key in keys {
        total = total + dictionary[key]!
        weightedSums.append(total)
    }
    
    if !hasSrand {
        srand48(Int(Date().timeIntervalSince1970))
        hasSrand = true
    }
    
    let random = drand48() * total
    for (index, item) in weightedSums.enumerated() {
        if random < item {
            return keys[index]
        }
    }
    return nil
}

func RandomBinaryChoice(withProbability probability: Double = 0.5) -> Bool {
    
    if !hasSrand {
        srand48(Int(Date().timeIntervalSince1970))
        hasSrand = true
    }
    return drand48() <= probability
}


var hasSrand: Bool = false
