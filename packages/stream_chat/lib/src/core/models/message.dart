import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:stream_chat/src/core/models/attachment.dart';
import 'package:stream_chat/src/core/models/message_state.dart';
import 'package:stream_chat/src/core/models/poll.dart';
import 'package:stream_chat/src/core/models/reaction.dart';
import 'package:stream_chat/src/core/models/user.dart';
import 'package:stream_chat/src/core/util/serializer.dart';
import 'package:uuid/uuid.dart';

part 'message.g.dart';

class _NullConst {
  const _NullConst();
}

const _nullConst = _NullConst();

/// The class that contains the information about a message.
@JsonSerializable()
class Message extends Equatable {
  /// Constructor used for json serialization.
  Message({
    String? id,
    this.text,
    this.type = 'regular',
    this.attachments = const [],
    this.mentionedUsers = const [],
    this.silent = false,
    this.shadowed = false,
    this.reactionCounts,
    this.reactionScores,
    this.latestReactions,
    this.ownReactions,
    this.parentId,
    this.quotedMessage,
    String? quotedMessageId,
    this.replyCount = 0,
    this.threadParticipants,
    this.showInChannel,
    this.command,
    DateTime? createdAt,
    this.localCreatedAt,
    DateTime? updatedAt,
    this.localUpdatedAt,
    DateTime? deletedAt,
    this.localDeletedAt,
    this.messageTextUpdatedAt,
    this.user,
    this.pinned = false,
    this.pinnedAt,
    DateTime? pinExpires,
    this.pinnedBy,
    this.poll,
    String? pollId,
    this.extraData = const {},
    this.state = const MessageState.initial(),
    this.i18n,
    this.restrictedVisibility,
  })  : id = id ?? const Uuid().v4(),
        pinExpires = pinExpires?.toUtc(),
        remoteCreatedAt = createdAt,
        remoteUpdatedAt = updatedAt,
        remoteDeletedAt = deletedAt,
        _quotedMessageId = quotedMessageId,
        _pollId = pollId;

  /// Create a new instance from JSON.
  factory Message.fromJson(Map<String, dynamic> json) {
    final message = _$MessageFromJson(
      Serializer.moveToExtraDataFromRoot(json, topLevelFields),
    );

    var state = MessageState.sent;
    if (message.deletedAt != null) {
      state = MessageState.softDeleted;
    } else if (message.updatedAt.isAfter(message.createdAt)) {
      state = MessageState.updated;
    }

    return message.copyWith(state: state);
  }

  /// The message ID. This is either created by Stream or set client side when
  /// the message is added.
  final String id;

  /// The text of this message.
  final String? text;

  /// The current state of the message.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final MessageState state;

  /// The message type.
  @JsonKey(includeIfNull: false, toJson: _typeToJson)
  final String type;

  // We need to skip passing type if it's not regular or system as the API
  // does not expect it.
  static String? _typeToJson(String type) {
    if (['regular', 'system'].contains(type)) return type;
    return null;
  }

  /// The list of attachments, either provided by the user or generated from a
  /// command or as a result of URL scraping.
  @JsonKey(includeIfNull: false)
  final List<Attachment> attachments;

  /// The list of user mentioned in the message.
  @JsonKey(toJson: User.toIds)
  final List<User> mentionedUsers;

  /// A map describing the count of number of every reaction.
  @JsonKey(includeToJson: false)
  final Map<String, int>? reactionCounts;

  /// A map describing the count of score of every reaction.
  @JsonKey(includeToJson: false)
  final Map<String, int>? reactionScores;

  /// The latest reactions to the message created by any user.
  @JsonKey(includeToJson: false)
  final List<Reaction>? latestReactions;

  /// The reactions added to the message by the current user.
  @JsonKey(includeToJson: false)
  final List<Reaction>? ownReactions;

  /// The ID of the parent message, if the message is a thread reply.
  final String? parentId;

  /// A quoted reply message.
  @JsonKey(includeToJson: false)
  final Message? quotedMessage;

  final String? _quotedMessageId;

  /// The ID of the quoted message, if the message is a quoted reply.
  String? get quotedMessageId => _quotedMessageId ?? quotedMessage?.id;

  /// Reserved field indicating the number of replies for this message.
  @JsonKey(includeToJson: false)
  final int? replyCount;

  /// Reserved field indicating the thread participants for this message.
  @JsonKey(includeToJson: false)
  final List<User>? threadParticipants;

  /// Check if this message needs to show in the channel.
  final bool? showInChannel;

