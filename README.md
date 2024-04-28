# rss-feed-ios

### Overview
RSS reader. Add your desired RSS feeds using the plus button. Bell icon turns on the notifictions and star icon favorites them. There is pull to refresh functionality for refreshing articles. Tap on article opens a WebView. There is a background task set up to refresh feed items for feeds with notifications enabled, ensuring a minimum window of 15 minutes between each run.

### How to test a background task?
After the background task is submitted, set a breakpoint and in lldb debugger execute following command: 

`e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"org.hernaus.RSS-Feed.backgroundTask"]`

It has to be tested on a real device and make sure you have Background App Refresh setting turned on in system settings.

### Test RSS URLs
- https://www.index.hr/rss
- https://www.24sata.hr/feeds/aktualno.xml
- https://www.vecernji.hr/feeds/latest
- https://feeds.bbci.co.uk/news/world/rss.xml
- https://www.nytimes.com/svc/collections/v1/publish/https://www.nytimes.com/section/world/rss.xml
- https://www.aljazeera.com/xml/rss/all.xml
- https://defence-blog.com/feed/
- https://www.e-ir.info/feed/
- https://www.thecipherbrief.com/feed

### Screenshots
<img width="522" alt="image" src="https://github.com/veks9/rss-feed-ios/assets/81360929/5b586745-be24-4fb0-a1c3-30052407bebd">
<img width="522" alt="image" src="https://github.com/veks9/rss-feed-ios/assets/81360929/d5c6877c-b35a-4b72-a09d-44fbe9480237">
<img width="522" alt="image" src="https://github.com/veks9/rss-feed-ios/assets/81360929/c852f9b1-1fcb-4e58-afbe-c6d3cacd00af">
<img width="522" alt="image" src="https://github.com/veks9/rss-feed-ios/assets/81360929/7bc1aaef-ae9a-4966-bbf1-9f9320713ce4">

