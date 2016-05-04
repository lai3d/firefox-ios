/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared

public protocol RecentlyClosedTabs {
    var tabs: [ClosedTab] { get }
    var count: Int { get }
    func addTab(url: NSURL, title: String?, faviconURL: String?)
    func clearTabs()
}

public class RecentlyClosedTabsStore: RecentlyClosedTabs {
    lazy public var tabs: [ClosedTab] = {
        guard let recentlyClosedTabs = NSUserDefaults.standardUserDefaults().objectForKey("recentlyClosedTabs") else {
            return []
        }
        return NSKeyedUnarchiver.unarchiveObjectWithData(recentlyClosedTabs as! NSData) as! [ClosedTab]
    }()

    public var count: Int {
        guard let tabsArray = NSUserDefaults.standardUserDefaults().objectForKey("recentlyClosedTabs") else {
            return 0
        }
        return NSKeyedUnarchiver.unarchiveObjectWithData(tabsArray as! NSData)?.count ?? 0
    }

    public init() {
    }

    public func addTab(url: NSURL, title: String?, faviconURL: String?) {
        let recentlyClosedTab = ClosedTab(url: url, title: title ?? "", faviconURL: faviconURL ?? "")
        var tabsArray = NSUserDefaults.standardUserDefaults().objectForKey("recentlyClosedTabs")
        if tabsArray == nil {
            var newArray = [ClosedTab]()
            newArray.append(recentlyClosedTab)
            tabsArray = newArray
        } else {
            var unarchivedTabsArray = NSKeyedUnarchiver.unarchiveObjectWithData(tabsArray as! NSData) as! [ClosedTab]
            unarchivedTabsArray.append(recentlyClosedTab)
            tabsArray = unarchivedTabsArray
        }
        let archivedTabsArray = NSKeyedArchiver.archivedDataWithRootObject(tabsArray!)
        NSUserDefaults.standardUserDefaults().setObject(archivedTabsArray, forKey: "recentlyClosedTabs")
    }

    public func clearTabs() {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "recentlyClosedTabs")
    }
}

public class ClosedTab: NSObject, NSCoding {
    public let url: NSURL
    public let title: String?
    public let faviconURL: String?

    var jsonDictionary: [String: AnyObject] {
        let json: [String: AnyObject] = [
            "title": title ?? "",
            "url": url,
            "faviconURL": faviconURL ?? "",
        ]
        return json
    }

    init(url: NSURL, title: String?, faviconURL: String?) {
        assert(NSThread.isMainThread())

        self.title = title
        self.url = url
        self.faviconURL = faviconURL
        super.init()
    }

    required convenience public init?(coder: NSCoder) {
        guard let url = coder.decodeObjectForKey("url") as? NSURL,
              let faviconURL = coder.decodeObjectForKey("faviconURL") as? String,
              let title = coder.decodeObjectForKey("title") as? String else { return nil }

        self.init(
            url: url,
            title: title,
            faviconURL: faviconURL
        )
    }

    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(url, forKey: "url")
        coder.encodeObject(faviconURL, forKey: "faviconURL")
        coder.encodeObject(title, forKey: "title")
    }
}

public class MockRecentlyClosedTabsStore: RecentlyClosedTabsStore {
}
