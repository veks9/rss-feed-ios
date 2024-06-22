//
//  Localization.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 22.06.2024..
//

import Foundation

enum Localization: String {
    
    // MARK: - Feed List
    
    case feedListNavigationTitle = "feed_list_navigation_title"
    case feedListEmptyDescription = "feed_list_empty_description"
    case feedListEmptyFavoritesDescription = "feed_list_empty_favorites_description"
    case feedListAddNewFeedTitle = "feed_list_add_new_feed_title"
    case feedListAddNewFeedPlaceholder = "feed_list_add_new_feed_placeholder"
    case feedListAddNewFeedSubmitButtonTitle = "feed_list_add_new_feed_submit_button_title"
    case feedListAddNewFeedCancelButtonTitle = "feed_list_add_new_feed_cancel_button_title"
    case feedListCellDeleteActionTitle = "feed_list_cell_delete_action_title"
    case feedListFeedAlreadyExists = "feed_list_feed_already_exists"
    case feedListFeedAddingFailure = "feed_list_feed_adding_failure"
    case feedListFeedFetchingFailure = "feed_list_feed_fetching_failure"
    case feedListFeedDeletingFailure = "feed_list_feed_deleting_failure"
    case feedListFeedFavoritingFailure = "feed_list_feed_favoriting_failure"
    case feedListFeedsSectionTitle = "feed_list_feeds_section_title"
    case feedListFavoritesSectionTitle = "feed_list_favorites_section_title"
    
    // MARK: - Feed Items List
    
    case feedItemsListEmptyDescription = "feed_items_list_empty_description"
    case feedItemsListBrokenArticleLinkTitle = "feed_items_list_broken_article_link_title"
    case feedItemsListFetchingError = "feed_items_list_fetching_error"
    case feedItemsListNotificationsError = "feed_items_list_notifications_error"
    case feedItemsListFavoritingError = "feed_items_list_favoriting_error"
    
    // MARK: - Notifications
    
    case notificationNewArticlesBody = "notification_new_articles_body"
}

// MARK: - Internal functions

extension Localization {
    func localized(_ args: CVarArg...) -> String {
        rawValue.localized(args)
    }
}
