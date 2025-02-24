import 'package:doko_react/features/user-profile/domain/entity/poll/poll_entity.dart';

/// this handles user like action on nodes
class UserActionModel {
  const UserActionModel({
    required this.userLike,
    required this.likesCount,
    required this.commentsCount,
  });

  final bool userLike;
  final int likesCount;

  final int commentsCount;

  static UserActionModel createModel(Map map) {
    bool userLike = (map["likedBy"] as List).length == 1;

    return UserActionModel(
      userLike: userLike,
      likesCount: map["likedByConnection"]["totalCount"],
      commentsCount: map["commentsConnection"]["totalCount"],
    );
  }
}

class UserPollVoteModel {
  const UserPollVoteModel({
    required this.userVote,
    required this.options,
  });

  final PollOption? userVote;
  final List<OptionEntity> options;

  static UserPollVoteModel createModel(Map map) {
    PollOption? userVote;
    if (map.containsKey("selfVote")) {
      List votes = map["selfVote"]["edges"] as List;
      if (votes.isNotEmpty) {
        userVote =
            PollOption.fromOptionString(votes[0]["properties"]["option"]);
      }
    }

    List optionsList = map["options"];
    List<OptionEntity> pollOptions = [];
    for (int i = 0; i < optionsList.length; i++) {
      String optionString = optionsList[i].toString();
      PollOption option = PollOption.fromIndex(i);

      String key = option.name;
      int voteCount = map[key]["totalCount"];

      pollOptions.add(OptionEntity(
        optionValue: optionString,
        voteCount: voteCount,
        option: option,
      ));
    }
    return UserPollVoteModel(
      userVote: userVote,
      options: pollOptions,
    );
  }
}
