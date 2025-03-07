/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;


/** This is an auto generated class representing the MessageInbox type in your schema. */
class MessageInbox extends amplify_core.Model {
  static const classType = const _MessageInboxModelType();
  final String? _user;
  final String? _inboxUser;
  final String? _displayText;
  final bool? _unread;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => modelIdentifier.serializeAsString();
  
  MessageInboxModelIdentifier get modelIdentifier {
    try {
      return MessageInboxModelIdentifier(
        user: _user!,
        inboxUser: _inboxUser!
      );
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get user {
    try {
      return _user!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get inboxUser {
    try {
      return _inboxUser!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get displayText {
    return _displayText;
  }
  
  bool get unread {
    try {
      return _unread!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get createdAt {
    try {
      return _createdAt!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const MessageInbox._internal({required user, required inboxUser, displayText, required unread, required createdAt, updatedAt}): _user = user, _inboxUser = inboxUser, _displayText = displayText, _unread = unread, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory MessageInbox({required String user, required String inboxUser, String? displayText, required bool unread, required amplify_core.TemporalDateTime createdAt}) {
    return MessageInbox._internal(
      user: user,
      inboxUser: inboxUser,
      displayText: displayText,
      unread: unread,
      createdAt: createdAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MessageInbox &&
      _user == other._user &&
      _inboxUser == other._inboxUser &&
      _displayText == other._displayText &&
      _unread == other._unread &&
      _createdAt == other._createdAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("MessageInbox {");
    buffer.write("user=" + "$_user" + ", ");
    buffer.write("inboxUser=" + "$_inboxUser" + ", ");
    buffer.write("displayText=" + "$_displayText" + ", ");
    buffer.write("unread=" + (_unread != null ? _unread!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  MessageInbox copyWith({String? displayText, bool? unread, amplify_core.TemporalDateTime? createdAt}) {
    return MessageInbox._internal(
      user: user,
      inboxUser: inboxUser,
      displayText: displayText ?? this.displayText,
      unread: unread ?? this.unread,
      createdAt: createdAt ?? this.createdAt);
  }
  
  MessageInbox copyWithModelFieldValues({
    ModelFieldValue<String?>? displayText,
    ModelFieldValue<bool>? unread,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt
  }) {
    return MessageInbox._internal(
      user: user,
      inboxUser: inboxUser,
      displayText: displayText == null ? this.displayText : displayText.value,
      unread: unread == null ? this.unread : unread.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value
    );
  }
  
  MessageInbox.fromJson(Map<String, dynamic> json)  
    : _user = json['user'],
      _inboxUser = json['inboxUser'],
      _displayText = json['displayText'],
      _unread = json['unread'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'user': _user, 'inboxUser': _inboxUser, 'displayText': _displayText, 'unread': _unread, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'user': _user,
    'inboxUser': _inboxUser,
    'displayText': _displayText,
    'unread': _unread,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<MessageInboxModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<MessageInboxModelIdentifier>();
  static final USER = amplify_core.QueryField(fieldName: "user");
  static final INBOXUSER = amplify_core.QueryField(fieldName: "inboxUser");
  static final DISPLAYTEXT = amplify_core.QueryField(fieldName: "displayText");
  static final UNREAD = amplify_core.QueryField(fieldName: "unread");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "MessageInbox";
    modelSchemaDefinition.pluralName = "MessageInboxes";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PRIVATE,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["user", "inboxUser"], name: null),
      amplify_core.ModelIndex(fields: const ["user", "createdAt"], name: "messageInboxesByUserAndCreatedAt")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: MessageInbox.USER,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: MessageInbox.INBOXUSER,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: MessageInbox.DISPLAYTEXT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: MessageInbox.UNREAD,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: MessageInbox.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _MessageInboxModelType extends amplify_core.ModelType<MessageInbox> {
  const _MessageInboxModelType();
  
  @override
  MessageInbox fromJson(Map<String, dynamic> jsonData) {
    return MessageInbox.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'MessageInbox';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [MessageInbox] in your schema.
 */
class MessageInboxModelIdentifier implements amplify_core.ModelIdentifier<MessageInbox> {
  final String user;
  final String inboxUser;

  /**
   * Create an instance of MessageInboxModelIdentifier using [user] the primary key.
   * And [inboxUser] the sort key.
   */
  const MessageInboxModelIdentifier({
    required this.user,
    required this.inboxUser});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'user': user,
    'inboxUser': inboxUser
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'MessageInboxModelIdentifier(user: $user, inboxUser: $inboxUser)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is MessageInboxModelIdentifier &&
      user == other.user &&
      inboxUser == other.inboxUser;
  }
  
  @override
  int get hashCode =>
    user.hashCode ^
    inboxUser.hashCode;
}