import 'package:shared_preferences/shared_preferences.dart';

class LibraryLocalSource {
  static const String _bookmarkedResourcesKey = 'bookmarked_resources';

  Future<List<String>> getBookmarkedResourceIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_bookmarkedResourcesKey) ?? [];
  }

  Future<void> toggleResourceBookmark(String resourceId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(_bookmarkedResourcesKey) ?? [];

    if (bookmarks.contains(resourceId)) {
      bookmarks.remove(resourceId);
    } else {
      bookmarks.add(resourceId);
    }

    await prefs.setStringList(_bookmarkedResourcesKey, bookmarks);
  }

  Future<bool> isResourceBookmarked(String resourceId) async {
    final bookmarks = await getBookmarkedResourceIds();
    return bookmarks.contains(resourceId);
  }
}
