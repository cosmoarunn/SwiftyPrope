//
//  HomeTabBarController.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 13/12/2024.
//

import Foundation
import UIKit

class HomeTabBarController: UITabBarController {
    
    private let appState: AppStateImposer
    
    
    init(appState: AppStateImposer)  {
        self.appState = appState
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Tabs: Int {
        case chatList = 0
        case calls = 1
        case stories = 2

        var title: String {
            switch self {
            case .chatList:
                return PropeLocalizedString(
                    "CHAT_LIST_TITLE_INBOX",
                    comment: "Title for the chat list's default mode."
                )
            case .calls:
                return PropeLocalizedString(
                    "CALLS_LIST_TITLE",
                    comment: "Title for the calls list view."
                )
            case .stories:
                return PropeLocalizedString(
                    "STORIES_TITLE",
                    comment: "Title for the stories view."
                )
            }
        }

        var image: UIImage? {
            switch self {
            case .chatList:
                return UIImage(imageLiteralResourceName: "tab-chats")
            case .calls:
                return UIImage(named: "tab-calls")
            case .stories:
                return UIImage(named: "tab-stories")
            }
        }

        var selectedImage: UIImage? {
            switch self {
            case .chatList:
                return UIImage(named: "tab-chats")
            case .calls:
                return UIImage(named: "tab-calls")
            case .stories:
                return UIImage(named: "tab-stories")
            }
        }

        var tabBarItem: UITabBarItem {
            return UITabBarItem(
                title: title,
                image: image,
                selectedImage: selectedImage
            )
        }

        var tabIdentifier: String {
            switch self {
            case .chatList:
                return "chats"
            case .calls:
                return "calls"
            case .stories:
                return "stories"
            }
        }
    }
    
    
    
}