  /// If true the message is silent.
  final bool silent;

  /// If true the message is shadowed.
  @JsonKey(includeToJson: false)
  final bool shadowed;

  /// A used command name.
  @JsonKey(includeToJson: false)
  final String? command;

  /// Indicates when the message was created.
  ///
  /// Returns the latest between [localCreatedAt] and [remoteCreatedAt].
  /// If both are null, returns [DateTime.now].
  @JsonKey(includeToJson: false)
  DateTime get createdAt => localCreatedAt ?? remoteCreatedAt ?? DateTime.now();

  /// Indicates when the message was created locally.
  @JsonKey(includeToJson: false, includeFromJson: false)
  final DateTime? localCreatedAt;

  /// Indicates when the message was created on the server.
  @JsonKey(includeToJson: false, includeFromJson: false)
  final DateTime? remoteCreatedAt;

  /// Indicates when the message was updated last time.
  ///
  /// Returns the latest between [localUpdatedAt] and [remoteUpdatedAt].
  /// If both are null, returns [createdAt].
  @JsonKey(includeToJson: false)
  DateTime get updatedAt => localUpdatedAt ?? remoteUpdatedAt ?? createdAt;

  /// Indicates when the message was updated locally.
  @JsonKey(includeToJson: false, includeFromJson: false)
  final DateTime? localUpdatedAt;

  /// Indicates when the message was updated on the server.
  @JsonKey(includeToJson: false, includeFromJson: false)
  final DateTime? remoteUpdatedAt;

  /// Indicates when the message was deleted.
  ///
  /// Returns the latest between [localDeletedAt] and [remoteDeletedAt].
  @JsonKey(includeToJson: false)
  DateTime? get deletedAt => localDeletedAt ?? remoteDeletedAt;

  /// Reserved field indicating when the message text was edited.
  @JsonKey(includeToJson: false)
  final DateTime? messageTextUpdatedAt;

  /// Indicates when the message was deleted locally.
  @JsonKey(includeToJson: false, includeFromJson: false)
  final DateTime? localDeletedAt;

  /// Indicates when the message was deleted on the server.
  @JsonKey(includeToJson: false, includeFromJson: false)
  final DateTime? remoteDeletedAt;

  /// User who sent the message.
  @JsonKey(includeToJson: false)
  final User? user;

  /// If true the message is pinned.
  final bool pinned;

  /// Reserved field indicating when the message was pinned.
  @JsonKey(includeToJson: false)
  final DateTime? pinnedAt;

  /// Reserved field indicating when the message will expire.
  ///
  /// If `null` message has no expiry.
  final DateTime? pinExpires;

  /// Reserved field indicating who pinned the message.
  @JsonKey(includeToJson: false)
  final User? pinnedBy;

  /// The poll associated with this message.
  @JsonKey(includeToJson: false)
  final Poll? poll;

  /// The ID of the [poll] associated with this message.
  String? get pollId => _pollId ?? poll?.id;
  final String? _pollId;

  /// The list of user ids that should be able to see the message.
  ///
  /// If null or empty, the message is visible to all users.
  /// If populated, only users whose ids are included in this list can see
  /// the message.
  @JsonKey(includeIfNull: false)
  final List<String>? restrictedVisibility;

  /// Message custom extraData.
  final Map<String, Object?> extraData;

  /// True if the message is a error.
  bool get isError => type == 'error';

  /// True if the message is a system info.
  bool get isSystem => type == 'system';

  /// True if the message has been deleted.
  bool get isDeleted => type == 'deleted';

  /// True if the message is ephemeral.
  bool get isEphemeral => type == 'ephemeral';

  /// A Map of translations.
  @JsonKey(includeToJson: false)
  final Map<String, String>? i18n;

  /// Known top level fields.
  ///
  /// Useful for [Serializer] methods.
  static const topLevelFields = [
    'id',
    'text',
    'type',
    'silent',
    'attachments',
    'latest_reactions',
    'shadowed',
    'own_reactions',
    'mentioned_users',
    'reaction_counts',
    'reaction_scores',
    'silent',
    'parent_id',
    'quoted_message',
    'quoted_message_id',
    'reply_count',
    'thread_participants',
    'show_in_channel',
    'command',
    'created_at',
    'updated_at',
    'deleted_at',
    'message_text_updated_at',
    'user',
    'pinned',
    'pinned_at',
    'pin_expires',
    'pinned_by',
    'i18n',
    'poll',
    'poll_id',
    'restricted_visibility',
  ];

