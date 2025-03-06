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
  final String? _inbox_user;
  final String? _last_message_at;
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
        inbox_user: _inbox_user!
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
  
  String get inbox_user {
    try {
      return _inbox_user!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get last_message_at {
    return _last_message_at;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const MessageInbox._internal({required user, required inbox_user, last_message_at, createdAt, updatedAt}): _user = user, _inbox_user = inbox_user, _last_message_at = last_message_at, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory MessageInbox({required String user, required String inbox_user, String? last_message_at}) {
    return MessageInbox._internal(
      user: user,
      inbox_user: inbox_user,
      last_message_at: last_message_at);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MessageInbox &&
      _user == other._user &&
      _inbox_user == other._inbox_user &&
      _last_message_at == other._last_message_at;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("MessageInbox {");
    buffer.write("user=" + "$_user" + ", ");
    buffer.write("inbox_user=" + "$_inbox_user" + ", ");
    buffer.write("last_message_at=" + "$_last_message_at" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  MessageInbox copyWith({String? last_message_at}) {
    return MessageInbox._internal(
      user: user,
      inbox_user: inbox_user,
      last_message_at: last_message_at ?? this.last_message_at);
  }
  
  MessageInbox copyWithModelFieldValues({
    ModelFieldValue<String?>? last_message_at
  }) {
    return MessageInbox._internal(
      user: user,
      inbox_user: inbox_user,
      last_message_at: last_message_at == null ? this.last_message_at : last_message_at.value
    );
  }
  
  MessageInbox.fromJson(Map<String, dynamic> json)  
    : _user = json['user'],
      _inbox_user = json['inbox_user'],
      _last_message_at = json['last_message_at'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'user': _user, 'inbox_user': _inbox_user, 'last_message_at': _last_message_at, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'user': _user,
    'inbox_user': _inbox_user,
    'last_message_at': _last_message_at,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<MessageInboxModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<MessageInboxModelIdentifier>();
  static final USER = amplify_core.QueryField(fieldName: "user");
  static final INBOX_USER = amplify_core.QueryField(fieldName: "inbox_user");
  static final LAST_MESSAGE_AT = amplify_core.QueryField(fieldName: "last_message_at");
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
      amplify_core.ModelIndex(fields: const ["user", "inbox_user"], name: null),
      amplify_core.ModelIndex(fields: const ["user", "last_message_at"], name: "messageInboxesByUserAndLast_message_at")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: MessageInbox.USER,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: MessageInbox.INBOX_USER,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: MessageInbox.LAST_MESSAGE_AT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
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
  final String inbox_user;

  /**
   * Create an instance of MessageInboxModelIdentifier using [user] the primary key.
   * And [inbox_user] the sort key.
   */
  const MessageInboxModelIdentifier({
    required this.user,
    required this.inbox_user});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'user': user,
    'inbox_user': inbox_user
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'MessageInboxModelIdentifier(user: $user, inbox_user: $inbox_user)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is MessageInboxModelIdentifier &&
      user == other.user &&
      inbox_user == other.inbox_user;
  }
  
  @override
  int get hashCode =>
    user.hashCode ^
    inbox_user.hashCode;
}