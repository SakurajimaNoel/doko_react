/// this class is used for cursor pagination
/// all one to many and many to many relationship object
/// will have this instance
/// instead of updating this class just create a new instance
/// of this class after fetching more records
class PageInfo {
  const PageInfo({
    required this.endCursor,
    required this.hasNextPage,
  });

  PageInfo.empty()
      : endCursor = null,
        hasNextPage = false;

  final String? endCursor;
  final bool hasNextPage;

  static PageInfo createEntity({required Map map}) {
    return PageInfo(
      endCursor: map["endCursor"],
      hasNextPage: map["hasNextPage"],
    );
  }
}