  /// Serialize to json.
  Map<String, dynamic> toJson() => Serializer.moveFromExtraDataToRoot(
        _$MessageToJson(this),
      );

  /// Creates a copy of [Message] with specified attributes overridden.
  Message copyWith({
    String? id,
    String? text,
    String? type,
    List<Attachment>? attachments,
    List<User>? mentionedUsers,
    bool? silent,
    bool? shadowed,
    Map<String, int>? reactionCounts,
    Map<String, int>? reactionScores,
    List<Reaction>? latestReactions,
    List<Reaction>? ownReactions,
    String? parentId,
    Object? quotedMessage = _nullConst,
    Object? quotedMessageId = _nullConst,
    int? replyCount,
    List<User>? threadParticipants,
    bool? showInChannel,
    String? command,
    DateTime? createdAt,
    DateTime? localCreatedAt,
    DateTime? updatedAt,
    DateTime? localUpdatedAt,
    DateTime? deletedAt,
    DateTime? localDeletedAt,
    DateTime? messageTextUpdatedAt,
    User? user,
    bool? pinned,
    DateTime? pinnedAt,
    Object? pinExpires = _nullConst,
    User? pinnedBy,
    Poll? poll,
    String? pollId,
    Map<String, Object?>? extraData,
    MessageState? state,
    Map<String, String>? i18n,
    List<String>? restrictedVisibility,
  }) {
    assert(() {
      if (pinExpires is! DateTime &&
          pinExpires != null &&
          pinExpires is! _NullConst) {
        throw ArgumentError('`pinExpires` can only be set as DateTime or null');
      }
      return true;
    }(), 'Validate type for pinExpires');

    assert(() {
      if (quotedMessage is! Message &&
          quotedMessage != null &&
          quotedMessage is! _NullConst) {
        throw ArgumentError(
          '`quotedMessage` can only be set as Message or null',
        );
      }
      return true;
    }(), 'Validate type for quotedMessage');

    assert(() {
      if (quotedMessageId is! String &&
          quotedMessageId != null &&
          quotedMessageId is! _NullConst) {
        throw ArgumentError(
          '`quotedMessage` can only be set as String or null',
        );
      }
      return true;
    }(), 'Validate type for quotedMessage');

    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      attachments: attachments ?? this.attachments,
      mentionedUsers: mentionedUsers ?? this.mentionedUsers,
      silent: silent ?? this.silent,
      shadowed: shadowed ?? this.shadowed,
      reactionCounts: reactionCounts ?? this.reactionCounts,
      reactionScores: reactionScores ?? this.reactionScores,
      latestReactions: latestReactions ?? this.latestReactions,
      ownReactions: ownReactions ?? this.ownReactions,
      parentId: parentId ?? this.parentId,
      quotedMessage: quotedMessage == _nullConst
          ? this.quotedMessage
          : quotedMessage as Message?,
      quotedMessageId: quotedMessageId == _nullConst
          ? _quotedMessageId
          : quotedMessageId as String?,
      replyCount: replyCount ?? this.replyCount,
      threadParticipants: threadParticipants ?? this.threadParticipants,
      showInChannel: showInChannel ?? this.showInChannel,
      command: command ?? this.command,
      createdAt: createdAt ?? remoteCreatedAt,
      localCreatedAt: localCreatedAt ?? this.localCreatedAt,
      updatedAt: updatedAt ?? remoteUpdatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      deletedAt: deletedAt ?? remoteDeletedAt,
      localDeletedAt: localDeletedAt ?? this.localDeletedAt,
      messageTextUpdatedAt: messageTextUpdatedAt ?? this.messageTextUpdatedAt,
      user: user ?? this.user,
      pinned: pinned ?? this.pinned,
      pinnedAt: pinnedAt ?? this.pinnedAt,
      pinExpires:
          pinExpires == _nullConst ? this.pinExpires : pinExpires as DateTime?,
      pinnedBy: pinnedBy ?? this.pinnedBy,
      poll: poll ?? this.poll,
      pollId: pollId ?? _pollId,
      extraData: extraData ?? this.extraData,
      state: state ?? this.state,
      i18n: i18n ?? this.i18n,
      restrictedVisibility: restrictedVisibility ?? this.restrictedVisibility,
    );
  }

  /// Returns a new [Message] that is a combination of this message and the
  /// given [other] message.
  Message merge(Message other) {
    return copyWith(
      id: other.id,
      text: other.text,
      type: other.type,
      attachments: other.attachments,
      mentionedUsers: other.mentionedUsers,
      silent: other.silent,
      shadowed: other.shadowed,
      reactionCounts: other.reactionCounts,
      reactionScores: other.reactionScores,
      latestReactions: other.latestReactions,
      ownReactions: other.ownReactions,
      parentId: other.parentId,
      quotedMessage: other.quotedMessage,
      quotedMessageId: other.quotedMessageId,
      replyCount: other.replyCount,
      threadParticipants: other.threadParticipants,
      showInChannel: other.showInChannel,
      command: other.command,
      createdAt: other.remoteCreatedAt,
      localCreatedAt: other.localCreatedAt,
      updatedAt: other.remoteUpdatedAt,
      localUpdatedAt: other.localUpdatedAt,
      deletedAt: other.remoteDeletedAt,
      localDeletedAt: other.localDeletedAt,
      messageTextUpdatedAt: other.messageTextUpdatedAt,
      user: other.user,
      pinned: other.pinned,
      pinnedAt: other.pinnedAt,
      pinExpires: other.pinExpires,
      pinnedBy: other.pinnedBy,
      poll: other.poll,
      pollId: other.pollId,
      extraData: other.extraData,
      state: other.state,
      i18n: other.i18n,
      restrictedVisibility: other.restrictedVisibility,
    );
  }

  /// Returns a new [Message] that is [other] with local changes applied to it.
  ///
  /// This ensures that the local sync changes are not lost when the message is
  /// updated on the server.
  ///
  /// For example, when a message is sent, it is immediately shown
  /// optimistically in the UI. When the message is received from the server,
  /// it will not contain the local changes. This method can be used to merge
  /// the local changes back into the message.
  ///
  /// This also helps in maintaining the order of the messages in the channel
  /// when the messages are sorted by the [createdAt] field.
  Message syncWith(Message? other) {
    if (other == null) return this;

    return copyWith(
      localCreatedAt: other.localCreatedAt,
      localUpdatedAt: other.localUpdatedAt,
      localDeletedAt: other.localDeletedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        text,
        type,
        attachments,
        mentionedUsers,
        reactionCounts,
        reactionScores,
        latestReactions,
        ownReactions,
        parentId,
        quotedMessage,
        quotedMessageId,
        replyCount,
        threadParticipants,
        showInChannel,
        shadowed,
        silent,
        command,
        localCreatedAt,
        remoteCreatedAt,
        localUpdatedAt,
        remoteUpdatedAt,
        localDeletedAt,
        remoteDeletedAt,
        messageTextUpdatedAt,
        user,
        pinned,
        pinnedAt,
        pinExpires,
        pinnedBy,
        poll,
        pollId,
        extraData,
        state,
        i18n,
        restrictedVisibility,
      ];
}

