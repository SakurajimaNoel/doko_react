import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/global/entity/storage-resource/storage_resource.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:equatable/equatable.dart';

enum PollOption {
  invalid(
    value: "",
    ind: -1,
  ),

  optionA(
    value: "OPTION_A",
    ind: 0,
  ),
  optionB(
    value: "OPTION_B",
    ind: 1,
  ),
  optionC(
    value: "OPTION_C",
    ind: 2,
  ),
  optionD(
    value: "OPTION_D",
    ind: 3,
  ),
  optionE(
    value: "OPTION_E",
    ind: 4,
  );

  const PollOption({
    required this.value,
    required this.ind,
  });

  final String value;
  final int ind;

  factory PollOption.fromOptionString(String optionString) {
    for (var option in PollOption.values) {
      if (option.value == optionString) return option;
    }

    return PollOption.invalid;
  }

  factory PollOption.fromIndex(int index) {
    for (var option in PollOption.values) {
      if (option.ind == index) return option;
    }

    return PollOption.invalid;
  }
}

class OptionEntity extends Equatable {
  const OptionEntity({
    required this.optionValue,
    required this.voteCount,
    required this.option,
  });

  // actual value of option
  final String optionValue;
  final int voteCount;
  final PollOption option;

  OptionEntity copyWith({int? voteCount, String? optionValue}) {
    return OptionEntity(
      optionValue: optionValue ?? this.optionValue,
      voteCount: voteCount ?? this.voteCount,
      option: option,
    );
  }

  @override
  List<Object?> get props => [voteCount];
}

class PollEntity implements GraphEntityWithUserAction {
  PollEntity({
    required this.id,
    required this.createdOn,
    required this.createdBy,
    required this.likesCount,
    required this.commentsCount,
    required this.comments,
    required this.userLike,
    required this.usersTagged,
    required this.question,
    required this.userVote,
    required this.options,
    required this.activeTill,
  });

  PollOption? userVote;

  void updateOptions(List<OptionEntity> newOptions) {
    options = newOptions;
  }

  void updateUserVote(PollOption vote) {
    userVote = vote;
  }

  void addVote(int index) {
    if (userVote != null) {
      var prevOption = options[userVote!.ind];
      int newVoteCount = prevOption.voteCount - 1;
      if (newVoteCount < 0) newVoteCount = 0;

      options[userVote!.ind] = prevOption.copyWith(
        voteCount: newVoteCount,
      );
    }

    var option = options[index];
    options[index] = option.copyWith(
      voteCount: option.voteCount + 1,
    );

    userVote = option.option;
  }

  // called when adding vote failed
  void removeVote() {
    if (userVote != null) {
      var prevOption = options[userVote!.ind];
      int newVoteCount = prevOption.voteCount - 1;
      if (newVoteCount < 0) newVoteCount = 0;

      options[userVote!.ind] = prevOption.copyWith(
        voteCount: newVoteCount,
      );
    }

    userVote = null;
  }

  List<OptionEntity> options;

  bool get isActive => activeTill.isAfter(DateTime.now());
  bool get isEnded => activeTill.isBefore(DateTime.now());

  int get totalVotes {
    int count = 0;
    for (var option in options) {
      count += option.voteCount;
    }
    return count;
  }

  /// getter used to send payload to other clients
  List<int> get getVotes {
    List<int> votes = [];
    for (var option in options) {
      votes.add(option.voteCount);
    }

    return votes;
  }

  /// used when remote payload is received
  void updateVotes(List<int> votes) {
    for (int i = 0; i < options.length; i++) {
      var option = options[i];

      options[i] = option.copyWith(
        voteCount: votes[i],
      );
    }
  }

  final DateTime activeTill;

  @override
  final String id;
  @override
  final DateTime createdOn;
  @override
  final String createdBy;
  @override
  final List<UsersTagged> usersTagged;

  final String question;

  @override
  int likesCount;
  @override
  int commentsCount;
  @override
  bool userLike;
  @override
  Nodes comments;

  @override
  void updateUserLikeStatus(bool userLike) {
    this.userLike = userLike;
  }

  @override
  void updateLikeCount(int likesCount) {
    this.likesCount = likesCount;
  }

  @override
  void updateCommentsCount(int newCommentsCount) {
    commentsCount = newCommentsCount;
  }

  static Future<PollEntity> createEntity({required Map map}) async {
    final String createdByUsername = map["createdBy"]["username"];
    String key = generateUserNodeKey(createdByUsername);

    final UserGraph graph = UserGraph();
    if (!graph.containsKey(key)) {
      UserEntity user = await UserEntity.createEntity(map: map["createdBy"]);
      String key = generateUserNodeKey(user.username);

      graph.addEntity(key, user);
    }

    bool userLike = (map["likedBy"] as List).length == 1;

    List<UsersTagged> usersTagged = [];
    if (map["usersTagged"] != null) {
      for (var el in (map["usersTagged"] as List)) {
        String username = el["username"];
        StorageResource profilePicture =
            await StorageResource.createStorageResource(el["profilePicture"]);
        usersTagged.add(UsersTagged(
          username: username,
          profilePicture: profilePicture,
        ));
      }
    }

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

    return PollEntity(
      id: map["id"],
      createdOn: DateTime.parse(map["createdOn"]).toLocal(),
      createdBy: key,
      comments: Nodes.empty(),
      likesCount: map["likedByConnection"]["totalCount"],
      commentsCount: map["commentsConnection"]["totalCount"],
      userLike: userLike,
      usersTagged: usersTagged,
      question: map["question"],
      userVote: userVote,
      options: pollOptions,
      activeTill: DateTime.parse(map["activeTill"]).toLocal(),
    );
  }

  @override
  String getNodeKey() {
    return generatePollNodeKey(id);
  }
}
