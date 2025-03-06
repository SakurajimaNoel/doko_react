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


/** This is an auto generated class representing the MessageArchive type in your schema. */
class MessageArchive extends amplify_core.Model {
  static const classType = const _MessageArchiveModelType();
  final String id;
  final String? _archive;
  final String? _from;
  final String? _to;
  final String? _subject;
  final String? _body;
  final bool? _edited;
  final int? _deleted;
  final String? _replyFor;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => modelIdentifier.serializeAsString();
  
  MessageArchiveModelIdentifier get modelIdentifier {
    try {
      return MessageArchiveModelIdentifier(
        archive: _archive!,
        id: id
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
  
  String get archive {
    try {
      return _archive!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get from {
    try {
      return _from!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get to {
    try {
      return _to!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get subject {
    try {
      return _subject!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get body {
    try {
      return _body!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  bool get edited {
    try {
      return _edited!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get deleted {
    try {
      return _deleted!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get replyFor {
    return _replyFor;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const MessageArchive._internal({required this.id, required archive, required from, required to, required subject, required body, required edited, required deleted, replyFor, createdAt, updatedAt}): _archive = archive, _from = from, _to = to, _subject = subject, _body = body, _edited = edited, _deleted = deleted, _replyFor = replyFor, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory MessageArchive({String? id, required String archive, required String from, required String to, required String subject, required String body, required bool edited, required int deleted, String? replyFor}) {
    return MessageArchive._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      archive: archive,
      from: from,
      to: to,
      subject: subject,
      body: body,
      edited: edited,
      deleted: deleted,
      replyFor: replyFor);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MessageArchive &&
      id == other.id &&
      _archive == other._archive &&
      _from == other._from &&
      _to == other._to &&
      _subject == other._subject &&
      _body == other._body &&
      _edited == other._edited &&
      _deleted == other._deleted &&
      _replyFor == other._replyFor;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("MessageArchive {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("archive=" + "$_archive" + ", ");
    buffer.write("from=" + "$_from" + ", ");
    buffer.write("to=" + "$_to" + ", ");
    buffer.write("subject=" + "$_subject" + ", ");
    buffer.write("body=" + "$_body" + ", ");
    buffer.write("edited=" + (_edited != null ? _edited!.toString() : "null") + ", ");
    buffer.write("deleted=" + (_deleted != null ? _deleted!.toString() : "null") + ", ");
    buffer.write("replyFor=" + "$_replyFor" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  MessageArchive copyWith({String? from, String? to, String? subject, String? body, bool? edited, int? deleted, String? replyFor}) {
    return MessageArchive._internal(
      id: id,
      archive: archive,
      from: from ?? this.from,
      to: to ?? this.to,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      edited: edited ?? this.edited,
      deleted: deleted ?? this.deleted,
      replyFor: replyFor ?? this.replyFor);
  }
  
  MessageArchive copyWithModelFieldValues({
    ModelFieldValue<String>? from,
    ModelFieldValue<String>? to,
    ModelFieldValue<String>? subject,
    ModelFieldValue<String>? body,
    ModelFieldValue<bool>? edited,
    ModelFieldValue<int>? deleted,
    ModelFieldValue<String?>? replyFor
  }) {
    return MessageArchive._internal(
      id: id,
      archive: archive,
      from: from == null ? this.from : from.value,
      to: to == null ? this.to : to.value,
      subject: subject == null ? this.subject : subject.value,
      body: body == null ? this.body : body.value,
      edited: edited == null ? this.edited : edited.value,
      deleted: deleted == null ? this.deleted : deleted.value,
      replyFor: replyFor == null ? this.replyFor : replyFor.value
    );
  }
  
  MessageArchive.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _archive = json['archive'],
      _from = json['from'],
      _to = json['to'],
      _subject = json['subject'],
      _body = json['body'],
      _edited = json['edited'],
      _deleted = (json['deleted'] as num?)?.toInt(),
      _replyFor = json['replyFor'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'archive': _archive, 'from': _from, 'to': _to, 'subject': _subject, 'body': _body, 'edited': _edited, 'deleted': _deleted, 'replyFor': _replyFor, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'archive': _archive,
    'from': _from,
    'to': _to,
    'subject': _subject,
    'body': _body,
    'edited': _edited,
    'deleted': _deleted,
    'replyFor': _replyFor,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<MessageArchiveModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<MessageArchiveModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final ARCHIVE = amplify_core.QueryField(fieldName: "archive");
  static final FROM = amplify_core.QueryField(fieldName: "from");
  static final TO = amplify_core.QueryField(fieldName: "to");
  static final SUBJECT = amplify_core.QueryField(fieldName: "subject");
  static final BODY = amplify_core.QueryField(fieldName: "body");
  static final EDITED = amplify_core.QueryField(fieldName: "edited");
  static final DELETED = amplify_core.QueryField(fieldName: "deleted");
  static final REPLYFOR = amplify_core.QueryField(fieldName: "replyFor");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "MessageArchive";
    modelSchemaDefinition.pluralName = "MessageArchives";
    
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
      amplify_core.ModelIndex(fields: const ["archive", "id"], name: null)
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: MessageArchive.ARCHIVE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: MessageArchive.FROM,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: MessageArchive.TO,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: MessageArchive.SUBJECT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: MessageArchive.BODY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: MessageArchive.EDITED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: MessageArchive.DELETED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: MessageArchive.REPLYFOR,
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

class _MessageArchiveModelType extends amplify_core.ModelType<MessageArchive> {
  const _MessageArchiveModelType();
  
  @override
  MessageArchive fromJson(Map<String, dynamic> jsonData) {
    return MessageArchive.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'MessageArchive';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [MessageArchive] in your schema.
 */
class MessageArchiveModelIdentifier implements amplify_core.ModelIdentifier<MessageArchive> {
  final String archive;
  final String id;

  /**
   * Create an instance of MessageArchiveModelIdentifier using [archive] the primary key.
   * And [id] the sort key.
   */
  const MessageArchiveModelIdentifier({
    required this.archive,
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'archive': archive,
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'MessageArchiveModelIdentifier(archive: $archive, id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is MessageArchiveModelIdentifier &&
      archive == other.archive &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    archive.hashCode ^
    id.hashCode;
}