/// Extension that adds visibility control functionality to Message objects.
///
/// This extension provides methods to determine if a message is visible to a
/// specific user based on the [Message.restrictedVisibility] list.
extension MessageVisibility on Message {
  /// Checks if this message has any visibility restrictions applied.
  ///
  /// Returns true if the restrictedVisibility list exists and contains at
  /// least one entry, indicating that visibility of this message is restricted
  /// to specific users.
  ///
  /// Returns false if the restrictedVisibility list is null or empty,
  /// indicating that this message is visible to all users.
  bool get hasRestrictedVisibility {
    final visibility = restrictedVisibility;
    if (visibility == null || visibility.isEmpty) return false;

    return true;
  }

  /// Determines if a message is visible to a specific user based on
  /// restricted visibility settings.
  ///
  /// Returns true in the following cases:
  /// - The restrictedVisibility list is null or empty (visible to everyone)
  /// - The provided userId is found in the restrictedVisibility list
  ///
  /// Returns false if the restrictedVisibility list exists and doesn't
  /// contain the provided userId.
  ///
  /// [userId] The unique identifier of the user to check visibility for.
  bool isVisibleTo(String userId) {
    final visibility = restrictedVisibility;
    if (visibility == null || visibility.isEmpty) return true;

    return visibility.contains(userId);
  }

  /// Determines if a message is not visible to a specific user based on
  /// restricted visibility settings.
  ///
  /// Returns true if the restrictedVisibility list exists and doesn't
  /// contain the provided userId.
  ///
  /// Returns false in the following cases:
  /// - The restrictedVisibility list is null or empty (visible to everyone)
  /// - The provided userId is found in the restrictedVisibility list
  ///
  /// [userId] The unique identifier of the user to check visibility for.
  bool isNotVisibleTo(String userId) => !isVisibleTo(userId);
}
