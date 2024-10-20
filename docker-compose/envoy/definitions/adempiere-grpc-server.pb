
�x
google/api/http.proto
google.api"y
Http*
rules (2.google.api.HttpRuleRrulesE
fully_decode_reserved_expansion (RfullyDecodeReservedExpansion"�
HttpRule
selector (	Rselector
get (	H Rget
put (	H Rput
post (	H Rpost
delete (	H Rdelete
patch (	H Rpatch7
custom (2.google.api.CustomHttpPatternH Rcustom
body (	Rbody#
response_body (	RresponseBodyE
additional_bindings (2.google.api.HttpRuleRadditionalBindingsB	
pattern";
CustomHttpPattern
kind (	Rkind
path (	RpathBj
com.google.apiB	HttpProtoPZAgoogle.golang.org/genproto/googleapis/api/annotations;annotations��GAPIJ�s
 �
�
 2� Copyright 2023 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 
	
 

 X
	
 X

 "
	

 "

 *
	
 *

 '
	
 '

 "
	
$ "
�
  )� Defines the HTTP configuration for an API service. It contains a list of
 [HttpRule][google.api.HttpRule], each specifying the mapping of an RPC method
 to one or more HTTP REST API methods.



 
�
   � A list of HTTP configuration rules that apply to individual API methods.

 **NOTE:** All service configuration rules follow "last one wins" order.


   


   

   

   
�
 (+� When set to true, URL path parameters will be fully URI-decoded except in
 cases of single segment matches in reserved expansion, where "%2F" will be
 left encoded.

 The default behavior is to not decode RFC 6570 reserved characters in multi
 segment matches.


 (

 (&

 ()*
�S
� ��S # gRPC Transcoding

 gRPC Transcoding is a feature for mapping between a gRPC method and one or
 more HTTP REST endpoints. It allows developers to build a single API service
 that supports both gRPC APIs and REST APIs. Many systems, including [Google
 APIs](https://github.com/googleapis/googleapis),
 [Cloud Endpoints](https://cloud.google.com/endpoints), [gRPC
 Gateway](https://github.com/grpc-ecosystem/grpc-gateway),
 and [Envoy](https://github.com/envoyproxy/envoy) proxy support this feature
 and use it for large scale production services.

 `HttpRule` defines the schema of the gRPC/REST mapping. The mapping specifies
 how different portions of the gRPC request message are mapped to the URL
 path, URL query parameters, and HTTP request body. It also controls how the
 gRPC response message is mapped to the HTTP response body. `HttpRule` is
 typically specified as an `google.api.http` annotation on the gRPC method.

 Each mapping specifies a URL path template and an HTTP method. The path
 template may refer to one or more fields in the gRPC request message, as long
 as each field is a non-repeated field with a primitive (non-message) type.
 The path template controls how fields of the request message are mapped to
 the URL path.

 Example:

     service Messaging {
       rpc GetMessage(GetMessageRequest) returns (Message) {
         option (google.api.http) = {
             get: "/v1/{name=messages/*}"
         };
       }
     }
     message GetMessageRequest {
       string name = 1; // Mapped to URL path.
     }
     message Message {
       string text = 1; // The resource content.
     }

 This enables an HTTP REST to gRPC mapping as below:

 HTTP | gRPC
 -----|-----
 `GET /v1/messages/123456`  | `GetMessage(name: "messages/123456")`

 Any fields in the request message which are not bound by the path template
 automatically become HTTP query parameters if there is no HTTP request body.
 For example:

     service Messaging {
       rpc GetMessage(GetMessageRequest) returns (Message) {
         option (google.api.http) = {
             get:"/v1/messages/{message_id}"
         };
       }
     }
     message GetMessageRequest {
       message SubMessage {
         string subfield = 1;
       }
       string message_id = 1; // Mapped to URL path.
       int64 revision = 2;    // Mapped to URL query parameter `revision`.
       SubMessage sub = 3;    // Mapped to URL query parameter `sub.subfield`.
     }

 This enables a HTTP JSON to RPC mapping as below:

 HTTP | gRPC
 -----|-----
 `GET /v1/messages/123456?revision=2&sub.subfield=foo` |
 `GetMessage(message_id: "123456" revision: 2 sub: SubMessage(subfield:
 "foo"))`

 Note that fields which are mapped to URL query parameters must have a
 primitive type or a repeated primitive type or a non-repeated message type.
 In the case of a repeated type, the parameter can be repeated in the URL
 as `...?param=A&param=B`. In the case of a message type, each field of the
 message is mapped to a separate parameter, such as
 `...?foo.a=A&foo.b=B&foo.c=C`.

 For HTTP methods that allow a request body, the `body` field
 specifies the mapping. Consider a REST update method on the
 message resource collection:

     service Messaging {
       rpc UpdateMessage(UpdateMessageRequest) returns (Message) {
         option (google.api.http) = {
           patch: "/v1/messages/{message_id}"
           body: "message"
         };
       }
     }
     message UpdateMessageRequest {
       string message_id = 1; // mapped to the URL
       Message message = 2;   // mapped to the body
     }

 The following HTTP JSON to RPC mapping is enabled, where the
 representation of the JSON in the request body is determined by
 protos JSON encoding:

 HTTP | gRPC
 -----|-----
 `PATCH /v1/messages/123456 { "text": "Hi!" }` | `UpdateMessage(message_id:
 "123456" message { text: "Hi!" })`

 The special name `*` can be used in the body mapping to define that
 every field not bound by the path template should be mapped to the
 request body.  This enables the following alternative definition of
 the update method:

     service Messaging {
       rpc UpdateMessage(Message) returns (Message) {
         option (google.api.http) = {
           patch: "/v1/messages/{message_id}"
           body: "*"
         };
       }
     }
     message Message {
       string message_id = 1;
       string text = 2;
     }


 The following HTTP JSON to RPC mapping is enabled:

 HTTP | gRPC
 -----|-----
 `PATCH /v1/messages/123456 { "text": "Hi!" }` | `UpdateMessage(message_id:
 "123456" text: "Hi!")`

 Note that when using `*` in the body mapping, it is not possible to
 have HTTP parameters, as all fields not bound by the path end in
 the body. This makes this option more rarely used in practice when
 defining REST APIs. The common usage of `*` is in custom methods
 which don't use the URL at all for transferring data.

 It is possible to define multiple HTTP methods for one RPC by using
 the `additional_bindings` option. Example:

     service Messaging {
       rpc GetMessage(GetMessageRequest) returns (Message) {
         option (google.api.http) = {
           get: "/v1/messages/{message_id}"
           additional_bindings {
             get: "/v1/users/{user_id}/messages/{message_id}"
           }
         };
       }
     }
     message GetMessageRequest {
       string message_id = 1;
       string user_id = 2;
     }

 This enables the following two alternative HTTP JSON to RPC mappings:

 HTTP | gRPC
 -----|-----
 `GET /v1/messages/123456` | `GetMessage(message_id: "123456")`
 `GET /v1/users/me/messages/123456` | `GetMessage(user_id: "me" message_id:
 "123456")`

 ## Rules for HTTP mapping

 1. Leaf request fields (recursive expansion nested messages in the request
    message) are classified into three categories:
    - Fields referred by the path template. They are passed via the URL path.
    - Fields referred by the [HttpRule.body][google.api.HttpRule.body]. They
    are passed via the HTTP
      request body.
    - All other fields are passed via the URL query parameters, and the
      parameter name is the field path in the request message. A repeated
      field can be represented as multiple query parameters under the same
      name.
  2. If [HttpRule.body][google.api.HttpRule.body] is "*", there is no URL
  query parameter, all fields
     are passed via URL path and HTTP request body.
  3. If [HttpRule.body][google.api.HttpRule.body] is omitted, there is no HTTP
  request body, all
     fields are passed via URL path and URL query parameters.

 ### Path template syntax

     Template = "/" Segments [ Verb ] ;
     Segments = Segment { "/" Segment } ;
     Segment  = "*" | "**" | LITERAL | Variable ;
     Variable = "{" FieldPath [ "=" Segments ] "}" ;
     FieldPath = IDENT { "." IDENT } ;
     Verb     = ":" LITERAL ;

 The syntax `*` matches a single URL path segment. The syntax `**` matches
 zero or more URL path segments, which must be the last part of the URL path
 except the `Verb`.

 The syntax `Variable` matches part of the URL path as specified by its
 template. A variable template must not contain other variables. If a variable
 matches a single path segment, its template may be omitted, e.g. `{var}`
 is equivalent to `{var=*}`.

 The syntax `LITERAL` matches literal text in the URL path. If the `LITERAL`
 contains any reserved character, such characters should be percent-encoded
 before the matching.

 If a variable contains exactly one path segment, such as `"{var}"` or
 `"{var=*}"`, when such a variable is expanded into a URL path on the client
 side, all characters except `[-_.~0-9a-zA-Z]` are percent-encoded. The
 server side does the reverse decoding. Such variables show up in the
 [Discovery
 Document](https://developers.google.com/discovery/v1/reference/apis) as
 `{var}`.

 If a variable contains multiple path segments, such as `"{var=foo/*}"`
 or `"{var=**}"`, when such a variable is expanded into a URL path on the
 client side, all characters except `[-_.~/0-9a-zA-Z]` are percent-encoded.
 The server side does the reverse decoding, except "%2F" and "%2f" are left
 unchanged. Such variables show up in the
 [Discovery
 Document](https://developers.google.com/discovery/v1/reference/apis) as
 `{+var}`.

 ## Using gRPC API Service Configuration

 gRPC API Service Configuration (service config) is a configuration language
 for configuring a gRPC service to become a user-facing product. The
 service config is simply the YAML representation of the `google.api.Service`
 proto message.

 As an alternative to annotating your proto file, you can configure gRPC
 transcoding in your service config YAML files. You do this by specifying a
 `HttpRule` that maps the gRPC method to a REST endpoint, achieving the same
 effect as the proto annotation. This can be particularly useful if you
 have a proto that is reused in multiple services. Note that any transcoding
 specified in the service config will override any matching transcoding
 configuration in the proto.

 Example:

     http:
       rules:
         # Selects a gRPC method and applies HttpRule to it.
         - selector: example.v1.Messaging.GetMessage
           get: /v1/messages/{message_id}/{sub.subfield}

 ## Special notes

 When gRPC Transcoding is used to map a gRPC to JSON REST endpoints, the
 proto to JSON conversion must follow the [proto3
 specification](https://developers.google.com/protocol-buffers/docs/proto3#json).

 While the single segment variable follows the semantics of
 [RFC 6570](https://tools.ietf.org/html/rfc6570) Section 3.2.2 Simple String
 Expansion, the multi segment variable **does not** follow RFC 6570 Section
 3.2.3 Reserved Expansion. The reason is that the Reserved Expansion
 does not expand special characters like `?` and `#`, which would lead
 to invalid URLs. As the result, gRPC Transcoding uses a custom encoding
 for multi segment variables.

 The path variables **must not** refer to any repeated or mapped field,
 because client libraries are not capable of handling such variable expansion.

 The path variables **must not** capture the leading "/" character. The reason
 is that the most common use case "{var}" does not capture the leading "/"
 character. For consistency, all path variables must share the same behavior.

 Repeated message fields must not be mapped to URL query parameters, because
 no client library can support such complicated mapping.

 If an API needs to use a JSON array for request or response body, it can map
 the request or response body to a repeated field. However, some gRPC
 Transcoding implementations may not support this feature.


�
�
 �� Selects a method to which this rule applies.

 Refer to [selector][google.api.DocumentationRule.selector] for syntax
 details.


 �

 �	

 �
�
 ��� Determines the URL pattern is matched by this rules. This pattern can be
 used with any of the {get|put|post|delete|patch} methods. A custom method
 can be defined using the 'custom' field.


 �
\
�N Maps to HTTP GET. Used for listing and getting information about
 resources.


�


�

�
@
�2 Maps to HTTP PUT. Used for replacing a resource.


�


�

�
X
�J Maps to HTTP POST. Used for creating a resource or performing an action.


�


�

�
B
�4 Maps to HTTP DELETE. Used for deleting a resource.


�


�

�
A
�3 Maps to HTTP PATCH. Used for updating a resource.


�


�

�
�
�!� The custom pattern is used for specifying an HTTP method that is not
 included in the `pattern` field, such as HEAD, or "*" to leave the
 HTTP method unspecified for this rule. The wild-card rule is useful
 for services that provide content to Web (HTML) clients.


�

�

� 
�
�� The name of the request field whose value is mapped to the HTTP request
 body, or `*` for mapping all request fields not captured by the path
 pattern to the HTTP body, or omitted for not having any HTTP request body.

 NOTE: the referred field must be present at the top-level of the request
 message type.


�

�	

�
�
�� Optional. The name of the response field whose value is mapped to the HTTP
 response body. When omitted, the entire response message will be used
 as the HTTP response body.

 NOTE: The referred field must be present at the top-level of the response
 message type.


�

�	

�
�
	�-� Additional HTTP bindings for the selector. Nested bindings must
 not contain an `additional_bindings` field themselves (that is,
 the nesting may only be one level deep).


	�


	�

	�'

	�*,
G
� �9 A custom pattern is used for defining custom HTTP verb.


�
2
 �$ The name of this custom HTTP verb.


 �

 �	

 �
5
�' The path matched by this custom verb.


�

�	

�bproto3
��
 google/protobuf/descriptor.protogoogle.protobuf"M
FileDescriptorSet8
file (2$.google.protobuf.FileDescriptorProtoRfile"�
FileDescriptorProto
name (	Rname
package (	Rpackage

dependency (	R
dependency+
public_dependency
 (RpublicDependency'
weak_dependency (RweakDependencyC
message_type (2 .google.protobuf.DescriptorProtoRmessageTypeA
	enum_type (2$.google.protobuf.EnumDescriptorProtoRenumTypeA
service (2'.google.protobuf.ServiceDescriptorProtoRserviceC
	extension (2%.google.protobuf.FieldDescriptorProtoR	extension6
options (2.google.protobuf.FileOptionsRoptionsI
source_code_info	 (2.google.protobuf.SourceCodeInfoRsourceCodeInfo
syntax (	Rsyntax2
edition (2.google.protobuf.EditionRedition"�
DescriptorProto
name (	Rname;
field (2%.google.protobuf.FieldDescriptorProtoRfieldC
	extension (2%.google.protobuf.FieldDescriptorProtoR	extensionA
nested_type (2 .google.protobuf.DescriptorProtoR
nestedTypeA
	enum_type (2$.google.protobuf.EnumDescriptorProtoRenumTypeX
extension_range (2/.google.protobuf.DescriptorProto.ExtensionRangeRextensionRangeD

oneof_decl (2%.google.protobuf.OneofDescriptorProtoR	oneofDecl9
options (2.google.protobuf.MessageOptionsRoptionsU
reserved_range	 (2..google.protobuf.DescriptorProto.ReservedRangeRreservedRange#
reserved_name
 (	RreservedNamez
ExtensionRange
start (Rstart
end (Rend@
options (2&.google.protobuf.ExtensionRangeOptionsRoptions7
ReservedRange
start (Rstart
end (Rend"�
ExtensionRangeOptionsX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOptionY
declaration (22.google.protobuf.ExtensionRangeOptions.DeclarationB�Rdeclaration7
features2 (2.google.protobuf.FeatureSetRfeaturesh
verification (28.google.protobuf.ExtensionRangeOptions.VerificationState:
UNVERIFIEDRverification�
Declaration
number (Rnumber
	full_name (	RfullName
type (	Rtype
reserved (Rreserved
repeated (RrepeatedJ"4
VerificationState
DECLARATION 

UNVERIFIED*	�����"�
FieldDescriptorProto
name (	Rname
number (RnumberA
label (2+.google.protobuf.FieldDescriptorProto.LabelRlabel>
type (2*.google.protobuf.FieldDescriptorProto.TypeRtype
	type_name (	RtypeName
extendee (	Rextendee#
default_value (	RdefaultValue
oneof_index	 (R
oneofIndex
	json_name
 (	RjsonName7
options (2.google.protobuf.FieldOptionsRoptions'
proto3_optional (Rproto3Optional"�
Type
TYPE_DOUBLE

TYPE_FLOAT

TYPE_INT64
TYPE_UINT64

TYPE_INT32
TYPE_FIXED64
TYPE_FIXED32
	TYPE_BOOL
TYPE_STRING	

TYPE_GROUP

TYPE_MESSAGE

TYPE_BYTES
TYPE_UINT32
	TYPE_ENUM
TYPE_SFIXED32
TYPE_SFIXED64
TYPE_SINT32
TYPE_SINT64"C
Label
LABEL_OPTIONAL
LABEL_REPEATED
LABEL_REQUIRED"c
OneofDescriptorProto
name (	Rname7
options (2.google.protobuf.OneofOptionsRoptions"�
EnumDescriptorProto
name (	Rname?
value (2).google.protobuf.EnumValueDescriptorProtoRvalue6
options (2.google.protobuf.EnumOptionsRoptions]
reserved_range (26.google.protobuf.EnumDescriptorProto.EnumReservedRangeRreservedRange#
reserved_name (	RreservedName;
EnumReservedRange
start (Rstart
end (Rend"�
EnumValueDescriptorProto
name (	Rname
number (Rnumber;
options (2!.google.protobuf.EnumValueOptionsRoptions"�
ServiceDescriptorProto
name (	Rname>
method (2&.google.protobuf.MethodDescriptorProtoRmethod9
options (2.google.protobuf.ServiceOptionsRoptions"�
MethodDescriptorProto
name (	Rname

input_type (	R	inputType
output_type (	R
outputType8
options (2.google.protobuf.MethodOptionsRoptions0
client_streaming (:falseRclientStreaming0
server_streaming (:falseRserverStreaming"�	
FileOptions!
java_package (	RjavaPackage0
java_outer_classname (	RjavaOuterClassname5
java_multiple_files
 (:falseRjavaMultipleFilesD
java_generate_equals_and_hash (BRjavaGenerateEqualsAndHash:
java_string_check_utf8 (:falseRjavaStringCheckUtf8S
optimize_for	 (2).google.protobuf.FileOptions.OptimizeMode:SPEEDRoptimizeFor

go_package (	R	goPackage5
cc_generic_services (:falseRccGenericServices9
java_generic_services (:falseRjavaGenericServices5
py_generic_services (:falseRpyGenericServices7
php_generic_services* (:falseRphpGenericServices%

deprecated (:falseR
deprecated.
cc_enable_arenas (:trueRccEnableArenas*
objc_class_prefix$ (	RobjcClassPrefix)
csharp_namespace% (	RcsharpNamespace!
swift_prefix' (	RswiftPrefix(
php_class_prefix( (	RphpClassPrefix#
php_namespace) (	RphpNamespace4
php_metadata_namespace, (	RphpMetadataNamespace!
ruby_package- (	RrubyPackage7
features2 (2.google.protobuf.FeatureSetRfeaturesX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption":
OptimizeMode	
SPEED
	CODE_SIZE
LITE_RUNTIME*	�����J&'"�
MessageOptions<
message_set_wire_format (:falseRmessageSetWireFormatL
no_standard_descriptor_accessor (:falseRnoStandardDescriptorAccessor%

deprecated (:falseR
deprecated
	map_entry (RmapEntryV
&deprecated_legacy_json_field_conflicts (BR"deprecatedLegacyJsonFieldConflicts7
features (2.google.protobuf.FeatureSetRfeaturesX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����JJJJ	J	
"�

FieldOptionsA
ctype (2#.google.protobuf.FieldOptions.CType:STRINGRctype
packed (RpackedG
jstype (2$.google.protobuf.FieldOptions.JSType:	JS_NORMALRjstype
lazy (:falseRlazy.
unverified_lazy (:falseRunverifiedLazy%

deprecated (:falseR
deprecated
weak
 (:falseRweak(
debug_redact (:falseRdebugRedactK
	retention (2-.google.protobuf.FieldOptions.OptionRetentionR	retentionH
targets (2..google.protobuf.FieldOptions.OptionTargetTypeRtargetsW
edition_defaults (2,.google.protobuf.FieldOptions.EditionDefaultReditionDefaults7
features (2.google.protobuf.FeatureSetRfeaturesX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOptionZ
EditionDefault2
edition (2.google.protobuf.EditionRedition
value (	Rvalue"/
CType

STRING 
CORD
STRING_PIECE"5
JSType
	JS_NORMAL 
	JS_STRING
	JS_NUMBER"U
OptionRetention
RETENTION_UNKNOWN 
RETENTION_RUNTIME
RETENTION_SOURCE"�
OptionTargetType
TARGET_TYPE_UNKNOWN 
TARGET_TYPE_FILE
TARGET_TYPE_EXTENSION_RANGE
TARGET_TYPE_MESSAGE
TARGET_TYPE_FIELD
TARGET_TYPE_ONEOF
TARGET_TYPE_ENUM
TARGET_TYPE_ENUM_ENTRY
TARGET_TYPE_SERVICE
TARGET_TYPE_METHOD	*	�����JJ"�
OneofOptions7
features (2.google.protobuf.FeatureSetRfeaturesX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����"�
EnumOptions
allow_alias (R
allowAlias%

deprecated (:falseR
deprecatedV
&deprecated_legacy_json_field_conflicts (BR"deprecatedLegacyJsonFieldConflicts7
features (2.google.protobuf.FeatureSetRfeaturesX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����J"�
EnumValueOptions%

deprecated (:falseR
deprecated7
features (2.google.protobuf.FeatureSetRfeatures(
debug_redact (:falseRdebugRedactX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����"�
ServiceOptions7
features" (2.google.protobuf.FeatureSetRfeatures%

deprecated! (:falseR
deprecatedX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����"�
MethodOptions%

deprecated! (:falseR
deprecatedq
idempotency_level" (2/.google.protobuf.MethodOptions.IdempotencyLevel:IDEMPOTENCY_UNKNOWNRidempotencyLevel7
features# (2.google.protobuf.FeatureSetRfeaturesX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption"P
IdempotencyLevel
IDEMPOTENCY_UNKNOWN 
NO_SIDE_EFFECTS

IDEMPOTENT*	�����"�
UninterpretedOptionA
name (2-.google.protobuf.UninterpretedOption.NamePartRname)
identifier_value (	RidentifierValue,
positive_int_value (RpositiveIntValue,
negative_int_value (RnegativeIntValue!
double_value (RdoubleValue!
string_value (RstringValue'
aggregate_value (	RaggregateValueJ
NamePart
	name_part (	RnamePart!
is_extension (RisExtension"�	

FeatureSet�
field_presence (2).google.protobuf.FeatureSet.FieldPresenceB9����EXPLICIT��IMPLICIT��EXPLICIT�RfieldPresencef
	enum_type (2$.google.protobuf.FeatureSet.EnumTypeB#����CLOSED��	OPEN�RenumType�
repeated_field_encoding (21.google.protobuf.FeatureSet.RepeatedFieldEncodingB'����EXPANDED��PACKED�RrepeatedFieldEncodingx
utf8_validation (2*.google.protobuf.FeatureSet.Utf8ValidationB#����	NONE��VERIFY�Rutf8Validationx
message_encoding (2+.google.protobuf.FeatureSet.MessageEncodingB ����LENGTH_PREFIXED�RmessageEncoding|
json_format (2&.google.protobuf.FeatureSet.JsonFormatB3�����LEGACY_BEST_EFFORT��
ALLOW�R
jsonFormat"\
FieldPresence
FIELD_PRESENCE_UNKNOWN 
EXPLICIT
IMPLICIT
LEGACY_REQUIRED"7
EnumType
ENUM_TYPE_UNKNOWN 
OPEN

CLOSED"V
RepeatedFieldEncoding#
REPEATED_FIELD_ENCODING_UNKNOWN 

PACKED
EXPANDED"C
Utf8Validation
UTF8_VALIDATION_UNKNOWN 
NONE

VERIFY"S
MessageEncoding
MESSAGE_ENCODING_UNKNOWN 
LENGTH_PREFIXED
	DELIMITED"H

JsonFormat
JSON_FORMAT_UNKNOWN 	
ALLOW
LEGACY_BEST_EFFORT*��*��*�N�NJ��"�
FeatureSetDefaultsX
defaults (2<.google.protobuf.FeatureSetDefaults.FeatureSetEditionDefaultRdefaultsA
minimum_edition (2.google.protobuf.EditionRminimumEditionA
maximum_edition (2.google.protobuf.EditionRmaximumEdition�
FeatureSetEditionDefault2
edition (2.google.protobuf.EditionRedition7
features (2.google.protobuf.FeatureSetRfeatures"�
SourceCodeInfoD
location (2(.google.protobuf.SourceCodeInfo.LocationRlocation�
Location
path (BRpath
span (BRspan)
leading_comments (	RleadingComments+
trailing_comments (	RtrailingComments:
leading_detached_comments (	RleadingDetachedComments"�
GeneratedCodeInfoM

annotation (2-.google.protobuf.GeneratedCodeInfo.AnnotationR
annotation�

Annotation
path (BRpath
source_file (	R
sourceFile
begin (Rbegin
end (RendR
semantic (26.google.protobuf.GeneratedCodeInfo.Annotation.SemanticRsemantic"(
Semantic
NONE 
SET	
ALIAS*�
Edition
EDITION_UNKNOWN 
EDITION_PROTO2�
EDITION_PROTO3�
EDITION_2023�
EDITION_1_TEST_ONLY
EDITION_2_TEST_ONLY
EDITION_99997_TEST_ONLY��
EDITION_99998_TEST_ONLY��
EDITION_99999_TEST_ONLY��B~
com.google.protobufBDescriptorProtosHZ-google.golang.org/protobuf/types/descriptorpb��GPB�Google.Protobuf.ReflectionJ��
& �	
�
& 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
2� Author: kenton@google.com (Kenton Varda)
  Based on original Protocol Buffers design by
  Sanjay Ghemawat, Jeff Dean, and others.

 The messages in this file describe the definitions found in .proto files.
 A valid .proto file can be translated directly to a FileDescriptorProto
 without any other information (e.g. without reading its imports).


( 

* D
	
* D

+ ,
	
+ ,

, 1
	
, 1

- 7
	
%- 7

. !
	
$. !

/ 
	
/ 

3 

	3 t descriptor.proto must be optimized for speed because reflection-based
 algorithms don't work during bootstrapping.

j
 7 9^ The protocol compiler can output a FileDescriptorSet containing the .proto
 files it parses.



 7

  8(

  8


  8

  8#

  8&'
-
 < S! The full set of known editions.



 <
:
  >- A placeholder for an unknown edition value.


  >

  >
�
 D� Legacy syntax "editions".  These pre-date editions, but behave much like
 distinct editions.  These can't be used to specify the edition of proto
 files, but feature definitions must supply proto2/proto3 defaults for
 backwards compatibility.


 D

 D

 E

 E

 E
�
 J� Editions that have been released.  The specific values are arbitrary and
 should not be depended on, but they will always be time-ordered for easy
 comparison.


 J

 J
}
 Np Placeholder editions for testing feature resolution.  These should not be
 used or relyed on outside of tests.


 N

 N

 O

 O

 O

 P"

 P

 P!

 Q"

 Q

 Q!

 R"

 R

 R!
/
V x# Describes a complete .proto file.



V
9
 W", file name, relative to root of source tree


 W


 W

 W

 W
*
X" e.g. "foo", "foo.bar", etc.


X


X

X

X
4
[!' Names of files imported by this file.


[


[

[

[ 
Q
](D Indexes of the public imported files in the dependency list above.


]


]

]"

]%'
z
`&m Indexes of the weak imported files in the dependency list.
 For Google-internal migration only. Do not use.


`


`

` 

`#%
6
c,) All top-level definitions in this file.


c


c

c'

c*+

d-

d


d

d(

d+,

e.

e


e!

e")

e,-

f.

f


f

f )

f,-

	h#

	h


	h

	h

	h!"
�

n/� This field contains optional information about the original source code.
 You may safely remove this entire field without harming runtime
 functionality of the descriptors -- the information is needed only by
 development tools.



n



n


n*


n-.
�
t� The syntax of the proto file.
 The supported values are "proto2", "proto3", and "editions".

 If `edition` is present, this value must be "editions".


t


t

t

t
-
w   The edition of the proto file.


w


w

w

w
(
{ � Describes a message type.



{

 |

 |


 |

 |

 |

~*

~


~

~ %

~()

.






 )

,-

�+

�


�

�&

�)*

�-

�


�

�(

�+,

 ��

 �


  �" Inclusive.


  �

  �

  �

  �

 �" Exclusive.


 �

 �

 �

 �

 �/

 �

 �"

 �#*

 �-.

�.

�


�

�)

�,-

�/

�


�

� *

�-.

�&

�


�

�!

�$%
�
��� Range of reserved tag numbers. Reserved tag numbers may not be used by
 fields or extension ranges in the same message. Reserved ranges may
 not overlap.


�


 �" Inclusive.


 �

 �

 �

 �

�" Exclusive.


�

�

�

�

�,

�


�

�'

�*+
�
	�%u Reserved field names, which may not be used by fields in the same message.
 A given name may only be reserved once.


	�


	�

	�

	�"$

� �

�
O
 �:A The parser stores options it doesn't recognize here. See above.


 �


 �

 �3

 �69

 ��

 �

K
  �; The extension number declared within the extension range.


  �

  �

  �

  �
z
 �"j The fully-qualified name of the extension field. There must be a leading
 dot in front of the full name.


 �

 �

 �

 � !
�
 �� The fully-qualified type name of the extension field. Unlike
 Metadata.type, Declaration.type must have a leading dot for messages
 and enums.


 �

 �

 �

 �
�
 �� If true, indicates that the number is reserved in the extension range,
 and any extension field with the number will fail to compile. Set this
 when a declared extension field is deleted.


 �

 �

 �

 �
�
 �z If true, indicates that the extension must be defined as repeated.
 Otherwise the extension must be defined as optional.


 �

 �

 �

 �
$
 	�" removed is_repeated


 	 �

 	 �

 	 �
�
�F� For external users: DO NOT USE. We are in the process of open sourcing
 extension declaration and executing internal cleanups before it can be
 used externally.


�


�

�"

�%&

�'E

�(D
=
�$/ Any features defined in the specific edition.


�


�

�

�!#
@
 ��0 The verification state of the extension range.


 �
C
  �3 All the extensions of the range must be declared.


  �

  �

 �

 �

 �
�
�E~ The verification state of the range.
 TODO: flip the default to DECLARATION once all empty ranges
 are marked as UNVERIFIED.


�


�

�)

�,-

�.D

�9C
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �
3
� �% Describes a field within a message.


�

 ��

 �
S
  �C 0 is reserved for errors.
 Order is weird for historical reasons.


  �

  �

 �

 �

 �
w
 �g Not ZigZag encoded.  Negative numbers take 10 bytes.  Use TYPE_SINT64 if
 negative values are likely.


 �

 �

 �

 �

 �
w
 �g Not ZigZag encoded.  Negative numbers take 10 bytes.  Use TYPE_SINT32 if
 negative values are likely.


 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �
�
 	�� Tag-delimited aggregate.
 Group type is deprecated and not supported after google.protobuf. However, Proto3
 implementations should still be able to parse the group wire format and
 treat group fields as unknown fields.  In Editions, the group wire format
 can be enabled via the `message_encoding` feature.


 	�

 	�
-
 
�" Length-delimited aggregate.


 
�

 
�
#
 � New in version 2.


 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �
'
 �" Uses ZigZag encoding.


 �

 �
'
 �" Uses ZigZag encoding.


 �

 �

��

�
*
 � 0 is reserved for errors


 �

 �

�

�

�
�
�� The required label is only allowed in google.protobuf.  In proto3 and Editions
 it's explicitly prohibited.  In Editions, the `field_presence` feature
 can be used to get this behavior.


�

�

 �

 �


 �

 �

 �

�

�


�

�

�

�

�


�

�

�
�
�� If type_name is set, this need not be set.  If both this and type_name
 are set, this must be one of TYPE_ENUM, TYPE_MESSAGE or TYPE_GROUP.


�


�

�

�
�
� � For message and enum types, this is the name of the type.  If the name
 starts with a '.', it is fully-qualified.  Otherwise, C++-like scoping
 rules are used to find the type (i.e. first the nested types within this
 message are searched, then within the parent, on up to the root
 namespace).


�


�

�

�
~
�p For extensions, this is the name of the type being extended.  It is
 resolved in the same manner as type_name.


�


�

�

�
�
�$� For numeric types, contains the original text representation of the value.
 For booleans, "true" or "false".
 For strings, contains the default text contents (not escaped in any way).
 For bytes, contains the C escaped value.  All bytes >= 128 are escaped.


�


�

�

�"#
�
�!v If set, gives the index of a oneof in the containing type's oneof_decl
 list.  This field is a member of that oneof.


�


�

�

� 
�
�!� JSON name of this field. The value is set by protocol compiler. If the
 user has set a "json_name" option on this field, that option's value
 will be used. Otherwise, it's deduced from the field's name by converting
 it to camelCase.


�


�

�

� 

	�$

	�


	�

	�

	�"#
�	

�%�	 If true, this is a proto3 "optional". When a proto3 field is optional, it
 tracks presence regardless of field type.

 When proto3_optional is true, this field must be belong to a oneof to
 signal to old proto3 clients that presence is tracked for this field. This
 oneof is known as a "synthetic" oneof, and this field must be its sole
 member (each proto3 optional field gets its own synthetic oneof). Synthetic
 oneofs exist in the descriptor only, and do not generate any API. Synthetic
 oneofs must be ordered after all "real" oneofs.

 For message fields, proto3_optional doesn't create any semantic change,
 since non-repeated message fields always track presence. However it still
 indicates the semantic detail of whether the user wrote "optional" or not.
 This can be useful for round-tripping the .proto file. For consistency we
 give message fields a synthetic oneof also, even though it is not required
 to track presence. This is especially important because the parser can't
 tell if a field is a message or an enum, so it must always create a
 synthetic oneof.

 Proto2 optional fields do not set this flag, because they already indicate
 optional with `LABEL_OPTIONAL`.



�



�


�


�"$
"
� � Describes a oneof.


�

 �

 �


 �

 �

 �

�$

�


�

�

�"#
'
� � Describes an enum type.


�

 �

 �


 �

 �

 �

�.

�


�#

�$)

�,-

�#

�


�

�

�!"
�
 ��� Range of reserved numeric values. Reserved values may not be used by
 entries in the same enum. Reserved ranges may not overlap.

 Note that this is distinct from DescriptorProto.ReservedRange in that it
 is inclusive such that it can appropriately represent the entire int32
 domain.


 �


  �" Inclusive.


  �

  �

  �

  �

 �" Inclusive.


 �

 �

 �

 �
�
�0� Range of reserved numeric values. Reserved numeric values may not be used
 by enum values in the same enum declaration. Reserved ranges may not
 overlap.


�


�

�+

�./
l
�$^ Reserved enum value names, which may not be reused. A given name may only
 be reserved once.


�


�

�

�"#
1
� �# Describes a value within an enum.


� 

 �

 �


 �

 �

 �

�

�


�

�

�

�(

�


�

�#

�&'
$
� � Describes a service.


�

 �

 �


 �

 �

 �

�,

�


� 

�!'

�*+

�&

�


�

�!

�$%
0
	� �" Describes a method of a service.


	�

	 �

	 �


	 �

	 �

	 �
�
	�!� Input and output type names.  These are resolved in the same way as
 FieldDescriptorProto.type_name, but must refer to a message type.


	�


	�

	�

	� 

	�"

	�


	�

	�

	� !

	�%

	�


	�

	� 

	�#$
E
	�77 Identifies if client streams multiple client messages


	�


	�

	� 

	�#$

	�%6

	�05
E
	�77 Identifies if server streams multiple server messages


	�


	�

	� 

	�#$

	�%6

	�05
�

� �2N ===================================================================
 Options
2� Each of the definitions above may have "options" attached.  These are
 just annotations which may cause code to be generated slightly differently
 or may contain hints for code that manipulates protocol messages.

 Clients may define custom options as extensions of the *Options messages.
 These extensions may not yet be known at parsing time, so the parser cannot
 store the values in them.  Instead it stores them in a field in the *Options
 message called uninterpreted_option. This field must have the same name
 across all *Options messages. We then use this field to populate the
 extensions when we build a descriptor, at which point all protos have been
 parsed and so all extensions are known.

 Extension numbers for custom options may be chosen as follows:
 * For options which will only be used within a single application or
   organization, or for experimental options, use field numbers 50000
   through 99999.  It is up to you to ensure that you do not use the
   same number for multiple options.
 * For options which will be published and used publicly by multiple
   independent entities, e-mail protobuf-global-extension-registry@google.com
   to reserve extension numbers. Simply provide your project name (e.g.
   Objective-C plugin) and your project website (if available) -- there's no
   need to explain how you intend to use them. Usually you only need one
   extension number. You can declare multiple options with only one extension
   number by putting them in a sub-message. See the Custom Options section of
   the docs for examples:
   https://developers.google.com/protocol-buffers/docs/proto#options
   If this turns out to be popular, a web service will be set up
   to automatically assign option numbers.



�
�

 �#� Sets the Java package where classes generated from this .proto will be
 placed.  By default, the proto package is used, but this is often
 inappropriate because proto packages do not normally start with backwards
 domain names.



 �



 �


 �


 �!"
�

�+� Controls the name of the wrapper Java class generated for the .proto file.
 That class will always contain the .proto file's getDescriptor() method as
 well as any top-level extensions defined in the .proto file.
 If java_multiple_files is disabled, then all the other classes from the
 .proto file will be nested inside the single wrapper outer class.



�



�


�&


�)*
�

�;� If enabled, then the Java code generator will generate a separate .java
 file for each top-level message, enum, and service defined in the .proto
 file.  Thus, these types will *not* be nested inside the wrapper class
 named by java_outer_classname.  However, the wrapper class will still be
 generated to contain the file's getDescriptor() method as well as any
 top-level extensions defined in the file.



�



�


�#


�&(


�):


�49
)

�E This option does nothing.



�



�


�-


�02


�3D


�4C
�

�>� If set true, then the Java2 code generator will generate code that
 throws an exception whenever an attempt is made to assign a non-UTF-8
 byte sequence to a string field.
 Message reflection will do the same.
 However, an extension field still accepts non-UTF-8 byte sequences.
 This option has no effect on when used with the lite runtime.



�



�


�&


�)+


�,=


�7<
L

 ��< Generated classes can be optimized for speed or code size.



 �
D

  �"4 Generate complete code for parsing, serialization,



  �	


  �
G

 � etc.
"/ Use ReflectionOps to implement these methods.



 �


 �
G

 �"7 Generate code using MessageLite and the lite runtime.



 �


 �


�;


�



�


�$


�'(


�):


�49
�

�"� Sets the Go package where structs generated from this .proto will be
 placed. If omitted, the Go package will be derived from the following:
   - The basename of the package import path, if provided.
   - Otherwise, the package statement in the .proto file, if present.
   - Otherwise, the basename of the .proto file, without extension.



�



�


�


�!
�

�;� Should generic services be generated in each language?  "Generic" services
 are not specific to any particular RPC system.  They are generated by the
 main code generators in each language (without additional plugins).
 Generic services were the only kind of service generation supported by
 early versions of google.protobuf.

 Generic services are now considered deprecated in favor of using plugins
 that generate code specific to your particular RPC system.  Therefore,
 these default to false.  Old code which depends on generic services should
 explicitly set them to true.



�



�


�#


�&(


�):


�49


�=


�



�


�%


�(*


�+<


�6;


	�;


	�



	�


	�#


	�&(


	�):


	�49



�<



�




�



�$



�')



�*;



�5:
�

�2� Is this file deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for everything in the file, or it will be completely ignored; in the very
 least, this is a formalization for deprecating files.



�



�


�


�


� 1


�+0


�7q Enables the use of arenas for the proto messages in this file. This applies
 only to generated classes for C++.



�



�


� 


�#%


�&6


�15
�

�)� Sets the objective c class prefix which is prepended to all objective c
 generated classes from this .proto. There is no default.



�



�


�#


�&(
I

�(; Namespace for generated classes; defaults to the package.



�



�


�"


�%'
�

�$� By default Swift generators will take the proto package and CamelCase it
 replacing '.' with underscore and use that to prefix the types/symbols
 defined. When this options is provided, they will use this value instead
 to prefix the types/symbols defined.



�



�


�


�!#
~

�(p Sets the php class prefix which is prepended to all php generated classes
 from this .proto. Default is empty.



�



�


�"


�%'
�

�%� Use this option to change the namespace of php generated classes. Default
 is empty. When this option is empty, the package name will be used for
 determining the namespace.



�



�


�


�"$
�

�.� Use this option to change the namespace of php generated metadata classes.
 Default is empty. When this option is empty, the proto file name will be
 used for determining the namespace.



�



�


�(


�+-
�

�$� Use this option to change the package of ruby generated classes. Default
 is empty. When this option is not set, the package name will be used for
 determining the ruby package.



�



�


�


�!#
=

�$/ Any features defined in the specific edition.



�



�


�


�!#
|

�:n The parser stores options it doesn't recognize here.
 See the documentation for the "Options" section above.



�



�


�3


�69
�

�z Clients can define custom options in extensions of this message.
 See the documentation for the "Options" section above.



 �


 �


 �


	�


	 �


	 �


	 �

� �

�
�
 �>� Set true to use the old proto1 MessageSet wire format for extensions.
 This is provided for backwards-compatibility with the MessageSet wire
 format.  You should not use this for any other reason:  It's less
 efficient, has fewer features, and is more complicated.

 The message must be defined exactly as follows:
   message Foo {
     option message_set_wire_format = true;
     extensions 4 to max;
   }
 Note that the message cannot have any defined fields; MessageSets only
 have extensions.

 All extensions of your type must be singular messages; e.g. they cannot
 be int32s, enums, or repeated messages.

 Because this is an option, the above two restrictions are not enforced by
 the protocol compiler.


 �


 �

 �'

 �*+

 �,=

 �7<
�
�F� Disables the generation of the standard "descriptor()" accessor, which can
 conflict with a field of the same name.  This is meant to make migration
 from proto1 easier; new code should avoid fields named "descriptor".


�


�

�/

�23

�4E

�?D
�
�1� Is this message deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the message, or it will be completely ignored; in the very least,
 this is a formalization for deprecating messages.


�


�

�

�

�0

�*/

	�

	 �

	 �

	 �

	�

	�

	�

	�

	�

	�
�
�� NOTE: Do not set the option in .proto files. Always use the maps syntax
 instead. The option should only be implicitly set by the proto compiler
 parser.

 Whether the message is an automatically generated map entry type for the
 maps field.

 For maps fields:
     map<KeyType, ValueType> map_field = 1;
 The parsed descriptor looks like:
     message MapFieldEntry {
         option map_entry = true;
         optional KeyType key = 1;
         optional ValueType value = 2;
     }
     repeated MapFieldEntry map_field = 1;

 Implementations may choose not to generate the map_entry=true message, but
 use a native map in the target language to hold the keys and values.
 The reflection APIs in such implementations still need to work as
 if the field is a repeated message field.


�


�

�

�
$
	�" javalite_serializable


	�

	�

	�

	�" javanano_as_lite


	�

	�

	�
�
�P� Enable the legacy handling of JSON field name conflicts.  This lowercases
 and strips underscored from the fields before comparison in proto3 only.
 The new behavior takes `json_name` into account and applies to proto2 as
 well.

 This should only be used as a temporary measure against broken builds due
 to the change in behavior for JSON field name conflicts.

 TODO This is legacy behavior we plan to remove once downstream
 teams have had time to migrate.


�


�

�6

�9;

�<O

�=N
=
�$/ Any features defined in the specific edition.


�


�

�

�!#
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
�
 �.� The ctype option instructs the C++ code generator to use a different
 representation of the field than it normally would.  See the specific
 options below.  This option is only implemented to support use of
 [ctype=CORD] and [ctype=STRING] (the default) on non-repeated fields of
 type "bytes" in the open source release -- sorry, we'll try to include
 other types in a future version!


 �


 �

 �

 �

 �-

 �&,

 ��

 �

  � Default mode.


  �


  �
�
 �� The option [ctype=CORD] may be applied to a non-repeated field of type
 "bytes". It indicates that in C++, the data should be stored in a Cord
 instead of a string.  For very large strings, this may reduce memory
 fragmentation. It may also allow better performance when parsing from a
 Cord, or when parsing with aliasing enabled, as the parsed Cord may then
 alias the original buffer.


 �

 �

 �

 �

 �
�
�� The packed option can be enabled for repeated primitive fields to enable
 a more efficient representation on the wire. Rather than repeatedly
 writing the tag and type for each element, the entire array is encoded as
 a single length-delimited blob. In proto3, only explicit setting it to
 false will avoid using packed encoding.  This option is prohibited in
 Editions, but the `repeated_field_encoding` feature can be used to control
 the behavior.


�


�

�

�
�
�3� The jstype option determines the JavaScript type used for values of the
 field.  The option is permitted only for 64 bit integral and fixed types
 (int64, uint64, sint64, fixed64, sfixed64).  A field with jstype JS_STRING
 is represented as JavaScript string, which avoids loss of precision that
 can happen when a large value is converted to a floating point JavaScript.
 Specifying JS_NUMBER for the jstype causes the generated JavaScript code to
 use the JavaScript "number" type.  The behavior of the default option
 JS_NORMAL is implementation dependent.

 This option is an enum to permit additional types to be added, e.g.
 goog.math.Integer.


�


�

�

�

�2

�(1

��

�
'
 � Use the default type.


 �

 �
)
� Use JavaScript strings.


�

�
)
� Use JavaScript numbers.


�

�
�
�+� Should this field be parsed lazily?  Lazy applies only to message-type
 fields.  It means that when the outer message is initially parsed, the
 inner message's contents will not be parsed but instead stored in encoded
 form.  The inner message will actually be parsed when it is first accessed.

 This is only a hint.  Implementations are free to choose whether to use
 eager or lazy parsing regardless of the value of this option.  However,
 setting this option true suggests that the protocol author believes that
 using lazy parsing on this field is worth the additional bookkeeping
 overhead typically needed to implement it.

 This option does not affect the public interface of any generated code;
 all method signatures remain the same.  Furthermore, thread-safety of the
 interface is not affected by this option; const methods remain safe to
 call from multiple threads concurrently, while non-const methods continue
 to require exclusive access.

 Note that implementations may choose not to check required fields within
 a lazy sub-message.  That is, calling IsInitialized() on the outer message
 may return true even if the inner message has missing required fields.
 This is necessary because otherwise the inner message would have to be
 parsed in order to perform the check, defeating the purpose of lazy
 parsing.  An implementation which chooses not to check required fields
 must be consistent about it.  That is, for any particular sub-message, the
 implementation must either *always* check its required fields, or *never*
 check its required fields, regardless of whether or not the message has
 been parsed.

 As of May 2022, lazy verifies the contents of the byte stream during
 parsing.  An invalid byte stream will cause the overall parsing to fail.


�


�

�

�

�*

�$)
�
�7� unverified_lazy does no correctness checks on the byte stream. This should
 only be used where lazy with verification is prohibitive for performance
 reasons.


�


�

�

�"$

�%6

�05
�
�1� Is this field deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for accessors, or it will be completely ignored; in the very least, this
 is a formalization for deprecating fields.


�


�

�

�

�0

�*/
?
�,1 For Google-internal migration only. Do not use.


�


�

�

�

�+

�%*
�
�4� Indicate that the field value should not be printed out when using debug
 formats, e.g. when the field contains sensitive credentials.


�


�

�

�!

�"3

�-2
�
��� If set to RETENTION_SOURCE, the option will be omitted from the binary.
 Note: as of January 2023, support for this is in progress and does not yet
 have an effect (b/264593489).


�

 �

 �

 �

�

�

�

�

�

�

�*

�


�

�$

�')
�
��� This indicates the types of entities that the field may apply to when used
 as an option. If it is unset, then the field may be freely used as an
 option on any kind of entity. Note: as of January 2023, support for this is
 in progress and does not yet have an effect (b/264593489).


�

 �

 �

 �

�

�

�

�$

�

�"#

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

	�

	�

	�

	�)

	�


	�

	�#

	�&(

 ��

 �


  �!

  �

  �

  �

  � 
"
 �" Textproto value.


 �

 �

 �

 �


�0


�



�


�*


�-/
=
�$/ Any features defined in the specific edition.


�


�

�

�!#
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

	�" removed jtype


	 �

	 �

	 �
9
	�", reserve target, target_obsolete_do_not_use


	�

	�

	�

� �

�
=
 �#/ Any features defined in the specific edition.


 �


 �

 �

 �!"
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
`
 � R Set this option to true to allow mapping different tag names to the same
 value.


 �


 �

 �

 �
�
�1� Is this enum deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the enum, or it will be completely ignored; in the very least, this
 is a formalization for deprecating enums.


�


�

�

�

�0

�*/

	�" javanano_as_lite


	 �

	 �

	 �
�
�O� Enable the legacy handling of JSON field name conflicts.  This lowercases
 and strips underscored from the fields before comparison in proto3 only.
 The new behavior takes `json_name` into account and applies to proto2 as
 well.
 TODO Remove this legacy behavior once downstream teams have
 had time to migrate.


�


�

�6

�9:

�;N

�<M
=
�#/ Any features defined in the specific edition.


�


�

�

�!"
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
�
 �1� Is this enum value deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the enum value, or it will be completely ignored; in the very least,
 this is a formalization for deprecating enum values.


 �


 �

 �

 �

 �0

 �*/
=
�#/ Any features defined in the specific edition.


�


�

�

�!"
�
�3� Indicate that fields annotated with this enum value should not be printed
 out when using debug formats, e.g. when the field contains sensitive
 credentials.


�


�

�

� 

�!2

�,1
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
=
 �$/ Any features defined in the specific edition.


 �


 �

 �

 �!#
�
�2� Is this service deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the service, or it will be completely ignored; in the very least,
 this is a formalization for deprecating services.
2� Note:  Field numbers 1 through 32 are reserved for Google's internal RPC
   framework.  We apologize for hoarding these numbers to ourselves, but
   we were already using them long before we decided to release Protocol
   Buffers.


�


�

�

�

� 1

�+0
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
�
 �2� Is this method deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the method, or it will be completely ignored; in the very least,
 this is a formalization for deprecating methods.
2� Note:  Field numbers 1 through 32 are reserved for Google's internal RPC
   framework.  We apologize for hoarding these numbers to ourselves, but
   we were already using them long before we decided to release Protocol
   Buffers.


 �


 �

 �

 �

 � 1

 �+0
�
 ��� Is this method side-effect-free (or safe in HTTP parlance), or idempotent,
 or neither? HTTP based RPC implementation may choose GET verb for safe
 methods, and PUT verb for idempotent methods instead of the default POST.


 �

  �

  �

  �
$
 �" implies idempotent


 �

 �
7
 �"' idempotent, but may have side effects


 �

 �

��&

�


�

�-

�02

�%

�$
=
�$/ Any features defined in the specific edition.


�


�

�

�!#
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �
�
� �� A message representing a option the parser does not recognize. This only
 appears in options protos created by the compiler::Parser class.
 DescriptorPool resolves these when building Descriptor objects. Therefore,
 options protos in descriptor objects (e.g. returned by Descriptor::options(),
 or produced by Descriptor::CopyTo()) will never have UninterpretedOptions
 in them.


�
�
 ��� The name of the uninterpreted option.  Each string represents a segment in
 a dot-separated name.  is_extension is true iff a segment represents an
 extension (denoted with parentheses in options specs in .proto files).
 E.g.,{ ["foo", false], ["bar.baz", true], ["moo", false] } represents
 "foo.(bar.baz).moo".


 �


  �"

  �

  �

  �

  � !

 �#

 �

 �

 �

 �!"

 �

 �


 �

 �

 �
�
�'� The value of the uninterpreted option, in whatever type the tokenizer
 identified it as during parsing. Exactly one of these should be set.


�


�

�"

�%&

�)

�


�

�$

�'(

�(

�


�

�#

�&'

�#

�


�

�

�!"

�"

�


�

�

� !

�&

�


�

�!

�$%
�
� �� TODO Enums in C++ gencode (and potentially other languages) are
 not well scoped.  This means that each of the feature enums below can clash
 with each other.  The short names we've chosen maximize call-site
 readability, but leave us very open to this scenario.  A future feature will
 be designed and implemented to handle this, hopefully before we ever hit a
 conflict here.
2O ===================================================================
 Features


�

 ��

 �

  �

  �

  �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 ��

 �


 �

 �'

 �*+

 �,�

 �!

  �

 �

  �E

 �E

 �C

��

�

 �

 �

 �

�

�

�

�

�


�

��

�


�

�

� !

�"�

�!

 �

�

 �C

�A

��

�

 �(

 �#

 �&'

�

�


�

�

�

�

��

�


� 

�!8

�;<

�=�

�!

 �

�

 �E

�C

��

�

 � 

 �

 �

�

�

�

�

�


�

��

�


�

�)

�,-

�.�

�!

 �

�

 �A

�C

��

�

 �!

 �

 � 

�

�

�

�

�

�

��

�


�

�+

�./

�0�

�!

 �

�

 �L

��

�

 �

 �

 �

�

�	

�

�

�

�

��

�


�

�!

�$%

�&�

�!

 �!

�

�

 �O

�B

	�

	 �

	 �

	 �

�" for Protobuf C++


 �

 �

 �
 
�" for Protobuf Java


�

�

�
#
�" For internal testing


�

�

�
�
� �� A compiled specification for the defaults of a set of features.  These
 messages are generated from FeatureSet extensions and can be used to seed
 feature resolution. The resolution with this object becomes a simple search
 for the closest matching edition, followed by proto merges.


�
�
 ��� A map from every known edition with a unique set of defaults to its
 defaults. Not all editions may be contained here.  For a given edition,
 the defaults at the closest matching edition ordered at or before it should
 be used.  This field must be in strict ascending order by edition.


 �
"

  �!

  �

  �

  �

  � 

 �%

 �

 �

 � 

 �#$

 �1

 �


 �#

 �$,

 �/0
�
�'t The minimum supported edition (inclusive) when this was constructed.
 Editions before this will not have defaults.


�


�

�"

�%&
�
�'x The maximum known edition (inclusive) when this was constructed. Editions
 after this will not have reliable defaults.


�


�

�"

�%&
�
� �	j Encapsulates information about the original source file from which a
 FileDescriptorProto was generated.
2` ===================================================================
 Optional source code info


�
�
 �!� A Location identifies a piece of source code in a .proto file which
 corresponds to a particular definition.  This information is intended
 to be useful to IDEs, code indexers, documentation generators, and similar
 tools.

 For example, say we have a file like:
   message Foo {
     optional string foo = 1;
   }
 Let's look at just the field definition:
   optional string foo = 1;
   ^       ^^     ^^  ^  ^^^
   a       bc     de  f  ghi
 We have the following locations:
   span   path               represents
   [a,i)  [ 4, 0, 2, 0 ]     The whole field definition.
   [a,b)  [ 4, 0, 2, 0, 4 ]  The label (optional).
   [c,d)  [ 4, 0, 2, 0, 5 ]  The type (string).
   [e,f)  [ 4, 0, 2, 0, 1 ]  The name (foo).
   [g,h)  [ 4, 0, 2, 0, 3 ]  The number (1).

 Notes:
 - A location may refer to a repeated field itself (i.e. not to any
   particular index within it).  This is used whenever a set of elements are
   logically enclosed in a single code segment.  For example, an entire
   extend block (possibly containing multiple extension definitions) will
   have an outer location whose path refers to the "extensions" repeated
   field without an index.
 - Multiple locations may have the same path.  This happens when a single
   logical declaration is spread out across multiple places.  The most
   obvious example is the "extend" block again -- there may be multiple
   extend blocks in the same scope, each of which will have the same path.
 - A location's span is not always a subset of its parent's span.  For
   example, the "extendee" of an extension declaration appears at the
   beginning of the "extend" block and is shared by all extensions within
   the block.
 - Just because a location's span is a subset of some other location's span
   does not mean that it is a descendant.  For example, a "group" defines
   both a type and a field in a single declaration.  Thus, the locations
   corresponding to the type and field and their components will overlap.
 - Code which tries to interpret locations should probably be designed to
   ignore those that it doesn't understand, as more types of locations could
   be recorded in the future.


 �


 �

 �

 � 

 ��	

 �

�
  �,� Identifies which part of the FileDescriptorProto was defined at this
 location.

 Each element is a field number or an index.  They form a path from
 the root FileDescriptorProto to the place where the definition occurs.
 For example, this path:
   [ 4, 3, 2, 7, 1 ]
 refers to:
   file.message_type(3)  // 4, 3
       .field(7)         // 2, 7
       .name()           // 1
 This is because FileDescriptorProto.message_type has field number 4:
   repeated DescriptorProto message_type = 4;
 and DescriptorProto.field has field number 2:
   repeated FieldDescriptorProto field = 2;
 and FieldDescriptorProto.name has field number 1:
   optional string name = 1;

 Thus, the above path gives the location of a field name.  If we removed
 the last element:
   [ 4, 3, 2, 7 ]
 this path refers to the whole field declaration (from the beginning
 of the label to the terminating semicolon).


  �

  �

  �

  �

  �+

  �*
�
 �,� Always has exactly three or four elements: start line, start column,
 end line (optional, otherwise assumed same as start line), end column.
 These are packed into a single field for efficiency.  Note that line
 and column numbers are zero-based -- typically you will want to add
 1 to each before displaying to a user.


 �

 �

 �

 �

 �+

 �*
�
 �	)� If this SourceCodeInfo represents a complete declaration, these are any
 comments appearing before and after the declaration which appear to be
 attached to the declaration.

 A series of line comments appearing on consecutive lines, with no other
 tokens appearing on those lines, will be treated as a single comment.

 leading_detached_comments will keep paragraphs of comments that appear
 before (but not connected to) the current element. Each paragraph,
 separated by empty lines, will be one comment element in the repeated
 field.

 Only the comment content is provided; comment markers (e.g. //) are
 stripped out.  For block comments, leading whitespace and an asterisk
 will be stripped from the beginning of each line other than the first.
 Newlines are included in the output.

 Examples:

   optional int32 foo = 1;  // Comment attached to foo.
   // Comment attached to bar.
   optional int32 bar = 2;

   optional string baz = 3;
   // Comment attached to baz.
   // Another line attached to baz.

   // Comment attached to moo.
   //
   // Another line attached to moo.
   optional double moo = 4;

   // Detached comment for corge. This is not leading or trailing comments
   // to moo or corge because there are blank lines separating it from
   // both.

   // Detached comment for corge paragraph 2.

   optional string corge = 5;
   /* Block comment attached
    * to corge.  Leading asterisks
    * will be removed. */
   /* Block comment attached to
    * grault. */
   optional int32 grault = 6;

   // ignored detached comments.


 �	

 �	

 �	$

 �	'(

 �	*

 �	

 �	

 �	%

 �	()

 �	2

 �	

 �	

 �	-

 �	01
�
�	 �	� Describes the relationship between generated code and its original source
 file. A GeneratedCodeInfo message is associated with only one generated
 source file, but may contain references to different source .proto files.


�	
x
 �	%j An Annotation connects some span of text in generated code to an element
 of its generating .proto file.


 �	


 �	

 �	 

 �	#$

 �	�	

 �	

�
  �	, Identifies the element in the original source .proto file. This field
 is formatted the same as SourceCodeInfo.Location.path.


  �	

  �	

  �	

  �	

  �	+

  �	*
O
 �	$? Identifies the filesystem path to the original source .proto.


 �	

 �	

 �	

 �	"#
w
 �	g Identifies the starting offset in bytes in the generated code
 that relates to the identified object.


 �	

 �	

 �	

 �	
�
 �	� Identifies the ending offset in bytes in the generated code that
 relates to the identified object. The end offset should be one past
 the last relevant byte (so the length of the text = end - begin).


 �	

 �	

 �	

 �	
j
  �	�	X Represents the identified object's effect on the element in the original
 .proto file.


  �		
F
   �	4 There is no effect or the effect is indescribable.


	   �	


	   �	
<
  �	* The element is set or otherwise mutated.


	  �		

	  �	
8
  �	& An alias to the element is returned.


	  �	

	  �	

 �	#

 �	

 �	

 �	

 �	!"
�
google/api/annotations.proto
google.apigoogle/api/http.proto google/protobuf/descriptor.proto:K
http.google.protobuf.MethodOptions�ʼ" (2.google.api.HttpRuleRhttpBn
com.google.apiBAnnotationsProtoPZAgoogle.golang.org/genproto/googleapis/api/annotations;annotations�GAPIJ�
 
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  
	
 *

 X
	
 X

 "
	

 "

 1
	
 1

 '
	
 '

 "
	
$ "
	
 

  See `HttpRule`.



 $


 



 


 bproto3
�1
google/protobuf/timestamp.protogoogle.protobuf";
	Timestamp
seconds (Rseconds
nanos (RnanosB�
com.google.protobufBTimestampProtoPZ2google.golang.org/protobuf/types/known/timestamppb��GPB�Google.Protobuf.WellKnownTypesJ�/
 �
�
 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


  

" 
	
" 

# I
	
# I

$ ,
	
$ ,

% /
	
% /

& "
	

& "

' !
	
$' !

( ;
	
%( ;
�
 � �� A Timestamp represents a point in time independent of any time zone or local
 calendar, encoded as a count of seconds and fractions of seconds at
 nanosecond resolution. The count is relative to an epoch at UTC midnight on
 January 1, 1970, in the proleptic Gregorian calendar which extends the
 Gregorian calendar backwards to year one.

 All minutes are 60 seconds long. Leap seconds are "smeared" so that no leap
 second table is needed for interpretation, using a [24-hour linear
 smear](https://developers.google.com/time/smear).

 The range is from 0001-01-01T00:00:00Z to 9999-12-31T23:59:59.999999999Z. By
 restricting to that range, we ensure that we can convert to and from [RFC
 3339](https://www.ietf.org/rfc/rfc3339.txt) date strings.

 # Examples

 Example 1: Compute Timestamp from POSIX `time()`.

     Timestamp timestamp;
     timestamp.set_seconds(time(NULL));
     timestamp.set_nanos(0);

 Example 2: Compute Timestamp from POSIX `gettimeofday()`.

     struct timeval tv;
     gettimeofday(&tv, NULL);

     Timestamp timestamp;
     timestamp.set_seconds(tv.tv_sec);
     timestamp.set_nanos(tv.tv_usec * 1000);

 Example 3: Compute Timestamp from Win32 `GetSystemTimeAsFileTime()`.

     FILETIME ft;
     GetSystemTimeAsFileTime(&ft);
     UINT64 ticks = (((UINT64)ft.dwHighDateTime) << 32) | ft.dwLowDateTime;

     // A Windows tick is 100 nanoseconds. Windows epoch 1601-01-01T00:00:00Z
     // is 11644473600 seconds before Unix epoch 1970-01-01T00:00:00Z.
     Timestamp timestamp;
     timestamp.set_seconds((INT64) ((ticks / 10000000) - 11644473600LL));
     timestamp.set_nanos((INT32) ((ticks % 10000000) * 100));

 Example 4: Compute Timestamp from Java `System.currentTimeMillis()`.

     long millis = System.currentTimeMillis();

     Timestamp timestamp = Timestamp.newBuilder().setSeconds(millis / 1000)
         .setNanos((int) ((millis % 1000) * 1000000)).build();

 Example 5: Compute Timestamp from Java `Instant.now()`.

     Instant now = Instant.now();

     Timestamp timestamp =
         Timestamp.newBuilder().setSeconds(now.getEpochSecond())
             .setNanos(now.getNano()).build();

 Example 6: Compute Timestamp from current time in Python.

     timestamp = Timestamp()
     timestamp.GetCurrentTime()

 # JSON Mapping

 In JSON format, the Timestamp type is encoded as a string in the
 [RFC 3339](https://www.ietf.org/rfc/rfc3339.txt) format. That is, the
 format is "{year}-{month}-{day}T{hour}:{min}:{sec}[.{frac_sec}]Z"
 where {year} is always expressed using four digits while {month}, {day},
 {hour}, {min}, and {sec} are zero-padded to two digits each. The fractional
 seconds, which can go up to 9 digits (i.e. up to 1 nanosecond resolution),
 are optional. The "Z" suffix indicates the timezone ("UTC"); the timezone
 is required. A proto3 JSON serializer should always use UTC (as indicated by
 "Z") when printing the Timestamp type and a proto3 JSON parser should be
 able to accept both UTC and other timezones (as indicated by an offset).

 For example, "2017-01-15T01:30:15.01Z" encodes 15.01 seconds past
 01:30 UTC on January 15, 2017.

 In JavaScript, one can convert a Date object to this format using the
 standard
 [toISOString()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/toISOString)
 method. In Python, a standard `datetime.datetime` object can be converted
 to this format using
 [`strftime`](https://docs.python.org/2/library/time.html#time.strftime) with
 the time format spec '%Y-%m-%dT%H:%M:%S.%fZ'. Likewise, in Java, one can use
 the Joda Time's [`ISODateTimeFormat.dateTime()`](
 http://joda-time.sourceforge.net/apidocs/org/joda/time/format/ISODateTimeFormat.html#dateTime()
 ) to obtain a formatter capable of generating timestamps in this format.



 �
�
  �� Represents seconds of UTC time since Unix epoch
 1970-01-01T00:00:00Z. Must be from 0001-01-01T00:00:00Z to
 9999-12-31T23:59:59Z inclusive.


  �

  �

  �
�
 �� Non-negative fractions of a second at nanosecond resolution. Negative
 second values with fractions must still have non-negative nanos values
 that count forward in time. Must be from 0 to 999,999,999
 inclusive.


 �

 �

 �bproto3
�"
google/protobuf/struct.protogoogle.protobuf"�
Struct;
fields (2#.google.protobuf.Struct.FieldsEntryRfieldsQ
FieldsEntry
key (	Rkey,
value (2.google.protobuf.ValueRvalue:8"�
Value;

null_value (2.google.protobuf.NullValueH R	nullValue#
number_value (H RnumberValue#
string_value (	H RstringValue

bool_value (H R	boolValue<
struct_value (2.google.protobuf.StructH RstructValue;

list_value (2.google.protobuf.ListValueH R	listValueB
kind";
	ListValue.
values (2.google.protobuf.ValueRvalues*
	NullValue

NULL_VALUE B
com.google.protobufBStructProtoPZ/google.golang.org/protobuf/types/known/structpb��GPB�Google.Protobuf.WellKnownTypesJ�
 ^
�
 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


  

" 
	
" 

# F
	
# F

$ ,
	
$ ,

% ,
	
% ,

& "
	

& "

' !
	
$' !

( ;
	
%( ;
�
 2 5� `Struct` represents a structured data value, consisting of fields
 which map to dynamically typed values. In some languages, `Struct`
 might be supported by a native representation. For example, in
 scripting languages like JS a struct is represented as an
 object. The details of that representation are described together
 with the proto support for the language.

 The JSON representation for `Struct` is JSON object.



 2
9
  4 , Unordered map of dynamically typed values.


  4

  4

  4
�
= M� `Value` represents a dynamically typed value which can be either
 null, a number, a string, a boolean, a recursive struct value, or a
 list of values. A producer of value is expected to set one of these
 variants. Absence of any variant indicates an error.

 The JSON representation for `Value` is JSON value.



=
"
 ?L The kind of value.


 ?
'
 A Represents a null value.


 A

 A

 A
)
C Represents a double value.


C


C

C
)
E Represents a string value.


E


E

E
*
G Represents a boolean value.


G

G	

G
-
I  Represents a structured value.


I


I

I
-
K  Represents a repeated `Value`.


K

K

K
�
 S V� `NullValue` is a singleton enumeration to represent the null value for the
 `Value` type union.

 The JSON representation for `NullValue` is JSON `null`.



 S

  U Null value.


  U

  U
�
[ ^v `ListValue` is a wrapper around a repeated field of values.

 The JSON representation for `ListValue` is JSON array.



[
:
 ]- Repeated field of dynamically typed values.


 ]


 ]

 ]

 ]bproto3
�F
base_data_type.protodatagoogle/protobuf/struct.protogoogle/protobuf/timestamp.proto"\
DocumentStatus
value (	Rvalue
name (	Rname 
description (	Rdescription"\
DocumentAction
value (	Rvalue
name (	Rname 
description (	Rdescription"�

LookupItem
id (Rid

table_name (	R	tableName/
values (2.google.protobuf.StructRvalues
	is_active (RisActive"�
ListLookupItemsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords0
process_parameter_id
 (RprocessParameterId
field_id (RfieldId&
browse_field_id (RbrowseFieldId!
reference_id (RreferenceId
	column_id (RcolumnId

table_name (	R	tableName
column_name (	R
columnName2
is_without_validation (RisWithoutValidation"�
ListLookupItemsResponse!
record_count (RrecordCount*
records (2.data.LookupItemRrecords&
next_page_token (	RnextPageToken"g
KeyValueSelection!
selection_id (RselectionId/
values (2.google.protobuf.StructRvalues"h
Entity
id (Rid

table_name (	R	tableName/
values (2.google.protobuf.StructRvalues"�
ListEntitiesResponse!
record_count (RrecordCount&
records (2.data.EntityRrecords&
next_page_token (	RnextPageToken"�
ProcesInstanceParameter
id (Rid
name (	Rname
column_name (	R
columnName,
value (2.google.protobuf.ValueRvalue1
value_to (2.google.protobuf.ValueRvalueTo"�

ProcessLog
id (Rid
name (	Rname 
description (	Rdescription
instance_id (R
instanceId
is_error (RisError
summary (	Rsummary*
result_table_name (	RresultTableName#
is_processing (RisProcessing5
last_run	 (2.google.protobuf.TimestampRlastRun(
logs
 (2.data.ProcessInfoLogRlogs7

parameters (2.google.protobuf.StructR
parameters*
output (2.data.ReportOutputRoutput[
process_intance_parameters (2.data.ProcesInstanceParameterRprocessIntanceParameters"?
ProcessInfoLog
	record_id (RrecordId
log (	Rlog"�
ReportOutput
id (Rid
name (	Rname 
description (	Rdescription
	file_name (	RfileName
output (	Routput
	mime_type (	RmimeType
	data_cols (RdataCols
	data_rows (RdataRows
header_name	 (	R
headerName
footer_name
 (	R
footerName&
print_format_id (RprintFormatId$
report_view_id (RreportViewId

table_name (	R	tableName#
output_stream (RoutputStream
report_type (	R
reportTypeB/
org.spin.backend.grpc.commonBADempiereBasePJ�/
 �
�	
 �	***********************************************************************************
 Copyright (C) 2012-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Yamel Senih ysenih@erpya.com                                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 5
	
 5

 .
	
 .
	
  &
	
 )

 

   Document Item



 

  

  

  

  

 

 

 

 

 

 

 

 

" & Document Item



"

 #

 #

 #

 #

$

$

$

$

%

%

%

%

) . Lookup Item



)

 *

 *

 *

 *

+

+

+

+

,*

,

,%

,()

-

-

-

-


0 D


0

 1

 1

 1

 1

2

2

2

2

3*

3

3

3%

3()

4+

4

4

4&

4)*

5

5

5

5

6

6

6

6

7 

7

7

7

8&

8

8!

8$%

9(

9

9#

9&'

	;( references


	;

	;"

	;%'


<


<


<


<

=#

=

=

= "

> 

>

>

>

?

?

?

?

@

@

@

@

A 

A

A

A

C(


C

C"

C%'


F J


F

 G

 G

 G

 G

H(

H

H

H#

H&'

I#

I

I

I!"
!
M P	Entities Selections



M

 N

 N

 N

 N

O*

O

O%

O()
)
S W Value Object from ADempiere



S

 T

 T

 T

 T

U

U

U

U

V*

V

V%

V()


Y ]


Y

 Z

 Z

 Z

 Z

[$

[

[

[

["#

\#

\

\

\!"
6
` f*	Response with log and values from server



`

 a

 a

 a

 a

b

b

b

b

c

c

c

c

d(

d

d#

d&'

e+

e

e&

e)*


	h v


	h

	 i

	 i

	 i

	 i

	j

	j

	j

	j

	k

	k

	k

	k

	l

	l

	l

	l

	m

	m

	m

	m

	n

	n

	n

	n

	o%

	o

	o 

	o#$

	p

	p

	p

	p

	q/

	q!

	q"*

	q-.

		r*

		r

		r

		r $

		r')

	
s/

	
s

	
s)

	
s,.

	t!

	t

	t

	t 

	uI

	u

	u(

	u)C

	uFH
(

y |	BusinessProcess Log result




y


 z


 z


 z


 z


{


{


{


{
�
� ��	Used for get output from report / BusinessProcess like PDF, HTML another result for show to end user
 TODO: Move to report_management


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

	� 

	�

	�

	�


�#


�


�


� "

�"

�

�

�!

�

�

�

�

�!

�

�

� 

� 	Output Type


�

�

�bproto3
��
bank_statement_match.protobank_statement_matchgoogle/api/annotations.protogoogle/protobuf/timestamp.protobase_data_type.proto"h
Bank
id (Rid
name (	Rname

routing_no (	R	routingNo

swift_code (	R	swiftCode"�
BankAccount
id (Rid
name (	Rname

account_no (	R	accountNo&
account_no_mask (	RaccountNoMask.
bank (2.bank_statement_match.BankRbank:
currency (2.bank_statement_match.CurrencyRcurrency'
current_balance (	RcurrentBalance"�
BankStatement
id (RidD
bank_account (2!.bank_statement_match.BankAccountRbankAccount
document_no (	R
documentNo
name (	RnameA
statement_date (2.google.protobuf.TimestampRstatementDate 
description (	Rdescription
	is_manual (RisManual'
document_status (	RdocumentStatus!
is_processed	 (RisProcessed+
beginning_balance
 (	RbeginningBalance1
statement_difference (	RstatementDifference%
ending_balance (	RendingBalance")
GetBankStatementRequest
id (Rid"�
ListBankStatementsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListBankStatementsResponse!
record_count (RrecordCount=
records (2#.bank_statement_match.BankStatementRrecords&
next_page_token (	RnextPageToken"�
ListBankAccountsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
BusinessPartner
id (Rid
value (	Rvalue
tax_id (	RtaxId
name (	Rname 
description (	Rdescription"�
ListBusinessPartnersRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListBusinessPartnersResponse!
record_count (RrecordCount?
records (2%.bank_statement_match.BusinessPartnerRrecords&
next_page_token (	RnextPageToken"�
ListSearchModesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"W
Currency
id (Rid
iso_code (	RisoCode 
description (	Rdescription"h

TenderType
id (Rid
value (	Rvalue
name (	Rname 
description (	Rdescription"�
 ListImportedBankMovementsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue*
bank_statement_id (RbankStatementId&
bank_account_id	 (RbankAccountId.
payment_amount_from
 (	RpaymentAmountFrom*
payment_amount_to (	RpaymentAmountToN
transaction_date_from (2.google.protobuf.TimestampRtransactionDateFromJ
transaction_date_to (2.google.protobuf.TimestampRtransactionDateTo>

match_mode (2.bank_statement_match.MatchModeR	matchMode"�
ImportedBankMovement
id (RidE
transaction_date (2.google.protobuf.TimestampRtransactionDate

is_receipt (R	isReceipt!
reference_no (	RreferenceNoP
business_partner (2%.bank_statement_match.BusinessPartnerRbusinessPartner:
currency (2.bank_statement_match.CurrencyRcurrency
amount (	Ramount
memo (	Rmemo

payment_id	 (R	paymentId3
bank_statement_line_id
 (RbankStatementLineId"�
!ListImportedBankMovementsResponse!
record_count (RrecordCountD
records (2*.bank_statement_match.ImportedBankMovementRrecords&
next_page_token (	RnextPageToken"�
ListPaymentsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue*
bank_statement_id (RbankStatementId&
bank_account_id	 (RbankAccountId.
business_partner_id
 (RbusinessPartnerId.
payment_amount_from (	RpaymentAmountFrom*
payment_amount_to (	RpaymentAmountToN
transaction_date_from (2.google.protobuf.TimestampRtransactionDateFromJ
transaction_date_to (2.google.protobuf.TimestampRtransactionDateTo>

match_mode (2.bank_statement_match.MatchModeR	matchMode"�
Payment
id (RidE
transaction_date (2.google.protobuf.TimestampRtransactionDate

is_receipt (R	isReceipt
document_no (	R
documentNoP
business_partner (2%.bank_statement_match.BusinessPartnerRbusinessPartnerA
tender_type (2 .bank_statement_match.TenderTypeR
tenderType:
currency (2.bank_statement_match.CurrencyRcurrency
amount (	Ramount 
description	 (	Rdescription"�
ListPaymentsResponse!
record_count (RrecordCount7
records (2.bank_statement_match.PaymentRrecords&
next_page_token (	RnextPageToken"�
ListMatchingMovementsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue*
bank_statement_id (RbankStatementId&
bank_account_id	 (RbankAccountId.
business_partner_id
 (RbusinessPartnerId.
payment_amount_from (	RpaymentAmountFrom*
payment_amount_to (	RpaymentAmountToN
transaction_date_from (2.google.protobuf.TimestampRtransactionDateFromJ
transaction_date_to (2.google.protobuf.TimestampRtransactionDateTo>

match_mode (2.bank_statement_match.MatchModeR	matchMode"�
MatchingMovement
id (RidE
transaction_date (2.google.protobuf.TimestampRtransactionDate

is_receipt (R	isReceipt
document_no (	R
documentNoP
business_partner (2%.bank_statement_match.BusinessPartnerRbusinessPartnerA
tender_type (2 .bank_statement_match.TenderTypeR
tenderType:
currency (2.bank_statement_match.CurrencyRcurrency
amount (	Ramount 
description	 (	Rdescription!
reference_no
 (	RreferenceNo
memo (	Rmemo

payment_id (R	paymentId!
is_automatic (RisAutomatic%
payment_amount (	RpaymentAmount=
payment_date (2.google.protobuf.TimestampRpaymentDate"�
ListMatchingMovementsResponse!
record_count (RrecordCount@
records (2&.bank_statement_match.MatchingMovementRrecords&
next_page_token (	RnextPageToken"�
ResultMovement
id (RidE
transaction_date (2.google.protobuf.TimestampRtransactionDate

is_receipt (R	isReceipt
document_no (	R
documentNoP
business_partner (2%.bank_statement_match.BusinessPartnerRbusinessPartnerA
tender_type (2 .bank_statement_match.TenderTypeR
tenderType:
currency (2.bank_statement_match.CurrencyRcurrency
amount (	Ramount 
description	 (	Rdescription!
reference_no
 (	RreferenceNo
memo (	Rmemo

payment_id (R	paymentId!
is_automatic (RisAutomatic%
payment_amount (	RpaymentAmount=
payment_date (2.google.protobuf.TimestampRpaymentDate"�
ListResultMovementsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue*
bank_statement_id (RbankStatementId&
bank_account_id	 (RbankAccountId.
payment_amount_from
 (	RpaymentAmountFrom*
payment_amount_to (	RpaymentAmountToN
transaction_date_from (2.google.protobuf.TimestampRtransactionDateFromJ
transaction_date_to (2.google.protobuf.TimestampRtransactionDateTo"�
ListResultMovementsResponse!
record_count (RrecordCount>
records (2$.bank_statement_match.ResultMovementRrecords&
next_page_token (	RnextPageToken"[
KeyMatch

payment_id (R	paymentId0
imported_movement_id (RimportedMovementId"W
MatchPaymentsRequest?
key_matches (2.bank_statement_match.KeyMatchR
keyMatches"1
MatchPaymentsResponse
message (	Rmessage"N
UnmatchPaymentsRequest4
imported_movements_ids (RimportedMovementsIds"3
UnmatchPaymentsResponse
message (	Rmessage"�
ProcessMovementsRequest*
bank_statement_id (RbankStatementId&
bank_account_id (RbankAccountId.
payment_amount_from (	RpaymentAmountFrom*
payment_amount_to (	RpaymentAmountToN
transaction_date_from (2.google.protobuf.TimestampRtransactionDateFromJ
transaction_date_to (2.google.protobuf.TimestampRtransactionDateTo"4
ProcessMovementsResponse
message (	Rmessage*3
	MatchMode
MODE_NOT_MATCHED 
MODE_MATCHED2�
BankStatementMatch�
GetBankStatement-.bank_statement_match.GetBankStatementRequest#.bank_statement_match.BankStatement"2���,*/bank-statement-match/bank-statements/{id}�
ListBankStatements/.bank_statement_match.ListBankStatementsRequest0.bank_statement_match.ListBankStatementsResponse"-���'%/bank-statement-match/bank-statements�
ListBankAccounts-.bank_statement_match.ListBankAccountsRequest.data.ListLookupItemsResponse"&��� /bank-statement-match/accounts�
ListBusinessPartners1.bank_statement_match.ListBusinessPartnersRequest.data.ListLookupItemsResponse"/���)'/bank-statement-match/business-partners�
ListSearchModes,.bank_statement_match.ListSearchModesRequest.data.ListLookupItemsResponse"*���$"/bank-statement-match/search-modes�
ListImportedBankMovements6.bank_statement_match.ListImportedBankMovementsRequest7.bank_statement_match.ListImportedBankMovementsResponse"0���*(/bank-statement-match/imported-movements�
ListPayments).bank_statement_match.ListPaymentsRequest*.bank_statement_match.ListPaymentsResponse"&��� /bank-statement-match/payments�
ListMatchingMovements2.bank_statement_match.ListMatchingMovementsRequest3.bank_statement_match.ListMatchingMovementsResponse"0���*(/bank-statement-match/matching-movements�
ListResultMovements0.bank_statement_match.ListResultMovementsRequest1.bank_statement_match.ListResultMovementsResponse"'���!/bank-statement-match/movements�
MatchPayments*.bank_statement_match.MatchPaymentsRequest+.bank_statement_match.MatchPaymentsResponse"/���)"$/bank-statement-match/match-payments:*�
UnmatchPayments,.bank_statement_match.UnmatchPaymentsRequest-.bank_statement_match.UnmatchPaymentsResponse"1���+"&/bank-statement-match/unmatch-payments:*�
ProcessMovements-.bank_statement_match.ProcessMovementsRequest..bank_statement_match.ProcessMovementsResponse"2���,"'/bank-statement-match/process-movements:*BP
/org.spin.backend.grpc.form.bank_statement_matchBADempiereBankStatementMatchPJ�
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 H
	
 H

 <
	
 <
	
  &
	
 )
	
 
,
 2" Base URL
 /bank-statement-match/

�
 " S� The Banck Statement Match form service definition.
 - org.spin.apps.form.BankStatementMatchController
 - org.spin.apps.form.VBankStatementMatch
 - org.spin.apps.form.WBankStatementMatch



 "

  $&	 lists criteria


  $

  $4

  $?L

  %a

	  �ʼ"%a

 ')	

 '

 '8

 'C]

 (\

	 �ʼ"(\

 *,	

 *

 *4

 *?[

 +U

	 �ʼ"+U

 -/	

 - 

 -!<

 -Gc

 .^

	 �ʼ".^

 02	

 0

 02

 0=Y

 1Y

	 �ʼ"1Y

 46		 results


 4%

 4&F

 4Qr

 5_

	 �ʼ"5_

 79	

 7

 7,

 77K

 8U

	 �ʼ"8U

 :<	

 :!

 :">

 :If

 ;_

	 �ʼ";_

 =?	

 =

 = :

 =E`

 >V

	 �ʼ">V

 	AF		 process


 	A

 	A.

 	A9N

 	BE

	 	�ʼ"BE

 
GL	

 
G

 
G2

 
G=T

 
HK

	 
�ʼ"HK

 MR	

 M

 M4

 M?W

 NQ

	 �ʼ"NQ

 V [ Bank



 V

  W

  W

  W

  W

 X

 X

 X

 X

 Y

 Y

 Y

 Y

 Z

 Z

 Z

 Z

^ f	Bank Account



^

 _

 _

 _

 _

`

`

`

`

a

a

a

a

b#

b

b

b!"

c

c

c

c

d

d

d

d

e#

e

e

e!"

i v Bank Statement



i

 j

 j

 j

 j

k%

k

k 

k#$

l

l

l

l

m

m

m

m

n5

n!

n"0

n34

o

o

o

o

p

p

p

p

q#

q

q

q!"

r

r

r

r

	s&

	s

	s 

	s#%


t)


t


t#


t&(

u#

u

u

u "


x z


x

 y

 y

 y

 y

| �


|!

 }

 }

 }

 }

~

~

~

~

*





%

()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

� �

�"

 �

 �

 �

 �

�+

�

�

�&

�)*

�#

�

�

�!"

� � Bank Account


�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'
 
� � Business Partner


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� �

�#

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

	� �

	�$

	 �

	 �

	 �

	 �

	�-

	�

	� 

	�!(

	�+,

	�#

	�

	�

	�!"


� �


�


 �


 �


 �


 �


�


�


�


�


�*


�


�


�%


�()


�+


�


�


�&


�)*


�


�


�


�


�


�


�


�


� 


�


�


�


�&


�


�!


�$%


�(


�


�#


�&'

� �	 Payment


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

 � �

 �

  �

  �

  �

 �

 �

 �
'
� � Imported Bank Movements


�(

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�$

�

�

�"#

�"

�

�

� !

	�(

	�

	�"

	�%'


�&


�


� 


�#%

�=

�!

�"7

�:<

�;

�!

�"5

�8:

�"

�

�

�!

� �

�

 �

 �

 �

 �

�7

�!

�"2

�56

�

�

�

�

� 

�

�

�

�-

�

�(

�+,

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

	�*

	�

	�$

	�')

� �

�)

 �

 �

 �

 �

�2

�

�%

�&-

�01

�#

�

�

�!"
"
� � Payments Movements


�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�$

�

�

�"#

�"

�

�

� !

	�'

	�

	�!

	�$&


�(


�


�"


�%'

�&

�

� 

�#%

�=

�!

�"7

�:<

�;

�!

�"5

�8:

�"

�

�

�!

� �

�

 �

 �

 �

 �

�7

�!

�"2

�56

�

�

�

�

�

�

�

�

�-

�

�(

�+,

�#

�

�

�!"

�

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�%

�

�

� 

�#$

�#

�

�

�!"
.
� �  Matched Bank/Payment Movements


�$

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�$

�

�

�"#

�"

�

�

� !

	�'

	�

	�!

	�$&


�(


�


�"


�%'

�&

�

� 

�#%

�=

�!

�"7

�:<

�;

�!

�"5

�8:

�"

�

�

�!

� �

�

 �

 �

 �

 �

�7

�!

�"2

�56

�

�

�

�

�

�

�

�

�-

�

�(

�+,

�#

�

�

�!"

�

�

�

�

�

�

�

�

�

�

�

�

	�!

	�

	�

	� 


�


�


�


�

�

�

�

�

�

�

�

�

�#

�

�

� "

�4

�!

�".

�13

� �

�%

 �

 �

 �

 �

�.

�

�!

�")

�,-

�#

�

�

�!"

� � Result Movement


�

 �

 �

 �

 �

�7

�!

�"2

�56

�

�

�

�

�

�

�

�

�-

�

�(

�+,

�#

�

�

�!"

�

�

�

�

�

�

�

�

�

�

�

�

	�!

	�

	�

	� 


�


�


�


�

�

�

�

�

�

�

�

�

�#

�

�

� "

�4

�!

�".

�13

� �

�"

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�$

�

�

�"#

�"

�

�

� !

	�(

	�

	�"

	�%'


�&


�


� 


�#%

�=

�!

�"7

�:<

�;

�!

�"5

�8:

� �

�#

 �

 �

 �

 �

�,

�

�

� '

�*+

�#

�

�

�!"
!
� � Payment Bank keys


�

 �

 �

 �

 �

�'

�

�"

�%&

� �

�

 �*

 �

 �

 �%

 �()

� �

�

 �

 �

 �

 �

� �

�

 �2

 �

 �

 �-

 �01

� �

�

 �

 �

 �

 �

� �

�

 �$

 �

 �

 �"#

�"

�

�

� !

�'

�

�"

�%&

�%

�

� 

�#$

�<

�!

�"7

�:;

�:

�!

�"5

�89

� �

� 

 �

 �

 �

 �bproto3
�
google/protobuf/empty.protogoogle.protobuf"
EmptyB}
com.google.protobufB
EmptyProtoPZ.google.golang.org/protobuf/types/known/emptypb��GPB�Google.Protobuf.WellKnownTypesJ�
 2
�
 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


  

" E
	
" E

# ,
	
# ,

$ +
	
$ +

% "
	

% "

& !
	
$& !

' ;
	
%' ;

( 
	
( 
�
 2 � A generic empty message that you can re-use to avoid defining duplicated
 empty messages in your APIs. A typical example is to use it as the request
 or the response type of an API method. For instance:

     service Foo {
       rpc Bar(google.protobuf.Empty) returns (google.protobuf.Empty);
     }




 2bproto3
�=
business.protodatagoogle/api/annotations.protogoogle/protobuf/empty.protogoogle/protobuf/struct.protobase_data_type.proto"m
CreateEntityRequest

table_name (	R	tableName7

attributes (2.google.protobuf.StructR
attributes"�
GetEntityRequest
id (Rid

table_name (	R	tableName
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken"�
ListEntitiesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue

table_name (	R	tableName2
record_reference_uuid	 (	RrecordReferenceUuid"}
UpdateEntityRequest

table_name (	R	tableName
id (Rid7

attributes (2.google.protobuf.StructR
attributes"D
DeleteEntityRequest

table_name (	R	tableName
id (Rid"M
DeleteEntitiesBatchRequest

table_name (	R	tableName
ids (Rids"�
RunBusinessProcessRequest
id (Rid7

parameters (2.google.protobuf.StructR
parameters
report_type (	R
reportType&
print_format_id (RprintFormatId$
report_view_id (RreportViewId

is_summary (R	isSummary

browser_id (R	browserId7

selections (2.data.KeyValueSelectionR
selections(
is_all_selection	 (RisAllSelection<
browser_context_attributes
 (	RbrowserContextAttributes)
criteria_filters (	RcriteriaFilters

table_name (	R	tableName
	record_id (RrecordId
workflow_id (R
workflowId'
document_action (	RdocumentAction2�
BusinessDatad
	GetEntity.data.GetEntityRequest.data.Entity"1���+)/business-data/entities/{table_name}/{id}h
CreateEntity.data.CreateEntityRequest.data.Entity"/���)"$/business-data/entities/{table_name}:*m
UpdateEntity.data.UpdateEntityRequest.data.Entity"4���.2)/business-data/entities/{table_name}/{id}:*t
DeleteEntity.data.DeleteEntityRequest.google.protobuf.Empty"1���+*)/business-data/entities/{table_name}/{id}�
DeleteEntitiesBatch .data.DeleteEntitiesBatchRequest.google.protobuf.Empty"9���3"1/business-data/entities/batch-delete/{table_name}s
ListEntities.data.ListEntitiesRequest.data.ListEntitiesResponse",���&$/business-data/entities/{table_name}�
RunBusinessProcess.data.RunBusinessProcessRequest.data.ProcessLog"�����"/business-data/process/{id}:*Z"/business-data/report/{id}:*Z:"5/business-data/process/{id}/smart-browse/{browser_id}:*Z@";/business-data/process/{id}/window/{table_name}/{record_id}:*ZT"O/business-data/process/{id}/workflow/{table_name}/{record_id}/{document_action}:*B/
org.spin.backend.grpc.commonBADempiereDataPJ�'
 �
�	
 �	***********************************************************************************
 Copyright (C) 2012-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Yamel Senih ysenih@erpya.com                                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 5
	
 5

 .
	
 .
	
  &
	
 %
	
 &
	
 
%
 2 Base URL
 /business-data/

.
 ! W" The greeting service definition.



 !

  #%	 Get a Entity


  #

  #&

  #17

  $`

	  �ʼ"$`
%
 ',	 Create Entity Request


 '

 ',

 '7=

 (+

	 �ʼ"(+
%
 .3	 Update Entity Request


 .

 .,

 .7=

 /2

	 �ʼ"/2
%
 57	 Delete Entity Request


 5

 5,

 57L

 6c

	 �ʼ"6c
%
 9;	 Delete Entity Request


 9

 9 :

 9EZ

 :i

	 �ʼ":i

 =?		List a Entities


 =

 =,

 =7K

 >[

	 �ʼ">[
2
 AV	$	Request a BusinessProcess / Report


 A

 A8

 ACM

 BU

	 �ʼ"BU
#
 Z ] Create Entity Request



 Z

  [

  [

  [

  [

 \.

 \

 \)

 \,-
 
` j Get Entity Request



`

 a

 a

 a

 a

b

b

b

b

d		Filters


d

d

d

e

e

e

e

f*

f

f

f%

f()

g+

g

g

g&

g)*

h

h

h

h

i

i

i

i


l v


l

 m

 m

 m

 m

n

n

n

n

o*

o

o

o%

o()

p+

p

p

p&

p)*

q

q

q

q

r

r

r

r

s 

s

s

s

t

t

t

t

u)

u

u$

u'(
#
y } Update Entity Request



y

 z

 z

 z

 z

{

{

{

{

|.

|

|)

|,-
%
� � Delete Entity Request


�

 �

 �

 �

 �

�

�

�

�
+
� � Delete Batch Entity Request


�"

 �

 �

 �

 �

�

�

�

�

�
'
� � BusinessProcess Request


�!

 �

 �

 �

 �

�.

�

�)

�,-

� report


�

�

�

�"

�

�

� !

�!

�

�

� 

�

�

�

�

�	 browser


�

�

�

�2

�

�"

�#-

�01

�"

�

�

� !

	�/

	�

	�)

	�,.


�%


�


�


�"$

� window


�

�

�

�

�

�

�

�
 workflow


�

�

�

�$

�

�

�!#bproto3
��
core_functionality.protocore_functionalitygoogle/api/annotations.protogoogle/protobuf/timestamp.proto"
GetSystemInfoRequest"�

SystemInfo
name (	Rname

release_no (	R	releaseNo
version (	Rversion&
last_build_info (	RlastBuildInfo
logo_url (	RlogoUrlL
backend_date_version (2.google.protobuf.TimestampRbackendDateVersion0
backend_main_version (	RbackendMainVersionD
backend_implementation_version (	RbackendImplementationVersion"#
GetCountryRequest
id (Rid"�
ListBusinessPartnersResponse!
record_count (RrecordCountP
business_partners (2#.core_functionality.BusinessPartnerRbusinessPartners&
next_page_token (	RnextPageToken"�
ListBusinessPartnersRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
value (	Rvalue
name	 (	Rname!
contact_name
 (	RcontactName
email (	Remail
postal_code (	R
postalCode
phone (	Rphone"�
ListLanguagesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListLanguagesResponse!
record_count (RrecordCount:
	languages (2.core_functionality.LanguageR	languages&
next_page_token (	RnextPageToken"�
Country
id (Rid!
country_code (	RcountryCode
name (	Rname 
description (	Rdescription

has_region (R	hasRegion
region_name (	R
regionName)
display_sequence (	RdisplaySequence7
is_address_lines_reverse (RisAddressLinesReverse)
capture_sequence	 (	RcaptureSequence4
display_sequence_local
 (	RdisplaySequenceLocalB
is_address_lines_local_reverse (RisAddressLinesLocalReverse+
expression_postal (	RexpressionPostal$
has_postal_add (RhasPostalAdd)
expression_phone (	RexpressionPhone

media_size (	R	mediaSize;
expression_bank_routing_no (	RexpressionBankRoutingNo;
expression_bank_account_no (	RexpressionBankAccountNo
language (	Rlanguage6
allow_cities_out_of_list (RallowCitiesOutOfList,
is_postcode_lookup (RisPostcodeLookup8
currency (2.core_functionality.CurrencyRcurrency"�
GetConversionRateRequest,
conversion_type_id (RconversionTypeId(
currency_from_id (RcurrencyFromId$
currency_to_id (RcurrencyToIdC
conversion_date (2.google.protobuf.TimestampRconversionDate"�
Currency
id (Rid
iso_code (	RisoCode

cur_symbol (	R	curSymbol 
description (	Rdescription-
standard_precision (RstandardPrecision+
costing_precision (RcostingPrecision"�
ConversionRate
id (Rid,
conversion_type_id (RconversionTypeId9

valid_from (2.google.protobuf.TimestampR	validFrom5
valid_to (2.google.protobuf.TimestampRvalidToA
currency_from (2.core_functionality.CurrencyRcurrencyFrom=
currency_to (2.core_functionality.CurrencyR
currencyTo#
multiply_rate (	RmultiplyRate
divide_rate (	R
divideRate"�
Organization
id (Rid
name (	Rname 
description (	Rdescription 
is_read_only (R
isReadOnly
duns (	Rduns
tax_id (	RtaxId
phone (	Rphone
phone2 (	Rphone2
fax	 (	Rfax8
corporate_branding_image
 (	RcorporateBrandingImage"Q
	Warehouse
id (Rid
name (	Rname 
description (	Rdescription"�
UnitOfMeasure
id (Rid
code (	Rcode
symbol (	Rsymbol
name (	Rname 
description (	Rdescription-
standard_precision (RstandardPrecision+
costing_precision (RcostingPrecision"�
ProductConversion
id (Rid3
uom (2!.core_functionality.UnitOfMeasureRuomB
product_uom (2!.core_functionality.UnitOfMeasureR
productUom#
multiply_rate (	RmultiplyRate
divide_rate (	R
divideRate"�
ListProductConversionRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
id (Rid"�
ListProductConversionResponse!
record_count (RrecordCountT
product_conversion (2%.core_functionality.ProductConversionRproductConversion&
next_page_token (	RnextPageToken"N
Charge
id (Rid
name (	Rname 
description (	Rdescription"�
BusinessPartner
id (Rid
value (	Rvalue
tax_id (	RtaxId
duns (	Rduns
naics (	Rnaics
name (	Rname
	last_name (	RlastName 
description (	Rdescription"s
DocumentType
id (Rid
name (	Rname

print_name (	R	printName 
description (	Rdescription"[
SalesRepresentative
id (Rid
name (	Rname 
description (	Rdescription"�
Product
id (Rid
value (	Rvalue
name (	Rname
help (	Rhelp#
document_note (	RdocumentNote
uom_name (	RuomName!
product_type (	RproductType

is_stocked (R	isStocked 
is_drop_ship	 (R
isDropShip!
is_purchased
 (RisPurchased
is_sold (RisSold
	image_url (	RimageUrl2
product_category_name (	RproductCategoryName,
product_group_name (	RproductGroupName,
product_class_name (	RproductClassName>
product_classification_name (	RproductClassificationName
weight (	Rweight
volume (	Rvolume
upc (	Rupc
sku (	Rsku
shelf_width (	R
shelfWidth!
shelf_height (	RshelfHeight
shelf_depth (	R
shelfDepth$
units_per_pack (	RunitsPerPack(
units_per_pallet (	RunitsPerPallet%
guarantee_days (RguaranteeDays'
description_url (	RdescriptionUrl

version_no (	R	versionNo!
tax_category (	RtaxCategory 
description (	Rdescription"�
TaxRate
id (Rid
name (	Rname 
description (	Rdescription#
tax_indicator (	RtaxIndicator
rate (	Rrate"�
ProductPrice5
product (2.core_functionality.ProductRproduct

price_list (	R	priceList%
price_standard (	RpriceStandard
price_limit (	R
priceLimit&
price_list_name (	RpriceListName&
is_tax_included (RisTaxIncluded

valid_from (	R	validFrom8
currency (2.core_functionality.CurrencyRcurrency6
tax_rate	 (2.core_functionality.TaxRateRtaxRate'
price_precision
 (RpricePrecision(
quantity_on_hand (	RquantityOnHand+
quantity_reserved (	RquantityReserved)
quantity_ordered (	RquantityOrdered-
quantity_available (	RquantityAvailableG
display_currency (2.core_functionality.CurrencyRdisplayCurrency,
display_price_list (	RdisplayPriceList4
display_price_standard (	RdisplayPriceStandard.
display_price_limit (	RdisplayPriceLimitK
conversion_rate (2".core_functionality.ConversionRateRconversionRate"�
Language
language (	Rlanguage#
language_name (	RlanguageName!
language_iso (	RlanguageIso!
country_code (	RcountryCode(
is_base_language (RisBaseLanguage,
is_system_language (RisSystemLanguage(
is_decimal_point (RisDecimalPoint!
date_pattern (	RdatePattern!
time_pattern	 (	RtimePattern"�
	PriceList
id (Rid
name (	Rname 
description (	Rdescription8
currency (2.core_functionality.CurrencyRcurrency

is_default (R	isDefault&
is_tax_included (RisTaxIncluded3
is_enforce_price_limit (RisEnforcePriceLimit 
is_net_price (R
isNetPrice'
price_precision	 (RpricePrecision"�
BankAccount
id (Rid
name (	Rname

account_no (	R	accountNo 
description (	Rdescription8
currency (2.core_functionality.CurrencyRcurrency
bban (	Rbban
iban (	Riban!
credit_limit (	RcreditLimit'
current_balance	 (	RcurrentBalance

is_default
 (R	isDefaultN
business_partner (2#.core_functionality.BusinessPartnerRbusinessPartnerO
bank_account_type (2#.core_functionality.BankAccountTypeRbankAccountType
bank_id (RbankId*,
BankAccountType
CHECKING 
SAVINGS2�
CoreFunctionality�
GetSystemInfo(.core_functionality.GetSystemInfoRequest.core_functionality.SystemInfo"'���!/core-functionality/system-info|

GetCountry%.core_functionality.GetCountryRequest.core_functionality.Country"*���$"/core-functionality/countries/{id}�
ListLanguages(.core_functionality.ListLanguagesRequest).core_functionality.ListLanguagesResponse"%���/core-functionality/languages�
ListBusinessPartners/.core_functionality.ListBusinessPartnersRequest0.core_functionality.ListBusinessPartnersResponse"-���'%/core-functionality/business-partners�
GetConversionRate,.core_functionality.GetConversionRateRequest".core_functionality.ConversionRate",���&$/core-functionality/conversion-rates�
ListProductConversion0.core_functionality.ListProductConversionRequest1.core_functionality.ListProductConversionResponse"4���.,/core-functionality/product-conversions/{id}BH
(org.spin.backend.grpc.core_functionalityBADempiereCoreFunctionalityPJ�{
 �
�	
 �	***********************************************************************************
 Copyright (C) 2012-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Yamel Senih ysenih@erpya.com                                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 A
	
 A

 ;
	
 ;
	
  &
	
 )
*
 2  Base URL
 /core-functionality/



  9


 
"
   	 system information


  

  .

  9C

  V

	  �ʼ"V
'
 #%		Get Country Information


 #

 #(

 #3:

 $Y

	 �ʼ"$Y
%
 ')		Request Language List


 '

 '.

 '9N

 (T

	 �ʼ"(T
%
 ,.		List Business Partner


 , 

 ,!<

 ,Gc

 -\

	 �ʼ"-\
!
 13		Get Currency Rate


 1

 16

 1AO

 2[

	 �ʼ"2[
&
 68		Product Conversion UOM


 6!

 6">

 6If

 7c

	 �ʼ"7c

 ; =" empty request



 ;


? J


?

 A adempiere


 A

 A

 A

B

B

B

B

C

C

C

C

D#

D

D

D!"

E

E

E

E

G;	 backend


G!

G"6

G9:

H(

H

H#

H&'

I2

I

I-

I01
!
M O Get Country Request



M

 N

 N

 N

 N
#
R V	List Business Partner



R$

 S

 S

 S

 S

T7

T

T 

T!2

T56

U#

U

U

U!"


W e


W#

 X

 X

 X

 X

Y

Y

Y

Y

Z*

Z

Z

Z%

Z()

[+

[

[

[&

[)*

\

\

\

\

]

]

]

]

^ 

^

^

^

_

_

_

_

`

`

`

`

	a!

	a

	a

	a 


b


b


b


b

c 

c

c

c

d

d

d

d

i q Languages Request



i

 j

 j

 j

 j

k

k

k

k

l*

l

l

l%

l()

m+

m

m

m&

m)*

n

n

n

n

o

o

o

o

p 

p

p

p

t x	Languages List



t

 u

 u

 u

 u

v(

v

v

v#

v&'

w#

w

w

w!"

{ �	 Country



{

 |

 |

 |

 |

} 

}

}

}

~

~

~

~









�

�

�

�

�

�

�

�

�$

�

�

�"#

�*

�

�%

�()

�$

�

�

�"#

	�+

	�

	�%

	�(*


�1


�


�+


�.0

�&

�

� 

�#%

�!

�

�

� 

�%

�

�

�"$

�

�

�

�

�/

�

�)

�,.

�/

�

�)

�,.

�

�

�

�

�+

�

�%

�(*

�%

�

�

�"$

�

�

�

�
%
� � Request Currency Rate


� 

 �%

 �

 � 

 �#$

�#

�

�

�!"

�!

�

�

� 

�6

�!

�"1

�45

	� � Currency info


	�

	 �

	 �

	 �

	 �

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�%

	�

	� 

	�#$

	�$

	�

	�

	�"#


� � Conversion Rate



�


 �


 �


 �


 �


�%


�


� 


�#$


�1


�!


�",


�/0


�/


�!


�"*


�-.


�#


�


�


�!"


�!


�


�


� 


�!


�


�


� 


�


�


�


�

� � Organization


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

	�-

	�

	�'

	�*,

� � Warehouse


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�
'
� � Product Unit of Measure


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�%

�

� 

�#$

�$

�

�

�"#

� �

�

 �

 �

 �

 �

�

�

�

�

�&

�

�!

�$%

�!

�

�

� 

�

�

�

�

� �

�$

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

� �

�%

 �

 �

 �

 �

�:

�

�"

�#5

�89

�#

�

�

�!"
!
� � Charge definition


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�
 
� � Business Partner


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�
(
� � Document Type definition


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�
/
� �! Sales Representative definition


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�
"
� � Product Definition


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�!

�

�

� 

�

�

�

�

� 

�

�

�

�

�

�

�

�

�

�

�

	�

	�

	�

	�


�


�


�


�

�

�

�

�

�*

�

�$

�')

�'

�

�!

�$&

�'

�

�!

�$&

�0

�

�*

�-/

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� 

�

�

�

�!

�

�

� 

� 

�

�

�

�#

�

�

� "

�%

�

�

�"$

�"

�

�

�!

�$

�

�

�!#

�

�

�

�

�!

�

�

� 

� 

�

�

�

� �
 Tax Rate


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�!

�

�

� 

�

�

�

�

� � Product Price


�

 �

 �

 �

 �

�

�

�

�

�"

�

�

� !

�

�

�

�

�#

�

�

�!"

�!

�

�

� 

�

�

�

�

�

�

�

�

�

�

�

�

	�#

	�

	�

	� "


�%


�


�


�"$

�&

�

� 

�#%

�%

�

�

�"$

�'

�

�!

�$&

�'	Schema Values


�

�!

�$&

�'

�

�!

�$&

�+

�

�%

�(*

�(

�

�"

�%'

�,

�

�&

�)+

� � Language Item


�

 �

 �

 �

 �

�!

�

�

� 

� 

�

�

�

� 

�

�

�

�"

�

�

� !

�$

�

�

�"#

�"

�

�

� !

� 

�

�

�

� 

�

�

�

� �	Price List


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�!

�

�

� 

�(

�

�#

�&'

�

�

�

�

�"

�

�

� !

 � �	Bank Account


 �

  �

  �

  �

 �

 �

 �

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� 

�

�

�

�#

�

�

�!"

	�

	�

	�

	�


�.


�


�(


�+-

�/

�

�)

�,.

�

�

�

�bproto3
��
dictionary.proto
dictionarygoogle/api/annotations.proto"
EntityRequest
id (Rid"�
FieldRequest
id (Rid
	column_id (RcolumnId

element_id (R	elementId.
element_column_name (	RelementColumnName

table_name (	R	tableName
column_name (	R
columnName"C
ReferenceRequest
id (Rid
column_name (	R
columnName"�
Window
id (Rid
uuid (	Ruuid
name (	Rname 
description (	Rdescription
help (	Rhelp0
is_sales_transaction (RisSalesTransaction
window_type (	R
windowType#
tabs
 (2.dictionary.TabRtabs"�
Table

table_name (	R	tableName!
access_level (RaccessLevel
key_columns (	R
keyColumns
is_view (RisView#
is_deleteable (RisDeleteable
is_document (R
isDocument"
is_change_log (RisChangeLog-
identifier_columns (	RidentifierColumns+
selection_columns	 (	RselectionColumns"�	
Tab
id (Rid
uuid (	Ruuid
name (	Rname 
description (	Rdescription
help (	Rhelp

table_name (	R	tableName'
table (2.dictionary.TableRtable(
is_insert_record (RisInsertRecord%
commit_warning (	RcommitWarning#
display_logic (	RdisplayLogic
sequence (Rsequence
	tab_level (RtabLevel 
is_read_only (R
isReadOnly&
read_only_logic (	RreadOnlyLogic"
is_single_row (RisSingleRow&
is_advanced_tab (RisAdvancedTab
is_has_tree (R	isHasTree
is_info_tab (R	isInfoTab,
is_translation_tab (RisTranslationTab(
link_column_name (	RlinkColumnName,
parent_column_name (	RparentColumnName
is_sort_tab (R	isSortTab8
sort_order_column_name (	H RsortOrderColumnName�9
sort_yes_no_column_name  (	HRsortYesNoColumnName�1
filter_column_name! (	HRfilterColumnName�
	window_id" (RwindowId"
parent_tab_id# (RparentTabId0
context_column_names$ (	RcontextColumnNames2
process% (2.dictionary.ProcessHRprocess�1
	processes& (2.dictionary.ProcessR	processes)
fields' (2.dictionary.FieldRfieldsB
_sort_order_column_nameB
_sort_yes_no_column_nameB
_filter_column_nameB

_process"�
Field
id (Rid
uuid (	Ruuid
column_name (	R
columnName
name (	Rname 
description (	Rdescription
help (	Rhelp!
display_type (RdisplayType
sequence	 (Rsequence!
is_displayed
 (RisDisplayed#
display_logic (	RdisplayLogic 
is_read_only (R
isReadOnly&
read_only_logic (	RreadOnlyLogic!
is_mandatory (RisMandatory'
mandatory_logic (	RmandatoryLogic
is_key (RisKey
is_range (RisRange#
default_value (	RdefaultValue!
field_length (RfieldLength
v_format (	RvFormat
	value_min (	RvalueMin
	value_max (	RvalueMax?
context_info (2.dictionary.ContextInfoH RcontextInfo�8
	reference (2.dictionary.ReferenceHR	reference�E
dependent_fields (2.dictionary.DependentFieldRdependentFields0
context_column_names (	RcontextColumnNames!
element_name (	RelementName

column_sql (	R	columnSql*
is_displayed_grid  (RisDisplayedGrid
seq_no_grid! (R	seqNoGrid<
field_group" (2.dictionary.FieldGroupHR
fieldGroup�"
is_allow_copy# (RisAllowCopy 
is_same_line$ (R
isSameLine

is_heading% (R	isHeading"
is_field_only& (RisFieldOnly
callout' (	Rcallout%
format_pattern) (	RformatPattern!
is_encrypted* (RisEncrypted.
is_selection_column+ (RisSelectionColumn0
is_always_updateable, (RisAlwaysUpdateable(
is_allow_logging- (RisAllowLogging#
is_updateable. (RisUpdateable$
is_quick_entry/ (RisQuickEntry
	is_parent0 (RisParent#
is_translated1 (RisTranslated#
is_identifier2 (RisIdentifier/
identifier_sequence3 (RidentifierSequence2
process4 (2.dictionary.ProcessHRprocess�(
default_value_to5 (	RdefaultValueTo 
is_info_only6 (R
isInfoOnly*
is_query_criteria7 (RisQueryCriteria
is_order_by8 (R	isOrderBy
sort_no9 (RsortNo1
is_displayed_as_panel: (	RisDisplayedAsPanel1
is_displayed_as_table; (	RisDisplayedAsTableB
_context_infoB

_referenceB
_field_groupB

_process"�
DependentField
	parent_id (RparentId
parent_uuid (	R
parentUuid
parent_name (	R
parentName
id (Rid
uuid (	Ruuid
column_name (	R
columnName"�
ContextInfo
id (Rid
uuid (	Ruuid
name (	Rname 
description (	Rdescription?
message_text (2.dictionary.MessageTextH RmessageText�#
sql_statement (	RsqlStatementB
_message_text"�
MessageText
id (Rid
uuid (	Ruuid
value (	Rvalue!
message_type (	RmessageType!
message_text (	RmessageText
message_tip (	R
messageTip"n

FieldGroup
id (Rid
uuid (	Ruuid
name (	Rname(
field_group_type (	RfieldGroupType"�
FieldDefinition
id (Rid
uuid (	Ruuid
value (	Rvalue
name (	Rname(
field_group_type (	RfieldGroupType:

conditions (2.dictionary.FieldConditionR
conditions"r
FieldCondition
id (Rid
uuid (	Ruuid
	condition (	R	condition

stylesheet (	R
stylesheet"�
DictionaryEntity
id (Rid
uuid (	Ruuid
name (	Rname 
description (	Rdescription
help (	Rhelp"�
Process
id (Rid
uuid (	Ruuid
code (	Rcode
name (	Rname 
description (	Rdescription
help (	Rhelp
	show_help (	RshowHelp
	is_report (RisReport7
is_process_before_launch	 (RisProcessBeforeLaunch$
report_view_id
 (RreportViewId&
print_format_id (RprintFormatIdL
report_export_types (2.dictionary.ReportExportTypeRreportExportTypes

browser_id (R	browserId;
browser (2.dictionary.DictionaryEntityH Rbrowser�
form_id (RformId5
form (2.dictionary.DictionaryEntityHRform�
workflow_id (R
workflowId=
workflow (2.dictionary.DictionaryEntityHRworkflow�%
has_parameters (RhasParameters1

parameters (2.dictionary.FieldR
parametersB

_browserB
_formB
	_workflow"�
Form
id (Rid
uuid (	Ruuid
name (	Rname 
description (	Rdescription
help (	Rhelp
	file_name (	RfileName"�
Browser
id (Rid
uuid (	Ruuid
code (	Rcode
name (	Rname 
description (	Rdescription
help (	Rhelp
	field_key (	RfieldKey>
is_executed_query_by_default	 (RisExecutedQueryByDefault9
is_collapsible_by_default
 (RisCollapsibleByDefault3
is_selected_by_default (RisSelectedByDefault"
is_show_total (RisShowTotal

table_name (	R	tableName!
access_level (RaccessLevel#
is_updateable (RisUpdateable#
is_deleteable (RisDeleteable0
context_column_names (	RcontextColumnNames
	window_id (RwindowId9
window (2.dictionary.DictionaryEntityH Rwindow�

process_id (R	processId;
process (2.dictionary.DictionaryEntityHRprocess�)
fields (2.dictionary.FieldRfieldsB	
_windowB

_process"\
	Reference

table_name (	R	tableName0
context_column_names (	RcontextColumnNames":
ReportExportType
name (	Rname
type (	Rtype"�
ListIdentifierColumnsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue

table_name (	R	tableName0
process_parameter_id	 (RprocessParameterId
field_id
 (RfieldId&
browse_field_id (RbrowseFieldId
	column_id (RcolumnId
column_name (	R
columnName

element_id (R	elementId.
element_column_name (	RelementColumnName"�
ListIdentifierColumnsResponse!
record_count (RrecordCount-
identifier_columns (	RidentifierColumns&
next_page_token (	RnextPageToken"�
SearchColumn
column_name (	R
columnName
name (	Rname
sequence (Rsequence!
display_type (RdisplayType"�
ListSearchFieldsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue

table_name (	R	tableName0
process_parameter_id	 (RprocessParameterId
field_id
 (RfieldId&
browse_field_id (RbrowseFieldId
	column_id (RcolumnId
column_name (	R
columnName

element_id (R	elementId.
element_column_name (	RelementColumnName"�
ListSearchFieldsResponse

table_name (	R	tableName4
query_fields (2.dictionary.FieldRqueryFields=
table_columns (2.dictionary.SearchColumnRtableColumns2�

Dictionary\
	GetWindow.dictionary.EntityRequest.dictionary.Window" ���/dictionary/windows/{id}S
GetTab.dictionary.EntityRequest.dictionary.Tab"���/dictionary/tabs/{id}�
GetField.dictionary.FieldRequest.dictionary.Field"�����/dictionary/fields/{id}Z/-/dictionary/fields/{table_name}/{column_name}Z'%/dictionary/fields/column/{column_id}Z)'/dictionary/fields/element/{element_id}Z97/dictionary/fields/element/column/{element_column_name}h
GetReference.dictionary.ReferenceRequest.dictionary.Reference"#���/dictionary/references/{id}|

GetProcess.dictionary.EntityRequest.dictionary.Process">���8/dictionary/processes/{id}Z/dictionary/reports/{id}_

GetBrowser.dictionary.EntityRequest.dictionary.Browser"!���/dictionary/browsers/{id}V
GetForm.dictionary.EntityRequest.dictionary.Form"���/dictionary/forms/{id}�
ListIdentifiersColumns(.dictionary.ListIdentifierColumnsRequest).dictionary.ListIdentifierColumnsResponse"�����$/dictionary/identifiers/{table_name}Z:8/dictionary/identifiers/table/{table_name}/{column_name}Z'%/field/identifiers/column/{column_id}Z%#/field/identifiers/field/{field_id}Z53/field/identifiers/parameter/{process_parameter_id}Z53/field/identifiers/query-criteria/{browse_field_id}Z.,/dictionary/identifiers/element/{element_id}Z></dictionary/identifiers/element/column/{element_column_name}�
ListSearchFields#.dictionary.ListSearchFieldsRequest$.dictionary.ListSearchFieldsResponse"�����/dictionary/search/{table_name}Z53/dictionary/search/table/{table_name}/{column_name}Z'%/dictionary/search/column/{column_id}Z%#/dictionary/search/field/{field_id}Z53/dictionary/search/parameter/{process_parameter_id}Z53/dictionary/search/query-criteria/{browse_field_id}Z)'/dictionary/search/element/{element_id}Z97/dictionary/search/element/column/{element_column_name}B9
 org.spin.backend.grpc.dictionaryBADempiereDictionaryPJŐ
 �
�	
 �	***********************************************************************************
 Copyright (C) 2012-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Yamel Senih ysenih@erpya.com                                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 9
	
 9

 4
	
 4
	
  &

 
/
  �" The greeting service definition.



 
 
  	 Request a Window


  

  #

  .4

  O

	  �ʼ"O

 !	 Request a Tab


 

  

 +.

  L

	 �ʼ" L

 #3	 Request a Field


 #

 #!

 #,1

 $2

	 �ʼ"$2
!
 57	 Reference Request


 5

 5)

 54=

 6R

	 �ʼ"6R
&
 9@	 Request Process/Report


 9

 9$

 9/6

 :?

	 �ʼ":?

 BD	 Request Browser


 B

 B$

 B/6

 CP

	 �ʼ"CP

 FH	
 Get Form


 F

 F!

 F,0

 GM

	 �ʼ"GM

 Jc	

 J"

 J#?

 JJg

 Kb

	 �ʼ"Kb
'
 f	 List Search Info Fields


 f

 f4

 f?W

 g~

	 �ʼ"g~

 � � Object request


 �

  �

  �

  �

  �

� � Field request


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�'

�

�"

�%&
)
� Table_name + _column_name


�

�

�

�

�

�

�
!
� � Reference request


�

 �

 �

 �

 �
H
�: Table_name + column_name assumed that it is Table Direct


�

�

�

� � Window


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�&

�

�!

�$%

�

�

�

�
<
�.	External Info
 ContextInfo context_info = 9;


�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�(

�

�

�#

�&'

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�/

�

�

�*

�-.

�.

�

�

�)

�,-

� � Tab


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�
 
� Table attributes


�

�

�

�

�

�

�
!
�# Record Attributes


�

�

� "

�#

�

�

� "

	�" Attributes


	�

	�

	�!


�


�


�


�

�

�

�

�

�

�

�

�

�$

�

�

�!#

� 

�

�

�

�"

�

�

�!

�

�

�

�

�

�

�

�

�%

�

�

�"$

�% Link attributes


�

�

�"$

�'

�

�!

�$&

� Sort attributes


�

�

�

�4

�

�

�.

�13

�5

�

�

�/

�24

�0

�

�

�*

�-/

� External Info


�

�

�

�!

�

�

� 

�2

�

�

�,

�/1

�&

�

�

� 

�#%

�(

�

�

�"

�%'
A
�# Fields Attributes
" FieldGroup field_group = 40;


�

�

�

� "

� � Field


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

	�"

	�

	�

	�!


�


�


�


�

�$

�

�

�!#

�

�

�

�

�$

�

�

�!#

�

�

�

�

�

�

�

�

�"

�

�

�!

� 

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�/ External Info


�

�

�)

�,.

�*

�

�

�$

�')

�6

�

�

� 0

�35

�2

�

�

�,

�/1

�!

�

�

� 
*
� Window Field Compatibility


�

�

�

�$

�

�

�!#

�

�

�

�

�-

�

�

�'

�*,

� 

�

�

�

�

�

�

�

 �

 �

 �

 �

!� 

!�

!�

!�

"�

"�

"�

"�
6
#�#( FieldDefinition field_definition = 40;


#�

#�

#� "

$�

$�

$�

$�

%�&

%�

%� 

%�#%

&�'

&�

&�!

&�$&

'�#

'�

'�

'� "

(� 

(�

(�

(�

)�!

)�

)�

)� 

*�

*�

*�

*�

+� 

+�

+�

+�

,� 

,�

,�

,�

-�'

-�

-�!

-�$&

.�&

.�

.�

.� 

.�#%
/
/�%! Process Parameter Compatibility


/�

/�

/�"$

0�

0�

0�

0�
1
1�$# Smart Browser Field Compatibility


1�

1�

1�!#

2�

2�

2�

2�

3�

3�

3�

3�
%
4�* ASP Custom Attributes


4�

4�$

4�')

5�*

5�

5�$

5�')

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� � Context Info


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�.

�

�

�)

�,-

�!

�

�

� 

	� �	 Message


	�

	 �

	 �

	 �

	 �

	�

	�

	�

	�

	�

	�

	�

	�

	� 

	�

	�

	�

	� 

	�

	�

	�

	�

	�

	�

	�


� � Context Info



�


 �


 �


 �


 �


�


�


�


�


�


�


�


�


�$


�


�


�"#

� � Context Info


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�$

�

�

�"#

�/

�

�

� *

�-.

� � Field Condition


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� �	 Process


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� Report


�

�

�

�*

�

�%

�()

	�"

	�

	�

	�!


�#


�


�


� "

�;

�

�!

�"5

�8:

� Browse


�

�

�

�/

�

�!

�")

�,.

� From


�

�

�

�,

�

�!

�"&

�)+

�
 Workflow


�

�

�

�0

�

�!

�"*

�-/

�! Parameters


�

�

� 

�'

�

�

�!

�$&

� � Form


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� � Smart Browser


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�.

�

�)

�,-

�,

�

�&

�)+

	�)

	�

	�#

	�&(


� 


�


�


�
!
� Record Attributes


�

�

�

� 

�

�

�

� 

�

�

�

� 

�

�

�
"
�2 External Reference


�

�

�,

�/1

�

�

�

�

�.

�

�!

�"(

�+-

�

�

�

�

�/

�

�!

�")

�,.

�# Browse Fields


�

�

�

� "
!
� � Foreign Reference


�

 �

 �

 �

 �

�1

�

�

�,

�/0
&
� � Report Type for Export


�

 �

 �

 �

 �

�

�

�

�
!
� � Identifier Fields


�$

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

� references


�

�

�

�'

�

�"

�%&

	�

	�

	�

	�


�#


�


�


� "

�

�

�

�

� 

�

�

�

�

�

�

�

�(

�

�"

�%'

� �

�%

 �

 �

 �

 �

�/

�

�

�*

�-.

�#

�

�

�!"

� � Search Fields


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

� references


�

�

�

�'

�

�"

�%&

	�

	�

	�

	�


�#


�


�


� "

�

�

�

�

� 

�

�

�

�

�

�

�

�(

�

�"

�%'

� �

� 

 �

 �

 �

 �

�(

�

�

�#

�&'

�0

�

�

�+

�./bproto3
Ȟ
dashboarding.protodashboardinggoogle/api/annotations.protogoogle/protobuf/struct.protodictionary.proto"�
	Dashboard
id (Rid
name (	Rname 
description (	Rdescription
	file_name (	RfileName%
dashboard_type (	RdashboardType

chart_type (	R	chartType
sequence (Rsequence
html (	Rhtml
	column_no	 (RcolumnNo
line_no
 (RlineNo%
is_collapsible (RisCollapsible+
is_open_by_default (RisOpenByDefault*
is_event_required (RisEventRequired

browser_id (R	browserId
	window_id (RwindowId"�
ListDashboardsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListDashboardsResponse!
record_count (RrecordCount7

dashboards (2.dashboarding.DashboardR
dashboards&
next_page_token (	RnextPageToken"�
ListFavoritesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
Favorite
menu_id (RmenuId
	menu_name (	RmenuName)
menu_description (	RmenuDescription!
reference_id (RreferenceId
action (	Raction"�
ListFavoritesResponse!
record_count (RrecordCount4
	favorites (2.dashboarding.FavoriteR	favorites&
next_page_token (	RnextPageToken"�
ListPendingDocumentsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListPendingDocumentsResponse!
record_count (RrecordCountJ
pending_documents (2.dashboarding.PendingDocumentRpendingDocuments&
next_page_token (	RnextPageToken"�
PendingDocument
	window_id (RwindowId
tab_id (RtabId

table_name (	R	tableName
form_id (RformId#
document_name (	RdocumentName1
document_description (	RdocumentDescription
sequence (Rsequence!
record_count (RrecordCount2
record_reference_uuid	 (	RrecordReferenceUuid"#
GetMetricsRequest
id (Rid"�
Metrics
id (Rid
name (	Rname 
description (	Rdescription 
x_axis_label (	R
xAxisLabel 
y_axis_label (	R
yAxisLabel%
measure_target (	RmeasureTarget%
measure_actual (	RmeasureActual)
performance_goal (	RperformanceGoal>
color_schemas	 (2.dashboarding.ColorSchemaRcolorSchemas0
series
 (2.dashboarding.ChartSerieRseries"T

ChartSerie
name (	Rname2
data_set (2.dashboarding.ChartDataRdataSet"5
	ChartData
name (	Rname
value (	Rvalue"Q
ColorSchema
name (	Rname
color (	Rcolor
percent (	Rpercent"�
Notification
name (	Rname 
description (	Rdescription
quantity (Rquantity,
action (2.dashboarding.ActionRaction
	action_id (RactionId"�
ListNotificationsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListNotificationsResponse!
record_count (RrecordCount@
notifications (2.dashboarding.NotificationRnotifications&
next_page_token (	RnextPageToken"S
ExistsWindowDashboardsRequest
	window_id (RwindowId
tab_id (RtabId"C
ExistsWindowDashboardsResponse!
record_count (RrecordCount"�
WindowDashboardParameter
id (Rid
name (	Rname 
description (	Rdescription
help (	Rhelp
sequence (Rsequence
column_name (	R
columnName

column_sql (	R	columnSql

element_id (R	elementId
field_id	 (RfieldId!
is_mandatory
 (RisMandatory
is_range (RisRange#
default_value (	RdefaultValue!
display_type (RdisplayType
v_format (	RvFormat
	value_min (	RvalueMin
	value_max (	RvalueMax#
display_logic (	RdisplayLogic&
read_only_logic (	RreadOnlyLogic3
	reference (2.dictionary.ReferenceR	reference"�
WindowDashboard
id (Rid
name (	Rname 
description (	Rdescription
sequence (Rsequence%
is_collapsible (RisCollapsible+
is_open_by_default (RisOpenByDefault%
dashboard_type (	RdashboardType

chart_type (	R	chartType0
context_column_names	 (	RcontextColumnNames3
transformation_script
 (	RtransformationScriptF

parameters (2&.dashboarding.WindowDashboardParameterR
parameters"�
ListWindowDashboardsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
	window_id (RwindowId
tab_id	 (RtabId"�
ListWindowDashboardsResponse!
record_count (RrecordCount7
records (2.dashboarding.WindowDashboardRrecords&
next_page_token (	RnextPageToken"�
WindowMetrics
id (Rid
name (	Rname 
description (	Rdescription 
x_axis_label (	R
xAxisLabel 
y_axis_label (	R
yAxisLabel%
measure_target (	RmeasureTarget%
measure_actual (	RmeasureActual)
performance_goal (	RperformanceGoal>
color_schemas	 (2.dashboarding.ColorSchemaRcolorSchemas0
series
 (2.dashboarding.ChartSerieRseries"�
GetWindowMetricsRequest
id (Rid

table_name (	R	tableName
	record_id (RrecordId
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token	 (	R	pageTokenF
context_attributes
 (2.google.protobuf.StructRcontextAttributes*R
Action

WINDOW 
PROCESS

REPORT
BROWSER
FORM
WORKFLOW2�	
Dashboarding}
ListDashboards#.dashboarding.ListDashboardsRequest$.dashboarding.ListDashboardsResponse" ���/dashboarding/dashboardss

GetMetrics.dashboarding.GetMetricsRequest.dashboarding.Metrics"-���'%/dashboarding/dashboards/{id}/metricsy
ListFavorites".dashboarding.ListFavoritesRequest#.dashboarding.ListFavoritesResponse"���/dashboarding/favorites�
ListPendingDocuments).dashboarding.ListPendingDocumentsRequest*.dashboarding.ListPendingDocumentsResponse"'���!/dashboarding/pending-documents�
ListNotifications&.dashboarding.ListNotificationsRequest'.dashboarding.ListNotificationsResponse"#���/dashboarding/notifications�
ExistsWindowDashboards+.dashboarding.ExistsWindowDashboardsRequest,.dashboarding.ExistsWindowDashboardsResponse";���53/dashboarding/dashboards/windows/{window_id}/exists�
ListWindowDashboards).dashboarding.ListWindowDashboardsRequest*.dashboarding.ListWindowDashboardsResponse"4���.,/dashboarding/dashboards/windows/{window_id}�
GetWindowMetrics%.dashboarding.GetWindowMetricsRequest.dashboarding.WindowMetrics"N���HF/dashboarding/dashboards/windows/metrics/{id}/{table_name}/{record_id}B=
"org.spin.backend.grpc.dashboardingBADempiereDashboardingPJ�e
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 ;
	
 ;

 6
	
 6
	
  &
	
 &
	
 

 
)
  ;	All related to Dashboarding



 
/
   	!	Request Dashboards Content Edit


  

  0

  ;Q

  O

	  �ʼ"O

 "$		Get Metrics


 "

 "(

 "3:

 #\

	 �ʼ"#\
!
 &(		Request Favorites


 &

 &.

 &9N

 'N

	 �ʼ"'N
)
 *,		Request Document Statuses


 * 

 *!<

 *Gc

 +V

	 �ʼ"+V
'
 .0	 NotificationWindowChart


 .

 .6

 .AZ

 /R

	 �ʼ"/R
%
 24	 Custom Window Metrics


 2"

 2#@

 2Ki

 3j

	 �ʼ"3j

 57	

 5 

 5!<

 5Gc

 6c

	 �ʼ"6c

 8:	

 8

 84

 8?L

 9}

	 �ʼ"9}

 > N Dashboard



 >

  ?

  ?

  ?

  ?

 @

 @

 @

 @

 A

 A

 A

 A

 B

 B

 B

 B

 C"

 C

 C

 C !

 D

 D

 D

 D

 E

 E

 E

 E

 F

 F

 F

 F

 G

 G

 G

 G

 	H

 	H

 	H

 	H

 
I!

 
I

 
I

 
I 

 J%

 J

 J

 J"$

 K$

 K

 K

 K!#

 L

 L

 L

 L

 M

 M

 M

 M
 
Q Y Dashboards Request



Q

 R

 R

 R

 R

S

S

S

S

T*

T

T

T%

T()

U+

U

U

U&

U)*

V

V

V

V

W

W

W

W

X 

X

X

X

\ `	Dashboards List



\

 ]

 ]

 ]

 ]

^*

^

^

^%

^()

_#

_

_

_!"
%
c k Favorites Items Request



c

 d

 d

 d

 d

e

e

e

e

f*

f

f

f%

f()

g+

g

g

g&

g)*

h

h

h

h

i

i

i

i

j 

j

j

j

n t Recent Item



n

 o

 o

 o

 o

p

p

p

p

q$

q

q

q"#

r

r

r

r

s

s

s

s

w {	Recent Items List



w

 x

 x

 x

 x

y(

y

y

y#

y&'

z#

z

z

z!"
(
~ � Document Statuses Request



~#

 

 

 

 

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�
!
� �	Recent Items List


�$

 �

 �

 �

 �

�7

�

� 

�!2

�56

�#

�

�

�!"

� � Recent Item


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�!

�

�

� 

�(

�

�#

�&'

�

�

�

�

�

�

�

�

�)

�

�$

�'(

	� � Metrics Request


	�

	 �

	 �

	 �

	 �


� �	 Metrics



�


 �


 �


 �


 �


�


�


�


�


�


�


�


�


� 


�


�


�


� 


�


�


�


�"


�


�


� !


�"


�


�


� !


�$


�


�


�"#


�/


�


�


�*


�-.


	�(


	�


	�


	�"


	�%'

� �	Serie


�

 �

 �

 �

 �

�(

�

�

�#

�&'

� �	Data of Chart


�

 �

 �

 �

 �

�

�

�

�

� �	Color Schema


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

 � �

 �

  �

  �

  �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� �

� 

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

� �

�!

 �

 �

 �

 �

�0

�

�

�+

�./

�#

�

�

�!"

� � Window Chart


�%

 �

 �

 �

 �

�

�

�

�

� �

�&

 �

 �

 �

 �

� �

� 

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

	�

	�

	�

	�


�


�


�


�

�"

�

�

�!

� 

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�"

�

�

�!

�$

�

�

�!#

�, External Info


�

�&

�)+

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

� 

�

�

�

�$

�

�

�"#

�"

�

�

� !

�

�

�

�

�1

�

�

�,

�/0

	�*

	�

	�$

	�')


�:


�


�)


�*4


�79

� �

�#

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

�

�

�

�

� �

�$

 �

 �

 �

 �

�-

�

� 

�!(

�+,

�#

�

�

�!"

� � Window Metrics


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

� 

�

�

�

� 

�

�

�

�"

�

�

� !

�"

�

�

� !

�$

�

�

�"#

�/

�

�

�*

�-.

	�(

	�

	�

	�"

	�%'

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�		Filters


�

�

�

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

	�7

	�

	�1

	�46bproto3
�'
enrollment.proto
enrollmentgoogle/api/annotations.proto"�
EnrollUserRequest
	user_name (	RuserName
name (	Rname
email (	Remail%
client_version (	RclientVersion)
application_type (	RapplicationType
password (	Rpassword"p
ResetPasswordRequest
	user_name (	RuserName
email (	Remail%
client_version (	RclientVersion"t
ResetPasswordTokenRequest
token (	Rtoken
password (	Rpassword%
client_version (	RclientVersion"R
ActivateUserRequest
token (	Rtoken%
client_version (	RclientVersion"M
User
	user_name (	RuserName
name (	Rname
email (	Remail"�
ResetPasswordResponseS
response_type (2..enrollment.ResetPasswordResponse.ResponseTypeRresponseType"J
ResponseType
OK 
USER_NOT_FOUND
TOKEN_NOT_FOUND	
ERROR"�
ActivateUserResponseR
response_type (2-.enrollment.ActivateUserResponse.ResponseTypeRresponseType"6
ResponseType
OK 
TOKEN_NOT_FOUND	
ERROR2�
RegisterZ

EnrollUser.enrollment.EnrollUserRequest.enrollment.User"���"/enrollment/user:*{
ResetPassword .enrollment.ResetPasswordRequest!.enrollment.ResetPasswordResponse"%���/enrollment/reset-password:*�
ResetPasswordFromToken%.enrollment.ResetPasswordTokenRequest!.enrollment.ResetPasswordResponse"+���% /enrollment/reset-password-token:*n
ActivateUser.enrollment.ActivateUserRequest .enrollment.ActivateUserResponse"���/enrollment/user:*B0
 org.spin.backend.grpc.enrollmentB
EnrollmentPJ�
 p
�	
 �	************************************************************************************
 Copyright (C) 2012-2018 E.R.P. Consultores y Asociados, C.A.                      *
 Contributor(s): Yamel Senih ysenih@erpya.com                                      *
 This program is free software: you can redistribute it and/or modify              *
 it under the terms of the GNU General Public License as published by              *
 the Free Software Foundation, either version 2 of the License, or                 *
 (at your option) any later version.                                               *
 This program is distributed in the hope that it will be useful,                   *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                    *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                      *
 GNU General Public License for more details.                                      *
 You should have received a copy of the GNU General Public License                 *
 along with this program. If not, see <https://www.gnu.org/licenses/>.             *
**********************************************************************************

 "
	

 "

 9
	
 9

 +
	
 +
	
  &

 
.
  6" The greeting service definition.



 
#
   	 Request enroll User


  

  (

  37

  

	  �ʼ"

 "'	


 "

 ".

 "9N

 #&

	 �ʼ"#&

 ).	


 )"

 )#<

 )G\

 *-

	 �ʼ"*-

 05	


 0

 0,

 07K

 14

	 �ʼ"14
)
 9 @ Request a Enroll for a user



 9

  :

  :

  :

  :

 ;

 ;

 ;

 ;

 <

 <

 <

 <

 ="

 =

 =

 = !

 >$

 >

 >

 >"#

 ?

 ?

 ?

 ?
&
C G Request a Password Reset



C

 D

 D

 D

 D

E

E

E

E

F"

F

F

F !
&
J N Request a Password Reset



J!

 K

 K

 K

 K

L

L

L

L

M"

M

M

M !
&
Q T Request a Password Reset



Q

 R

 R

 R

 R

S"

S

S

S !

W [ user enrolled



W

 X

 X

 X

 X

Y

Y

Y

Y

Z

Z

Z

Z
%
^ f Reset Password Response



^

 _d	

 _

  `

  `

  `

 a#

 a

 a!"

 b$

 b

 b"#

 c

 c

 c

 e'

 e

 e"

 e%&
%
i p Reset Password Response



i

 jn	

 j

  k

  k

  k

 l$

 l

 l"#

 m

 m

 m

 o'

 o

 o"

 o%&bproto3
�S
express_movement.protoexpress_movementgoogle/api/annotations.protogoogle/protobuf/empty.protogoogle/protobuf/timestamp.proto"g
	Warehouse
id (Rid
value (	Rvalue
name (	Rname 
description (	Rdescription"�
ListWarehousesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListWarehousesResponse!
record_count (RrecordCount5
records (2.express_movement.WarehouseRrecords&
next_page_token (	RnextPageToken"�
ListProductsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
Product
id (Rid
upc (	Rupc
sku (	Rsku
value (	Rvalue
name (	Rname 
description (	Rdescription"�
ListProductsResponse!
record_count (RrecordCount3
records (2.express_movement.ProductRrecords&
next_page_token (	RnextPageToken"
CreateMovementRequest"�
Movement
id (Rid
document_no (	R
documentNo?
movement_date (2.google.protobuf.TimestampRmovementDate 
description (	Rdescription!
is_completed (RisCompleted"'
DeleteMovementRequest
id (Rid"J
ProcessMovementRequest
id (Rid 
description (	Rdescription"�
CreateMovementLineRequest
movement_id (R
movementId!
warehouse_id (RwarehouseId&
warehouse_to_id (RwarehouseToId 
description (	Rdescription

product_id (R	productId
quantity (	Rquantity"�
MovementLine
id (Rid!
warehouse_id (RwarehouseId&
warehouse_to_id (RwarehouseToId3
product (2.express_movement.ProductRproduct 
description (	Rdescription
quantity (	Rquantity
line (Rline"�
ListMovementLinesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
movement_id (R
movementId"�
ListMovementLinesResponse!
record_count (RrecordCount8
records (2.express_movement.MovementLineRrecords&
next_page_token (	RnextPageToken"L
DeleteMovementLineRequest
movement_id (R
movementId
id (Rid"�
UpdateMovementLineRequest
movement_id (R
movementId
id (Rid 
description (	Rdescription
quantity (	Rquantity2�

ExpressMovement�
ListWarehouses'.express_movement.ListWarehousesRequest(.express_movement.ListWarehousesResponse"$���/express-movement/warehouses�
ListProducts%.express_movement.ListProductsRequest&.express_movement.ListProductsResponse""���/express-movement/products}
CreateMovement'.express_movement.CreateMovementRequest.express_movement.Movement"&��� "/express-movement/movements:*{
DeleteMovement'.express_movement.DeleteMovementRequest.google.protobuf.Empty"(���"* /express-movement/movements/{id}�
ProcessMovement(.express_movement.ProcessMovementRequest.express_movement.Movement"3���-"(/express-movement/movements/{id}/process:*�
CreateMovementLine+.express_movement.CreateMovementLineRequest.express_movement.MovementLine":���4"//express-movement/movements/{movement_id}/lines:*�
DeleteMovementLine+.express_movement.DeleteMovementLineRequest.google.protobuf.Empty";���5*3/express-movement/movement/{movement_id}/lines/{id}�
UpdateMovementLine+.express_movement.UpdateMovementLineRequest.express_movement.MovementLine">���823/express-movement/movement/{movement_id}/lines/{id}:*�
ListMovementLines*.express_movement.ListMovementLinesRequest+.express_movement.ListMovementLinesResponse"7���1//express-movement/{movement_id}/movements/linesBI
+org.spin.backend.grpc.form.express_movementBADempiereExpressMovementPJ�3
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 D
	
 D

 9
	
 9
	
  &
	
 %
	
 )

 


  D


 

  	

  

  0

  ;Q

  S

	  �ʼ"S

  	

 

 ,

 7K

 Q

	 �ʼ"Q

 "'	
 Movement


 "

 "0

 ";C

 #&

	 �ʼ"#&

 (*	

 (

 (0

 (;P

 )Z

	 �ʼ")Z

 +0	

 +

 +2

 +=E

 ,/

	 �ʼ",/

 27		Movement Line


 2

 28

 2CO

 36

	 �ʼ"36

 8:	

 8

 88

 8CX

 9m

	 �ʼ"9m

 ;@	

 ;

 ;8

 ;CO

 <?

	 �ʼ"<?

 AC	

 A

 A6

 AAZ

 Bf

	 �ʼ"Bf

 H M Warehouse



 H

  I

  I

  I

  I

 J

 J

 J

 J

 K

 K

 K

 K

 L

 L

 L

 L


O W


O

 P

 P

 P

 P

Q

Q

Q

Q

R*

R

R

R%

R()

S+

S

S

S&

S)*

T

T

T

T

U

U

U

U

V 

V

V

V


Y ]


Y

 Z

 Z

 Z

 Z

['

[

[

["

[%&

\#

\

\

\!"

a i	 Product



a

 b

 b

 b

 b

c

c

c

c

d*

d

d

d%

d()

e+

e

e

e&

e)*

f

f

f

f

g

g

g

g

h 

h

h

h


k r


k

 l

 l

 l

 l

m

m

m

m

n

n

n

n

o

o

o

o

p

p

p

p

q

q

q

q


t x


t

 u

 u

 u

 u

v%

v

v

v 

v#$

w#

w

w

w!"

| }
 Movement



|

 �




 �

 �

 �

 �

�

�

�

�

�4

�!

�"/

�23

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

	� �

	�

	 �

	 �

	 �

	 �

	�

	�

	�

	�


� � Movement Line



�!


 �


 �


 �


 �


�


�


�


�


�"


�


�


� !


�


�


�


�


�


�


�


�


�


�


�


�

� �

�

 �

 �

 �

 �

�

�

�

�

�"

�

�

� !

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� �

� 

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

� �

�!

 �

 �

 �

 �

�*

�

�

�%

�()

�#

�

�

�!"

� �

�!

 �

 �

 �

 �

�

�

�

�

� �

�!

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�bproto3
�d
express_receipt.protoexpress_receiptgoogle/api/annotations.protogoogle/protobuf/empty.protogoogle/protobuf/timestamp.proto"�
BusinessPartner
id (Rid
value (	Rvalue
tax_id (	RtaxId
name (	Rname 
description (	Rdescription"�
ListBusinessPartnersRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListBusinessPartnersResponse!
record_count (RrecordCount:
records (2 .express_receipt.BusinessPartnerRrecords&
next_page_token (	RnextPageToken"�
ListPurchaseOrdersRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue.
business_partner_id (RbusinessPartnerId"
PurchaseOrder
id (Rid
document_no (	R
documentNo=
date_ordered (2.google.protobuf.TimestampRdateOrdered"�
ListPurchaseOrdersResponse!
record_count (RrecordCount8
records (2.express_receipt.PurchaseOrderRrecords&
next_page_token (	RnextPageToken"�
ListProductsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
order_id (RorderId"�
Product
id (Rid
upc (	Rupc
sku (	Rsku
value (	Rvalue
name (	Rname 
description (	Rdescription"�
ListProductsResponse!
record_count (RrecordCount2
records (2.express_receipt.ProductRrecords&
next_page_token (	RnextPageToken"m
CreateReceiptRequest
order_id (RorderId:
is_create_lines_from_order (RisCreateLinesFromOrder"�
Receipt
id (Rid
document_no (	R
documentNo=
date_ordered (2.google.protobuf.TimestampRdateOrdered?
movement_date (2.google.protobuf.TimestampRmovementDate
order_id (RorderId!
is_completed (RisCompleted"&
DeleteReceiptRequest
id (Rid"I
ProcessReceiptRequest
id (Rid 
description (	Rdescription"�
CreateReceiptLineRequest

receipt_id (R	receiptId 
description (	Rdescription

product_id (R	productId
quantity (	Rquantity<
is_quantity_from_order_line (RisQuantityFromOrderLine"�
ReceiptLine
id (Rid"
order_line_id (RorderLineId2
product (2.express_receipt.ProductRproduct 
description (	Rdescription
quantity (	Rquantity
line (Rline"�
ListReceiptLinesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue

receipt_id (R	receiptId"�
ListReceiptLinesResponse!
record_count (RrecordCount6
records (2.express_receipt.ReceiptLineRrecords&
next_page_token (	RnextPageToken"I
DeleteReceiptLineRequest

receipt_id (R	receiptId
id (Rid"�
UpdateReceiptLineRequest

receipt_id (R	receiptId
id (Rid 
description (	Rdescription
quantity (	Rquantity2�
ExpressReceipt�
ListBusinessPartners,.express_receipt.ListBusinessPartnersRequest-.express_receipt.ListBusinessPartnersResponse"*���$"/express-receipt/business-partners�
ListPurchaseOrders*.express_receipt.ListPurchaseOrdersRequest+.express_receipt.ListPurchaseOrdersResponse"���/express-receipt/orders�
ListProducts$.express_receipt.ListProductsRequest%.express_receipt.ListProductsResponse"3���-+/express-receipt/orders/{order_id}/productsv
CreateReceipt%.express_receipt.CreateReceiptRequest.express_receipt.Receipt"$���"/express-receipt/receipts:*v
DeleteReceipt%.express_receipt.DeleteReceiptRequest.google.protobuf.Empty"&��� */express-receipt/receipts/{id}�
ProcessReceipt&.express_receipt.ProcessReceiptRequest.express_receipt.Receipt"1���+"&/express-receipt/receipts/{id}/process:*�
CreateReceiptLine).express_receipt.CreateReceiptLineRequest.express_receipt.ReceiptLine"7���1",/express-receipt/receipts/{receipt_id}/lines:*�
DeleteReceiptLine).express_receipt.DeleteReceiptLineRequest.google.protobuf.Empty"9���3*1/express-receipt/receipts/{receipt_id}/lines/{id}�
UpdateReceiptLine).express_receipt.UpdateReceiptLineRequest.express_receipt.ReceiptLine"<���621/express-receipt/receipts/{receipt_id}/lines/{id}:*�
ListReceiptLines(.express_receipt.ListReceiptLinesRequest).express_receipt.ListReceiptLinesResponse"4���.,/express-receipt/receipts/{receipt_id}/linesBG
*org.spin.backend.grpc.form.express_receiptBADempiereExpressReceiptPJ�=
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 C
	
 C

 8
	
 8
	
  &
	
 %
	
 )

 


  G


 

  	

   

  !<

  Gc

  Y

	  �ʼ"Y

  	

 

 8

 C]

 N

	 �ʼ"N

 !#	

 !

 !,

 !7K

 "b

	 �ʼ""b

 %*		 Receipt


 %

 %.

 %9@

 &)

	 �ʼ"&)

 +-	

 +

 +.

 +9N

 ,X

	 �ʼ",X

 .3	

 .

 .0

 .;B

 /2

	 �ʼ"/2

 5:		Receipt Line


 5

 56

 5AL

 69

	 �ʼ"69

 ;=	

 ;

 ;6

 ;AV

 <k

	 �ʼ"<k

 >C	

 >

 >6

 >AL

 ?B

	 �ʼ"?B

 	DF	

 	D

 	D4

 	D?W

 	Ec

	 	�ʼ"Ec

 K Q Business Partner



 K

  L

  L

  L

  L

 M

 M

 M

 M

 N

 N

 N

 N

 O

 O

 O

 O

 P

 P

 P

 P


S [


S#

 T

 T

 T

 T

U

U

U

U

V*

V

V

V%

V()

W+

W

W

W&

W)*

X

X

X

X

Y

Y

Y

Y

Z 

Z

Z

Z


] a


]$

 ^

 ^

 ^

 ^

_-

_

_ 

_!(

_+,

`#

`

`

`!"

e n Orders



e!

 f

 f

 f

 f

g

g

g

g

h*

h

h

h%

h()

i+

i

i

i&

i)*

j

j

j

j

k

k

k

k

l 

l

l

l

m&

m

m!

m$%


p t


p

 q

 q

 q

 q

r

r

r

r

s3

s!

s".

s12


v z


v"

 w

 w

 w

 w

x+

x

x

x&

x)*

y#

y

y

y!"

~ �	 Product



~

 

 

 

 

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�%

�

�

� 

�#$

�#

�

�

�!"

	� �	 Receipt


	�

	 �

	 �

	 �

	 �

	�,

	�

	�'

	�*+


� �


�


 �


 �


 �


 �


�


�


�


�


�3


�!


�".


�12


�4


�!


�"/


�23


�


�


�


�


�


�


�


�

� �

�

 �

 �

 �

 �

� �

�

 �

 �

 �

 �

�

�

�

�

� � Receipt Line


� 

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�-

�

�(

�+,

� �

�

 �

 �

 �

 �

� 

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

� �

� 

 �

 �

 �

 �

�)

�

�

�$

�'(

�#

�

�

�!"

� �

� 

 �

 �

 �

 �

�

�

�

�

� �

� 

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�bproto3
�d
express_shipment.protoexpress_shipmentgoogle/api/annotations.protogoogle/protobuf/empty.protogoogle/protobuf/timestamp.proto"�
BusinessPartner
id (Rid
value (	Rvalue
tax_id (	RtaxId
name (	Rname 
description (	Rdescription"�
ListBusinessPartnersRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListBusinessPartnersResponse!
record_count (RrecordCount;
records (2!.express_shipment.BusinessPartnerRrecords&
next_page_token (	RnextPageToken"�
ListSalesOrdersRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue.
business_partner_id (RbusinessPartnerId"|

SalesOrder
id (Rid
document_no (	R
documentNo=
date_ordered (2.google.protobuf.TimestampRdateOrdered"�
ListSalesOrdersResponse!
record_count (RrecordCount6
records (2.express_shipment.SalesOrderRrecords&
next_page_token (	RnextPageToken"�
ListProductsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
order_id (RorderId"�
Product
id (Rid
upc (	Rupc
sku (	Rsku
value (	Rvalue
name (	Rname 
description (	Rdescription"�
ListProductsResponse!
record_count (RrecordCount3
records (2.express_shipment.ProductRrecords&
next_page_token (	RnextPageToken"n
CreateShipmentRequest
order_id (RorderId:
is_create_lines_from_order (RisCreateLinesFromOrder"�
Shipment
id (Rid
document_no (	R
documentNo=
date_ordered (2.google.protobuf.TimestampRdateOrdered?
movement_date (2.google.protobuf.TimestampRmovementDate
order_id (RorderId!
is_completed (RisCompleted"'
DeleteShipmentRequest
id (Rid"J
ProcessShipmentRequest
id (Rid 
description (	Rdescription"�
CreateShipmentLineRequest
shipment_id (R
shipmentId 
description (	Rdescription

product_id (R	productId
quantity (	Rquantity<
is_quantity_from_order_line (RisQuantityFromOrderLine"�
ShipmentLine
id (Rid"
order_line_id (RorderLineId3
product (2.express_shipment.ProductRproduct 
description (	Rdescription
quantity (	Rquantity
line (Rline"�
ListShipmentLinesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
shipment_id (R
shipmentId"�
ListShipmentLinesResponse!
record_count (RrecordCount8
records (2.express_shipment.ShipmentLineRrecords&
next_page_token (	RnextPageToken"L
DeleteShipmentLineRequest
shipment_id (R
shipmentId
id (Rid"i
UpdateShipmentLineRequest
id (Rid 
description (	Rdescription
quantity (	Rquantity2�
ExpressShipment�
ListBusinessPartners-.express_shipment.ListBusinessPartnersRequest..express_shipment.ListBusinessPartnersResponse"+���%#/express-shipment/business-partners�
ListSalesOrders(.express_shipment.ListSalesOrdersRequest).express_shipment.ListSalesOrdersResponse" ���/express-shipment/orders�
ListProducts%.express_shipment.ListProductsRequest&.express_shipment.ListProductsResponse"4���.,/express-shipment/orders/{order_id}/products}
CreateShipment'.express_shipment.CreateShipmentRequest.express_shipment.Shipment"&��� "/express-shipment/shipments:*{
DeleteShipment'.express_shipment.DeleteShipmentRequest.google.protobuf.Empty"(���"* /express-shipment/shipments/{id}�
ProcessShipment(.express_shipment.ProcessShipmentRequest.express_shipment.Shipment"3���-"(/express-shipment/shipments/{id}/process:*�
CreateShipmentLine+.express_shipment.CreateShipmentLineRequest.express_shipment.ShipmentLine":���4"//express-shipment/shipments/{shipment_id}/lines:*�
DeleteShipmentLine+.express_shipment.DeleteShipmentLineRequest.google.protobuf.Empty"<���6*4/express-shipment/shipments/{shipment_id}/lines/{id}�
UpdateShipmentLine+.express_shipment.UpdateShipmentLineRequest.express_shipment.ShipmentLine"?���924/express-shipment/shipments/{shipment_id}/lines/{id}:*�
ListShipmentLines*.express_shipment.ListShipmentLinesRequest+.express_shipment.ListShipmentLinesResponse"7���1//express-shipment/shipments/{shipment_id}/linesBI
+org.spin.backend.grpc.form.express_shipmentBADempiereExpressShipmentPJ�=
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 D
	
 D

 9
	
 9
	
  &
	
 %
	
 )
(
 2 Base URL
 /express-shipment/



  J


 

   	

   

  !<

  Gc

  Z

	  �ʼ"Z

 !#	

 !

 !2

 !=T

 "O

	 �ʼ""O

 $&	

 $

 $,

 $7K

 %c

	 �ʼ"%c

 (-	
 Shipment


 (

 (0

 (;C

 ),

	 �ʼ"),

 .0	

 .

 .0

 .;P

 /Z

	 �ʼ"/Z

 16	

 1

 12

 1=E

 25

	 �ʼ"25

 8=		Shipment Line


 8

 88

 8CO

 9<

	 �ʼ"9<

 >@	

 >

 >8

 >CX

 ?n

	 �ʼ"?n

 AF	

 A

 A8

 ACO

 BE

	 �ʼ"BE

 	GI	

 	G

 	G6

 	GAZ

 	Hf

	 	�ʼ"Hf

 N T Business Partner



 N

  O

  O

  O

  O

 P

 P

 P

 P

 Q

 Q

 Q

 Q

 R

 R

 R

 R

 S

 S

 S

 S


V ^


V#

 W

 W

 W

 W

X

X

X

X

Y*

Y

Y

Y%

Y()

Z+

Z

Z

Z&

Z)*

[

[

[

[

\

\

\

\

] 

]

]

]


` d


`$

 a

 a

 a

 a

b-

b

b 

b!(

b+,

c#

c

c

c!"

h q Orders



h

 i

 i

 i

 i

j

j

j

j

k*

k

k

k%

k()

l+

l

l

l&

l)*

m

m

m

m

n

n

n

n

o 

o

o

o

p&

p

p!

p$%


s w


s

 t

 t

 t

 t

u

u

u

u

v3

v!

v".

v12


y }


y

 z

 z

 z

 z

{(

{

{

{#

{&'

|#

|

|

|!"

� �	 Product


�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�%

�

�

� 

�#$

�#

�

�

�!"

	� �
 Shipment


	�

	 �

	 �

	 �

	 �

	�,

	�

	�'

	�*+


� �


�


 �


 �


 �


 �


�


�


�


�


�3


�!


�".


�12


�4


�!


�"/


�23


�


�


�


�


�


�


�


�

� �

�

 �

 �

 �

 �

� �

�

 �

 �

 �

 �

�

�

�

�

� � Shipment Line


�!

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�-

�

�(

�+,

� �

�

 �

 �

 �

 �

� 

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� �

� 

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

� �

�!

 �

 �

 �

 �

�*

�

�

�%

�()

�#

�

�

�!"

� �

�!

 �

 �

 �

 �

�

�

�

�

� �

�!

 �

 �

 �

 �

�

�

�

�

�

�

�

�bproto3
�]
field.business_partner.protofield.business_partnergoogle/api/annotations.protogoogle/protobuf/timestamp.proto"�
BusinessPartnerInfo
id (Rid
uuid (	Ruuid#
display_value (	RdisplayValue
value (	Rvalue
tax_id (	RtaxId
name (	Rname
name2 (	Rname2 
description (	Rdescription4
business_partner_group	 (	RbusinessPartnerGroup.
open_balance_amount
 (	RopenBalanceAmount6
credit_available_amount (	RcreditAvailableAmount,
credit_used_amount (	RcreditUsedAmount%
revenue_amount (	RrevenueAmount
	is_active (RisActive"�
 ListBusinessPartnersInfoResponse!
record_count (RrecordCountE
records (2+.field.business_partner.BusinessPartnerInfoRrecords&
next_page_token (	RnextPageToken"�
ListBusinessPartnersInfoRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords0
process_parameter_id
 (RprocessParameterId
field_id (RfieldId&
browse_field_id (RbrowseFieldId!
reference_id (RreferenceId
	column_id (RcolumnId

table_name (	R	tableName
column_name (	R
columnName2
is_without_validation (RisWithoutValidation
value (	Rvalue
contact (	Rcontact
phone (	Rphone
customer (	Rcustomer
name (	Rname
email (	Remail
postal_code (	R
postalCode
	is_vendor (	RisVendor
is_customer (	R
isCustomer"�
BusinessPartnerContact
id (Rid
uuid (	Ruuid
greeting (	Rgreeting
name (	Rname
title (	Rtitle
address (	Raddress
phone (	Rphone
phone_2 (	Rphone2
fax	 (	Rfax
email
 (	Remail=
last_contact (2.google.protobuf.TimestampRlastContact
last_result (	R
lastResult
	is_active (RisActive"�
#ListBusinessPartnerContactsResponse!
record_count (RrecordCountH
records (2..field.business_partner.BusinessPartnerContactRrecords&
next_page_token (	RnextPageToken"�
"ListBusinessPartnerContactsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes.
business_partner_id	 (RbusinessPartnerId"�
BusinessPartnerAddressLocation
id (Rid
uuid (	Ruuid
phone (	Rphone
phone2 (	Rphone2
fax (	Rfax
address (	Raddress+
is_ship_to_address (RisShipToAddress+
is_bill_to_address (RisBillToAddress-
is_remit_to_address	 (RisRemitToAddress-
is_pay_form_address
 (RisPayFormAddress
	is_active (RisActive"�
+ListBusinessPartnerAddressLocationsResponse!
record_count (RrecordCountP
records (26.field.business_partner.BusinessPartnerAddressLocationRrecords&
next_page_token (	RnextPageToken"�
*ListBusinessPartnerAddressLocationsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes.
business_partner_id	 (RbusinessPartnerId2�
BusinessPartnerInfoService�
ListBusinessPartnersInfo7.field.business_partner.ListBusinessPartnersInfoRequest8.field.business_partner.ListBusinessPartnersInfoResponse"�����/fields/business-partnersZ<:/fields/business-partners/table/{table_name}/{column_name}Z.,/fields/business-partners/column/{column_id}Z,*/fields/business-partners/field/{field_id}Z<:/fields/business-partners/parameter/{process_parameter_id}Z<:/fields/business-partners/query-criteria/{browse_field_id}�
ListBusinessPartnerContacts:.field.business_partner.ListBusinessPartnerContactsRequest;.field.business_partner.ListBusinessPartnerContactsResponse"@���:8/fields/business-partners/{business_partner_id}/contacts�
#ListBusinessPartnerAddressLocationsB.field.business_partner.ListBusinessPartnerAddressLocationsRequestC.field.business_partner.ListBusinessPartnerAddressLocationsResponse"I���CA/fields/business-partners/{business_partner_id}/address-locationsBJ
,org.spin.backend.grpc.field.business_partnerBADempiereBusinessPartnerPJ�:
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 E
	
 E

 9
	
 9
	
  &
	
 )
0
 2& Base URL
 /fields/business-partners/

6
  >* The business partner service definition.



 "

   3	 Result


   $

   %D

   Oo

  !2

	  �ʼ"!2

 48	

 4'

 4(J

 4Ux

 57

	 �ʼ"57

 9=	

 9/

 90Z

 9e�

 :<

	 �ʼ":<
(
 B Q List Business Partner Info



 B

  C

  C

  C

  C

 D

 D

 D

 D

 E!

 E

 E

 E 

 F

 F

 F

 F

 G

 G

 G

 G

 H

 H

 H

 H

 I

 I

 I

 I

 J

 J

 J

 J

 K*

 K

 K%

 K()

 	L(

 	L

 	L"

 	L%'

 
M,

 
M

 
M&

 
M)+

 N'

 N

 N!

 N$&

 O#

 O

 O

 O "

 P

 P

 P

 P


S W


S(

 T

 T

 T

 T

U1

U

U$

U%,

U/0

V#

V

V

V!"


Y w


Y'

 Z

 Z

 Z

 Z

[

[

[

[

\*

\

\

\%

\()

]+

]

]

]&

])*

^

^

^

^

_

_

_

_

` 

`

`

`

a&

a

a!

a$%

b(

b

b#

b&'

	d( references


	d

	d"

	d%'


e


e


e


e

f#

f

f

f "

g 

g

g

g

h

h

h

h

i

i

i

i

j 

j

j

j

l(


l

l"

l%'

n custom filters


n

n

n

o

o

o

o

p

p

p

p

q

q

q

q

r

r

r

r

s

s

s

s

t 

t

t

t

u

u

u

u

v 

v

v

v

| �	 Contact



|

 }

 }

 }

 }

~

~

~

~









�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

	�

	�

	�

	�


�4


�!


�".


�13

� 

�

�

�

�

�

�

�

� �

�+

 �

 �

 �

 �

�4

�

�'

�(/

�23

�#

�

�

�!"

� �

�*

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�& custom filters


�

�!

�$%
 
� � Address Location


�&

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�$" Ship Adrress


�

�

�"#

�$" Invoice Address


�

�

�"#
 
�%" Pay-From Address


�

� 

�#$
 
	�&" Remit-To Address


	�

	� 

	�#%


�


�


�


�

� �

�3

 �

 �

 �

 �

�<

�

�/

�07

�:;

�#

�

�

�!"

� �

�2

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�& custom filters


�

�!

�$%bproto3
�
field.in_out.protofield.in_outgoogle/api/annotations.protobase_data_type.proto"�
ListInOutInfoRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords0
process_parameter_id
 (RprocessParameterId
field_id (RfieldId&
browse_field_id (RbrowseFieldId!
reference_id (RreferenceId
	column_id (RcolumnId

table_name (	R	tableName
column_name (	R
columnName2
is_without_validation (RisWithoutValidation2|
InOutInfoServiceh
ListInOutInfo".field.in_out.ListInOutInfoRequest.data.ListEntitiesResponse"���/fields/in-outsB/
org.spin.backend.grpc.inoutBADempiereInOutPJ�
 =
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 4
	
 4

 /
	
 /
	
  &
	
 
&
 2 Base URL
 /fields/in-outs/

,
  &  The in-out service definition.



 
(
  !%	 List In-Out Info Request


  !

  !.

  !9R

  "$

	  �ʼ""$
%
 ) = List InOut Info Request



 )

  *

  *

  *

  *

 +

 +

 +

 +

 ,*

 ,

 ,

 ,%

 ,()

 -+

 -

 -

 -&

 -)*

 .

 .

 .

 .

 /

 /

 /

 /

 0 

 0

 0

 0

 1&

 1

 1!

 1$%

 2(

 2

 2#

 2&'

 	4( references


 	4

 	4"

 	4%'

 
5

 
5

 
5

 
5

 6#

 6

 6

 6 "

 7 

 7

 7

 7

 8

 8

 8

 8

 9

 9

 9

 9

 : 

 :

 :

 :

 <(


 <

 <"

 <%'bproto3
�_
field.invoice.protofield.invoicegoogle/api/annotations.protogoogle/protobuf/timestamp.protobase_data_type.proto"�
ListOrdersRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords0
is_sales_transaction
 (	RisSalesTransaction"�
ListBusinessPartnersRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords0
is_sales_transaction
 (	RisSalesTransaction"�
InvoiceInfo
id (Rid
uuid (	Ruuid#
display_value (	RdisplayValue)
business_partner (	RbusinessPartner?
date_invoiced (2.google.protobuf.TimestampRdateInvoiced
document_no (	R
documentNo
currency (	Rcurrency
grand_total (	R
grandTotal)
converted_amount	 (	RconvertedAmount
open_amount
 (	R
openAmount!
payment_term (	RpaymentTerm
is_paid (RisPaid0
is_sales_transaction (RisSalesTransaction 
description (	Rdescription!
po_reference (	RpoReference'
document_status (	RdocumentStatus";
GetInvoiceInfoRequest
id (Rid
uuid (	Ruuid"�
ListInvoicesInfoResponse!
record_count (RrecordCount4
records (2.field.invoice.InvoiceInfoRrecords&
next_page_token (	RnextPageToken"�
ListInvoicesInfoRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords0
process_parameter_id
 (RprocessParameterId
field_id (RfieldId&
browse_field_id (RbrowseFieldId!
reference_id (RreferenceId
	column_id (RcolumnId

table_name (	R	tableName
column_name (	R
columnName2
is_without_validation (RisWithoutValidation
document_no (	R
documentNo.
business_partner_id (RbusinessPartnerId0
is_sales_transaction (	RisSalesTransaction
is_paid (	RisPaid 
description (	RdescriptionF
invoice_date_from (2.google.protobuf.TimestampRinvoiceDateFromB
invoice_date_to (2.google.protobuf.TimestampRinvoiceDateTo
order_id (RorderId(
grand_total_from (	RgrandTotalFrom$
grand_total_to (	RgrandTotalTo"�
InvoicePaySchedule
id (Rid
uuid (	Ruuid#
payment_count (RpaymentCount5
due_date (2.google.protobuf.TimestampRdueDate
currency (	Rcurrency
grand_total (	R
grandTotal)
converted_amount (	RconvertedAmount
open_amount	 (	R
openAmount
is_paid
 (RisPaid"�
ListInvoicePaySchedulesResponse!
record_count (RrecordCount;
records (2!.field.invoice.InvoicePayScheduleRrecords&
next_page_token (	RnextPageToken"�
ListInvoicePaySchedulesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes

invoice_id	 (R	invoiceId2�
InvoiceInfoServicen

ListOrders .field.invoice.ListOrdersRequest.data.ListLookupItemsResponse"���/fields/invoices/orders�
ListBusinessPartners*.field.invoice.ListBusinessPartnersRequest.data.ListLookupItemsResponse"*���$"/fields/invoices/business-partners�
ListInvoiceInfo&.field.invoice.ListInvoicesInfoRequest'.field.invoice.ListInvoicesInfoResponse"�����/fields/invoicesZ31/fields/invoices/table/{table_name}/{column_name}Z%#/fields/invoices/column/{column_id}Z#!/fields/invoices/field/{field_id}Z31/fields/invoices/parameter/{process_parameter_id}Z31/fields/invoices/query-criteria/{browse_field_id}q
GetInvoiceInfo$.field.invoice.GetInvoiceInfoRequest.field.invoice.InvoiceInfo"���/fields/invoices/{id}�
ListInvoicePaySchedules-.field.invoice.ListInvoicePaySchedulesRequest..field.invoice.ListInvoicePaySchedulesResponse"3���-+/fields/invoices/{invoice_id}/pay-schedulesB9
#org.spin.backend.grpc.field.invoiceBADempiereInvoicePJ�:
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 <
	
 <

 1
	
 1
	
  &
	
 )
	
 
'
 2 Base URL
 /fields/invoices/

-
   L! The invoice service definition.



  

  "&	
 criteria


  "

  "(

  "3O

  #%

	  �ʼ"#%

 '+	

 ' 

 '!<

 'Gc

 (*

	 �ʼ"(*

 .A	 result


 .

 .3

 .>V

 /@

	 �ʼ"/@

 BF	

 B

 B0

 B;F

 CE

	 �ʼ"CE

 GK	

 G#

 G$B

 GMl

 HJ

	 �ʼ"HJ
'
 O [ List Invoice Info Request



 O

  P

  P

  P

  P

 Q

 Q

 Q

 Q

 R*

 R

 R

 R%

 R()

 S+

 S

 S

 S&

 S)*

 T

 T

 T

 T

 U

 U

 U

 U

 V 

 V

 V

 V

 W&

 W

 W!

 W$%

 X(

 X

 X#

 X&'

 	Z) custom filters


 	Z

 	Z#

 	Z&(

^ j Business Partners



^#

 _

 _

 _

 _

`

`

`

`

a*

a

a

a%

a()

b+

b

b

b&

b)*

c

c

c

c

d

d

d

d

e 

e

e

e

f&

f

f!

f$%

g(

g

g#

g&'

	i) custom filters


	i

	i#

	i&(
'
n  List Invoice Info Request



n

 o

 o

 o

 o

p

p

p

p

q!

q

q

q 

r$

r

r

r"#

s4

s!

s"/

s23

t

t

t

t

u

u

u

u

v

v

v

v

w$

w

w

w"#

	x 

	x

	x

	x


y!


y


y


y 

z

z

z

z

{'

{

{!

{$&

| 

|

|

|

}!

}

}

} 

~$

~

~

~!#

� �

�

 �

 �

 �

 �

�

�

�

�

� �

� 

 �

 �

 �

 �

�)

�

�

�$

�'(

�#

�

�

�!"

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

	�( references


	�

	�"

	�%'


�


�


�


�

�#

�

�

� "

� 

�

�

�

�

�

�

�

�

�

�

�

� 

�

�

�

�(


�

�"

�%'

�  custom filter


�

�

�

�'

�

�!

�$&

�)

�

�#

�&(

�

�

�

�

� 

�

�

�

�9

�!

�"3

�68

�7

�!

�"1

�46

�

�

�

�

�%

�

�

�"$

�#

�

�

� "
$
� � Invoice Pay Schedule


�

 �

 �

 �

 �

�

�

�

�

� 

�

�

�

�/

�!

�"*

�-.

�

�

�

�

�

�

�

�

�$

�

�

�"#

�

�

�

�

�

�

�

�

� �

�'

 �

 �

 �

 �

�0

�

�#

�$+

�./

�#

�

�

�!"

� �

�&

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

� custom filters


�

�

�bproto3
�G
field.order.protofield.ordergoogle/api/annotations.protogoogle/protobuf/timestamp.protobase_data_type.proto"�
ListOrdersRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords0
is_sales_transaction
 (	RisSalesTransaction"�
 ListBusinessPartnersOrderRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords0
is_sales_transaction
 (	RisSalesTransaction"�
	OrderInfo
id (Rid
uuid (	Ruuid#
display_value (	RdisplayValue)
business_partner (	RbusinessPartner=
date_ordered (2.google.protobuf.TimestampRdateOrdered
document_no (	R
documentNo
currency (	Rcurrency
grand_total (	R
grandTotal)
converted_amount	 (	RconvertedAmount0
is_sales_transaction
 (RisSalesTransaction!
is_delivered (RisDelivered 
description (	Rdescription!
po_reference (	RpoReference'
document_status (	RdocumentStatus"9
GetOrderInfoRequest
id (Rid
uuid (	Ruuid"�
ListOrdersInfoResponse!
record_count (RrecordCount0
records (2.field.order.OrderInfoRrecords&
next_page_token (	RnextPageToken"�
ListOrdersInfoRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords0
process_parameter_id
 (RprocessParameterId
field_id (RfieldId&
browse_field_id (RbrowseFieldId!
reference_id (RreferenceId
	column_id (RcolumnId

table_name (	R	tableName
column_name (	R
columnName2
is_without_validation (RisWithoutValidation
document_no (	R
documentNo.
business_partner_id (RbusinessPartnerId0
is_sales_transaction (	RisSalesTransaction 
description (	RdescriptionB
order_date_from (2.google.protobuf.TimestampRorderDateFrom>
order_date_to (2.google.protobuf.TimestampRorderDateTo!
is_delivered (	RisDelivered
order_id (RorderId(
grand_total_from (	RgrandTotalFrom$
grand_total_to (	RgrandTotalTo2�
OrderInfoService�
ListBusinessPartners-.field.order.ListBusinessPartnersOrderRequest.data.ListLookupItemsResponse" ���/fields/orders/customers�
ListOrderInfo".field.order.ListOrdersInfoRequest#.field.order.ListOrdersInfoResponse"�����/fields/ordersZ1//fields/orders/table/{table_name}/{column_name}Z#!/fields/orders/column/{column_id}Z!/fields/orders/field/{field_id}Z1//fields/orders/parameter/{process_parameter_id}Z1//fields/orders/query-criteria/{browse_field_id}e
GetOrderInfo .field.order.GetOrderInfoRequest.field.order.OrderInfo"���/fields/orders/{id}B5
!org.spin.backend.grpc.field.orderBADempiereOrderPJ�-
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Elsio Sanchez elsiosanches@gmail.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 :
	
 :

 /
	
 /
	
  &
	
 )
	
 
%
 2 Base URL
 /fields/orders/

+
   B The order service definition.



  

  "&	
 criteria


  " 

  "!A

  "Lh

  #%

	  �ʼ"#%

 )<	 result


 )

 )/

 ):P

 *;

	 �ʼ"*;

 =A	

 =

 =,

 =7@

 >@

	 �ʼ">@
%
 E Q List Order Info Request



 E

  F

  F

  F

  F

 G

 G

 G

 G

 H*

 H

 H

 H%

 H()

 I+

 I

 I

 I&

 I)*

 J

 J

 J

 J

 K

 K

 K

 K

 L 

 L

 L

 L

 M&

 M

 M!

 M$%

 N(

 N

 N#

 N&'

 	P) custom filters


 	P

 	P#

 	P&(

T ` Business Partners



T(

 U

 U

 U

 U

V

V

V

V

W*

W

W

W%

W()

X+

X

X

X&

X)*

Y

Y

Y

Y

Z

Z

Z

Z

[ 

[

[

[

\&

\

\!

\$%

](

]

]#

]&'

	_) custom filters


	_

	_#

	_&(
%
d s List Order Info Request



d

 e

 e

 e

 e

f

f

f

f

g!

g

g

g 

h$

h

h

h"#

i3

i!

i".

i12

j

j

j

j

k

k

k

k

l

l

l

l

m$

m

m

m"#

	n'

	n

	n!

	n$&


o


o


o


o

p 

p

p

p

q!

q

q

q 

r$

r

r

r!#


t w


t

 u

 u

 u

 u

v

v

v

v


x |


x

 y

 y

 y

 y

z'

z

z

z"

z%&

{#

{

{

{!"

} �


}

 ~

 ~

 ~

 ~









�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

	�( references


	�

	�"

	�%'


�


�


�


�

�#

�

�

� "

� 

�

�

�

�

�

�

�

�

�

�

�

� 

�

�

�

�(


�

�"

�%'

�  custom filter


�

�

�

�'

�

�!

�$&

�)

�

�#

�&(

� 

�

�

�

�7

�!

�"1

�46

�5

�!

�"/

�24

�!

�

�

� 

�

�

�

�

�%

�

�

�"$

�#

�

�

� "bproto3
�J
field.payment.protofield.paymentbase_data_type.protogoogle/api/annotations.protogoogle/protobuf/timestamp.proto"�
PaymentInfo
id (Rid
uuid (	Ruuid#
display_value (	RdisplayValue
document_no (	R
documentNo#
document_type (	RdocumentType!
bank_account (	RbankAccount)
business_partner (	RbusinessPartner=
date_payment (2.google.protobuf.TimestampRdatePayment
info_to	 (	RinfoTo!
account_name
 (	RaccountName
currency (	Rcurrency
pay_amt (	RpayAmt)
converted_amount (	RconvertedAmount!
discount_amt (	RdiscountAmt!
writeOff_amt (	RwriteOffAmt!
is_allocated (RisAllocated

is_receipt (R	isReceipt'
document_status (	RdocumentStatus";
GetPaymentInfoRequest
id (Rid
uuid (	Ruuid"�
ListPaymentInfoResponse!
record_count (RrecordCount4
records (2.field.payment.PaymentInfoRrecords&
next_page_token (	RnextPageToken"�
ListPaymentInfoRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords0
process_parameter_id
 (RprocessParameterId
field_id (RfieldId&
browse_field_id (RbrowseFieldId!
reference_id (RreferenceId
	column_id (RcolumnId

table_name (	R	tableName
column_name (	R
columnName2
is_without_validation (RisWithoutValidation
document_no (	R
documentNo.
business_partner_id (RbusinessPartnerId

is_receipt (	R	isReceipt

is_payment (	R	isPayment&
bank_account_id (RbankAccountIdF
payment_date_from (2.google.protobuf.TimestampRpaymentDateFromB
payment_date_to (2.google.protobuf.TimestampRpaymentDateTo(
grand_total_from (	RgrandTotalFrom$
grand_total_to (	RgrandTotalTo"�
ListBusinessPartnersRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords0
is_sales_transaction
 (	RisSalesTransaction"�
ListBankAccountRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords0
is_sales_transaction
 (	RisSalesTransaction2�
PaymentInfoService�
ListBusinessPartners*.field.payment.ListBusinessPartnersRequest.data.ListLookupItemsResponse"*���$"/fields/payments/business-partners~
ListBankAccount%.field.payment.ListBankAccountRequest.data.ListLookupItemsResponse"%���/fields/payments/bank-account�
ListPaymentInfo%.field.payment.ListPaymentInfoRequest&.field.payment.ListPaymentInfoResponse"�����/fields/paymentsZ31/fields/payments/table/{table_name}/{column_name}Z%#/fields/payments/column/{column_id}Z#!/fields/payments/field/{field_id}Z31/fields/payments/parameter/{process_parameter_id}Z31/fields/payments/query-criteria/{browse_field_id}B9
#org.spin.backend.grpc.field.paymentBADempierePaymentPJ�.
 �
�	
 �	***********************************************************************************
 Copyright (C) 2012-2022 E.R.P. Consultores y Asociados, C.A.                     *
 Contributor(s): Elsio Sanchez elsiosanches@gmail.com                             *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 <
	
 <

 1
	
 1
	
  
	
 &
	
 )
(
 2 Base URL
 /fields/paymnents/

-
  @! The payment service definition.



 

  !%	
 criteria


  ! 

  !!<

  !Gc

  "$

	  �ʼ""$

 &*	

 &

 &2

 &=Y

 ')

	 �ʼ"')

 ,?	 result


 ,

 ,2

 ,=T

 ->

	 �ʼ"->
'
 C V List Payment Info Request



 C

  D

  D

  D

  D

 E

 E

 E

 E

 F!

 F

 F

 F 

 G

 G

 G

 G

 H!

 H

 H

 H 

 I 

 I

 I

 I

 J$

 J

 J

 J"#

 K3

 K!

 K".

 K12

 L

 L

 L

 L

 	M!

 	M

 	M

 	M 

 
N

 
N

 
N

 
N

 O

 O

 O

 O

 P%

 P

 P

 P"$

 Q!

 Q

 Q

 Q 

 R!

 R

 R

 R 

 S

 S

 S

 S

 T

 T

 T

 T

 U$

 U

 U

 U!#


W Z


W

 X

 X

 X

 X

Y

Y

Y

Y


[ _


[

 \

 \

 \

 \

])

]

]

]$

]'(

^#

^

^

^!"
(
b � List Payment Info Request



b

 c

 c

 c

 c

d

d

d

d

e*

e

e

e%

e()

f+

f

f

f&

f)*

g

g

g

g

h

h

h

h

i 

i

i

i

j&

j

j!

j$%

k(

k

k#

k&'

	m( references


	m

	m"

	m%'


n


n


n


n

o#

o

o

o "

p 

p

p

p

q

q

q

q

r

r

r

r

s 

s

s

s

u(


u

u"

u%'

w  custom filter


w

w

w

x'

x

x!

x$&

y

y

y

y

z

z

z

z

{#

{

{

{ "

|9

|!

|"3

|68

}7

}!

}"1

}46

~%

~

~

~"$

#





 "
!
� � Business Partners


�#

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

	�) custom filters


	�

	�#

	�&(

� � Bank Account


�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

	�) custom filters


	�

	�#

	�&(bproto3
�
field.product.protofield.productgoogle/api/annotations.protogoogle/protobuf/timestamp.protobase_data_type.proto"�
ListWarehousesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
GetLastPriceListVersionRequest"
price_list_id (RpriceListId=
date_ordered (2.google.protobuf.TimestampRdateOrdered?
date_invoiced (2.google.protobuf.TimestampRdateInvoiced"�
ListPricesListVersionsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListAttributeSetsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
 ListAttributeSetInstancesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords(
attribute_set_id
 (RattributeSetId"�
ListProductCategoriesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListProductGroupsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListProductClasessRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
!ListProductClassificationsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListVendorsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ProductInfo
id (Rid
uuid (	Ruuid#
display_value (	RdisplayValue
value (	Rvalue
name (	Rname
upc (	Rupc
sku (	Rsku)
product_category (	RproductCategory#
product_group	 (	RproductGroup#
product_class
 (	RproductClass5
product_classification (	RproductClassification
uom (	Ruom

list_price (	R	listPrice%
standard_price (	RstandardPrice
limit_price (	R
limitPrice
margin (	Rmargin

is_stocked (R	isStocked-
available_quantity (	RavailableQuantity(
on_hand_quantity (	RonHandQuantity+
reserved_quantity (	RreservedQuantity)
ordered_quantity (	RorderedQuantity1
unconfirmed_quantity (	RunconfirmedQuantity:
unconfirmed_move_quantity (	RunconfirmedMoveQuantity
vendor (	Rvendor2
is_instance_attribute (RisInstanceAttribute 
description (	Rdescription#
document_note (	RdocumentNote
	is_active (RisActive"�
ListProductsInfoResponse!
record_count (RrecordCount4
records (2.field.product.ProductInfoRrecords&
next_page_token (	RnextPageToken"�	
ListProductsInfoRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords0
process_parameter_id
 (RprocessParameterId
field_id (RfieldId&
browse_field_id (RbrowseFieldId!
reference_id (RreferenceId
	column_id (RcolumnId

table_name (	R	tableName
column_name (	R
columnName2
is_without_validation (RisWithoutValidation
value (	Rvalue
name (	Rname
upc (	Rupc
sku (	Rsku!
warehouse_id (RwarehouseId1
price_list_version_id (RpriceListVersionId.
product_category_id (RproductCategoryId(
product_group_id (RproductGroupId(
product_class_id (RproductClassId:
product_classification_id (RproductClassificationId(
attribute_set_id (RattributeSetId9
attribute_set_instance_id (RattributeSetInstanceId
	vendor_id (RvendorId

is_stocked (	R	isStocked"�
WarehouseStock
id (Rid
uuid (	Ruuid
name (	Rname-
available_quantity (	RavailableQuantity(
on_hand_quantity (	RonHandQuantity+
reserved_quantity (	RreservedQuantity)
ordered_quantity (	RorderedQuantity"�
ListWarehouseStocksResponse!
record_count (RrecordCount7
records (2.field.product.WarehouseStockRrecords&
next_page_token (	RnextPageToken"�
ListWarehouseStocksRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes

product_id	 (R	productId"�
SubstituteProduct
id (Rid
uuid (	Ruuid
	warehouse (	R	warehouse 
description (	Rdescription
value (	Rvalue
name (	Rname-
available_quantity (	RavailableQuantity(
on_hand_quantity (	RonHandQuantity+
reserved_quantity	 (	RreservedQuantity%
standard_price
 (	RstandardPrice"�
ListSubstituteProductsResponse!
record_count (RrecordCount:
records (2 .field.product.SubstituteProductRrecords&
next_page_token (	RnextPageToken"�
ListSubstituteProductsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes

product_id	 (R	productId1
price_list_version_id
 (RpriceListVersionId"�
RelatedProduct
id (Rid
uuid (	Ruuid
	warehouse (	R	warehouse 
description (	Rdescription
value (	Rvalue
name (	Rname-
available_quantity (	RavailableQuantity(
on_hand_quantity (	RonHandQuantity+
reserved_quantity	 (	RreservedQuantity%
standard_price
 (	RstandardPrice"�
ListRelatedProductsResponse!
record_count (RrecordCount7
records (2.field.product.RelatedProductRrecords&
next_page_token (	RnextPageToken"�
ListRelatedProductsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes

product_id	 (R	productId1
price_list_version_id
 (RpriceListVersionId"�
AvailableToPromise
id (Rid
uuid (	Ruuid
name (	Rname
locator (	Rlocator
document_no (	R
documentNo.
date (2.google.protobuf.TimestampRdate(
on_hand_quantity (	RonHandQuantity+
reserved_quantity (	RreservedQuantity-
available_quantity	 (	RavailableQuantity)
ordered_quantity
 (	RorderedQuantityA
available_to_promise_quantity (	RavailableToPromiseQuantity)
business_partner (	RbusinessPartner4
attribute_set_instance (	RattributeSetInstance"�
ListAvailableToPromisesResponse!
record_count (RrecordCount;
records (2!.field.product.AvailableToPromiseRrecords&
next_page_token (	RnextPageToken"�
ListAvailableToPromisesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes

product_id	 (R	productId!
warehouse_id
 (RwarehouseId$
is_show_detail (RisShowDetail"�
VendorPurchase
id (Rid
uuid (	Ruuid
name (	Rname*
is_current_vendor (RisCurrentVendor&
unit_of_measure (	RunitOfMeasure
currency (	Rcurrency

list_price (	R	listPrice%
purchase_price (	RpurchasePrice.
last_purchase_price	 (	RlastPurchasePrice,
vendor_product_key
 (	RvendorProductKey,
min_order_quantity (	RminOrderQuantity4
promised_delivery_time (	RpromisedDeliveryTime0
actual_delivery_time (	RactualDeliveryTime"�
ListVendorPurchasesResponse!
record_count (RrecordCount7
records (2.field.product.VendorPurchaseRrecords&
next_page_token (	RnextPageToken"�
ListVendorPurchasesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes

product_id	 (R	productId2�
ProductInfoServicez
ListWarehouses$.field.product.ListWarehousesRequest.data.ListLookupItemsResponse"#���/fields/products/warehouses�
GetLastPriceListVersion-.field.product.GetLastPriceListVersionRequest.data.LookupItem">���86/fields/products/prices-lists-versions/{price_list_id}�
ListPricesListVersions,.field.product.ListPricesListVersionsRequest.data.ListLookupItemsResponse".���(&/fields/products/prices-lists-versions�
ListAttributeSets'.field.product.ListAttributeSetsRequest.data.ListLookupItemsResponse"'���!/fields/products/attribute-sets�
ListAttributeSetInstances/.field.product.ListAttributeSetInstancesRequest.data.ListLookupItemsResponse"D���></fields/products/attribute-sets/{attribute_set_id}/instances�
ListProductCategories+.field.product.ListProductCategoriesRequest.data.ListLookupItemsResponse"#���/fields/products/categories|
ListProductGroups'.field.product.ListProductGroupsRequest.data.ListLookupItemsResponse"���/fields/products/groups
ListProductClasses(.field.product.ListProductClasessRequest.data.ListLookupItemsResponse" ���/fields/products/clasess�
ListProductClassifications0.field.product.ListProductClassificationsRequest.data.ListLookupItemsResponse"(���" /fields/products/classificationsq
ListVendors!.field.product.ListVendorsRequest.data.ListLookupItemsResponse" ���/fields/products/vendors�
ListProductsInfo&.field.product.ListProductsInfoRequest'.field.product.ListProductsInfoResponse"�����/fields/productsZ31/fields/products/table/{table_name}/{column_name}Z%#/fields/products/column/{column_id}Z#!/fields/products/field/{field_id}Z31/fields/products/parameter/{process_parameter_id}Z31/fields/products/query-criteria/{browse_field_id}�
ListWarehouseStocks).field.product.ListWarehouseStocksRequest*.field.product.ListWarehouseStocksResponse"6���0./fields/products/{product_id}/warehouse-stocks�
ListSubstituteProducts,.field.product.ListSubstituteProductsRequest-.field.product.ListSubstituteProductsResponse"1���+)/fields/products/{product_id}/substitutes�
ListRelatedProducts).field.product.ListRelatedProductsRequest*.field.product.ListRelatedProductsResponse".���(&/fields/products/{product_id}/relateds�
ListAvailableToPromises-.field.product.ListAvailableToPromisesRequest..field.product.ListAvailableToPromisesResponse";���53/fields/products/{product_id}/available-to-promises�
ListVendorPurchases).field.product.ListVendorPurchasesRequest*.field.product.ListVendorPurchasesResponse"6���0./fields/products/{product_id}/vendor-purchasesB=
#org.spin.backend.grpc.field.productBADempiereProductInfoPJ�
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 <
	
 <

 5
	
 5
	
  &
	
 )
	
 
'
 2 Base URL
 /fields/products/

.
   �! The product service definition.



  

  "$	
 criteria


  "

  "0

  ";W

  #R

	  �ʼ"#R

 %)	

 %#

 %$B

 %M\

 &(

	 �ʼ"&(

 *.	

 *"

 *#@

 *Kg

 +-

	 �ʼ"+-

 /3	

 /

 /6

 /A]

 02

	 �ʼ"02

 47	

 4%

 4&F

 4Qm

 56^

	 �ʼ"56^

 8<	

 8!

 8">

 8Ie

 9;

	 �ʼ"9;

 =A	

 =

 =6

 =A]

 >@

	 �ʼ">@

 BF	

 B

 B8

 BC_

 CE

	 �ʼ"CE

 GK	

 G&

 G'H

 GSo

 HJ

	 �ʼ"HJ

 	LP	

 	L

 	L*

 	L5Q

 	MO

	 	�ʼ"MO

 
Sf	 result


 
S

 
S4

 
S?W

 
Te

	 
�ʼ"Te

 gk	

 g

 g :

 gE`

 hj

	 �ʼ"hj

 lp	

 l"

 l#@

 lKi

 mo

	 �ʼ"mo

 qu	

 q

 q :

 qE`

 rt

	 �ʼ"rt

 vz	

 v#

 v$B

 vMl

 wy

	 �ʼ"wy

 {	

 {

 { :

 {E`

 |~

	 �ʼ"|~

 � �

 �

  �

  �

  �

  �

 �

 �

 �

 �

 �*

 �

 �

 �%

 �()

 �+

 �

 �

 �&

 �)*

 �

 �

 �

 �

 �

 �

 �

 �

 � 

 �

 �

 �

 �&

 �

 �!

 �$%

 �(

 �

 �#

 �&'

� �

�&

 � 

 �

 �

 �

�3

�!

�".

�12

�4

�!

�"/

�23

� �

�%

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

� �

� 

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

� �

�(

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

	�$ custom filters


	�

	�

	�!#

� �

�$

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

� �

� 

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

� �

�!

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

� �

�)

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

	� �

	�

	 �

	 �

	 �

	 �

	�

	�

	�

	�

	�*

	�

	�

	�%

	�()

	�+

	�

	�

	�&

	�)*

	�

	�

	�

	�

	�

	�

	�

	�

	� 

	�

	�

	�

	�&

	�

	�!

	�$%

	�(

	�

	�#

	�&'


� � Product Info



�


 �


 �


 �


 �


�


�


�


�


�!


�


�


� 


�


�


�


�


�


�


�


�


�


�


�


�


�


�


�


�


�$


�


�


�"#


�!


�


�


� 


	�"


	�


	�


	�!



�+



�



�%



�(*


�


�


�


�


� price



�


�


�


�#


�


�


� "


� 


�


�


�


�


�


�


�


�	 storage



�


�


�


�'


�


�!


�$&


�%


�


�


�"$


�&


�


� 


�#%


�%


�


�


�"$


�)


�


�#


�&(


�.


�


�(


�+-


�



�


�


�


�(


�


�"


�%'


�  additional



�


�


�


�"


�


�


�!


�


�


�


�

� �

� 

 �

 �

 �

 �

�)

�

�

�$

�'(

�#

�

�

�!"

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

	�( references


	�

	�"

	�%'


�


�


�


�

�#

�

�

� "

� 

�

�

�

�

�

�

�

�

�

�

�

� 

�

�

�

�(


�

�"

�%'

� custom filters


�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� 

�

�

�

�)

�

�#

�&(

�'

�

�!

�$&

�$

�

�

�!#

�$

�

�

�!#

�-

�

�'

�*,

�$

�

�

�!#

�-

�

�'

�*,

�

�

�

�

�

�

�

�

� � Warehouse Stock


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�&

�

�!

�$%

�$

�

�

�"#

�%

�

� 

�#$

�$

�

�

�"#

� �

�#

 �

 �

 �

 �

�,

�

�

� '

�*+

�#

�

�

�!"

� �

�"

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

� custom filters


�

�

�
"
� � Substitute Product


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�& quantities


�

�!

�$%

�$

�

�

�"#

�%

�

� 

�#$

	�#

	�

	�

	� "

� �

�&

 �

 �

 �

 �

�/

�

�"

�#*

�-.

�#

�

�

�!"

� �

�%

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

� custom filters


�

�

�

	�)

	�

	�#

	�&(

� � Related Product


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�& quantities


�

�!

�$%

�$

�

�

�"#

�%

�

� 

�#$

	�#

	�

	�

	� "

� �

�#

 �

 �

 �

 �

�,

�

�

� '

�*+

�#

�

�

�!"

� �

�"

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

� custom filters


�

�

�

	�)

	�

	�#

	�&(
$
� � Available To Promise


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�+

�!

�"&

�)*

�$

�

�

�"#

�%

�

� 

�#$

�&

�

�!

�$%

	�%

	�

	�

	�"$


�2


�


�,


�/1

�%

�

�

�"$

�+

�

�%

�(*

� �

�'

 �

 �

 �

 �

�0

�

�#

�$+

�./

�#

�

�

�!"

� �

�&

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

� custom filters


�

�

�

	� 

	�

	�

	�


�!


�


�


� 
$
� � Available To Promise


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�#

�

�

�!"

�#

�

�

�!"

�

�

�

�

� price


�

�

�

�"

�

�

� !

�'

�

�"

�%&

	�'


	�

	�!

	�$&


�'


�


�!


�$&

�+

�

�%

�(*

�)

�

�#

�&(

� �

�#

 �

 �

 �

 �

�,

�

�

� '

�*+

�#

�

�

�!"

� �

�"

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

� custom filters


�

�

�bproto3
�N
field.protofieldbase_data_type.protogoogle/api/annotations.protogoogle/protobuf/struct.proto"�
GetDefaultValueRequest

table_name (	R	tableName
column_name (	R
columnName
	column_id (RcolumnId
field_id (RfieldId0
process_parameter_id (RprocessParameterId5
process_parameter_to_id (RprocessParameterToId&
browse_field_id (RbrowseFieldId+
browse_field_to_id (RbrowseFieldToId-
context_attributes	 (	RcontextAttributes,
value
 (2.google.protobuf.ValueRvalue"l
DefaultValue
id (Rid/
values (2.google.protobuf.StructRvalues
	is_active (RisActive"�
ListGeneralSearchRecordsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords0
process_parameter_id
 (RprocessParameterId
field_id (RfieldId&
browse_field_id (RbrowseFieldId!
reference_id (RreferenceId
	column_id (RcolumnId

table_name (	R	tableName
column_name (	R
columnName2
is_without_validation (RisWithoutValidation"�
ListZoomWindowsRequest0
process_parameter_id (RprocessParameterId
field_id (RfieldId&
browse_field_id (RbrowseFieldId!
reference_id (RreferenceId
	column_id (RcolumnId

table_name (	R	tableName
column_name (	R
columnName,
value (2.google.protobuf.ValueRvalue"�

ZoomWindow
id (Rid
name (	Rname 
description (	Rdescription0
is_sales_transaction (RisSalesTransaction
tab_id (RtabId
tab_uuid (	RtabUuid
tab_name (	RtabName"
is_parent_tab (RisParentTab"�
ListZoomWindowsResponse

table_name (	R	tableName&
key_column_name (	RkeyColumnName
key_columns (	R
keyColumns.
display_column_name (	RdisplayColumnName0
context_column_names (	RcontextColumnNames4
zoom_windows (2.field.ZoomWindowRzoomWindows"~
GetZoomParentRecordRequest
	window_id (RwindowId
tab_id (RtabId,
value (2.google.protobuf.ValueRvalue"�
GetZoomParentRecordResponse"
parent_tab_id (RparentTabId&
parent_tab_uuid (	RparentTabUuid

key_column (	R	keyColumn
name (	Rname
	record_id (RrecordId2�
FieldManagementService�
GetDefaultValue.field.GetDefaultValueRequest.field.DefaultValue"�����0/fields/default-value/{table_name}/{column_name}Z*(/fields/default-value/column/{column_id}Z(&/fields/default-value/field/{field_id}Z86/fields/default-value/parameter/{process_parameter_id}Z></fields/default-value/parameter/{process_parameter_to_id}/toZ86/fields/default-value/query-criteria/{browse_field_id}Z></fields/default-value/query-criteria/{browse_field_to_id}/to�
ListLookupItems.data.ListLookupItemsRequest.data.ListLookupItemsResponse"�����*/fields/lookups/{table_name}/{column_name}Z$"/fields/lookups/column/{column_id}Z" /fields/lookups/field/{field_id}Z20/fields/lookups/parameter/{process_parameter_id}Z20/fields/lookups/query-criteria/{browse_field_id}�
ListGeneralSearchRecords&.field.ListGeneralSearchRecordsRequest.data.ListEntitiesResponse"�����*/fields/searchs/{table_name}/{column_name}Z$"/fields/searchs/column/{column_id}Z" /fields/searchs/field/{field_id}Z20/fields/searchs/parameter/{process_parameter_id}Z20/fields/searchs/query-criteria/{browse_field_id}�
ListZoomWindows.field.ListZoomWindowsRequest.field.ListZoomWindowsResponse"�����(/fields/zooms/{table_name}/{column_name}Z" /fields/zooms/column/{column_id}Z /fields/zooms/field/{field_id}Z0./fields/zooms/parameter/{process_parameter_id}Z0./fields/zooms/query-criteria/{browse_field_id}�
GetZoomParentRecord!.field.GetZoomParentRecordRequest".field.GetZoomParentRecordResponse"1���+)/fields/zooms/record/{window_id}/{tab_id}B9
org.spin.backend.grpc.fieldBADempiereFieldManagementPJ�-
�
�	
�	***********************************************************************************
 Copyright (C) 2012-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Yamel Senih ysenih@erpya.com                                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 4
	
 4

 9
	
 9
	
  
	
 &
	
 &

 2 Base URL
 /fields/


  t	Field Management



 
!
  !7	 Get Default Value


  !

  !2

  !=I

  "6

	  �ʼ""6
 
 9I	 List Lookup Item


 9

 97

 9B^

 :H

	 �ʼ":H
+
 K[	 List General Search Records


 K$

 K%D

 KOh

 LZ

	 �ʼ"LZ
*
 ^n	 Windows To Zoom from field


 ^

 ^2

 ^=T

 _m

	 �ʼ"_m

 os	

 o

 o :

 oE`

 pr

	 �ʼ"pr

 w � Default Value



 w

  y References


  y

  y

  y

 z

 z

 z

 z

 {

 {

 {

 {

 |

 |

 |

 |

 }'

 }

 }"

 }%&

 ~*

 ~

 ~%

 ~()

 "

 

 

  !

 �%

 �

 � 

 �#$

 �&

 �

 �!

 �$%

 	�)

 	�

 	�#

 	�&(

� �

�

 �

 �

 �

 �

�*

�

�%

�()

�

�

�

�
+
� � List Search Records Request


�'

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

	�( references


	�

	�"

	�%'


�


�


�


�

�#

�

�

� "

� 

�

�

�

�

�

�

�

�

�

�

�

� 

�

�

�

�(


�

�"

�%'

� �	Zoom Window


�

 �' references


 �

 �"

 �%&

�

�

�

�

�"

�

�

� !

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�( current value


�

�#

�&'

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�&

�

�!

�$%

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�#

�

�

�!"

�(

�

�

�#

�&'

�'

�

�"

�%&

�1

�

�

�,

�/0

�-

�

�

�(

�+,

� �

�"

 �

 �

 �

 �

�

�

�

�

�( current value


�

�#

�&'

� �

�#

 � 

 �

 �

 �

�#

�

�

�!"

�

�

�

�

�

�

�

�

� parent value


�

�

�bproto3
�`
file_management.protofile_managementgoogle/api/annotations.protogoogle/protobuf/empty.protogoogle/protobuf/timestamp.proto"
Resource
data (Rdata"�

Attachment
id (Rid
title (	Rtitle!
text_message (	RtextMessageS
resource_references (2".file_management.ResourceReferenceRresourceReferences"�
ResourceReference
id (Rid
uuid (	Ruuid
name (	Rname
	file_name (	RfileName&
valid_file_name (	RvalidFileName
	file_size (	RfileSize 
description (	Rdescription!
text_message (	RtextMessage!
content_type	 (	RcontentType4
created
 (2.google.protobuf.TimestampRcreated4
updated (2.google.protobuf.TimestampRupdatedB
resource_type (2.file_management.ResourceTypeRresourceType
resource_id (R
resourceId"V
LoadResourceRequest
data (Rdata
id (Rid
	file_size (	RfileSize"�
GetResourceRequest
id (Rid#
resource_name (	RresourceName#
attachment_id (RattachmentId
	file_name (	RfileName
image_id (RimageId
width (Rwidth
height (Rheight8
	operation	 (2.file_management.OperationR	operation

archive_id (R	archiveId"�
GetResourceReferenceRequest
id (Rid#
resource_name (	RresourceName#
attachment_id (RattachmentId
	file_name (	RfileName
image_id (RimageId

archive_id (R	archiveId"R
GetAttachmentRequest

table_name (	R	tableName
	record_id (RrecordId"T
SetAttachmentDescriptionRequest
id (Rid!
text_message (	RtextMessage"�
SetResourceReferenceRequestB
resource_type (2.file_management.ResourceTypeRresourceType
id (Rid

table_name (	R	tableName
	record_id (RrecordId
	file_name (	RfileName
	file_size (RfileSize 
description (	Rdescription!
text_message (	RtextMessage"N
ConfirmResourceReferenceRequest
id (Rid
	file_size (	RfileSize"�
&SetResourceReferenceDescriptionRequest
id (Rid
	file_name (	RfileName 
description (	Rdescription!
text_message (	RtextMessage"�
DeleteResourceReferenceRequest
id (Rid#
resource_name (	RresourceName#
attachment_id (RattachmentId
fileName (	RfileName
image_id (RimageId

archive_id (R	archiveId5
is_delete_external_file (RisDeleteExternalFile"U
ExistsAttachmentRequest

table_name (	R	tableName
	record_id (RrecordId"=
ExistsAttachmentResponse!
record_count (RrecordCount*6
ResourceType

ATTACHMENT 	
IMAGE
ARCHIVE*8
	Operation

RESIZE 
CROP
FIX
IDENTIFY2�
FileManagement�
LoadResource$.file_management.LoadResourceRequest".file_management.ResourceReference"*���$"/file-management/resources/{id}:*(�
GetResource#.file_management.GetResourceRequest.file_management.Resource"�����/file-management/resources/{id}Z64/file-management/resources/file-name/{resource_name}ZC*A/file-management/resources/attachment/{attachment_id}/{file_name}Z-+/file-management/resources/image/{image_id}Z1//file-management/resources/archive/{archive_id}0�
SetAttachmentDescription0.file_management.SetAttachmentDescriptionRequest.file_management.Attachment",���&!/file-management/attachments/{id}:*�
ExistsAttachment(.file_management.ExistsAttachmentRequest).file_management.ExistsAttachmentResponse"D���></file-management/attachments/{table_name}/{record_id}/exists�
GetAttachment%.file_management.GetAttachmentRequest.file_management.Attachment"=���75/file-management/attachments/{table_name}/{record_id}�
SetResourceReference,.file_management.SetResourceReferenceRequest".file_management.ResourceReference"�����?/file-management/references/attachment/{table_name}/{record_id}:*Z+&/file-management/references/image/{id}:*Z-(/file-management/references/archive/{id}:*�
ConfirmResourceReference0.file_management.ConfirmResourceReferenceRequest".file_management.ResourceReference"3���-(/file-management/references/{id}/confirm:*�
SetResourceReferenceDescription7.file_management.SetResourceReferenceDescriptionRequest".file_management.ResourceReference"7���1,/file-management/references/{id}/description:*�
GetResourceReference,.file_management.GetResourceReferenceRequest".file_management.ResourceReference"����� /file-management/references/{id}Z75/file-management/references/file-name/{resource_name}ZD*B/file-management/references/attachment/{attachment_id}/{file_name}Z.,/file-management/references/image/{image_id}Z20/file-management/references/archive/{archive_id}�
DeleteResourceReference/.file_management.DeleteResourceReferenceRequest.google.protobuf.Empty"�����* /file-management/references/{id}Z7*5/file-management/references/file-name/{resource_name}ZD*B/file-management/references/attachment/{attachment_id}/{file_name}Z.,/file-management/references/image/{image_id}Z20/file-management/references/archive/{archive_id}BB
%org.spin.backend.grpc.file_managementBADempiereFileManagementPJ�8
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 >
	
 >

 8
	
 8
	
  &
	
 %
	
 )
'
 2 Base URL
 /file-management/

6
  �) The File Management service definition.



 

  !&		Resource/File


  !

  !

  ! 3

  !>O

  "%

	  �ʼ""%

 '7	

 '

 '*

 '5;

 '<D

 (6

	 �ʼ"(6

 :?		Attachment


 :$

 :%D

 :OY

 ;>

	 �ʼ";>

 @B	

 @

 @4

 @?W

 As

	 �ʼ"As

 CE	

 C

 C.

 C9C

 Dl

	 �ʼ"Dl
"
 HU		Resource Reference


 H 

 H!<

 HGX

 IT

	 �ʼ"IT

 V[	

 V$

 V%D

 VO`

 WZ

	 �ʼ"WZ

 \a	

 \+

 \,R

 \]n

 ]`

	 �ʼ"]`

 br	

 b 

 b!<

 bGX

 cq

	 �ʼ"cq

 	s�	

 	s#

 	s$B

 	sMb

 	t�

	 	�ʼ"t�

 � � Resource Chunk


 �

  �

  �

  �

  �

� � Attachment


�

 �

 �

 �

 �

�

�

�

�

� 

�

�

�

�;

�

�"

�#6

�9:

 � �

 �

  �"	 Default


  �

  �

 �

 �

 �

 �

 �

 �
"
� �	Resource reference


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�
 
�#" uuid + file_name


�

�

�!"

�

�

�

�

�

�

�

�

� 

�

�

�

� 

�

�

�

	�/

	�!

	�")

	�,.


�/


�!


�")


�,.

�(

�

�"

�%'
*
�" attachment, image, archive


�

�

�
+
� � Request for upload resource


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

�

�

�

�

�

�

�

�

�
-
� � Request for download resource


�

 �

 �

 �

 �

�!

�

�

� 

�  attachment


�

�

�

�

�

�

�

� image


�

�

�

�

�

�

�

�

�

�

�

� 

�

�

�

�	 archive


�

�

�
7
� �) Request for download resource reference


�#

 �

 �

 �

 �

�!

�

�

� 

� 

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�
8
� �* Request attachment from table and record


�

 �

 �

 �

 �

�

�

�

�

� �

�'

 �

 �

 �

 �

� 

�

�

�

� �

�#

 �'

 �

 �"

 �%&
*
�" attachment, image, archive


�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� 

�

�

�

	� �

	�'

	 �

	 �

	 �

	 �

	�

	�

	�

	�


� �


�.


 �


 �


 �


 �


�


�


�


�


�


�


�


�


� 


�


�


�

� �

�&

 �

 �

 �

 �

�!

�

�

� 

� 

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�
9
�)"+ delete external file with attachment util


�

�$

�'(

� �

�

 �

 �

 �

 �

�

�

�

�

� �

� 

 �

 �

 �

 �bproto3
��
general_ledger.protogeneral_ledgergoogle/api/annotations.protogoogle/protobuf/struct.protogoogle/protobuf/timestamp.protobase_data_type.proto"�
AccoutingElement!
element_type (	RelementType
column_name (	R
columnName
name (	Rname!
is_mandatory (RisMandatory
is_balanced (R
isBalanced
sequece (Rsequece0
context_column_names (	RcontextColumnNames!
display_type (RdisplayType
field_id	 (RfieldId"�
ListAccoutingElementsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes.
accouting_schema_id	 (RaccoutingSchemaId"�
ListAccoutingElementsResponse!
record_count (RrecordCountO
accouting_elements (2 .general_ledger.AccoutingElementRaccoutingElements&
next_page_token (	RnextPageToken"`
AccoutingElementValue
id (Rid
value (	Rvalue!
dispay_value (	RdispayValue"�
!ListAccoutingElementValuesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords.
accouting_schema_id
 (RaccoutingSchemaId!
element_type (	RelementType"�
"ListAccoutingElementValuesResponse!
record_count (RrecordCount_
accouting_element_values (2%.general_ledger.AccoutingElementValueRaccoutingElementValues&
next_page_token (	RnextPageToken"G
GetAccountingCombinationRequest
id (Rid
value (	Rvalue"�
!ListAccountingCombinationsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes'
organization_id	 (RorganizationId

account_id
 (R	accountId"�
 SaveAccountingCombinationRequest
id (Rid
	client_id (RclientId0
accounting_schema_id (RaccountingSchemaId'
organization_id (RorganizationId

account_id (R	accountId
alias (	RaliasF
context_attributes (2.google.protobuf.StructRcontextAttributes7

attributes (2.google.protobuf.StructR
attributes"�
ListAccountingSchemasRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListPostingTypesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListAccountingDocumentsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"W
AccountingDocument
id (Rid
name (	Rname

table_name (	R	tableName"�
ListAccountingDocumentsResponse!
record_count (RrecordCount<
records (2".general_ledger.AccountingDocumentRrecords&
next_page_token (	RnextPageToken"�
ListOrganizationsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ExistsAccoutingDocumentRequest0
accounting_schema_id (RaccountingSchemaId

table_name (	R	tableName
	record_id (RrecordId"M
ExistsAccoutingDocumentResponse*
is_show_accouting (RisShowAccouting"�
ListAccountingFactsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue0
accounting_schema_id (RaccountingSchemaId!
posting_type	 (	RpostingType

table_name
 (	R	tableName
	record_id (RrecordId7
	date_from (2.google.protobuf.TimestampRdateFrom3
date_to (2.google.protobuf.TimestampRdateTo'
organization_id (RorganizationId"k
StartRePostRequest

table_name (	R	tableName
	record_id (RrecordId
is_force (RisForce"2
StartRePostResponse
	error_msg (	RerrorMsg2�
GeneralLedger�
ListAccoutingElements,.general_ledger.ListAccoutingElementsRequest-.general_ledger.ListAccoutingElementsResponse"G���A?/general-ledger/accounts/schemas/{accouting_schema_id}/elements�
ListAccoutingElementValues1.general_ledger.ListAccoutingElementValuesRequest.data.ListLookupItemsResponse"V���PN/general-ledger/accounts/schemas/{accouting_schema_id}/elements/{element_type}�
getAccountingCombination/.general_ledger.GetAccountingCombinationRequest.data.Entity"o���i*/general-ledger/accounts/combinations/{id}Z;9/general-ledger/accounts/combinations/combination/{value}�
ListAccountingCombinations1.general_ledger.ListAccountingCombinationsRequest.data.ListEntitiesResponse"-���'%/general-ledger/accounts/combinations�
SaveAccountingCombination0.general_ledger.SaveAccountingCombinationRequest.data.Entity"0���*"%/general-ledger/accounts/combinations:*�
ListAccountingSchemas,.general_ledger.ListAccountingSchemasRequest.data.ListLookupItemsResponse"(���" /general-ledger/accounts/schemas�
ListPostingTypes'.general_ledger.ListPostingTypesRequest.data.ListLookupItemsResponse".���(&/general-ledger/accounts/posting-types�
ListOrganizations(.general_ledger.ListOrganizationsRequest.data.ListLookupItemsResponse"%���/general-ledger/organizations�
ListAccountingDocuments..general_ledger.ListAccountingDocumentsRequest/.general_ledger.ListAccountingDocumentsResponse"*���$"/general-ledger/accounts/documents�
ExistsAccoutingDocument..general_ledger.ExistsAccoutingDocumentRequest/.general_ledger.ExistsAccoutingDocumentResponse"f���`^/general-ledger/accounts/facts/{accounting_schema_id}/document/{table_name}/{record_id}/exists�
ListAccountingFacts*.general_ledger.ListAccountingFactsRequest.data.ListEntitiesResponse"�����5/general-ledger/accounts/facts/{accounting_schema_id}ZYW/general-ledger/accounts/facts/{accounting_schema_id}/document/{table_name}/{record_id}�
StartRePost".general_ledger.StartRePostRequest#.general_ledger.StartRePostResponse"B���<"7/general-ledger/accounts/facts/{table_name}/{record_id}:*B@
$org.spin.backend.grpc.general_ledgerBADempiereGeneralLedgerPJ�S
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 =
	
 =

 7
	
 7
	
  &
	
 &
	
 )
	
 
&
 2 Base URL
 /general-ledger/

4
 ! [( The General Ledger service definition.



 !
!
  #%	 Accouting Element


  #!

  #">

  #If

  $v

	  �ʼ"$v

 &(	

 &&

 &'H

 &So

 '�

	 �ʼ"'�
&
 +2	 Accounting Combination


 +$

 +%D

 +OZ

 ,1

	 �ʼ",1

 35	

 3&

 3'H

 3Sl

 4\

	 �ʼ"4\

 6;	

 6%

 6&F

 6Q\

 7:

	 �ʼ"7:
!
 >@	 Accounting Viewer


 >!

 >">

 >Ie

 ?W

	 �ʼ"?W

 AC	

 A

 A4

 A?[

 B]

	 �ʼ"B]

 DF	

 D

 D6

 DA]

 ET

	 �ʼ"ET

 GI	

 G#

 G$B

 GMl

 HY

	 �ʼ"HY

 	JL	

 	J#

 	J$B

 	JMl

 	K�

	 	�ʼ"K�

 
MT	

 
M

 
M :

 
ME^

 
NS

	 
�ʼ"NS

 UZ	

 U

 U*

 U5H

 VY

	 �ʼ"VY

 _ i Accouting Element



 _

  ` 

  `

  `

  `

 a

 a

 a

 a

 b

 b

 b

 b

 c

 c

 c

 c

 d

 d

 d

 d

 e

 e

 e

 e

 f1

 f

 f

 f,

 f/0

 g

 g

 g

 g

 h

 h

 h

 h


k u


k$

 l

 l

 l

 l

m

m

m

m

n*

n

n

n%

n()

o+

o

o

o&

o)*

p

p

p

p

q

q

q

q

r 

r

r

r

s&

s

s!

s$%

t&

t

t!

t$%


w {


w%

 x

 x

 x

 x

y9

y

y!

y"4

y78

z#

z

z

z!"

} �


}

 ~

 ~

 ~

 ~









� 

�

�

�

� �

�)

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

	�' Custom Filters


	�

	�!

	�$&


�!


�


�


� 

� �

�*

 �

 �

 �

 �

�D

�

�&

�'?

�BC

�#

�

�

�!"
&
� � Accounting Combination


�'

 �

 �

 �

 �

�

�

�

�

� �

�)

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�& custom filters


�

�!

�$%

�"

�

�

� !

	�

	�

	�

	�

� �

�(

 �

 �

 �

 �

�

�

�

�

�'

�

�"

�%&

�"

�

�

� !

�

�

�

�

�

�

�

�

�6

�

�1

�45

�.

�

�)

�,-
!
	� � Accounting Schema


	�$

	 �

	 �

	 �

	 �

	�

	�

	�

	�

	�*

	�

	�

	�%

	�()

	�+

	�

	�

	�&

	�)*

	�

	�

	�

	�

	�

	�

	�

	�

	� 

	�

	�

	�

	�&

	�

	�!

	�$%

	�(

	�

	�#

	�&'


� � Posting Type



�


 �


 �


 �


 �


�


�


�


�


�*


�


�


�%


�()


�+


�


�


�&


�)*


�


�


�


�


�


�


�


�


� 


�


�


�


�&


�


�!


�$%


�(


�


�#


�&'
#
� � Accounting Document


�&

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

� �

�'

 �

 �

 �

 �

�0

�

�#

�$+

�./

�#

�

�

�!"

� � Organization


� 

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

� � Accounting Fact


�&
!
 �' mandatory filters


 �

 �"

 �%&
 
� document filters


�

�

�

�

�

�

�

� �

�'

 �#

 �

 �

 �!"

� �

�"

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�
!
�' mandatory filters


�

�"

�%&

�  optional filter


�

�

�
 
	� document filters


	�

	�

	�


�


�


�


�

�1


�!

�"+

�.0

�/

�!

�")

�,.

�#

�

�

� "

� � Start Re-Post


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �bproto3
�i
import_file_loader.protoimport_file_loadergoogle/api/annotations.protogoogle/protobuf/struct.protobase_data_type.proto"�
ListCharsetsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListImportTablesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ImportColumn
id (Rid
uuid (	Ruuid
name (	Rname
column_name (	R
columnName!
display_type (RdisplayType"�
ImportTable
id (Rid
uuid (	Ruuid
name (	Rname

table_name (	R	tableNameG
import_columns (2 .import_file_loader.ImportColumnRimportColumns"�
ListImportTablesResponse!
record_count (RrecordCount9
records (2.import_file_loader.ImportTableRrecords&
next_page_token (	RnextPageToken"�
ListImportFormatsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords

table_name
 (	R	tableName"�
ListClientImportFormatsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords

table_name
 (	R	tableName"�
ImportFormat
id (Rid
uuid (	Ruuid
name (	Rname 
description (	Rdescription

table_name (	R	tableName
format_type (	R
formatType/
separator_character (	RseparatorCharacterD
format_fields (2.import_file_loader.FormatFieldRformatFields"�
FormatField
id (Rid
uuid (	Ruuid
name (	Rname
sequence (Rsequence
column_name (	R
columnName
	data_type (	RdataType
start_no (RstartNo
end_no (RendNo#
default_value	 (	RdefaultValue#
defimal_point
 (	RdefimalPoint'
is_divide_by_100 (RisDivideBy100
date_format (	R
dateFormat%
constant_value (	RconstantValue"(
GetImportFromatRequest
id (Rid"�
ListFilePreviewRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue(
import_format_id (RimportFormatId#
resource_name	 (	RresourceName
charset
 (	Rcharset"�
SaveRecordsRequest(
import_format_id (RimportFormatId#
resource_name (	RresourceName
charset (	Rcharset

is_process (R	isProcess

process_id (R	processId7

parameters (2.google.protobuf.StructR
parameters"x
SaveRecordsResponse
message (	Rmessage
total (Rtotal1
process_log (2.data.ProcessLogR
processLog"�
ListImportProcessesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords

table_name
 (	R	tableName2�
ImportFileLoaderw
ListCharsets'.import_file_loader.ListCharsetsRequest.data.ListLookupItemsResponse"���/import-loader/charsets�
ListImportTables+.import_file_loader.ListImportTablesRequest,.import_file_loader.ListImportTablesResponse"���/import-loader/tables�
ListImportFormats,.import_file_loader.ListImportFormatsRequest.data.ListLookupItemsResponse"+���%#/import-loader/formats/{table_name}�
GetImportFromat*.import_file_loader.GetImportFromatRequest .import_file_loader.ImportFormat"'���!/import-loader/formats/get/{id}�
SaveRecords&.import_file_loader.SaveRecordsRequest'.import_file_loader.SaveRecordsResponse"4���.")/import-loader/imports/{import_format_id}:*�
ListFilePreview*.import_file_loader.ListFilePreviewRequest.data.ListEntitiesResponse"B���<:/import-loader/imports/resource/preview/{import_format_id}�
ListImportProcesses..import_file_loader.ListImportProcessesRequest.data.ListLookupItemsResponse"-���'%/import-loader/processes/{table_name}BL
-org.spin.backend.grpc.form.import_file_loaderBADempiereImportFileLoaderPJ�B
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 F
	
 F

 :
	
 :
	
  &
	
 &
	
 
%
 2 Base URL
 /import-loader/



  E


 

  #	

  

  ,

  7S

   "

	  �ʼ" "

 $(	

 $

 $4

 $?W

 %'

	 �ʼ"%'

 )-	

 )

 )6

 )A]

 *,

	 �ʼ"*,

 .2	

 .

 .2

 .=I

 /1

	 �ʼ"/1

 49	 Manage File


 4

 4*

 45H

 58

	 �ʼ"58

 :>	

 :

 :2

 :=V

 ;=

	 �ʼ";=

 @D		 Process


 @

 @ :

 @Ea

 AC

	 �ʼ"AC

 H R	 Charset



 H

  I

  I

  I

  I

 J

 J

 J

 J

 K*

 K

 K

 K%

 K()

 L+

 L

 L

 L&

 L)*

 M

 M

 M

 M

 N

 N

 N

 N

 O 

 O

 O

 O

 P&

 P

 P!

 P$%

 Q(

 Q

 Q#

 Q&'

V ^ Import Table



V

 W

 W

 W

 W

X

X

X

X

Y*

Y

Y

Y%

Y()

Z+

Z

Z

Z&

Z)*

[

[

[

[

\

\

\

\

] 

]

]

]


` f


`

 a

 a

 a

 a

b

b

b

b

c

c

c

c

d

d

d

d

e

e

e

e


h n


h

 i

 i

 i

 i

j

j

j

j

k

k

k

k

l

l

l

l

m1

m

m

m,

m/0


p t


p 

 q

 q

 q

 q

r)

r

r

r$

r'(

s#

s

s

s!"

x � Import Format



x 

 y

 y

 y

 y

z

z

z

z

{*

{

{

{%

{()

|+

|

|

|&

|)*

}

}

}

}

~

~

~

~

 







�&

�

�!

�$%

�(

�

�#

�&'

	� custom filters


	�

	�

	�

� �

�&

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

	� custom filters


	�

	�

	�

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�'

�

�"

�%&

�/

�

�

�*

�-.

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�!

�

�

� 

	�" number


	�

	�

	�!


�#


�


�


� "

�  date


�

�

�

�#
 constant


�

�

� "

	� � Format Field


	�

	 �

	 �

	 �

	 �


� � Preview File



�


 �


 �


 �


 �


�


�


�


�


�*


�


�


�%


�()


�+


�


�


�&


�)*


�


�


�


�


�


�


�


�


� 


�


�


�


�#


�


�


�!"


�!


�


�


� 


	�


	�


	�


	�

� � Save Record


�

 �#

 �

 �

 �!"

�!

�

�

� 

�

�

�

�
+
� process before save changes


�

�

�

�

�

�

�

�.

�

�)

�,-

� �

�

 �

 �

 �

 �

�

�

�

�

�(

�

�#

�&'

� � Process Import


�"

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

	� custom filters


	�

	�

	�bproto3
�
issue_management.protoissue_managementgoogle/api/annotations.protogoogle/protobuf/empty.protogoogle/protobuf/struct.protogoogle/protobuf/timestamp.proto"�
RequestType
id (Rid
name (	Rname 
description (	Rdescription,
due_date_tolerance (RdueDateTolerance?
default_status (2.issue_management.StatusRdefaultStatus

is_default (R	isDefault"�
ListRequestTypesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListRequestTypesResponse!
record_count (RrecordCount7
records (2.issue_management.RequestTypeRrecords&
next_page_token (	RnextPageToken"d
User
id (Rid
name (	Rname 
description (	Rdescription
avatar (	Ravatar"�
ListSalesRepresentativesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
 ListSalesRepresentativesResponse!
record_count (RrecordCount0
records (2.issue_management.UserRrecords&
next_page_token (	RnextPageToken"f
Priority
id (Rid
value (	Rvalue
name (	Rname 
description (	Rdescription"�
ListPrioritiesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListPrioritiesResponse!
record_count (RrecordCount4
records (2.issue_management.PriorityRrecords&
next_page_token (	RnextPageToken"u
StatusCategory
id (Rid
name (	Rname 
description (	Rdescription

is_default (R	isDefault"�
ListStatusCategoriesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListStatusCategoriesResponse!
record_count (RrecordCount:
records (2 .issue_management.StatusCategoryRrecords&
next_page_token (	RnextPageToken"�
Status
id (Rid
value (	Rvalue
name (	Rname 
description (	Rdescription
sequence (Rsequence

is_default (R	isDefault"�
ListStatusesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue&
request_type_id (RrequestTypeId"�
ListStatusesResponse!
record_count (RrecordCount2
records (2.issue_management.StatusRrecords&
next_page_token (	RnextPageToken"P
Category
id (Rid
name (	Rname 
description (	Rdescription"�
ListCategoriesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue&
request_type_id (RrequestTypeId"�
ListCategoriesResponse!
record_count (RrecordCount4
records (2.issue_management.CategoryRrecords&
next_page_token (	RnextPageToken"M
Group
id (Rid
name (	Rname 
description (	Rdescription"�
ListGroupsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue&
request_type_id (RrequestTypeId"�
ListGroupsResponse!
record_count (RrecordCount1
records (2.issue_management.GroupRrecords&
next_page_token (	RnextPageToken"m
BusinessPartner
id (Rid
value (	Rvalue
name (	Rname 
description (	Rdescription"�
ListBusinessPartnersRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue&
request_type_id (RrequestTypeId"�
ListBusinessPartnersResponse!
record_count (RrecordCount;
records (2!.issue_management.BusinessPartnerRrecords&
next_page_token (	RnextPageToken"h

TaskStatus
id (Rid
value (	Rvalue
name (	Rname 
description (	Rdescription"�
ListTaskStatusesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue&
request_type_id (RrequestTypeId"�
ListTaskStatusesResponse!
record_count (RrecordCount6
records (2.issue_management.TaskStatusRrecords&
next_page_token (	RnextPageToken"e
Project
id (Rid
value (	Rvalue
name (	Rname 
description (	Rdescription"�
ListProjectsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue&
request_type_id (RrequestTypeId"�
ListProjectsResponse!
record_count (RrecordCount3
records (2.issue_management.ProjectRrecords&
next_page_token (	RnextPageToken"e
DueType
id (Rid
value (	Rvalue
name (	Rname 
description (	Rdescription"�
Issue
id (Rid
document_no (	R
documentNo
subject (	Rsubject
summary (	Rsummary4
created (2.google.protobuf.TimestampRcreated=
last_updated (2.google.protobuf.TimestampRlastUpdated@
request_type (2.issue_management.RequestTypeRrequestType*
user (2.issue_management.UserRuserI
sales_representative	 (2.issue_management.UserRsalesRepresentative0
status
 (2.issue_management.StatusRstatus6
priority (2.issue_management.PriorityRpriorityD
date_next_action (2.google.protobuf.TimestampRdateNextAction4
due_type (2.issue_management.DueTypeRdueType6
category (2.issue_management.CategoryRcategory-
group (2.issue_management.GroupRgroupL
business_partner (2!.issue_management.BusinessPartnerRbusinessPartner3
project (2.issue_management.ProjectRproject:
parent_issue (2.issue_management.IssueRparentIssue=
task_status (2.issue_management.TaskStatusR
taskStatus"Q
ExistsIssuesRequest

table_name (	R	tableName
	record_id (RrecordId"9
ExistsIssuesResponse!
record_count (RrecordCount"�
ListIssuesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue

table_name (	R	tableName
	record_id	 (RrecordId,
status_category_id
 (RstatusCategoryId"�
ListIssuesReponse!
record_count (RrecordCount1
records (2.issue_management.IssueRrecords&
next_page_token (	RnextPageToken"�
CreateIssueRequest

table_name (	R	tableName
	record_id (RrecordId
subject (	Rsubject
summary (	Rsummary&
request_type_id (RrequestTypeId6
sales_representative_id (RsalesRepresentativeId
	status_id (RstatusId%
priority_value (	RpriorityValue(
date_next_action	 (	RdateNextAction
category_id
 (R
categoryId
group_id (RgroupId.
business_partner_id (RbusinessPartnerId

project_id (R	projectId&
parent_issue_id (RparentIssueId*
task_status_value (	RtaskStatusValue"�
UpdateIssueRequest
id (Rid
subject (	Rsubject
summary (	Rsummary&
request_type_id (RrequestTypeId6
sales_representative_id (RsalesRepresentativeId
	status_id (RstatusId%
priority_value (	RpriorityValueD
date_next_action (2.google.protobuf.TimestampRdateNextAction
category_id	 (R
categoryId
group_id
 (RgroupId.
business_partner_id (RbusinessPartnerId

project_id (R	projectId&
parent_issue_id (RparentIssueId*
task_status_value (	RtaskStatusValue"$
DeleteIssueRequest
id (Rid"�
IssueCommentLog
column_name (	R
columnName
label (	Rlabel3
	new_value (2.google.protobuf.ValueRnewValue'
displayed_value (	RdisplayedValue"�
IssueComment
id (Rid
result (	Rresult4
created (2.google.protobuf.TimestampRcreated*
user (2.issue_management.UserRuserP
issue_comment_type (2".issue_management.IssueCommentTypeRissueCommentTypeB
change_logs (2!.issue_management.IssueCommentLogR
changeLogs"�
ListIssueCommentsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
issue_id (RissueId"�
ListIssueCommentsReponse!
record_count (RrecordCount8
records (2.issue_management.IssueCommentRrecords&
next_page_token (	RnextPageToken"N
CreateIssueCommentRequest
issue_id (RissueId
result (	Rresult"^
UpdateIssueCommentRequest
id (Rid
result (	Rresult
issue_id (RissueId"F
DeleteIssueCommentRequest
id (Rid
issue_id (RissueId*(
IssueCommentType
COMMENT 
LOG2�
IssueManagement�
ListRequestTypes).issue_management.ListRequestTypesRequest*.issue_management.ListRequestTypesResponse"'���!/issue-management/request-types�
ListSalesRepresentatives1.issue_management.ListSalesRepresentativesRequest2.issue_management.ListSalesRepresentativesResponse"/���)'/issue-management/sales-representatives�
ListPriorities'.issue_management.ListPrioritiesRequest(.issue_management.ListPrioritiesResponse"$���/issue-management/priorities�
ListStatusCategories-.issue_management.ListStatusCategoriesRequest..issue_management.ListStatusCategoriesResponse"+���%#/issue-management/status-categories�
ListStatuses%.issue_management.ListStatusesRequest&.issue_management.ListStatusesResponse"g���a/issue-management/statusesZCA/issue-management/status-categories/{status_category_id}/statuses�
ListCategories'.issue_management.ListCategoriesRequest(.issue_management.ListCategoriesResponse"$���/issue-management/categoriesy

ListGroups#.issue_management.ListGroupsRequest$.issue_management.ListGroupsResponse" ���/issue-management/groups�
ListTaskStatuses).issue_management.ListTaskStatusesRequest*.issue_management.ListTaskStatusesResponse"'���!/issue-management/task-statuses�
ListBusinessPartners-.issue_management.ListBusinessPartnersRequest..issue_management.ListBusinessPartnersResponse"+���%#/issue-management/business-partners�
ListProjects%.issue_management.ListProjectsRequest&.issue_management.ListProjectsResponse""���/issue-management/projects�
ExistsIssues%.issue_management.ExistsIssuesRequest&.issue_management.ExistsIssuesResponse"@���:8/issue-management/issues/{table_name}/{record_id}/exists|

ListIssues#.issue_management.ListIssuesRequest#.issue_management.ListIssuesReponse"$���/issue-management/issues/all�
ListMyIssues#.issue_management.ListIssuesRequest#.issue_management.ListIssuesReponse"U���O/issue-management/issuesZ31/issue-management/issues/{table_name}/{record_id}q
CreateIssue$.issue_management.CreateIssueRequest.issue_management.Issue"#���"/issue-management/issues:*v
UpdateIssue$.issue_management.UpdateIssueRequest.issue_management.Issue"(���"/issue-management/issues/{id}:*r
DeleteIssue$.issue_management.DeleteIssueRequest.google.protobuf.Empty"%���*/issue-management/issues/{id}�
ListIssueComments*.issue_management.ListIssueCommentsRequest*.issue_management.ListIssueCommentsReponse"4���.,/issue-management/issues/{issue_id}/comments�
CreateIssueComment+.issue_management.CreateIssueCommentRequest.issue_management.IssueComment"7���1",/issue-management/issues/{issue_id}/comments:*�
UpdateIssueComment+.issue_management.UpdateIssueCommentRequest.issue_management.IssueComment"<���61/issue-management/issues/{issue_id}/comments/{id}:*�
DeleteIssueComment+.issue_management.DeleteIssueCommentRequest.google.protobuf.Empty"9���3*1/issue-management/issues/{issue_id}/comments/{id}BD
&org.spin.backend.grpc.issue_managementBADempiereIssueManagementPJ��
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 ?
	
 ?

 9
	
 9
	
  &
	
 %
	
 &
	
 )
(
 2 Base URL
 /issue-management/

7
   �* The Issue Management service definition.



  

  "$	 Request Type


  "

  "4

  "?W

  #V

	  �ʼ"#V
$
 &(	 Sales Representative


 &$

 &%D

 &Oo

 '^

	 �ʼ"'^

 *,	
 Priority


 *

 *0

 *;Q

 +S

	 �ʼ"+S

 .0	 Status Category


 . 

 .!<

 .Gc

 /Z

	 �ʼ"/Z

 29	 Status


 2

 2,

 27K

 38

	 �ʼ"38

 ;=	
 Category


 ;

 ;0

 ;;Q

 <S

	 �ʼ"<S

 ?A	 Group


 ?

 ?(

 ?3E

 @O

	 �ʼ"@O

 CE	 Task Status


 C

 C4

 C?W

 DV

	 �ʼ"DV
 
 GI	 Business Partner


 G 

 G!<

 GGc

 HZ

	 �ʼ"HZ

 	KM		 Project


 	K

 	K,

 	K7K

 	LQ

	 	�ʼ"LQ

 
OQ	 Issue


 
O

 
O,

 
O7K

 
Po

	 
�ʼ"Po

 RV	

 R

 R(

 R3D

 SU

	 �ʼ"SU

 W^	

 W

 W*

 W5F

 X]

	 �ʼ"X]

 _d	

 _

 _*

 _5:

 `c

	 �ʼ"`c

 ej	

 e

 e*

 e5:

 fi

	 �ʼ"fi

 km	

 k

 k*

 k5J

 lW

	 �ʼ"lW

 oq	 Issue Comments


 o

 o6

 oAY

 pc

	 �ʼ"pc

 rw	

 r

 r8

 rCO

 sv

	 �ʼ"sv

 x}	

 x

 x8

 xCO

 y|

	 �ʼ"y|

 ~�	

 ~

 ~8

 ~CX

 k

	 �ʼ"k
'
 � � Request Type Definition


 �

  �

  �

  �

  �

 �

 �

 �

 �

 �

 �

 �

 �

 �%

 �

 � 

 �#$

 �"

 �

 �

 � !

 �

 �

 �

 �

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

� �

� 

 �

 �

 �

 �

�)

�

�

�$

�'(

�#

�

�

�!"
9
� �+ User (or Sales Representative) Definition


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

� �

�'

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

� �

�(

 �

 �

 �

 �

�"

�

�

�

� !

�#

�

�

�!"

� �
 Priority


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

� �

�

 �

 �

 �

 �

�&

�

�

�!

�$%

�#

�

�

�!"

	� � Status Category


	�

	 �

	 �

	 �

	 �

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�


� �


�#


 �


 �


 �


 �


�


�


�


�


�*


�


�


�%


�()


�+


�


�


�&


�)*


�


�


�


�


�


�


�


�


� 


�


�


�

� �

�$

 �

 �

 �

 �

�,

�

�

� '

�*+

�#

�

�

�!"

� � Status


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�"

�

�

� !

� �

�

 �

 �

 �

 �

�$

�

�

�

�"#

�#

�

�

�!"

� �
 Category


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�"

�

�

� !

� �

�

 �

 �

 �

 �

�&

�

�

�!

�$%

�#

�

�

�!"

� � Group


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�"

�

�

� !

� �

�

 �

 �

 �

 �

�#

�

�

�

�!"

�#

�

�

�!"
 
� � Business Partner


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

� �

�#

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�"

�

�

� !

� �

�$

 �

 �

 �

 �

�-

�

� 

�!(

�+,

�#

�

�

�!"

� � Task Status


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�"

�

�

� !

� �

� 

 �

 �

 �

 �

�(

�

�

�#

�&'

�#

�

�

�!"

� �	 Project


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�"

�

�

� !

� �

�

 �

 �

 �

 �

�%

�

�

� 

�#$

�#

�

�

�!"
 
� � Issue Definition


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�.

�!

�")

�,-

�3

�!

�".

�12

�%

�

� 

�#$

�

�

�

�

�&

�

�!

�$%

	�

	�

	�

	�


�


�


�


�

�8

�!

�"2

�57

�

�

�

�

�

�

�

�

�

�

�

�

�.

�

�(

�+-

�

�

�

�

� 

�

�

�

�$

�

�

�!#

 � �

 �

  �

  �

  �

  �

 �

 �

 �

 �

!� �

!�

! �

! �

! �

! �

"� �

"�

" �

" �

" �

" �

"�

"�

"�

"�

"�*

"�

"�

"�%

"�()

"�+

"�

"�

"�&

"�)*

"�

"�

"�

"�

"�

"�

"�

"�

"� 

"�

"�

"�

"�

"�

"�

"�

"�

"�

"�

"�

"	�& custom filters


"	�

"	� 

"	�#%

#� �

#�

# �

# �

# �

# �

#�#

#�

#�

#�

#�!"

#�#

#�

#�

#�!"

$� �

$�

$ �

$ �

$ �

$ �

$�

$�

$�

$�

$�

$�

$�

$�

$�

$�

$�

$�

$�"

$�

$�

$� !

$�*

$�

$�%

$�()

$�

$�

$�

$�

$�"

$�

$�

$� !

$�$

$�

$�

$�"#

$	�

$	�

$	�

$	�

$
�

$
�

$
�

$
�

$�'

$�

$�!

$�$&

$�

$�

$�

$�

$�#

$�

$�

$� "

$�&

$�

$� 

$�#%

%� �

%�

% �

% �

% �

% �

%�

%�

%�

%�

%�

%�

%�

%�

%�"

%�

%�

%� !

%�*

%�

%�%

%�()

%�

%�

%�

%�

%�"

%�

%�

%� !

%�7

%�!

%�"2

%�56

%�

%�

%�

%�

%	�

%	�

%	�

%	�

%
�'

%
�

%
�!

%
�$&

%�

%�

%�

%�

%�#

%�

%�

%� "

%�&

%�

%� 

%�#%

&� �

&�

& �

& �

& �

& �

 � �

 �

  �

  �

  �

 �

 �

 �
(
'� � Issue Comment Definition


'�

' �

' �

' �

' �

'�

'�

'�

'�

'�,

'�

'�'

'�*+

'�#

'�

'�

'�!"

(� �

(�

( �

( �

( �

( �

(�

(�

(�

(�

(�.

(�!

(�")

(�,-

(�

(�

(�

(�

(�0

(�

(�+

(�./

(�1 log fields


(�

(� 

(�!,

(�/0

)� �

)� 

) �

) �

) �

) �

)�

)�

)�

)�

)�*

)�

)�

)�%

)�()

)�+

)�

)�

)�&

)�)*

)�

)�

)�

)�

)�

)�

)�

)�

)� 

)�

)�

)�

)�

)�

)�

)�

*� �

*� 

* �

* �

* �

* �

*�*

*�

*�

*�%

*�()

*�#

*�

*�

*�!"

+� �

+�!

+ �

+ �

+ �

+ �

+�

+�

+�

+�

,� �

,�!

, �

, �

, �

, �

,�

,�

,�

,�

,�

,�

,�

,�

-� �

-�!

- �

- �

- �

- �

-�

-�

-�

-�bproto3
�g
location_address.protolocation_addressgoogle/api/annotations.proto".
ListItem
id (Rid
name (	Rname"�
Country
id (Rid
uuid (	Ruuid!
country_code (	RcountryCode
name (	Rname"
is_has_region (RisHasRegion
region_name (	R
regionName)
display_sequence (	RdisplaySequence7
is_address_lines_reverse (RisAddressLinesReverse)
capture_sequence	 (	RcaptureSequence4
display_sequence_local
 (	RdisplaySequenceLocalB
is_address_lines_local_reverse (RisAddressLinesLocalReverse4
expression_postal_code (	RexpressionPostalCode@
is_has_postal_code_additional (RisHasPostalCodeAdditionalI
!expression_postal_code_additional (	RexpressionPostalCodeAdditional;
is_allow_cities_out_of_list (RisAllowCitiesOutOfList"F
GetCountryRequest
id (Rid!
country_code (	RcountryCode"�
ListCountriesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListCountriesResponse!
record_count (RrecordCount8
	countries (2.location_address.ListItemR	countries&
next_page_token (	RnextPageToken"�
ListRegionsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue

country_id (R	countryId"�
ListRegionsResponse!
record_count (RrecordCount4
regions (2.location_address.ListItemRregions&
next_page_token (	RnextPageToken"�
ListCitiesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue

country_id (R	countryId
	region_id	 (RregionId"�
ListCitiesResponse!
record_count (RrecordCount2
cities (2.location_address.ListItemRcities&
next_page_token (	RnextPageToken"�
Address
id (Rid
uuid (	Ruuid#
display_value (	RdisplayValue

country_id (R	countryId!
country_name (	RcountryName
	region_id (RregionId
region_name (	R
regionName
city_id (RcityId
	city_name	 (	RcityName
city
 (	Rcity
address1 (	Raddress1
address2 (	Raddress2
address3 (	Raddress3
address4 (	Raddress4
postal_code (	R
postalCode4
postal_code_additional (	RpostalCodeAdditional
latitude (	Rlatitude
	longitude (	R	longitude
altitude (	Raltitude
	reference (	R	reference"#
GetAddressRequest
id (Rid"�
CreateAddressRequest

country_id (R	countryId
	region_id (RregionId
city_id (RcityId
city (	Rcity
address1 (	Raddress1
address2 (	Raddress2
address3 (	Raddress3
address4 (	Raddress4
postal_code	 (	R
postalCode2
posal_code_additional
 (	RposalCodeAdditional
latitude (	Rlatitude
	longitude (	R	longitude
altitude (	Raltitude
	reference (	R	reference"�
UpdateAddressRequest
id (Rid

country_id (R	countryId
	region_id (RregionId
city_id (RcityId
city (	Rcity
address1 (	Raddress1
address2 (	Raddress2
address3 (	Raddress3
address4	 (	Raddress4
postal_code
 (	R
postalCode2
posal_code_additional (	RposalCodeAdditional
latitude (	Rlatitude
	longitude (	R	longitude
altitude (	Raltitude
	reference (	R	reference2�
LocationAddress�
ListCountries&.location_address.ListCountriesRequest'.location_address.ListCountriesResponse"#���/location-address/countries�

GetCountry#.location_address.GetCountryRequest.location_address.Country"[���U /location-address/countries/{id}Z1//location-address/countries/code/{country_code}�
ListRegions$.location_address.ListRegionsRequest%.location_address.ListRegionsResponse"8���20/location-address/countries/{country_id}/regions�

ListCities#.location_address.ListCitiesRequest$.location_address.ListCitiesResponse"v���p//location-address/countries/{country_id}/citiesZ=;/location-address/countries/{country_id}/{region_id}/citiesv

GetAddress#.location_address.GetAddressRequest.location_address.Address"(���" /location-address/addresses/{id}z
CreateAddress&.location_address.CreateAddressRequest.location_address.Address"&��� "/location-address/addresses:*
UpdateAddress&.location_address.UpdateAddressRequest.location_address.Address"+���%2 /location-address/addresses/{id}:*BJ
,org.spin.backend.grpc.field.location_addressBADempiereLocationAddressPJ�A
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 E
	
 E

 9
	
 9
	
  &

 


  B


 

  		 Country


  

  .

  9N

  R

	  �ʼ"R

 $	

 

 (

 3:

 #

	 �ʼ"#

 &(	 Region


 &

 &*

 &5H

 'g

	 �ʼ"'g

 *1	 Cities


 *

 *(

 *3E

 +0

	 �ʼ"+0

 35	
 Location


 3

 3(

 33:

 4W

	 �ʼ"4W

 6;	

 6

 6.

 69@

 7:

	 �ʼ"7:

 <A	

 <

 <.

 <9@

 =@

	 �ʼ"=@


 E H


 E

  F

  F

  F

  F

 G

 G

 G

 G

L \	 Country



L

 M

 M

 M

 M

N

N

N

N

O 

O

O

O

P

P

P

P

Q

Q

Q

Q

R

R

R

R

S$

S

S

S"#

T*

T

T%

T()

U$

U

U

U"#

	V+

	V

	V%

	V(*


W1


W


W+


W.0

X+

X

X%

X(*

Y0

Y

Y*

Y-/

Z6

Z

Z0

Z35

[.

[

[(

[+-


^ a


^

 _

 _

 _

 _

` 

`

`

`


c k


c

 d

 d

 d

 d

e

e

e

e

f*

f

f

f%

f()

g+

g

g

g&

g)*

h

h

h

h

i

i

i

i

j 

j

j

j


m q


m

 n

 n

 n

 n

o(

o

o

o#

o&'

p#

p

p

p!"

u ~ Region



u

 v

 v

 v

 v

w

w

w

w

x*

x

x

x%

x()

y+

y

y

y&

y)*

z

z

z

z

{

{

{

{

| 

|

|

|

}

}

}

}

� �

�

 �

 �

 �

 �

�&

�

�

�!

�$%

�#

�

�

�!"

� � Cities


�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�%

�

�

� 

�#$

�#

�

�

�!"
 
	� � Address Location


	�

	 �

	 �

	 �

	 �

	�

	�

	�

	�

	�!

	�

	�

	� 

	�

	�

	�

	�

	� 

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

		�

		�

		�

		�

	
�

	
�

	
�

	
�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	� 

	�

	�

	�

	�+

	�

	�%

	�(*

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�


� �


�


 �


 �


 �


 �

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

	�*

	�

	�$

	�')


�


�


�


�

�

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

	� 

	�

	�

	�


�*


�


�$


�')

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�bproto3
�5
notice_management.protonotice_managementgoogle/api/annotations.protogoogle/protobuf/timestamp.protobase_data_type.proto"�
User
id (Rid
uuid (	Ruuid
value (	Rvalue
name (	Rname 
description (	Rdescription
avatar (	Ravatar"�
ListUsersRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListUsersResponse!
record_count (RrecordCount1
records (2.notice_management.UserRrecords&
next_page_token (	RnextPageToken"�
Notice
id (Rid
uuid (	Ruuid4
created (2.google.protobuf.TimestampRcreated
message (	Rmessage+
user (2.notice_management.UserRuser

table_name (	R	tableName
	record_id (RrecordId
	reference (	R	reference!
text_message	 (	RtextMessage 
description
 (	Rdescription%
is_acknowledge (RisAcknowledge"�
ListNoticesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListNoticesResponse!
record_count (RrecordCount3
records (2.notice_management.NoticeRrecords&
next_page_token (	RnextPageToken"S
DeleteNoticesRequest
user_id (RuserId"
keep_log_days (RkeepLogDays"[
DeleteNoticesResponse
summary (	Rsummary(
logs
 (2.data.ProcessInfoLogRlogs"*
AcknowledgeNoticeRequest
id (Rid"5
AcknowledgeNoticeResponse
message (	Rmessage2�
NoticeManagement�
ListNotices%.notice_management.ListNoticesRequest&.notice_management.ListNoticesResponse""���/notice-management/notices�
AcknowledgeNotice+.notice_management.AcknowledgeNoticeRequest,.notice_management.AcknowledgeNoticeResponse"3���-2+/notice-management/notices/{id}/acknowledge�
	ListUsers#.notice_management.ListUsersRequest$.notice_management.ListUsersResponse"(���" /notice-management/notices/users�
DeleteNotices'.notice_management.DeleteNoticesRequest(.notice_management.DeleteNoticesResponse""���*/notice-management/noticesBF
'org.spin.backend.grpc.notice_managementBADempiereNoticeManagementPJ�#
 ~
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 @
	
 @

 :
	
 :
	
  &
	
 )
	
 
)
 2 Base URL
 /notice-management/

7
   4+ The Notice Management service definition.



  

  !%	

  !

  !*

  !5H

  "$

	  �ʼ""$

 &*	

 &

 &6

 &AZ

 ')

	 �ʼ"')

 ,.	

 ,

 ,&

 ,1B

 -W

	 �ʼ"-W

 /3	

 /

 /.

 /9N

 02

	 �ʼ"02

 7 > User Definition



 7

  8

  8

  8

  8

 9

 9

 9

 9

 :

 :

 :

 :

 ;

 ;

 ;

 ;

 <

 <

 <

 <

 =

 =

 =

 =


? G


?

 @

 @

 @

 @

A

A

A

A

B*

B

B

B%

B()

C+

C

C

C&

C)*

D

D

D

D

E

E

E

E

F 

F

F

F


H L


H

 I

 I

 I

 I

J"

J

J

J

J !

K#

K

K

K!"

P \ notice



P

 Q

 Q

 Q

 Q

R

R

R

R

S.

S!

S")

S,-

T

T

T

T

U

U

U

U

V

V

V

V

W

W

W

W

X

X

X

X

Y 

Y

Y

Y

	Z 

	Z

	Z

	Z


[!


[


[


[ 


^ f


^

 _

 _

 _

 _

`

`

`

`

a*

a

a

a%

a()

b+

b

b

b&

b)*

c

c

c

c

d

d

d

d

e 

e

e

e


g k


g

 h

 h

 h

 h

i$

i

i

i

i"#

j#

j

j

j!"


n q


n

 o

 o

 o

 o

p 

p

p

p


r u


r

 s

 s

 s

 s

t/

t

t$

t%)

t,.
 
y { Acknowledge Notice



y 

 z

 z

 z

 z


	| ~


	|!

	 }

	 }

	 }

	 }bproto3
��
user_interface.protouser_interfacebase_data_type.protogoogle/api/annotations.protogoogle/protobuf/empty.protogoogle/protobuf/timestamp.protogoogle/protobuf/struct.proto"Z
Translation
language (	Rlanguage/
values (2.google.protobuf.StructRvalues"G
GetRecordAccessRequest

table_name (	R	tableName
id (Rid"�
SetRecordAccessRequest

table_name (	R	tableName
id (RidI
record_accesses (2 .user_interface.RecordAccessRoleRrecordAccesses"�
RecordAccess

table_name (	R	tableName
id (RidI
available_roles (2 .user_interface.RecordAccessRoleRavailableRolesE
current_roles (2 .user_interface.RecordAccessRoleRcurrentRoles"�
RecordAccessRole
role_id (RroleId
	role_name (	RroleName
	is_active (RisActive

is_exclude (R	isExclude 
is_read_only (R
isReadOnly2
is_dependent_entities (RisDependentEntities"H
GetPrivateAccessRequest

table_name (	R	tableName
id (Rid"I
LockPrivateAccessRequest

table_name (	R	tableName
id (Rid"K
UnlockPrivateAccessRequest

table_name (	R	tableName
id (Rid"[
PrivateAccess

table_name (	R	tableName
id (Rid
	is_locked (RisLocked"]
RollbackEntityRequest

table_name (	R	tableName
id (Rid
log_id (RlogId"�
ListBrowserItemsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes
id	 (Rid"�
ListBrowserItemsResponse!
record_count (RrecordCount&
records (2.data.EntityRrecords&
next_page_token (	RnextPageToken"�
BrowserHeaderField
column_name (	R
columnName
name (	Rname!
display_type (RdisplayType
sequence (Rsequence"�
ExportBrowserItemsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes
id	 (Rid"�
ExportBrowserItemsResponse!
record_count (RrecordCount&
records (2.data.EntityRrecordsG
header_fields (2".user_interface.BrowserHeaderFieldRheaderFields"�
UpdateBrowserEntityRequest
id (Rid
	record_id (RrecordId7

attributes (2.google.protobuf.StructR
attributes"V
ContextInfoValue!
message_text (	RmessageText
message_tip (	R
messageTip"B
GetContextInfoValueRequest
id (Rid
query (	Rquery"�
GetTabEntityRequest
id (Rid
	window_id (RwindowId
tab_id (RtabId-
context_attributes (	RcontextAttributes"�
CreateTabEntityRequest
	window_id (RwindowId
tab_id (RtabId7

attributes (2.google.protobuf.StructR
attributes"�
UpdateTabEntityRequest
id (Rid
	window_id (RwindowId
tab_id (RtabId7

attributes (2.google.protobuf.StructR
attributes"�
ListTabEntitiesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
	window_id (RwindowId
tab_id	 (RtabId-
context_attributes
 (	RcontextAttributes2
record_reference_uuid (	RrecordReferenceUuid"�
RunCalloutRequest

table_name (	R	tableName
	window_id (RwindowId
tab_id (RtabId
callout (	Rcallout
column_name (	R
columnName3
	old_value (2.google.protobuf.ValueRoldValue,
value (2.google.protobuf.ValueRvalue
	window_no (RwindowNoF
context_attributes	 (2.google.protobuf.StructRcontextAttributes"R
Callout
result (	Rresult/
values (2.google.protobuf.StructRvalues"�
ListTranslationsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
id (Rid

table_name	 (	R	tableName
language
 (	Rlanguage"�
ListTranslationsResponse!
record_count (RrecordCount?
translations (2.user_interface.TranslationRtranslations&
next_page_token (	RnextPageToken"a
CreateChatEntryRequest

table_name (	R	tableName
id (Rid
comment (	Rcomment"�
	ChatEntry
chat_id (RchatId
id (Rid
subject (	Rsubject%
character_data (	RcharacterData
user_id (RuserId
	user_name (	RuserNameE
chat_entry_type (2.user_interface.ChatEntryTypeRchatEntryTypeM
confidential_type (2 .user_interface.ConfidentialTypeRconfidentialTypeJ
moderator_status	 (2.user_interface.ModeratorStatusRmoderatorStatus5
log_date
 (2.google.protobuf.TimestampRlogDate"�
ListTabSequencesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes	 (	RcontextAttributes
	window_id
 (RwindowId
tab_id (RtabId,
filter_column_name (	RfilterColumnName(
filter_record_id (RfilterRecordId"�
SaveTabSequencesRequest
tab_id (RtabIdF
context_attributes (2.google.protobuf.StructRcontextAttributes3
entities (2.data.KeyValueSelectionRentities"�
ListTreeNodesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
tab_id (RtabId

table_name	 (	R	tableName
id
 (Rid

element_id (R	elementId-
context_attributes (	RcontextAttributes"�
TreeNode
id (Rid
	parent_id (RparentId
	record_id (RrecordId
name (	Rname 
description (	Rdescription
sequence (	Rsequence

is_summary (R	isSummary
	is_active (RisActive0
childs	 (2.user_interface.TreeNodeRchilds"f
TreeType
id (Rid
value (	Rvalue
name (	Rname 
description (	Rdescription"�
ListTreeNodesResponse!
record_count (RrecordCount2
records (2.user_interface.TreeNodeRrecords&
next_page_token (	RnextPageToken5
	tree_type (2.user_interface.TreeTypeRtreeType"i
MailTemplate
id (Rid
name (	Rname
subject (	Rsubject
	mail_text (	RmailText"�
ListMailTemplatesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListMailTemplatesResponse!
record_count (RrecordCount6
records (2.user_interface.MailTemplateRrecords&
next_page_token (	RnextPageToken*8
ConfidentialType

PUBLIC 

PARTER
INTERNAL*V
ModeratorStatus
NOT_DISPLAYED 
	PUBLISHED
	SUSPICIUS
TO_BE_REVIEWED*<
ChatEntryType
	NOTE_FLAT 
FORUM_THREADED
WIKI2�
UserInterfaceq
GetTabEntity#.user_interface.GetTabEntityRequest.data.Entity".���(&/user-interface/entities/{tab_id}/{id}u
CreateTabEntity&.user_interface.CreateTabEntityRequest.data.Entity",���&"!/user-interface/entities/{tab_id}:*z
UpdateTabEntity&.user_interface.UpdateTabEntityRequest.data.Entity"1���+2&/user-interface/entities/{tab_id}/{id}:*�
ListTabEntities&.user_interface.ListTabEntitiesRequest.data.ListEntitiesResponse")���#!/user-interface/entities/{tab_id}�
RollbackEntity%.user_interface.RollbackEntityRequest.data.Entity">���823/user-interface/entities/{table_name}/{id}/rollback:*�

RunCallout!.user_interface.RunCalloutRequest.user_interface.Callout"G���A"</user-interface/run-callout/{tab_id}/{column_name}/{callout}:*�
ListTranslations'.user_interface.ListTranslationsRequest(.user_interface.ListTranslationsResponse"A���;9/user-interface/translations/{table_name}/{id}/{language}�
ListBrowserItems'.user_interface.ListBrowserItemsRequest(.user_interface.ListBrowserItemsResponse"*���$"/user-interface/browser-items/{id}�
ExportBrowserItems).user_interface.ExportBrowserItemsRequest*.user_interface.ExportBrowserItemsResponse"1���+)/user-interface/browser-items/{id}/export�
UpdateBrowserEntity*.user_interface.UpdateBrowserEntityRequest.data.Entity"9���32./user-interface/browser-items/{id}/{record_id}:*�
GetContextInfoValue*.user_interface.GetContextInfoValueRequest .user_interface.ContextInfoValue")���#!/user-interface/context-info/{id}�
GetPrivateAccess'.user_interface.GetPrivateAccessRequest.user_interface.PrivateAccess"8���20/user-interface/private-access/{table_name}/{id}�
LockPrivateAccess(.user_interface.LockPrivateAccessRequest.user_interface.PrivateAccess"@���:25/user-interface/private-access/{table_name}/{id}/lock:*�
UnlockPrivateAccess*.user_interface.UnlockPrivateAccessRequest.user_interface.PrivateAccess"B���<27/user-interface/private-access/{table_name}/{id}/unlock:*�
GetRecordAccess&.user_interface.GetRecordAccessRequest.user_interface.RecordAccess"7���1//user-interface/record-access/{table_name}/{id}�
SetRecordAccess&.user_interface.SetRecordAccessRequest.user_interface.RecordAccess":���42//user-interface/record-access/{table_name}/{id}:*�
CreateChatEntry&.user_interface.CreateChatEntryRequest.user_interface.ChatEntry"2���,"'/user-interface/chat-entry/{table_name}:*�
ListTabSequences'.user_interface.ListTabSequencesRequest.data.ListEntitiesResponse".���(&/user-interface/tab-sequences/{tab_id}�
SaveTabSequences'.user_interface.SaveTabSequencesRequest.data.ListEntitiesResponse"1���+"&/user-interface/tab-sequences/{tab_id}:*�
ListTreeNodes$.user_interface.ListTreeNodesRequest%.user_interface.ListTreeNodesResponse"Z���T'/user-interface/tree-nodes/{table_name}Z)'/user-interface/tree-nodes/tab/{tab_id}�
ListMailTemplates(.user_interface.ListMailTemplatesRequest).user_interface.ListMailTemplatesResponse"&��� /user-interface/mail-templatesB@
$org.spin.backend.grpc.user_interfaceBADempiereUserInterfacePJ��
�
�	
�	***********************************************************************************
 Copyright (C) 2012-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Yamel Senih ysenih@erpya.com                                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

#
	

#

>
	
>

8
	
8
	
 
	
'
	
&
	
*
	
'
&
2 Base URL
 /user-interface/


 ! �	User Interface



 !
 
  #%	 Get a Tab Entity


  #

  #,

  #7B

  $]

	  �ʼ"$]
!
 ',	 Create Tab Entity


 '

 '2

 '=H

 (+

	 �ʼ"(+
!
 .3	 Update Tab Entity


 .

 .2

 .=H

 /2

	 �ʼ"/2
!
 57		List tab Entities


 5

 52

 5=V

 6X

	 �ʼ"6X
'
 9>		Rollback Entity Request


 9

 90

 9;F

 :=

	 �ʼ":=

 @E	 Run a Callout


 @

 @(

 @3:

 AD

	 �ʼ"AD
)
 GI		Request Translations List


 G

 G4

 G?W

 Hp

	 �ʼ"Hp

 LN		Browser Data


 L

 L4

 L?W

 MY

	 �ʼ"MY

 OQ	

 O

 O8

 OC]

 P`

	 �ʼ"P`

 	RW	

 	R

 	R :

 	REP

 	SV

	 	�ʼ"SV
 
 
Z\	 Get context Info


 
Z

 
Z :

 
ZEU

 
[X

	 
�ʼ"[X
"
 ^`	 Get Private Access


 ^

 ^4

 ^?L

 _g

	 �ʼ"_g
%
 bg	 Create Private Access


 b

 b6

 bAN

 cf

	 �ʼ"cf
%
 in	 Change Private Access


 i

 i :

 iER

 jm

	 �ʼ"jm
!
 pr	 Get Record Access


 p

 p2

 p=I

 qf

	 �ʼ"qf
!
 ty	 Set Record Access


 t

 t2

 t=I

 ux

	 �ʼ"ux

 {�	 Add Chat Entry


 {

 {2

 {=F

 |

	 �ʼ"|
$
 ��		List Tab Sequences


 �

 �4

 �?X

 �\

	 �ʼ"�\
$
 ��		Save Tab Sequences


 �

 �4

 �?X

 ��

	 �ʼ"��
)
 ��	 List Tree Nodes Request


 �

 �.

 �9N

 ��

	 �ʼ"��
%
 ��	 List Mail Templates


 �

 �6

 �AZ

 �U

	 �ʼ"�U
!
 � � Translations Item


 �

  �

  �

  �

  �

 �*

 �

 �%

 �()
#
� �	Role Access Request


�

 �

 �

 �

 �

�

�

�

�
"
� �	Set Access Request


�

 �

 �

 �

 �

�

�

�

�

�6

�

�!

�"1

�45
(
� �	Record Access Definition


�

 �

 �

 �

 �

�

�

�

�

�6

�

�!

�"1

�45

�4

�

�!

�"/

�23
"
� �	Record Access Stub


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�'

�

�"

�%&

� � Private Access


�

 �

 �

 �

 �

�

�

�

�

� �

� 

 �

 �

 �

 �

�

�

�

�

� �

�"

 �

 �

 �

 �

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

	� �  Empty message


	�

	 �

	 �

	 �

	 �

	�

	�

	�

	�

	�

	�

	�

	�


� � Browser Items



�


 �


 �


 �


 �


�


�


�


�


�*


�


�


�%


�()


�+


�


�


�&


�)*


�


�


�


�


�


�


�


�


� 


�


�


�


�&


�


�!


�$%


� custom filters



�


�


�

� �

� 

 �

 �

 �

 �

�)

�

�

�$

�'(

�#

�

�

�!"

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

� �

�!

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

� custom filters


�

�

�

� �

�"

 �

 �

 �

 �

�)

�

�

�$

�'(

�6

�

�#

�$1

�45

� �

�"

 �

 �

 �

 �

�

�

�

�

�.

�

�)

�,-
"
� � Context Info Value


�

 � 

 �

 �

 �

�

�

�

�

� � Get Lookup Item


�"

 �

 �

 �

 �

� Query


�

�

�
&
� � Get Tab Entity Request


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�&

�

�!

�$%
)
� � Create Tab Entity Request


�

 �

 �

 �

 �

�

�

�

�

�.

�

�)

�,-
)
� � Update Tab Entity Request


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�.

�

�)

�,-
)
� � List Tab Entities Request


�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

�

�

�

�

	�'

	�

	�!

	�$&


�*


�


�$


�')

� � Callout Request


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�,

�

�'

�*+

�(

�

�#

�&'

�

�

�

�

�6

�

�1

�45
6
� �( Callout response with data from server


�

 �

 �

 �

 �

�*

�

�%

�()
$
� � Translations Request


�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

�

�

�

�

	�

	�

	�

	�
!
� �	Translations List


� 

 �

 �

 �

 �

�.

�

�

�)

�,-

�#

�

�

�!"
)
� � Create Chat Entry Request


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

 � � Record Chat


 �

  �

  �

  �

 �

 �

 �

 �

 �

 �

� �

�

 �

 �

 �

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�"

�

�

� !

�

�

�

�

�

�

�

�

�*

�

�%

�()

�/

�

�*

�-.

�-

�

�(

�+,

	�0

	�!

	�"*

	�-/

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%
$
� dictinary attributes


�

�

�

	�

	�

	�

	�
!

�' record attributes



�


�!


�$&

�$

�

�

�!#

� �

�

 �

 �

 �

 �

�6

�

�1

�45

�5

�

�'

�(0

�34
'
� � List Tree Nodes Request


�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

�

�

�

�

	�

	�

	�

	�


�


�


�


�

�'

�

�!

�$&

� � Tree Node


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�%

�

�

� 

�#$

 � �

 �

  �

  �

  �

  �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �
(
!� � List Tree Nodes Response


!�

! �

! �

! �

! �

!�&

!�

!�

!�!

!�$%

!�#

!�

!�

!�!"

!�

!�

!�

!�

"� �

"�

" �

" �

" �

" �

"�

"�

"�

"�

"�

"�

"�

"�

"�

"�

"�

"�

#� �

#� 

# �

# �

# �

# �

#�

#�

#�

#�

#�*

#�

#�

#�%

#�()

#�+

#�

#�

#�&

#�)*

#�

#�

#�

#�

#�

#�

#�

#�

#� 

#�

#�

#�

$� �

$�!

$ �

$ �

$ �

$ �

$�*

$�

$�

$�%

$�()

$�#

$�

$�

$�!"bproto3
��
workflow.protoworkflowgoogle/api/annotations.protogoogle/protobuf/empty.protogoogle/protobuf/timestamp.protobase_data_type.proto"+
WorkflowDefinitionRequest
id (Rid"�
ListWorkflowsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue

table_name (	R	tableName"�
ListWorkflowsResponse!
record_count (RrecordCount:
	workflows (2.workflow.WorkflowDefinitionR	workflows&
next_page_token (	RnextPageToken"�
WorkflowDefinition
id (Rid
uuid (	Ruuid
value (	Rvalue
name (	Rname 
description (	Rdescription
help (	Rhelp

table_name (	R	tableName%
responsible_id (RresponsibleId)
responsible_name	 (	RresponsibleName
priority
 (Rpriority9

valid_from (2.google.protobuf.TimestampR	validFrom

is_default (R	isDefault
is_valid (RisValid>
publish_status (2.workflow.PublishStatusRpublishStatus;
duration_unit (2.workflow.DurationUnitRdurationUnit5

start_node (2.workflow.WorkflowNodeR	startNode=
workflow_nodes (2.workflow.WorkflowNodeRworkflowNodes"�
WorkflowNode
id (Rid
uuid (	Ruuid
value (	Rvalue
name (	Rname 
description (	Rdescription
help (	Rhelp%
responsible_id (RresponsibleId)
responsible_name (	RresponsibleName2
document_action_value	 (	RdocumentActionValue0
document_action_name
 (	RdocumentActionName
priority (Rpriority(
action (2.workflow.ActionRaction>
transitions (2.workflow.WorkflowTransitionRtransitions"�
WorkflowTransition
id (Rid
uuid (	Ruuid 
description (	Rdescription/
is_std_user_workflow (RisStdUserWorkflow
sequence (Rsequence 
node_next_id (R
nodeNextId$
node_next_name (	RnodeNextNameL
workflow_conditions (2.workflow.WorkflowConditionRworkflowConditions"�
WorkflowCondition
id (Rid
uuid (	Ruuid
sequence (Rsequence
column_name (	R
columnName
value (	Rvalue>
condition_type (2.workflow.ConditionTypeRconditionType1
	operation (2.workflow.OperationR	operation"�
ListDocumentActionsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue

table_name (	R	tableName
id	 (Rid"�
ListDocumentActionsResponse!
record_count (RrecordCount?
document_actions (2.data.DocumentActionRdocumentActionsL
default_document_action (2.data.DocumentActionRdefaultDocumentAction&
next_page_token (	RnextPageToken"�
ListDocumentStatusesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue

table_name (	R	tableName
id	 (Rid"�
ListDocumentStatusesResponse!
record_count (RrecordCountA
document_statuses (2.data.DocumentStatusRdocumentStatuses&
next_page_token (	RnextPageToken"�
ListWorkflowActivitiesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
user_id (RuserId"�
ListWorkflowActivitiesResponse!
record_count (RrecordCount:

activities (2.workflow.WorkflowActivityR
activities&
next_page_token (	RnextPageToken"�

ZoomWindow
id (Rid
uuid (	Ruuid
name (	Rname 
description (	Rdescription0
is_sales_transaction (RisSalesTransaction
	is_active (RisActive"�
WorkflowActivity
id (Rid
uuid (	Ruuid

table_name (	R	tableName
	record_id (RrecordId
user_id (RuserId
	user_name (	RuserName%
responsible_id (RresponsibleId)
responsible_name (	RresponsibleName!
text_message	 (	RtextMessage
	processed
 (R	processed
priority (Rpriority4
created (2.google.protobuf.TimestampRcreated9

last_alert (2.google.protobuf.TimestampR	lastAlertD
workflow_process (2.workflow.WorkflowProcessRworkflowProcess8
workflow (2.workflow.WorkflowDefinitionRworkflow*
node (2.workflow.WorkflowNodeRnode7
zoom_windows (2.workflow.ZoomWindowRzoomWindows0
is_sales_transaction (RisSalesTransaction"�
WorkflowProcess
id (Rid
uuid (	Ruuid

process_id (R	processId
workflow_id (R
workflowId#
workflow_name (	RworkflowName

table_name (	R	tableName
user_id (RuserId
	user_name (	RuserName%
responsible_id	 (RresponsibleId)
responsible_name
 (	RresponsibleName!
text_message (	RtextMessage
	processed (R	processed>
workflow_state (2.workflow.WorkflowStateRworkflowState.
priority (2.workflow.PriorityRpriority@
workflow_events (2.workflow.WorkflowEventRworkflowEvents5
log_date (2.google.protobuf.TimestampRlogDate"�
WorkflowEvent
id (Rid
uuid (	Ruuid
node_id (RnodeId
	node_name (	RnodeName

table_name (	R	tableName
user_id (RuserId
	user_name (	RuserName%
responsible_id (RresponsibleId)
responsible_name	 (	RresponsibleName!
text_message
 (	RtextMessage!
time_elapsed (RtimeElapsed%
attribute_name (	RattributeName
	old_value (	RoldValue
	new_value (	RnewValue>
workflow_state (2.workflow.WorkflowStateRworkflowState2

event_type (2.workflow.EventTypeR	eventType5
log_date (2.google.protobuf.TimestampRlogDate"r
RunDocumentActionRequest

table_name (	R	tableName
id (Rid'
document_action (	RdocumentAction"[
ProcessRequest
id (Rid
message (	Rmessage
is_approved (R
isApproved"S
ForwardRequest
id (Rid
message (	Rmessage
user_id (RuserId*N
DurationUnit
DAY 
HOUR

MINUTE	
MONTH

SECOND
YEAR*E
PublishStatus
RELEASED 
TEST
UNDER_REVISION
VOID*�
Action
USER_CHOICE 
DOCUMENT_ACTION
SUB_WORKFLOW	
EMAIL
APPS_PROCESS

SMART_VIEW
APPS_REPORT
SMART_BROWSE
	APPS_TASK
SET_VARIABLE	
USER_WINDOW

	USER_FORM

WAIT_SLEEP* 
ConditionType
AND 
OR*
	Operation	
EQUAL 
	NOT_EQUAL
LIKE
GREATER
GREATER_EQUAL
LESS

LESS_EQUAL
BETWEEN
SQL	*h
WorkflowState
RUNNING 
	COMPLETED
ABORTED

TERMINATED
	SUSPENDED
NOT_STARTED*@
Priority

URGENT 
HIGH

MEDIUM
LOW	
MINOR*J
	EventType
PROCESS_CREATED 
PROCESS_COMPLETED
STATE_CHANGED2�
Workflowr
GetWorkflow#.workflow.WorkflowDefinitionRequest.workflow.WorkflowDefinition" ���/workflow/workflows/{id}m
ListWorkflows.workflow.ListWorkflowsRequest.workflow.ListWorkflowsResponse"���/workflow/workflows�
ListDocumentActions$.workflow.ListDocumentActionsRequest%.workflow.ListDocumentActionsResponse"+���%#/workflow/actions/{table_name}/{id}�
ListDocumentStatuses%.workflow.ListDocumentStatusesRequest&.workflow.ListDocumentStatusesResponse",���&$/workflow/statuses/{table_name}/{id}�
ListWorkflowActivities'.workflow.ListWorkflowActivitiesRequest(.workflow.ListWorkflowActivitiesResponse"+���%#/workflow/workflows/{id}/activitiesh
Process.workflow.ProcessRequest.google.protobuf.Empty"+���%" /workflow/workflows/{id}/process:*h
Forward.workflow.ForwardRequest.google.protobuf.Empty"+���%" /workflow/workflows/{id}/forward:*�
RunDocumentAction".workflow.RunDocumentActionRequest.data.ProcessLog"M���G"B/workflow/workflows/run-action/{table_name}/{id}/{document_action}:*B/
org.spin.backend.grpc.wfBADempiereWorkflowPJ�u
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 1
	
 1

 2
	
 2
	
  &
	
 %
	
 )
	
 
 
 2 Base URL
 /workflow/

)
 ! I	Workflow management service



 !

  #%	 Get Workflow


  #

  #1

  #<N

  $O

	  �ʼ"$O

 ')		List Workflow


 '

 '.

 '9N

 (J

	 �ʼ"(J
%
 +-		List Document Actions


 +

 + :

 +E`

 ,Z

	 �ʼ",Z
&
 /1		List Document Statuses


 / 

 /!<

 /Gc

 0[

	 �ʼ"0[
#
 35		Workflow Activities


 3"

 3#@

 3Ki

 4Z

	 �ʼ"4Z

 6;	

 6

 6"

 6-B

 7:

	 �ʼ"7:

 <A	

 <

 <"

 <-B

 =@

	 �ʼ"=@
%
 CH		Run a Document Action


 C

 C6

 CAP

 DG

	 �ʼ"DG

 L N Object request



 L!

  M

  M

  M

  M
)
Q Z Workflow Definition Request



Q

 R

 R

 R

 R

S

S

S

S

T*

T

T

T%

T()

U+

U

U

U&

U)*

V

V

V

V

W

W

W

W

X 

X

X

X

Y

Y

Y

Y
&
] a	Workflow Definition List



]

 ^

 ^

 ^

 ^

_2

_

_#

_$-

_01

`#

`

`

`!"


 c j


 c

  d

  d

  d

 e

 e

 e

 f

 f

 f

 g

 g

 g

 h

 h

 h

 i

 i

 i


l q


l

 m

 m

 m

n

n

n

o

o

o

p

p

p
"
t � Workflow Definition



t

 u

 u

 u

 u

v

v

v

v

w

w

w

w

x

x

x

x

y

y

y

y

z

z

z

z

{

{

{

{

|!

|

|

| 

}$

}

}

}"#

	~

	~

	~

	~


2


!


",


/1

�

�

�

�

�

�

�

�

�*

�

�$

�')

�(

�

�"

�%'

�%

�

�

�"$

�2

�

�

�,

�/1

� �

�

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

	�

	�

	�


�


�


�

�

�

�

�

�

�

� � Workflow Node


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�!

�

�

� 

�$

�

�

�"#

�)

�

�$

�'(

	�)

	�

	�#

	�&(


�


�


�


�

�

�

�

�

�5

�

�#

�$/

�24
#
� �	Workflow Transition


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�&

�

�!

�$%

�

�

�

�

�

�

�

�

�"

�

�

� !

�;

�

�"

�#6

�9:

� �

�

 �

 �

 �

�

�


�

� �

�

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�
(
� �	Condition for transition


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�)

�

�$

�'(

� 

�

�

�
.
� �  Valid Document Actions Request


�"

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

�

�

�

�
%
� �	Document Actions List


�#

 �

 �

 �

 �

�:

�

�$

�%5

�89

�8

�

�3

�67

�#

�

�

�!"
-
	� � Valid Document Status Request


	�#

	 �

	 �

	 �

	 �

	�

	�

	�

	�

	�*

	�

	�

	�%

	�()

	�+

	�

	�

	�&

	�)*

	�

	�

	�

	�

	�

	�

	�

	�

	� 

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�
%

� �	Document Actions List



�$


 �


 �


 �


 �


�;


�


�$


�%6


�9:


�#


�


�


�!"
+
� � Workflow Activities Request


�%

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�
,
� �	Workflow Activities Response


�&

 �

 �

 �

 �

�1

�

�!

�",

�/0

�#

�

�

�!"

� � Zoom Window


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�&

�

�!

�$%

�

�

�

�
!
� �	Workflow Activity


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�!

�

�

� 

�$

�

�

�"#

� 

�

�

�

	�

	�

	�

	�


�


�


�


�

�/

�!

�")

�,.

�2

�!

�",

�/1

�.

�

�(

�+-

�)

�

�#

�&(

�

�

�

�

�.

�

�

�(

�+-

�'

�

�!

�$&

� �

�

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�
 
� � Workflow Process


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�!

�

�

� 

�

�

�

�

�

�

�

�

�

�

�

�

�!

�

�

� 

	�%

	�

	�

	�"$


�!


�


�


� 

�

�

�

�

�*

�

�$

�')

�

�

�

�

�4

�

�

�.

�13

�0

�!

�"*

�-/

� �

�

 �

 �

 �

�

�

�

�

�

�
$
� � Workflow Event Audit


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�!

�

�

� 

�$

�

�

�"#

	�!

	�

	�

	� 


� 


�


�


�

�#

�

�

� "

�

�

�

�

�

�

�

�

�*

�

�$

�')

�"

�

�

�!

�0

�!

�"*

�-/
+
� � Run Document Action Request


� 

 �

 �

 �

 �

�

�

�

�

�#

�

�

�!"

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�bproto3
��

logs.protologsgoogle/api/annotations.protogoogle/protobuf/timestamp.protobase_data_type.protonotice_management.protouser_interface.protoworkflow.proto"�
ListProcessLogsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
id (Rid
user_id	 (RuserId
instance_id
 (R
instanceId

table_name (	R	tableName
	record_id (RrecordId"�
ListProcessLogsResponse!
record_count (RrecordCount3
process_logs (2.data.ProcessLogRprocessLogs&
next_page_token (	RnextPageToken"�
ListEntityLogsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue

table_name (	R	tableName
id	 (Rid"�
	ChangeLog
column_name (	R
columnName.
display_column_name (	RdisplayColumnName
	old_value (	RoldValue*
old_display_value (	RoldDisplayValue
	new_value (	RnewValue*
new_display_value (	RnewDisplayValue 
description (	Rdescription!
display_type (RdisplayType"�
	EntityLog
log_id (RlogId
id (Rid%
displayed_name (	RdisplayedName
	window_id (RwindowId

table_name (	R	tableName

session_id (R	sessionId

created_by (R	createdBy&
created_by_name (	RcreatedByName

updated_by	 (R	updatedBy&
updated_by_name
 (	RupdatedByName)
transaction_name (	RtransactionName4

event_type (2.logs.EntityEventTypeR	eventType5
log_date (2.google.protobuf.TimestampRlogDate0
change_logs (2.logs.ChangeLogR
changeLogs"�
ListEntityLogsResponse!
record_count (RrecordCount0
entity_logs (2.logs.EntityLogR
entityLogs&
next_page_token (	RnextPageToken4
created (2.google.protobuf.TimestampRcreated

created_by (R	createdBy&
created_by_name (	RcreatedByName4
updated (2.google.protobuf.TimestampRupdated

updated_by (R	updatedBy&
updated_by_name	 (	RupdatedByName"V
ExistsChatEntriesRequest

table_name (	R	tableName
	record_id (RrecordId">
ExistsChatEntriesResponse!
record_count (RrecordCount"�
ListEntityChatsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue

table_name (	R	tableName
id	 (Rid"�
ListEntityChatsResponse!
record_count (RrecordCount3
entity_chats (2.logs.EntityChatRentityChats&
next_page_token (	RnextPageToken"�

EntityChat
chat_id (RchatId
id (Rid

table_name (	R	tableName 
chat_type_id (R
chatTypeId 
description (	RdescriptionC
confidential_type (2.logs.ConfidentialTypeRconfidentialType=
moderation_type (2.logs.ModerationTypeRmoderationType5
log_date (2.google.protobuf.TimestampRlogDate
user_id	 (RuserId
	user_name
 (	RuserName"�
ListChatEntriesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
id (Rid"�
ListChatEntriesResponse!
record_count (RrecordCount<
chat_entries (2.user_interface.ChatEntryRchatEntries&
next_page_token (	RnextPageToken"�
ListRecentItemsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListRecentItemsResponse!
record_count (RrecordCount3
recent_items (2.logs.RecentItemRrecentItems&
next_page_token (	RnextPageToken"�

RecentItem
menu_id (RmenuId
	menu_name (	RmenuName)
menu_description (	RmenuDescription
	window_id (RwindowId
tab_id (RtabId
table_id (RtableId

table_name (	R	tableName
id (Rid!
display_name	 (	RdisplayName4
updated
 (2.google.protobuf.TimestampRupdated!
reference_id (RreferenceId
action (	Raction"�
ListWorkflowLogsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue

table_name (	R	tableName
id	 (Rid"�
ListWorkflowLogsResponse!
record_count (RrecordCount>
workflow_logs (2.workflow.WorkflowProcessRworkflowLogs&
next_page_token (	RnextPageToken"�
ListUserActivitesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue.
date (2.google.protobuf.TimestampRdate"�
UserActivityD
user_activity_type (2.logs.UserActivityTypeRuserActivityType.

entity_log (2.logs.EntityLogR	entityLog1
process_log (2.data.ProcessLogR
processLog1
notice (2.notice_management.NoticeRnotice"�
ListUserActivitesResponse!
record_count (RrecordCount,
records (2.logs.UserActivityRrecords&
next_page_token (	RnextPageToken*5
EntityEventType

INSERT 

UPDATE

DELETE*8
ConfidentialType

PUBLIC 

PARTER
INTERNAL*P
ModerationType
NOT_MODERATED 
BEFORE_PUBLISHING
AFTER_PUBLISHING*?
UserActivityType

ENTITY_LOG 
PROCESS_LOG

NOTICE2�
Logs�
ListProcessLogs.logs.ListProcessLogsRequest.logs.ListProcessLogsResponse"�����/logs/processZ/logs/process/{id}Z&$/logs/process/instance/{instance_id}Z(&/logs/process/{table_name}/{record_id}Z/logs/process/user/{user_id}u
ListEntityLogs.logs.ListEntityLogsRequest.logs.ListEntityLogsResponse"(���" /logs/entities/{table_name}/{id}}
ListEntityChats.logs.ListEntityChatsRequest.logs.ListEntityChatsResponse"-���'%/logs/chat-entities/{table_name}/{id}�
ExistsChatEntries.logs.ExistsChatEntriesRequest.logs.ExistsChatEntriesResponse":���42/logs/chat-entries/{table_name}/{record_id}/existso
ListChatEntries.logs.ListChatEntriesRequest.logs.ListChatEntriesResponse"���/logs/chat-entries/{id}|
ListWorkflowLogs.logs.ListWorkflowLogsRequest.logs.ListWorkflowLogsResponse")���#!/logs/workflows/{table_name}/{id}j
ListRecentItems.logs.ListRecentItemsRequest.logs.ListRecentItemsResponse"���/logs/recent-itemss
ListUserActivites.logs.ListUserActivitesRequest.logs.ListUserActivitesResponse"���/logs/user-activitiesB-
org.spin.backend.grpc.logsBADempiereLogsPJ�`
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 3
	
 3

 .
	
 .
	
  &
	
 )
	
 
	
 !
	
 
	
 

  2 Base URL
 /logs/


 $ S	Logger services



 $
E
  &6	7	Request BusinessProcess Activity from current session


  &

  &2

  &=T

  '5

	  �ʼ"'5
'
 8:		Request Record Log List


 8

 80

 8;Q

 9W

	 �ʼ"9W
(
 <>		Request Record Chat List


 <

 <2

 <=T

 =\

	 �ʼ"=\
#
 @B		Exists Chat Entries


 @

 @6

 @AZ

 Ai

	 �ʼ"Ai
)
 DF		Request Chat Entries List


 D

 D2

 D=T

 EN

	 �ʼ"EN
'
 HJ		List workflow processes


 H

 H4

 H?W

 IX

	 �ʼ"IX
$
 LN		Request Recent Items


 L

 L2

 L=T

 MI

	 �ʼ"MI
,
 PR	 Request List User Activities


 P

 P6

 PAZ

 QL

	 �ʼ"QL
.
 V c" BusinessProcess Activity Request



 V

  W

  W

  W

  W

 X

 X

 X

 X

 Y*

 Y

 Y

 Y%

 Y()

 Z+

 Z

 Z

 Z&

 Z)*

 [

 [

 [

 [

 \

 \

 \

 \

 ] 

 ]

 ]

 ]

 ^

 ^

 ^

 ^

 _

 _

 _

 _

 	`

 	`

 	`

 	`

 
a

 
a

 
a

 
a

 b

 b

 b

 b
+
f j BusinessProcess Response List



f

 g

 g

 g

 g

h2

h

h 

h!-

h01

i#

i

i

i!"
 
m w Record Log Request



m

 n

 n

 n

 n

o

o

o

o

p*

p

p

p%

p()

q+

q

q

q&

q)*

r

r

r

r

s

s

s

s

t 

t

t

t

u

u

u

u

v

v

v

v

z � Record Log



z

 {

 {

 {

 {

|'

|

|"

|%&

}

}

}

}

~%

~

~ 

~#$









�%

�

� 

�#$

�

�

�

�

�

�

�

�

 � �

 �

  �

  �

  �

 �

 �

 �

 �

 �

 �

� �

�

 �

 �

 �

 �

�

�

�

�

�"

�

�

� !

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�#

�

�

�!"

�

�

�

�

	�$

	�

	�

	�!#


�%


�


�


�"$

�(

�

�"

�%'

�0

�!

�"*

�-/

�,

�

�

�&

�)+

� �

�

 �

 �

 �

 �

�+

�

�

�&

�)*

�#

�

�

�!"

�.

�!

�")

�,-

�

�

�

�

�#

�

�

�!"

�.

�!

�")

�,-

�

�

�

�

�#

�

�

�!"
)
� � Exists References Request


� 

 �

 �

 �

 �

�

�

�

�
"
� � Entity Chats Count


�!

 �

 �

 �

 �
#
� � Record Chat Request


�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

�

�

�

�
!
	� �	Record Chats List


	�

	 �

	 �

	 �

	 �

	�-

	�

	�

	�(

	�+,

	�#

	�

	�

	�!"

� � Record Chat


�

 �

 �

 �

�

�

�

�

�

�

� �

�

 �

 �

 �

�

�

�

�

�

�


� �


�


 �


 �


 �


 �


�


�


�


�


�


�


�


�


�


�


�


�


�


�


�


�


�/


�


�*


�-.


�+


�


�&


�)*


�/


�!


�"*


�-.


�


�


�


�


	�


	�


	�


	�
)
� � Record Chat Entry Request


�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�
!
� �	Record Chats List


�

 �

 �

 �

 �

�;

�

�)

�*6

�9:

�#

�

�

�!"
$
� � Recent Items Request


�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�
!
� �	Recent Items List


�

 �

 �

 �

 �

�-

�

�

�(

�+,

�#

�

�

�!"

� � Recent Item


�

 �

 �

 �

 �

�

�

�

�

�$

�

�

�"#

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� 

�

�

�

	�/

	�!

	�")

	�,.


� 


�


�


�

�

�

�

�
+
� � Workflow Activities Request


�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

�

�

�

�
(
� �	Workflow Activities List


� 

 �

 �

 �

 �

�<

�

�)

�*7

�:;

�#

�

�

�!"

� �	User Activity


� 

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�+

�!

�"&

�)*

� �

�

 �

 �

 �

�

�

�

�

�

�

� �

�

 �0

 �

 �+

 �./

�!

�

�

� 

�(

�

�#

�&'

�,

� 

�!'

�*+

� �

�!

 �

 �

 �

 �

�*

�

�

�%

�()

�#

�

�

�!"bproto3
�~
match_po_receipt_invoice.protomatch_po_receipt_invoicegoogle/api/annotations.protogoogle/protobuf/timestamp.protobase_data_type.proto"�
ListMatchesTypesFromRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListMatchesTypesToRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecordsK
match_from_type
 (2#.match_po_receipt_invoice.MatchTypeRmatchFromType"�
ListSearchModesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"{
Vendor
id (Rid
value (	Rvalue
tax_id (	RtaxId
name (	Rname 
description (	Rdescription"�
ListVendorsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListProductsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
Product
id (Rid
upc (	Rupc
sku (	Rsku
value (	Rvalue
name (	Rname 
description (	Rdescription"�
ListProductsResponse!
record_count (RrecordCount;
records (2!.match_po_receipt_invoice.ProductRrecords&
next_page_token (	RnextPageToken"�
Matched
id (Rid
	header_id (RheaderId
document_no (	R
documentNo.
date (2.google.protobuf.TimestampRdate
	vendor_id (RvendorId
vendor_name (	R
vendorName
line_no (RlineNo

product_id (R	productId!
product_name	 (	RproductName
quantity
 (	Rquantity)
matched_quantity (	RmatchedQuantityB

match_type (2#.match_po_receipt_invoice.MatchTypeR	matchType"�
ListMatchedFromRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValueB

match_mode (2#.match_po_receipt_invoice.MatchModeR	matchModeK
match_from_type	 (2#.match_po_receipt_invoice.MatchTypeRmatchFromTypeG
match_to_type
 (2#.match_po_receipt_invoice.MatchTypeRmatchToType
	vendor_id (RvendorId

product_id (R	productId7
	date_from (2.google.protobuf.TimestampRdateFrom3
date_to (2.google.protobuf.TimestampRdateTo"�
ListMatchedFromResponse!
record_count (RrecordCount;
records (2!.match_po_receipt_invoice.MatchedRrecords&
next_page_token (	RnextPageToken"�
ListMatchedToRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValueB

match_mode (2#.match_po_receipt_invoice.MatchModeR	matchModeK
match_from_type	 (2#.match_po_receipt_invoice.MatchTypeRmatchFromTypeG
match_to_type
 (2#.match_po_receipt_invoice.MatchTypeRmatchToType3
match_from_selected_id (RmatchFromSelectedId
	vendor_id (RvendorId

product_id (R	productId7
	date_from (2.google.protobuf.TimestampRdateFrom3
date_to (2.google.protobuf.TimestampRdateTo(
is_same_quantity (RisSameQuantity"�
ListMatchedToResponse!
record_count (RrecordCount;
records (2!.match_po_receipt_invoice.MatchedRrecords&
next_page_token (	RnextPageToken"�
ProcessRequestB

match_mode (2#.match_po_receipt_invoice.MatchModeR	matchModeK
match_from_type (2#.match_po_receipt_invoice.MatchTypeRmatchFromTypeG
match_to_type (2#.match_po_receipt_invoice.MatchTypeRmatchToType3
match_from_selected_id (RmatchFromSelectedIdU
matched_to_selections (2!.match_po_receipt_invoice.MatchedRmatchedToSelections
quantity (	Rquantity"+
ProcessResponse
message (	Rmessage*9
	MatchType
INVOICE 
RECEIPT
PURCHASE_ORDER*3
	MatchMode
MODE_NOT_MATCHED 
MODE_MATCHED2�

MatchPORReceiptInvoice�
ListMatchesTypesFrom5.match_po_receipt_invoice.ListMatchesTypesFromRequest.data.ListLookupItemsResponse"4���.,/match-po-receipt-invoice/matches-types/from�
ListMatchesTypesTo3.match_po_receipt_invoice.ListMatchesTypesToRequest.data.ListLookupItemsResponse"2���,*/match-po-receipt-invoice/matches-types/to�
ListSearchModes0.match_po_receipt_invoice.ListSearchModesRequest.data.ListLookupItemsResponse".���(&/match-po-receipt-invoice/search-modes�
ListVendors,.match_po_receipt_invoice.ListVendorsRequest.data.ListLookupItemsResponse")���#!/match-po-receipt-invoice/vendors�
ListProducts-.match_po_receipt_invoice.ListProductsRequest..match_po_receipt_invoice.ListProductsResponse"*���$"/match-po-receipt-invoice/products�
ListMatchedFrom0.match_po_receipt_invoice.ListMatchedFromRequest1.match_po_receipt_invoice.ListMatchedFromResponse".���(&/match-po-receipt-invoice/matches/from�
ListMatchedTo..match_po_receipt_invoice.ListMatchedToRequest/.match_po_receipt_invoice.ListMatchedToResponse"E���?=/match-po-receipt-invoice/matches/to/{vendor_id}/{product_id}�
Process(.match_po_receipt_invoice.ProcessRequest).match_po_receipt_invoice.ProcessResponse",���&"!/match-po-receipt-invoice/process:*BW
3org.spin.backend.grpc.form.match_po_receipt_invoiceBADempiereMatchPOReceiptInvoicePJ�L
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 L
	
 L

 ?
	
 ?
	
  &
	
 )
	
 
 
 !2 Base URL
 /match-po/

�
 " C� The Matching PO-Receipt-Invoice form service definition.
 - org.compiere.apps.form.Match
 - org.compiere.apps.form.VMatch
 - org.adempiere.webui.apps.form.WMatch



 "

  $&	 lists criteria


  $ 

  $!<

  $Gc

  %c

	  �ʼ"%c

 ')	

 '

 '8

 'C_

 (a

	 �ʼ"(a

 *,	

 *

 *2

 *=Y

 +]

	 �ʼ"+]

 -/	

 -

 -*

 -5Q

 .X

	 �ʼ".X

 02	

 0

 0,

 07K

 1Y

	 �ʼ"1Y

 57	 list result


 5

 52

 5=T

 6]

	 �ʼ"6]

 8:	

 8

 8.

 89N

 9t

	 �ʼ"9t

 =B		 process


 =

 ="

 =-<

 >A

	 �ʼ">A

 G K Match Type



 G

  H

  H

  H

 I

 I

 I

 J

 J

 J


 M W


 M#

  N

  N

  N

  N

 O

 O

 O

 O

 P*

 P

 P

 P%

 P()

 Q+

 Q

 Q

 Q&

 Q)*

 R

 R

 R

 R

 S

 S

 S

 S

 T 

 T

 T

 T

 U&

 U

 U!

 U$%

 V(

 V

 V#

 V&'


Y e


Y!

 Z

 Z

 Z

 Z

[

[

[

[

\*

\

\

\%

\()

]+

]

]

]&

])*

^

^

^

^

_

_

_

_

` 

`

`

`

a&

a

a!

a$%

b(

b

b#

b&'

	d' custom filters


	d

	d!

	d$&

i l Match Mode



i

 j

 j

 j

k

k

k


n x


n

 o

 o

 o

 o

p

p

p

p

q*

q

q

q%

q()

r+

r

r

r&

r)*

s

s

s

s

t

t

t

t

u 

u

u

u

v&

v

v!

v$%

w(

w

w#

w&'
(
| � Vendor (Business Partner)



|

 }

 }

 }

 }

~

~

~

~









�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

� �	 Product


�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�%

�

�

� 

�#$

�#

�

�

�!"

� �	 Matched


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�+

�!

�"&

�)*

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� 

�

�

�

	�

	�

	�

	�


�%


�


�


�"$

�"

�

�

�!

	� �

	�

	 �

	 �

	 �

	 �

	�

	�

	�

	�

	�*

	�

	�

	�%

	�()

	�+

	�

	�

	�&

	�)*

	�

	�

	�

	�

	�

	�

	�

	�

	� 

	�

	�

	�

	�!

	�

	�

	� 

	�&

	�

	�!

	�$%

		�%

		�

		�

		�"$

	
�

	
�

	
�

	
�

	�

	�

	�

	�

	�1

	�!

	�"+

	�.0

	�/

	�!

	�")

	�,.


� �


�


 �


 �


 �


 �


�%


�


�


� 


�#$


�#


�


�


�!"

� � Matched To


�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�!

�

�

� 

�&

�

�!

�$%

	�%

	�

	�

	�"$


�*


�


�$


�')

�

�

�

�

�

�

�

�

�1

�!

�"+

�.0

�/

�!

�")

�,.

�#

�

�

� "

� �

�

 �

 �

 �

 �

�%

�

�

� 

�#$

�#

�

�

�!"

� �	 Process


�

 �!

 �

 �

 � 

�&

�

�!

�$%

�$

�

�

�"#

�)

�

�$

�'(

�3

�

�

�.

�12

�

�

�

�

� �

�

 �

 �

 �

 �bproto3
��
material_management.protomaterial_managementgoogle/api/annotations.protogoogle/protobuf/struct.protogoogle/protobuf/timestamp.protobase_data_type.proto"�
ListProductStorageRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue

table_name (	R	tableName
	record_id	 (RrecordId"s
ProductAttributeValue
id (Rid
value (	Rvalue
name (	Rname 
description (	Rdescription"�
ProductAttribute
id (Rid
name (	Rname 
description (	Rdescription

value_type (	R	valueType!
is_mandatory (RisMandatory2
is_instance_attribute (RisInstanceAttribute
sequence (Rsequenced
product_attribute_values (2*.material_management.ProductAttributeValueRproductAttributeValues"�
ProductAttributeSet
id (Rid
name (	Rname 
description (	Rdescription2
is_instance_attribute (RisInstanceAttribute
is_lot (RisLot(
is_lot_mandatory (RisLotMandatory$
lot_control_id (RlotControlId7
lot_char_start_overwrite (	RlotCharStartOverwrite3
lot_char_end_overwrite	 (	RlotCharEndOverwrite
	is_serial
 (RisSerial.
is_serial_mandatory (RisSerialMandatory*
serial_control_id (RserialControlId=
serial_char_start_overwrite (	RserialCharStartOverwrite9
serial_char_end_overwrite (	RserialCharEndOverwrite*
is_guarantee_date (RisGuaranteeDate=
is_guarantee_date_mandatory (RisGuaranteeDateMandatory%
guarantee_days (RguaranteeDays%
mandatory_type (	RmandatoryTypeT
product_attributes (2%.material_management.ProductAttributeRproductAttributes"�
ProductAttributeInstance
id (Rid
value (	Rvalue!
value_number (	RvalueNumberH
!product_attribute_set_instance_id (RproductAttributeSetInstanceId0
product_attribute_id (RproductAttributeId;
product_attribute_value_id (RproductAttributeValueId"�
ProductAttributeSetInstance
id (Rid 
description (	RdescriptionA
guarantee_date (2.google.protobuf.TimestampRguaranteeDate
lot (	Rlot
lot_id (RlotId
serial (	Rserial\
product_attribute_set (2(.material_management.ProductAttributeSetRproductAttributeSetm
product_attribute_instances (2-.material_management.ProductAttributeInstanceRproductAttributeInstances"�
GetProductAttributeSetRequest
id (Rid

product_id (R	productIdH
!product_attribute_set_instance_id (RproductAttributeSetInstanceId"�
ListProductAttributesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue

product_id (R	productIdH
!product_attribute_set_instance_id	 (RproductAttributeSetInstanceId"�
!ListProductAttributeValuesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue0
product_attribute_id (RproductAttributeId"V
%GetProductAttributeSetInstanceRequest
id (Rid

product_id (R	productId"�
'ListProductAttributeSetInstancesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue

product_id (R	productId7
product_attribute_set_id	 (RproductAttributeSetId"�
(ListProductAttributeSetInstancesResponse!
record_count (RrecordCountJ
records (20.material_management.ProductAttributeSetInstanceRrecords&
next_page_token (	RnextPageToken"�
&SaveProductAttributeSetInstanceRequest
id (RidA
guarantee_date (2.google.protobuf.TimestampRguaranteeDate
lot (	Rlot
serial (	Rserial

product_id (R	productId7
product_attribute_set_id (RproductAttributeSetId7

attributes (2.google.protobuf.StructR
attributes"�
	Warehouse
id (Rid
value (	Rvalue
name (	Rname 
description (	Rdescription"
is_in_transit (RisInTransitI
warehouse_source (2.material_management.WarehouseRwarehouseSource"�
ListAvailableWarehousesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue!
warehouse_id (RwarehouseId"�
ListAvailableWarehousesResponse!
record_count (RrecordCount8
records (2.material_management.WarehouseRrecords&
next_page_token (	RnextPageToken"�
Locator
id (Rid
value (	Rvalue

is_default (R	isDefault
aisle (	Raisle
bin (	Rbin
level (	Rlevel<
	warehouse (2.material_management.WarehouseR	warehouse"�
ListLocatorsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValueF
context_attributes (2.google.protobuf.StructRcontextAttributes!
warehouse_id	 (RwarehouseId0
process_parameter_id
 (RprocessParameterId
field_id (RfieldId&
browse_field_id (RbrowseFieldId!
reference_id (RreferenceId
	column_id (RcolumnId

table_name (	R	tableName
column_name (	R
columnName"�
ListLocatorsResponse!
record_count (RrecordCount6
records (2.material_management.LocatorRrecords&
next_page_token (	RnextPageToken2�
MaterialManagement�
ListProductStorage..material_management.ListProductStorageRequest.data.ListEntitiesResponse"-���'%/material-management/products-storage�
ListProductAttributeValues6.material_management.ListProductAttributeValuesRequest.data.ListEntitiesResponse"-���'%/material-management/attribute-values�
ListProductAttributes1.material_management.ListProductAttributesRequest.data.ListEntitiesResponse"-���'%/material-management/attribute-values�
GetProductAttributeSet2.material_management.GetProductAttributeSetRequest(.material_management.ProductAttributeSet";���53/material-management/products/{id}/attribute-values�
GetProductAttributeSetInstance:.material_management.GetProductAttributeSetInstanceRequest0.material_management.ProductAttributeSetInstance"A���;9/material-management/products/{product_id}/instances/{id}�
 ListProductAttributeSetInstances<.material_management.ListProductAttributeSetInstancesRequest=.material_management.ListProductAttributeSetInstancesResponse"<���64/material-management/products/{product_id}/instances�
SaveProductAttributeSetInstance;.material_management.SaveProductAttributeSetInstanceRequest0.material_management.ProductAttributeSetInstance"?���9"4/material-management/products/{product_id}/instances:*�
ListAvailableWarehouses3.material_management.ListAvailableWarehousesRequest4.material_management.ListAvailableWarehousesResponse"'���!/material-management/warehouses�
ListLocators(.material_management.ListLocatorsRequest).material_management.ListLocatorsResponse"$���/material-management/locatosBJ
)org.spin.backend.grpc.material_managementBADempiereMaterialManagementPJ�X
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 B
	
 B

 <
	
 <
	
  &
	
 &
	
 )
	
 
+
 2! Base URL
 /material-management/

9
   D- The Material Management service definition.



  
$
  "$	 List Product Storage


  "

  "8

  "C\

  #\

	  �ʼ"#\

 ')	 Attribute Set


 '&

 ''H

 'Sl

 (\

	 �ʼ"(\

 *,	

 *!

 *">

 *Ib

 +\

	 �ʼ"+\

 -/	

 -"

 -#@

 -K^

 .j

	 �ʼ".j

 02	

 0*

 0+P

 0[v

 1p

	 �ʼ"1p

 35	

 3,

 3-T

 3_�

 4k

	 �ʼ"4k

 6;	

 6+

 6,R

 6]x

 7:

	 �ʼ"7:

 >@		 Locator


 >#

 >$B

 >Ml

 ?V

	 �ʼ"?V

 AC	

 A

 A,

 A7K

 BS

	 �ʼ"BS
0
 G Q$ Get Accounting Combination Request



 G!

  H

  H

  H

  H

 I

 I

 I

 I

 J*

 J

 J

 J%

 J()

 K+

 K

 K

 K&

 K)*

 L

 L

 L

 L

 M

 M

 M

 M

 N 

 N

 N

 N

 O

 O

 O

 O

 P

 P

 P

 P


S X


S

 T

 T

 T

 T

U

U

U

U

V

V

V

V

W

W

W

W


Z c


Z

 [

 [

 [

 [

\

\

\

\

]

]

]

]

^

^

^

^

_

_

_

_

`'

`

`"

`%&

a

a

a

a

bD

b

b&

b'?

bBC


e |


e

 f

 f

 f

 f

g

g

g

g

h

h

h

h

i'

i

i"

i%&

k Lot Attributes


k

k

k

l"

l

l

l !

m!

m

m

m 

n,

n

n'

n*+

o*

o

o%

o()
 
	q Serial Attributes


	q

	q

	q


r&


r


r 


r#%

s%

s

s

s"$

t0

t

t*

t-/

u.

u

u(

u+-
(
w$ Guarantee Date Attributes


w

w

w!#

x.

x

x(

x+-

y"

y

y

y!

z#

z

z

z "

{:

{

{!

{"4

{79
1
 �$ Based on M_AttributeInstance table



 

 �

 �

 �

 �

�

�

�

�

� 

�

�

�

�4

�

�/

�23

�'

�

�"

�%&

�-

�

�(

�+,

� �

�#

 �

 �

 �

 �

�

�

�

�

�5

�!

�"0

�34

�

�

�

�

�

�

�

�

�

�

�

�

�6

�

�1

�45

�J

�

�)

�*E

�HI

� �

�%

 �

 �

 �

 �

�

�

�

�

�4

�

�/

�23

� �

�$

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

�4

�

�/

�23

� �

�)

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�'

�

�"

�%&

	� �

	�-

	 �

	 �

	 �

	 �

	�

	�

	�

	�


� �


�/


 �


 �


 �


 �


�


�


�


�


�*


�


�


�%


�()


�+


�


�


�&


�)*


�


�


�


�


�


�


�


�


� 


�


�


�


�


�


�


�


�+


�


�&


�)*
B
� �4 List List Product Attribute Set Instances Response


�0

 �

 �

 �

 �

�9

�

�,

�-4

�78

�#

�

�

�!"
;
� �- Save Product Attribute Set Instance Request


�.

 �

 �

 �

 �

�5

�!

�"0

�34

�

�

�

�

�

�

�

�

�

�

�

�

�+

�

�&

�)*
-
�. Product Attribute UUID, Value


�

�)

�,-

� � Warehouse


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�'

�

�"

�%&

� �

�&

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

� �

�'

 �

 �

 �

 �

�'

�

�

�"

�%&

�#

�

�

�!"

� �	 Locator


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�" (X)


�

�

�

�" (Y)


�

�

�

�" (Z)


�

�

�

� 

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�6

�

�1

�45

�

�

�

�

	�( references


	�

	�"

	�%'


�


�


�


�

�#

�

�

� "

� 

�

�

�

�

�

�

�

�

�

�

�

� 

�

�

�

� �

�

 �

 �

 �

 �

�%

�

�

� 

�#$

�#

�

�

�!"bproto3
��
payment_allocation.protopayment_allocationgoogle/api/annotations.protogoogle/protobuf/timestamp.protobase_data_type.proto"�
BusinessPartner
id (Rid
value (	Rvalue
tax_id (	RtaxId
name (	Rname 
description (	Rdescription"�
ListBusinessPartnersRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListBusinessPartnersResponse!
record_count (RrecordCount=
records (2#.payment_allocation.BusinessPartnerRrecords&
next_page_token (	RnextPageToken"H
Organization
id (Rid
value (	Rvalue
name (	Rname"�
ListOrganizationsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListOrganizatiosResponse!
record_count (RrecordCount:
records (2 .payment_allocation.OrganizationRrecords&
next_page_token (	RnextPageToken"W
Currency
id (Rid
iso_code (	RisoCode 
description (	Rdescription"�
ListCurrenciesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListCurrenciesResponse!
record_count (RrecordCount6
records (2.payment_allocation.CurrencyRrecords&
next_page_token (	RnextPageToken"m
TransactionType
id (Rid
value (	Rvalue
name (	Rname 
description (	Rdescription"�
ListTransactionTypesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListTransactionTypesResponse!
record_count (RrecordCount=
records (2#.payment_allocation.TransactionTypeRrecords&
next_page_token (	RnextPageToken"�
Payment
id (RidE
transaction_date (2.google.protobuf.TimestampRtransactionDate

is_receipt (R	isReceipt
document_no (	R
documentNoN
transaction_type (2#.payment_allocation.TransactionTypeRtransactionTypeD
organization (2 .payment_allocation.OrganizationRorganization 
description (	Rdescription8
currency (2.payment_allocation.CurrencyRcurrency%
payment_amount	 (	RpaymentAmount)
converted_amount
 (	RconvertedAmount
open_amount (	R
openAmount"�
ListPaymentsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue.
business_partner_id (RbusinessPartnerId.
date	 (2.google.protobuf.TimestampRdate'
organization_id
 (RorganizationId
currency_id (R
currencyId*
is_multi_currency (RisMultiCurrency)
transaction_type (	RtransactionType3
is_automatic_write_off (RisAutomaticWriteOff"�
ListPaymentsResponse!
record_count (RrecordCount5
records (2.payment_allocation.PaymentRrecords&
next_page_token (	RnextPageToken"�
Invoice
id (Rid?
date_invoiced (2.google.protobuf.TimestampRdateInvoiced0
is_sales_transaction (RisSalesTransaction
document_no (	R
documentNoN
transaction_type (2#.payment_allocation.TransactionTypeRtransactionTypeD
organization (2 .payment_allocation.OrganizationRorganization 
description (	Rdescription8
currency (2.payment_allocation.CurrencyRcurrency'
original_amount	 (	RoriginalAmount)
converted_amount
 (	RconvertedAmount
open_amount (	R
openAmount'
discount_amount (	RdiscountAmount"�
ListInvoicesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue.
business_partner_id (RbusinessPartnerId.
date	 (2.google.protobuf.TimestampRdate'
organization_id
 (RorganizationId
currency_id (R
currencyId*
is_multi_currency (RisMultiCurrency)
transaction_type (	RtransactionType3
is_automatic_write_off (RisAutomaticWriteOff"�
ListInvoicesResponse!
record_count (RrecordCount5
records (2.payment_allocation.InvoiceRrecords&
next_page_token (	RnextPageToken"f
Charge
id (Rid
name (	Rname 
description (	Rdescription
amount (	Ramount"�
ListChargesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListChargesResponse!
record_count (RrecordCount4
records (2.payment_allocation.ChargeRrecords&
next_page_token (	RnextPageToken"�
#ListTransactionOrganizationsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
$ListTransactionOrganizationsResponse!
record_count (RrecordCount:
records (2 .payment_allocation.OrganizationRrecords&
next_page_token (	RnextPageToken"�
PaymentSelection
id (RidE
transaction_date (2.google.protobuf.TimestampRtransactionDate%
applied_amount (	RappliedAmount"�
InvoiceSelection
id (Rid?
date_invoiced (2.google.protobuf.TimestampRdateInvoiced%
applied_amount (	RappliedAmount'
discount_amount (	RdiscountAmount(
write_off_amount (	RwriteOffAmount
open_amount (	R
openAmount"�
ProcessRequest.
business_partner_id (RbusinessPartnerId
currency_id (R
currencyId*
is_multi_currency (RisMultiCurrency
	charge_id (RchargeId>
transaction_organization_id (RtransactionOrganizationId.
date (2.google.protobuf.TimestampRdate 
description (	Rdescription)
total_difference (	RtotalDifferenceS
payment_selections	 (2$.payment_allocation.PaymentSelectionRpaymentSelectionsS
invoice_selections
 (2$.payment_allocation.InvoiceSelectionRinvoiceSelections"+
ProcessResponse
message (	Rmessage2�

PaymentAllocation�
ListBusinessPartners/.payment_allocation.ListBusinessPartnersRequest.data.ListLookupItemsResponse"-���'%/payment-allocation/business-partners�
ListOrganizations,.payment_allocation.ListOrganizationsRequest.data.ListLookupItemsResponse")���#!/payment-allocation/organizations�
ListCurrencies).payment_allocation.ListCurrenciesRequest.data.ListLookupItemsResponse"&��� /payment-allocation/currencies�
ListTransactionTypes/.payment_allocation.ListTransactionTypesRequest.data.ListLookupItemsResponse"-���'%/payment-allocation/transaction-types�
ListPayments'.payment_allocation.ListPaymentsRequest(.payment_allocation.ListPaymentsResponse":���42/payment-allocation/payments/{business_partner_id}�
ListInvoices'.payment_allocation.ListInvoicesRequest(.payment_allocation.ListInvoicesResponse":���42/payment-allocation/invoices/{business_partner_id}y
ListCharges&.payment_allocation.ListChargesRequest.data.ListLookupItemsResponse"#���/payment-allocation/charges�
ListTransactionOrganizations7.payment_allocation.ListTransactionOrganizationsRequest.data.ListLookupItemsResponse"6���0./payment-allocation/organizations/transactionsz
Process".payment_allocation.ProcessRequest#.payment_allocation.ProcessResponse"&��� "/payment-allocation/process:*BM
-org.spin.backend.grpc.form.payment_allocationBADempierePaymentAllocationPJ�i
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 F
	
 F

 ;
	
 ;
	
  &
	
 )
	
 
*
 2  Base URL
 /payment-allocation/

�
 " F� The Banck Statement Match form service definition.
 - org.compiere.apps.form.Allocation
 - org.compiere.apps.form.VAllocation
 - org.adempiere.webui.apps.form.WAllocation



 "

  $&	 lists criteria


  $ 

  $!<

  $Gc

  %\

	  �ʼ"%\

 ')	

 '

 '6

 'A]

 (X

	 �ʼ"(X

 *,	

 *

 *0

 *;W

 +U

	 �ʼ"+U

 -/	

 - 

 -!<

 -Gc

 .\

	 �ʼ".\

 24	 list result


 2

 2,

 27K

 3i

	 �ʼ"3i

 57	

 5

 5,

 57K

 6i

	 �ʼ"6i

 :<		 process


 :

 :*

 :5Q

 ;R

	 �ʼ";R

 =?	

 =(

 =)L

 =Ws

 >e

	 �ʼ">e

 @E	

 @

 @"

 @-<

 AD

	 �ʼ"AD

 J P Business Partner



 J

  K

  K

  K

  K

 L

 L

 L

 L

 M

 M

 M

 M

 N

 N

 N

 N

 O

 O

 O

 O


R \


R#

 S

 S

 S

 S

T

T

T

T

U*

U

U

U%

U()

V+

V

V

V&

V)*

W

W

W

W

X

X

X

X

Y 

Y

Y

Y

Z&

Z

Z!

Z$%

[(

[

[#

[&'


^ b


^$

 _

 _

 _

 _

`-

`

` 

`!(

`+,

a#

a

a

a!"

f j Organization



f

 g

 g

 g

 g

h

h

h

h

i

i

i

i


l v


l 

 m

 m

 m

 m

n

n

n

n

o*

o

o

o%

o()

p+

p

p

p&

p)*

q

q

q

q

r

r

r

r

s 

s

s

s

t&

t

t!

t$%

u(

u

u#

u&'


x |


x 

 y

 y

 y

 y

z*

z

z

z%

z()

{#

{

{

{!"

� �
 Currency


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

� �

�

 �

 �

 �

 �

�&

�

�

�!

�$%

�#

�

�

�!"
 
	� � Transaction Type


	�

	 �

	 �

	 �

	 �

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�


� �


�#


 �


 �


 �


 �


�


�


�


�


�*


�


�


�%


�()


�+


�


�


�&


�)*


�


�


�


�


�


�


�


�


� 


�


�


�


�&


�


�!


�$%


�(


�


�#


�&'

� �

�$

 �

 �

 �

 �

�-

�

� 

�!(

�+,

�#

�

�

�!"
"
� � Payments Movements


�

 �

 �

 �

 �

�7

�!

�"2

�56

�

�

�

�

�

�

�

�

�-" AP-AR


�

�(

�+,

�&

�

�!

�$%

�

�

�

�

�

�

�

�

�"

�

�

� !

	�%

	�

	�

	�"$


� 


�


�


�

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�+

�!

�"&

�)*

	�#

	�

	�

	� "


�


�


�


�

�$

�

�

�!#

�%" AP-AR


�

�

�"$

�)

�

�#

�&(

� �

�

 �

 �

 �

 �

�%

�

�

� 

�#$

�#

�

�

�!"

� �	 Invoice


�

 �

 �

 �

 �

�4

�!

�"/

�23

�&

�

�!

�$%

�

�

�

�

�-" AP-AR


�

�(

�+,

�&

�

�!

�$%

�

�

�

�

�

�

�

�

�#

�

�

�!"

	�%

	�

	�

	�"$


� 


�


�


�

�$

�

�

�!#

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�+

�!

�"&

�)*

	�#

	�

	�

	� "


�


�


�


�

�$

�

�

�!#

�%" AP-AR


�

�

�"$

�)

�

�#

�&(

� �

�

 �

 �

 �

 �

�%

�

�

� 

�#$

�#

�

�

�!"

� � Charge


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

� �

�

 �

 �

 �

 �

�$

�

�

�

�"#

�#

�

�

�!"
(
� � Transaction Organization


�+

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

� �

�,

 �

 �

 �

 �

�*

�

�

�%

�()

�#

�

�

�!"

� �

�

 �

 �

 �

 �

�7

�!

�"2

�56

�"

�

�

� !

� �

�

 �

 �

 �

 �

�4

�!

�"/

�23

�"

�

�

� !

�#

�

�

�!"

�$

�

�

�"#

�

�

�

�

� �	 Process


�

 �&

 �

 �!

 �$%

�

�

�

�

�#

�

�

�!"

�

�

�

�

�.

�

�)

�,-

�+

�!

�"&

�)*

�

�

�

�

�$

�

�

�"#

�9

�

�!

�"4

�78

	�:

	�

	�!

	�"4

	�79

� �

�

 �

 �

 �

 �bproto3
�k
payment_print_export.protopayment_print_exportgoogle/api/annotations.protobase_data_type.protocore_functionality.proto"�
BankAccount
id (Rid

account_no (	R	accountNo!
account_name (	RaccountName
	bank_name (	RbankName'
current_balance (	RcurrentBalance"�
PaymentSelection
id (Rid
document_no (	R
documentNoD
bank_account (2!.payment_print_export.BankAccountRbankAccount%
payment_amount (	RpaymentAmount)
payment_quantity (RpaymentQuantity8
currency (2.core_functionality.CurrencyRcurrency"�
ListPaymentSelectionsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords",
GetPaymentSelectionRequest
id (Rid"�
ListPaymentRulesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords0
payment_selection_id
 (RpaymentSelectionId"a
GetDocumentNoRequest&
bank_account_id (RbankAccountId!
payment_rule (	RpaymentRule"8
GetDocumentNoResponse
document_no (R
documentNo"�
ListPaymentsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue0
payment_selection_id (RpaymentSelectionId!
payment_rule	 (	RpaymentRule"�
Payment
id (Rid
document_no (	R
documentNo
	vendor_id (RvendorId"
vendor_tax_id (	RvendorTaxId
vendor_name (	R
vendorName
grand_total (	R
grandTotal*
over_under_amount (	RoverUnderAmount%
payment_amount (	RpaymentAmount
open_amount	 (	R
openAmount#
final_balance
 (	RfinalBalance"�
ListPaymentsResponse!
record_count (RrecordCount7
records (2.payment_print_export.PaymentRrecords&
next_page_token (	RnextPageToken"�
ProcessRequest0
payment_selection_id (RpaymentSelectionId!
payment_rule (	RpaymentRule&
bank_account_id (RbankAccountId
document_no (R
documentNo"J
ProcessResponse7
report_output (2.data.ReportOutputRreportOutput"�
ExportRequest0
payment_selection_id (RpaymentSelectionId!
payment_rule (	RpaymentRule&
bank_account_id (RbankAccountId
document_no (R
documentNo"I
ExportResponse7
report_output (2.data.ReportOutputRreportOutput"�
PrintRequest0
payment_selection_id (RpaymentSelectionId!
payment_rule (	RpaymentRule
document_no (R
documentNo"H
PrintResponse7
report_output (2.data.ReportOutputRreportOutput"�
ConfirmPrintRequest0
payment_selection_id (RpaymentSelectionId!
payment_rule (	RpaymentRule&
bank_account_id (RbankAccountId
document_no (R
documentNo"@
ConfirmPrintResponse(
last_document_no (RlastDocumentNo"�
PrintRemittanceRequest0
payment_selection_id (RpaymentSelectionId!
payment_rule (	RpaymentRule
document_no (R
documentNo"R
PrintRemittanceResponse7
report_output (2.data.ReportOutputRreportOutput2�
PaymentPrintExport�
ListPaymentSelections2.payment_print_export.ListPaymentSelectionsRequest.data.ListLookupItemsResponse"0���*(/payment-print-export/payment-selections�
GetPaymentSelection0.payment_print_export.GetPaymentSelectionRequest&.payment_print_export.PaymentSelection"5���/-/payment-print-export/payment-selections/{id}�
ListPaymentRules-.payment_print_export.ListPaymentRulesRequest.data.ListLookupItemsResponse"U���OM/payment-print-export/payment-selections/{payment_selection_id}/payment-rules�
GetDocumentNo*.payment_print_export.GetDocumentNoRequest+.payment_print_export.GetDocumentNoResponse"J���DB/payment-print-export/document-no/{payment_rule}/{bank_account_id}�
ListPayments).payment_print_export.ListPaymentsRequest*.payment_print_export.ListPaymentsResponse"_���YW/payment-print-export/payment-selections/{payment_selection_id}/{payment_rule}/payments�
Process$.payment_print_export.ProcessRequest%.payment_print_export.ProcessResponse"s���m"h/payment-print-export/payment-selections/{payment_selection_id}/{payment_rule}/process/{bank_account_id}:*�
Export#.payment_print_export.ExportRequest$.payment_print_export.ExportResponse"`���Z"U/payment-print-export/payment-selections/{payment_selection_id}/{payment_rule}/export:*�
Print".payment_print_export.PrintRequest#.payment_print_export.PrintResponse"_���Y"T/payment-print-export/payment-selections/{payment_selection_id}/{payment_rule}/print:*�
ConfirmPrint).payment_print_export.ConfirmPrintRequest*.payment_print_export.ConfirmPrintResponse"y���s"n/payment-print-export/payment-selections/{payment_selection_id}/{payment_rule}/confirm-print/{bank_account_id}:*�
PrintRemittance,.payment_print_export.PrintRemittanceRequest-.payment_print_export.PrintRemittanceResponse"j���d"_/payment-print-export/payment-selections/{payment_selection_id}/{payment_rule}/print-remittance:*BK
*org.spin.backend.grpc.payment_print_exportBADempierePaymentPrintExportPJ�@
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 C
	
 C

 <
	
 <
	
  &
	
 
	
 "
%
 2 Base URL
 /payment-print/

�
 " Z� The Payment Print/Export form service definition.
 - org.compiere.apps.form.PayPrint
 - org.compiere.apps.form.VPayPrint
 - org.adempiere.webui.apps.form.WPayPrint



 "
'
  $&	 List Payment Selections


  $!

  $">

  $Ie

  %_

	  �ʼ"%_
,
 (*	 Get a Payment Selection info


 (

 ( :

 (EU

 )d

	 �ʼ")d
"
 ,.	 List Payment Rules


 ,

 ,4

 ,?[

 -�

	 �ʼ"-�

 02	 Get Document No


 0

 0.

 09N

 1y

	 �ʼ"1y
#
 46	 List Payments Check


 4

 4,

 47K

 5�

	 �ʼ"5�
.
 8=	  Process and Create EFT Payment


 8

 8"

 8-<

 9<

	 �ʼ"9<

 ?D	 Export Payments


 ?

 ? 

 ?+9

 @C

	 �ʼ"@C

 FK	 Print Payments


 F

 F

 F)6

 GJ

	 �ʼ"GJ

 MR	 Confirm Payment


 M

 M,

 M7K

 NQ

	 �ʼ"NQ
 
 	TY	 Print Remittance


 	T

 	T2

 	T=T

 	UX

	 	�ʼ"UX

 ] c	Bank Account



 ]

  ^

  ^

  ^

  ^

 _

 _

 _

 _

 ` 

 `

 `

 `

 a

 a

 a

 a

 b#

 b

 b

 b!"

f m Payment Selection



f

 g

 g

 g

 g

h

h

h

h

i%

i

i 

i#$

j"

j

j

j !

k#

k

k

k!"

l1

l#

l$,

l/0
-
p z! List Payment Selections Request



p$

 q

 q

 q

 q

r

r

r

r

s*

s

s

s%

s()

t+

t

t

t&

t)*

u

u

u

u

v

v

v

v

w 

w

w

w

x&

x

x!

x$%

y(

y

y#

y&'
+
}  Get Payment Selection Request



}"

 ~

 ~

 ~

 ~
*
� � List Payment Rules Request


�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

	�( custom filters


	�

	�"

	�%'
'
� � Get Document No Request


�

 �"

 �

 �

 � !

� 

�

�

�
(
� � Get Document No Response


�

 �

 �

 �

 �

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�'

�

�"

�%&

� 

�

�

�

� �

�

 �

 �

 �

 �

�"


�

�

�

�

�

�

�

�!

�

�

� 

�

�

�

�

�

�

�

�

�%

�

� 

�#$

�"

�

�

� !

�

�

�

�

	�"

	�

	�

	�!

	� �

	�

	 �

	 �

	 �

	 �

	�%

	�

	�

	� 

	�#$

	�#

	�

	�

	�!"
6

� �( Process and Create EFT Payment Request



�


 �'


 �


 �"


 �%&


� 


�


�


�


�"


�


�


� !


�


�


�


�

� �

�

 �,

 �

 �'

 �*+
&
� � Export Payment Request


�

 �'

 �

 �"

 �%&

� 

�

�

�

�"

�

�

� !

�

�

�

�

� �

�

 �,

 �

 �'

 �*+
%
� � Print Payment Request


�

 �'

 �

 �"

 �%&

� 

�

�

�

�

�

�

�

� �

�

 �,

 �

 �'

 �*+
%
� � Confirm Print Request


�

 �'

 �

 �"

 �%&

� 

�

�

�

�"

�

�

� !

�

�

�

�

� �

�

 �#

 �

 �

 �!"
(
� � Print Remittance Request


�

 �'

 �

 �"

 �%&

� 

�

�

�

�

�

�

�

� �

�

 �,

 �

 �'

 �*+bproto3
�F
payroll_action_notice.protopayroll_action_noticegoogle/api/annotations.protogoogle/protobuf/empty.protogoogle/protobuf/struct.protobase_data_type.proto"�
ListPayrollProcessRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListValidEmployeesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords,
payroll_process_id
 (RpayrollProcessId"�
ListPayrollConceptsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords,
payroll_process_id
 (RpayrollProcessId.
business_partner_id (RbusinessPartnerId"b
"GetPayrollConceptDefinitionRequest,
payroll_process_id (RpayrollProcessId
id (Rid"�
ListPayrollMovementsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes,
payroll_process_id	 (RpayrollProcessId.
business_partner_id
 (RbusinessPartnerId"�
SavePayrollMovementRequest,
payroll_process_id (RpayrollProcessId.
business_partner_id (RbusinessPartnerId

concept_id (R	conceptId
id (Rid7

attributes (2.google.protobuf.StructR
attributes"1
DeletePayrollMovementsRequest
ids (Rids2�

PayrollActionNotice�
ListPayrollProcess0.payroll_action_notice.ListPayrollProcessRequest.data.ListLookupItemsResponse"&��� /payroll-action-notice/process�
ListValidEmployees0.payroll_action_notice.ListValidEmployeesRequest.data.ListLookupItemsResponse"E���?=/payroll-action-notice/process/{payroll_process_id}/employees�
ListPayrollConcepts1.payroll_action_notice.ListPayrollConceptsRequest.data.ListLookupItemsResponse"d���^\/payroll-action-notice/process/{payroll_process_id}/concepts/employees/{business_partner_id}�
GetPayrollConceptDefinition9.payroll_action_notice.GetPayrollConceptDefinitionRequest.data.Entity"I���CA/payroll-action-notice/process/{payroll_process_id}/concepts/{id}�
ListPayrollMovements2.payroll_action_notice.ListPayrollMovementsRequest.data.ListEntitiesResponse"e���_]/payroll-action-notice/process/{payroll_process_id}/employees/{business_partner_id}/movements�
SavePayrollMovement1.payroll_action_notice.SavePayrollMovementRequest.data.Entity"~���x"s/payroll-action-notice/process/{payroll_process_id}/employees/{business_partner_id}/movements/concepts/{concept_id}:*�
DeletePayrollMovements4.payroll_action_notice.DeletePayrollMovementsRequest.google.protobuf.Empty"2���,"'/payroll-action-notice/delete-movements:*BR
0org.spin.backend.grpc.form.payroll_action_noticeBADempierePayrollActionNoticePJ�*
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 I
	
 I

 =
	
 =
	
  &
	
 %
	
 &
	
 
-
 2# Base URL
 /payroll-action-notice/

;
 ! D/ The payroll-action-notice service definition.



 !
$
  #%	 List Payroll Process


  #

  #8

  #C_

  $U

	  �ʼ"$U
#
 ')	 List Employee Valid


 '

 '8

 'C_

 (t

	 �ʼ"(t
%
 +-	 List Payroll Concepts


 +

 + :

 +Ea

 ,�

	 �ʼ",�
.
 /1	  Get Payroll Concept Definition


 /'

 /(J

 /U`

 0x

	 �ʼ"0x
&
 35	 List Payroll Movements


 3 

 3!<

 3G`

 4�

	 �ʼ"4�
%
 7<	 Save Payroll Movement


 7

 7 :

 7EP

 8;

	 �ʼ"8;
(
 >C	 Delete Payroll Movements


 >"

 >#@

 >K`

 ?B

	 �ʼ"?B
*
 G Q List Payroll Process Request



 G!

  H

  H

  H

  H

 I

 I

 I

 I

 J*

 J

 J

 J%

 J()

 K+

 K

 K

 K&

 K)*

 L

 L

 L

 L

 M

 M

 M

 M

 N 

 N

 N

 N

 O&

 O

 O!

 O$%

 P(

 P

 P#

 P&'
$
T ` List Employees Request



T!

 U

 U

 U

 U

V

V

V

V

W*

W

W

W%

W()

X+

X

X

X&

X)*

Y

Y

Y

Y

Z

Z

Z

Z

[ 

[

[

[

\&

\

\!

\$%

](

]

]#

]&'

	_& custom filters


	_

	_ 

	_#%
*
c p List Payroll Conceps Request



c"

 d

 d

 d

 d

e

e

e

e

f*

f

f

f%

f()

g+

g

g

g&

g)*

h

h

h

h

i

i

i

i

j 

j

j

j

k&

k

k!

k$%

l(

l

l#

l&'

	n& custom filters


	n

	n 

	n#%


o'


o


o!


o$&
4
s v( Get Payroll Concept Definition Request



s*

 t%

 t

 t 

 t#$

u

u

u

u
-
y �  List Payroll Movements Request



y#

 z

 z

 z

 z

{

{

{

{

|*

|

|

|%

|()

}+

}

}

}&

})*

~

~

~

~









� 

�

�

�

�&

�

�!

�$%

�%

�

� 

�#$

	�'

	�

	�!

	�$&
-
� � Save Payroll Movement Request


�"

 �%

 �

 � 

 �#$

�&

�

�!

�$%

�

�

�

�

�

�

�

�

�.

�

�)

�,-
0
� �" Delete Payroll Movements Request


�%

 �

 �

 �

 �

 �bproto3
�9
time_control.prototime_controlgoogle/api/annotations.protogoogle/protobuf/empty.protogoogle/protobuf/timestamp.protocore_functionality.proto"�
CreateResourceAssignmentRequest(
resource_type_id (RresourceTypeId
name (	Rname 
description (	Rdescription"�
ListResourcesAssignmentRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue(
resource_type_id (RresourceTypeId
name	 (	Rname 
description
 (	Rdescription
	confirmed (	R	confirmed3
is_waiting_for_ordered (RisWaitingForOrdered7
	date_from (2.google.protobuf.TimestampRdateFrom3
date_to (2.google.protobuf.TimestampRdateTo"g
UpdateResourceAssignmentRequest
id (Rid
name (	Rname 
description (	Rdescription"1
DeleteResourceAssignmentRequest
id (Rid"�
ResourceType
id (Rid
value (	Rvalue
name (	Rname 
description (	RdescriptionI
unit_of_measure (2!.core_functionality.UnitOfMeasureRunitOfMeasure"o
Resource
id (Rid?
resource_type (2.time_control.ResourceTypeRresourceType
name (	Rname"�
ResourceAssignment
id (Rid2
resource (2.time_control.ResourceRresource
name (	Rname 
description (	RdescriptionD
assign_date_from (2.google.protobuf.TimestampRassignDateFrom@
assign_date_to (2.google.protobuf.TimestampRassignDateTo!
is_confirmed (RisConfirmed
quantity (	Rquantity"�
ListResourcesAssignmentResponse!
record_count (RrecordCount:
records (2 .time_control.ResourceAssignmentRrecords&
next_page_token (	RnextPageToken"2
 ConfirmResourceAssignmentRequest
id (Rid2�
TimeControl�
CreateResourceAssignment-.time_control.CreateResourceAssignmentRequest .time_control.ResourceAssignment"%���"/time-control/assignements:*�
ListResourcesAssignment,.time_control.ListResourcesAssignmentRequest-.time_control.ListResourcesAssignmentResponse""���/time-control/assignements�
UpdateResourceAssignment-.time_control.UpdateResourceAssignmentRequest .time_control.ResourceAssignment"*���$/time-control/assignements/{id}:*�
DeleteResourceAssignment-.time_control.DeleteResourceAssignmentRequest.google.protobuf.Empty"'���!*/time-control/assignements/{id}�
ConfirmResourceAssignment..time_control.ConfirmResourceAssignmentRequest .time_control.ResourceAssignment"/���)"'/time-control/assignements/{id}/confirmB<
"org.spin.backend.grpc.time_controlBADempiereTimeControlPJ�$
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 ;
	
 ;

 5
	
 5
	
  &
	
 %
	
 )
	
 "
$
 2 Base URL
 /time-control/

2
 ! <& The Time Control service definition.



 !
*
  #(	 Create Resource Assignment


  #$

  #%D

  #Oa

  $'

	  �ʼ"$'
(
 *,	 List Resource Assignment


 *#

 *$B

 *Ml

 +Q

	 �ʼ"+Q
*
 .3	 Update Resource Assignment


 .$

 .%D

 .Oa

 /2

	 �ʼ"/2
*
 57	 Delete Resource Assignment


 5$

 5%D

 5Od

 6Y

	 �ʼ"6Y
+
 9;	 Confirm Resource Assignment


 9%

 9&F

 9Qc

 :_

	 �ʼ":_
)
 ? C Create Time Control Request



 ?'

  @#

  @

  @

  @!"

 A

 A

 A

 A

 B

 B

 B

 B
'
F V List Time Control Request



F&

 G

 G

 G

 G

H

H

H

H

I*

I

I

I%

I()

J+

J

J

J&

J)*

K

K

K

K

L

L

L

L

M 

M

M

M

O#	 filters


O

O

O!"

P

P

P

P

	Q 

	Q

	Q

	Q


R


R


R


R

S)

S

S#

S&(

T1

T!

T"+

T.0

U/

U!

U")

U,.
)
Y ] Update Time Control Request



Y'

 Z

 Z

 Z

 Z

[

[

[

[

\

\

\

\
)
` b Delete Time Control Request



`'

 a

 a

 a

 a


d j


d

 e

 e

 e

 e

f

f

f

f

g

g

g

g

h

h

h

h

i=

i(

i)8

i;<


l p


l

 m

 m

 m

 m

n'

n

n"

n%&

o

o

o

o


r {


r

 s

 s

 s

 s

t

t

t

t

u

u

u

u

v

v

v

v

w7

w!

w"2

w56

x5

x!

x"0

x34

y

y

y

y

z

z

z

z

} �


}'

 ~

 ~

 ~

 ~

0



#

$+

./

�#

�

�

�!"

� �

�(

 �

 �

 �

 �bproto3
��
point_of_sales.protodatagoogle/protobuf/empty.protogoogle/protobuf/struct.protogoogle/protobuf/timestamp.protogoogle/api/annotations.protobase_data_type.protocore_functionality.protofile_management.prototime_control.proto"a
DeletePaymentReferenceRequest
id (Rid
pos_id (RposId
order_id (RorderId"f
AllocateSellerRequest
pos_id (RposId6
sales_representative_id (RsalesRepresentativeId"h
DeallocateSellerRequest
pos_id (RposId6
sales_representative_id (RsalesRepresentativeId"�
ListAvailableSellersRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue*
is_only_allocated (RisOnlyAllocated
pos_id	 (RposId"�
ListAvailableSellersResponse!
record_count (RrecordCount/
sellers (2.data.AvailableSellerRsellers&
next_page_token (	RnextPageToken"�
AvailableSeller
id (Rid
key (	Rkey
name (	Rname-
is_pos_required_pin (RisPosRequiredPin 
description (	Rdescription
comments (	Rcomments
image (	Rimage"�
CreatePaymentReferenceRequest
pos_id (RposId6
sales_representative_id (RsalesRepresentativeId 
description (	Rdescription#
source_amount (	RsourceAmount
amount (	Ramount=
payment_date (2.google.protobuf.TimestampRpaymentDate(
tender_type_code (	RtenderTypeCode
currency_id (R
currencyId,
conversion_type_id	 (RconversionTypeId*
payment_method_id
 (RpaymentMethodIdL
payment_account_date (2.google.protobuf.TimestampRpaymentAccountDate7
customer_bank_account_id (RcustomerBankAccountId
order_id (RorderId
customer_id (R
customerId

is_receipt (R	isReceipt0
invoice_reference_id (RinvoiceReferenceId"�
PaymentReference
id (Rid
pos_id (RposIdZ
sales_representative (2'.core_functionality.SalesRepresentativeRsalesRepresentative 
description (	Rdescription
amount (	Ramount=
payment_date (2.google.protobuf.TimestampRpaymentDate(
tender_type_code (	RtenderTypeCode8
currency (2.core_functionality.CurrencyRcurrency:
payment_method	 (2.data.PaymentMethodRpaymentMethodL
payment_account_date
 (2.google.protobuf.TimestampRpaymentAccountDate7
customer_bank_account_id (RcustomerBankAccountId
order_id (RorderId
is_paid (RisPaid

is_receipt (R	isReceipt#
source_amount (	RsourceAmount!
is_automatic (RisAutomatic!
is_processed (RisProcessed)
converted_amount (	RconvertedAmount0
invoice_reference_id (RinvoiceReferenceId"�
ListPaymentReferencesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
pos_id (RposId
customer_id	 (R
customerId
order_id
 (RorderId"�
ListPaymentReferencesResponse!
record_count (RrecordCountE
payment_references (2.data.PaymentReferenceRpaymentReferences&
next_page_token (	RnextPageToken"�
PaymentSummary*
payment_method_id (RpaymentMethodId.
payment_method_name (	RpaymentMethodName(
tender_type_code (	RtenderTypeCode8
currency (2.core_functionality.CurrencyRcurrency
	is_refund (RisRefund
amount (	Ramount"�
ListCashMovementsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
pos_id (RposId.
business_partner_id	 (RbusinessPartnerId*
is_only_processed
 (RisOnlyProcessed$
is_only_refund (RisOnlyRefund6
sales_representative_id (RsalesRepresentativeId"�
ListCashMovementsResponse!
record_count (RrecordCount4
cash_movements (2.data.PaymentRcashMovements&
next_page_token (	RnextPageToken
id (Rid"�
ListCashSummaryMovementsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
pos_id (RposId*
is_only_processed	 (RisOnlyProcessed$
is_only_refund
 (RisOnlyRefund"�
 ListCashSummaryMovementsResponse!
record_count (RrecordCount
id (Rid;
cash_movements (2.data.PaymentSummaryRcashMovements&
next_page_token (	RnextPageToken"�
CashClosing
id (Rid
document_no (	R
documentNoE
document_type (2 .core_functionality.DocumentTypeRdocumentType=
document_status (2.data.DocumentStatusRdocumentStatus 
description (	Rdescription"�
CashClosingRequest
pos_id (RposId
id (Rid.
collecting_agent_id (RcollectingAgentId 
description (	Rdescription"�
CashWithdrawalRequest
pos_id (RposId.
collecting_agent_id (RcollectingAgentId 
description (	Rdescription"}
CashOpeningRequest
pos_id (RposId.
collecting_agent_id (RcollectingAgentId 
description (	Rdescription"�
CreateShipmentRequest
order_id (RorderId6
sales_representative_id (RsalesRepresentativeId
pos_id (RposId:
is_create_lines_from_order (RisCreateLinesFromOrder"J
GetOpenShipmentRequest
order_id (RorderId
pos_id (RposId"O
DeleteShipmentRequest
shipment_id (R
shipmentId
pos_id (RposId"c
DeleteShipmentLineRequest
shipment_id (R
shipmentId
id (Rid
pos_id (RposId"�
UpdateShipmentLineRequest
shipment_id (R
shipmentId
id (Rid 
description (	Rdescription
quantity (	Rquantity
pos_id (RposId"�
CreateShipmentLineRequest
shipment_id (R
shipmentId"
order_line_id (RorderLineId 
description (	Rdescription
quantity (	Rquantity
pos_id (RposId"�
ListShipmentLinesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
shipment_id (R
shipmentId
pos_id	 (RposId"�
ListShipmentLinesResponse!
record_count (RrecordCount9
shipment_lines (2.data.ShipmentLineRshipmentLines&
next_page_token (	RnextPageToken"�
Shipment
id (Rid
document_no (	R
documentNoE
document_type (2 .core_functionality.DocumentTypeRdocumentTypeZ
sales_representative (2'.core_functionality.SalesRepresentativeRsalesRepresentative=
document_status (2.data.DocumentStatusRdocumentStatus;
	warehouse (2.core_functionality.WarehouseR	warehouse?
movement_date (2.google.protobuf.TimestampRmovementDate
order_id (RorderId"�
ProcessShipmentRequest
id (Rid 
description (	Rdescription'
document_action (	RdocumentAction
pos_id (RposId"^
ReverseSalesRequest
pos_id (RposId
id (Rid 
description (	Rdescription"�
ShipmentLine
id (Rid"
order_line_id (RorderLineId5
product (2.core_functionality.ProductRproduct2
charge (2.core_functionality.ChargeRcharge 
description (	Rdescription
quantity (	Rquantity+
movement_quantity (	RmovementQuantity
line (Rline7
uom	 (2%.core_functionality.ProductConversionRuomF
product_uom
 (2%.core_functionality.ProductConversionR
productUom"�
Bank
id (Rid
uuid (	Ruuid
name (	Rname 
description (	Rdescription

routing_no (	R	routingNo

swift_code (	R	swiftCode" 
GetBankRequest
id (Rid"�
ListBanksRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
pos_id (RposId"�
ListBanksResponse!
record_count (RrecordCount$
records (2
.data.BankRrecords&
next_page_token (	RnextPageToken"'
GetBankAccountRequest
id (Rid"�
ListBankAccountsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
bank_id (RbankId
pos_id	 (RposId"�
ListBankAccountsResponse!
record_count (RrecordCount9
records (2.core_functionality.BankAccountRrecords&
next_page_token (	RnextPageToken"�
ListCustomerBankAccountsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
customer_id (R
customerId
pos_id	 (RposId
bank_id
 (RbankId"�
 ListCustomerBankAccountsResponse!
record_count (RrecordCountO
customer_bank_accounts (2.data.CustomerBankAccountRcustomerBankAccounts&
next_page_token (	RnextPageToken"�
 CreateCustomerBankAccountRequest
customer_id (R
customerId
pos_id (RposId
city (	Rcity
country (	Rcountry
email (	Remail%
driver_license (	RdriverLicense4
social_security_number (	RsocialSecurityNumber
name (	Rname
state	 (	Rstate
street
 (	Rstreet
zip (	Rzip*
bank_account_type (	RbankAccountType
bank_id (RbankId
is_ach (RisAch)
address_verified (	RaddressVerified!
zip_verified (	RzipVerified

routing_no (	R	routingNo
iban (	Riban,
is_payroll_account (RisPayrollAccount

account_no (	R	accountNo"�
 UpdateCustomerBankAccountRequest7
customer_bank_account_id (RcustomerBankAccountId
city (	Rcity
country (	Rcountry
email (	Remail%
driver_license (	RdriverLicense4
social_security_number (	RsocialSecurityNumber
name (	Rname
state (	Rstate
street	 (	Rstreet
zip
 (	Rzip*
bank_account_type (	RbankAccountType
bank_id (RbankId
is_ach (RisAch)
address_verified (	RaddressVerified!
zip_verified (	RzipVerified

routing_no (	R	routingNo
iban (	Riban,
is_payroll_account (RisPayrollAccount

account_no (	R	accountNo
pos_id (RposId"r
 DeleteCustomerBankAccountRequest7
customer_bank_account_id (RcustomerBankAccountId
pos_id (RposId"g
GetCustomerBankAccountRequest
cuatomer_id (R
cuatomerId
id (Rid
pos_id (RposId"�
CustomerBankAccount
id (Rid
customer_id (R
customerId
city (	Rcity
country (	Rcountry
email (	Remail%
driver_license (	RdriverLicense4
social_security_number (	RsocialSecurityNumber
name (	Rname
state	 (	Rstate
street
 (	Rstreet
zip (	Rzip*
bank_account_type (	RbankAccountType
bank_id (RbankId
is_ach (RisAch)
address_verified (	RaddressVerified!
zip_verified (	RzipVerified

routing_no (	R	routingNo
iban (	Riban,
is_payroll_account (RisPayrollAccount

account_no (	R	accountNo"�
PrintTicketRequest
pos_id (RposId
order_id (RorderId

invoice_id (R	invoiceId
shipment_id (R
shipmentId
	record_id (RrecordId

table_name (	R	tableName"�
PrintTicketResponse
summary (	Rsummary
is_error (RisError
	file_name (	RfileName
	mime_type (	RmimeType#
output_stream (RoutputStream
result_type (	R
resultType;
result_values (2.google.protobuf.ValueRresultValues"h
PrintPreviewRequest
pos_id (RposId
order_id (RorderId
report_type (	R
reportType"a
PrintPreviewResponse
result (	Rresult1
process_log (2.data.ProcessLogR
processLog"v
PrintShipmentPreviewRequest
pos_id (RposId
shipment_id (R
shipmentId
report_type (	R
reportType"i
PrintShipmentPreviewResponse
result (	Rresult1
process_log (2.data.ProcessLogR
processLog"b
GetAvailableRefundRequest
pos_id (RposId.
date (2.google.protobuf.TimestampRdate"q
AvailableRefund
refund (	RrefundF
tender_type_refunds (2.data.TenderTypeRefundRtenderTypeRefunds"K
TenderTypeRefund
tender_type (	R
tenderType
refund (	Rrefund"�
AddressRequest
id (Rid#
location_name (	RlocationName
address1 (	Raddress1
address2 (	Raddress2
address3 (	Raddress3
address4 (	Raddress4
city_id (RcityId
	city_name (	RcityName
postal_code	 (	R
postalCode4
postal_code_additional
 (	RpostalCodeAdditional
	region_id (RregionId

country_id (R	countryId 
description (	Rdescription,
is_default_billing (RisDefaultBilling.
is_default_shipping (RisDefaultShipping!
contact_name (	RcontactName
email (	Remail
phone (	RphoneL
additional_attributes (2.google.protobuf.StructRadditionalAttributes
pos_id (RposId"�
CreateCustomerRequest
value (	Rvalue
tax_id (	RtaxId
duns (	Rduns
naics (	Rnaics
name (	Rname
	last_name (	RlastName 
description (	Rdescription9
business_partner_group_id (RbusinessPartnerGroupId
pos_id	 (RposId2
	addresses
 (2.data.AddressRequestR	addressesL
additional_attributes (2.google.protobuf.StructRadditionalAttributes"�
UpdateCustomerRequest
id (Rid
value (	Rvalue
tax_id (	RtaxId
duns (	Rduns
naics (	Rnaics
name (	Rname
	last_name (	RlastName 
description (	Rdescription2
	addresses	 (2.data.AddressRequestR	addressesL
additional_attributes
 (2.google.protobuf.StructRadditionalAttributes
pos_id (RposId"�
GetCustomerRequest
id (Rid!
search_value (	RsearchValue
value (	Rvalue
name (	Rname!
contact_name (	RcontactName
email (	Remail
postal_code (	R
postalCode
phone (	Rphone
pos_id	 (RposId"�
Customer
id (Rid
value (	Rvalue
tax_id (	RtaxId
duns (	Rduns
naics (	Rnaics
name (	Rname
	last_name (	RlastName 
description (	Rdescription+
	addresses	 (2.data.AddressR	addressesL
additional_attributes
 (2.google.protobuf.StructRadditionalAttributes"�
ListCustomersRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
value (	Rvalue
name	 (	Rname!
contact_name
 (	RcontactName
email (	Remail
postal_code (	R
postalCode
phone (	Rphone
pos_id (RposId"�
ListCustomersResponse!
record_count (RrecordCount,
	customers (2.data.CustomerR	customers&
next_page_token (	RnextPageToken"�
Address
id (Rid#
display_value (	RdisplayValue$
region (2.data.RegionRregion
city (2
.data.CityRcity
address1 (	Raddress1
address2 (	Raddress2
address3 (	Raddress3
address4 (	Raddress4
phone	 (	Rphone
postal_code
 (	R
postalCode4
postal_code_additional (	RpostalCodeAdditional!
country_code (	RcountryCode

country_id (R	countryId.
is_default_shipping (RisDefaultShipping,
is_default_billing (RisDefaultBilling!
contact_name (	RcontactName
email (	Remail#
location_name (	RlocationName 
description (	Rdescription
	reference (	R	referenceL
additional_attributes (2.google.protobuf.StructRadditionalAttributes"*
City
id (Rid
name (	Rname",
Region
id (Rid
name (	Rname"y
AvailableWarehouse
id (Rid
key (	Rkey
name (	Rname-
is_pos_required_pin (RisPosRequiredPin"�
AvailablePaymentMethod
id (Rid
name (	Rname
pos_id (RposId>
is_displayedfrom_collection (RisDisplayedfromCollection-
is_pos_required_pin (RisPosRequiredPin/
is_allowed_to_refund (RisAllowedToRefund8
is_allowed_to_refund_open (RisAllowedToRefundOpen4
maximum_refund_allowed (	RmaximumRefundAllowed?
maximum_daily_refund_allowed	 (	RmaximumDailyRefundAllowedX
refund_reference_currency
 (2.core_functionality.CurrencyRrefundReferenceCurrencyK
reference_currency (2.core_functionality.CurrencyRreferenceCurrency0
is_payment_reference (RisPaymentReference:
payment_method (2.data.PaymentMethodRpaymentMethod(
document_type_id (RdocumentTypeId"�
PaymentMethod
id (Rid
value (	Rvalue
name (	Rname 
description (	Rdescription
tender_type (	R
tenderType
	is_active (RisActive"�
ListAvailableDiscountsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
pos_id (RposId"�
ListAvailableDiscountsResponse!
record_count (RrecordCount5
	discounts (2.data.AvailableDiscountR	discounts&
next_page_token (	RnextPageToken"x
AvailableDiscount
id (Rid
key (	Rkey
name (	Rname-
is_pos_required_pin (RisPosRequiredPin"|
AvailableDocumentType
id (Rid
key (	Rkey
name (	Rname-
is_pos_required_pin (RisPosRequiredPin"y
AvailablePriceList
id (Rid
key (	Rkey
name (	Rname-
is_pos_required_pin (RisPosRequiredPin"�
ListAvailableWarehousesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
pos_id (RposId"�
!ListAvailableDocumentTypesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
pos_id (RposId"�
ListAvailableWarehousesResponse!
record_count (RrecordCount8

warehouses (2.data.AvailableWarehouseR
warehouses&
next_page_token (	RnextPageToken"�
"ListAvailablePaymentMethodsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
pos_id (RposId"�
#ListAvailablePaymentMethodsResponse!
record_count (RrecordCountE
payment_methods (2.data.AvailablePaymentMethodRpaymentMethods&
next_page_token (	RnextPageToken"�
"ListAvailableDocumentTypesResponse!
record_count (RrecordCountB
document_types (2.data.AvailableDocumentTypeRdocumentTypes&
next_page_token (	RnextPageToken"�
ListAvailablePriceListRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
pos_id (RposId"�
ListAvailablePriceListResponse!
record_count (RrecordCount7

price_list (2.data.AvailablePriceListR	priceList&
next_page_token (	RnextPageToken"�
ListAvailableCurrenciesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
pos_id (RposId"�
ListAvailableCurrenciesResponse!
record_count (RrecordCount<

currencies (2.core_functionality.CurrencyR
currencies&
next_page_token (	RnextPageToken"�
ListPointOfSalesResponse!
record_count (RrecordCount9
selling_points (2.data.PointOfSalesRsellingPoints&
next_page_token (	RnextPageToken"�
ListProductPriceResponse!
record_count (RrecordCountG
product_prices (2 .core_functionality.ProductPriceRproductPrices&
next_page_token (	RnextPageToken"�
ListOrdersResponse!
record_count (RrecordCount#
orders (2.data.OrderRorders&
next_page_token (	RnextPageToken"�
ListOrdersRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
pos_id (RposId
document_no	 (	R
documentNo'
document_status
 (	RdocumentStatus.
business_partner_id (RbusinessPartnerId
grand_total (	R
grandTotal
open_amount (	R
openAmount+
is_waiting_for_pay (RisWaitingForPay*
is_only_processed (RisOnlyProcessed/
is_only_aisle_seller (RisOnlyAisleSeller3
is_waiting_for_invoice (RisWaitingForInvoice5
is_waiting_for_shipment (RisWaitingForShipment(
is_binding_offer (RisBindingOffer
	is_closed (RisClosed!
is_nullified (RisNullified
is_only_rma (R	isOnlyRmaF
date_ordered_from (2.google.protobuf.TimestampRdateOrderedFromB
date_ordered_to (2.google.protobuf.TimestampRdateOrderedTo6
sales_representative_id (RsalesRepresentativeId"�
ListOrderLinesResponse!
record_count (RrecordCount0
order_lines (2.data.OrderLineR
orderLines&
next_page_token (	RnextPageToken"�
ListOrderLinesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
pos_id (RposId
order_id	 (RorderId"�
ListProductPriceRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
pos_id (RposId.
business_partner_id	 (RbusinessPartnerId

valid_from
 (	R	validFrom"
price_list_id (RpriceListId!
warehouse_id (RwarehouseId"�
ListPointOfSalesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"%
PointOfSalesRequest
id (Rid"�
PointOfSales
id (Rid
name (	Rname 
description (	Rdescription
help (	Rhelp&
is_modify_price (RisModifyPrice-
is_pos_required_pin (RisPosRequiredPin&
is_aisle_seller (RisAisleSeller"
is_shared_pos (RisSharedPosE
document_type	 (2 .core_functionality.DocumentTypeRdocumentTypeK
cash_bank_account
 (2.core_functionality.BankAccountRcashBankAccount\
cash_transfer_bank_account (2.core_functionality.BankAccountRcashTransferBankAccountZ
sales_representative (2'.core_functionality.SalesRepresentativeRsalesRepresentative;
template_customer (2.data.CustomerRtemplateCustomer<

price_list (2.core_functionality.PriceListR	priceList;
	warehouse (2.core_functionality.WarehouseR	warehouseG
display_currency (2.core_functionality.CurrencyRdisplayCurrency,
conversion_type_id (RconversionTypeId"
key_layout_id (RkeyLayoutId9
is_allows_modify_quantity (RisAllowsModifyQuantity3
is_allows_return_order (RisAllowsReturnOrder5
is_allows_collect_order (RisAllowsCollectOrder3
is_allows_create_order (RisAllowsCreateOrder;
is_allows_confirm_shipment (RisAllowsConfirmShipment1
is_display_tax_amount (RisDisplayTaxAmount.
is_display_discount (RisDisplayDiscount4
maximum_refund_allowed (	RmaximumRefundAllowed?
maximum_daily_refund_allowed (	RmaximumDailyRefundAllowedX
refund_reference_currency (2.core_functionality.CurrencyRrefundReferenceCurrencyR
return_document_type (2 .core_functionality.DocumentTypeRreturnDocumentType9
default_campaign (2.data.CampaignRdefaultCampaign9
default_opening_charge_id (RdefaultOpeningChargeId?
default_withdrawal_charge_id  (RdefaultWithdrawalChargeId8
maximum_discount_allowed! (	RmaximumDiscountAllowed;
write_off_amount_tolerance" (	RwriteOffAmountTolerance9
is_allows_allocate_seller# (RisAllowsAllocateSeller7
is_allows_concurrent_use$ (RisAllowsConcurrentUse?
is_confirm_complete_shipment% (RisConfirmCompleteShipment3
is_allows_cash_closing& (RisAllowsCashClosing3
is_allows_cash_opening' (RisAllowsCashOpening9
is_allows_cash_withdrawal( (RisAllowsCashWithdrawal7
is_allows_apply_discount) (RisAllowsApplyDiscount9
is_allows_create_customer* (RisAllowsCreateCustomer7
is_allows_print_document+ (RisAllowsPrintDocument;
is_allows_preview_document, (RisAllowsPreviewDocument$
is_pos_manager- (RisPosManager9
is_allows_modify_discount. (RisAllowsModifyDiscount<
is_keep_price_from_customer/ (RisKeepPriceFromCustomerA
maximum_line_discount_allowed0 (	RmaximumLineDiscountAllowed9
is_allows_modify_customer1 (RisAllowsModifyCustomer@
is_allows_detail_cash_closing2 (RisAllowsDetailCashClosingC
write_off_percentage_tolerance3 (	RwriteOffPercentageTolerance4
is_write_off_by_percent4 (RisWriteOffByPercent:
is_allows_write_off_amount5 (RisAllowsWriteOffAmount"�
CreateOrderRequest
pos_id (RposId
customer_id (R
customerId(
document_type_id (RdocumentTypeId"
price_list_id (RpriceListId!
warehouse_id (RwarehouseId6
sales_representative_id (RsalesRepresentativeId
campaign_id (R
campaignId"t
ReleaseOrderRequest
pos_id (RposId6
sales_representative_id (RsalesRepresentativeId
id (Rid"q
HoldOrderRequest
pos_id (RposId6
sales_representative_id (RsalesRepresentativeId
id (Rid"�
ProcessOrderRequest
pos_id (RposId
id (Rid'
create_payments (RcreatePayments$
is_open_refund (RisOpenRefund6
payments (2.data.CreatePaymentRequestRpayments"�
CreatePaymentRequest
pos_id (RposId
order_id (RorderId

invoice_id (R	invoiceId
bank_id (RbankId!
reference_no (	RreferenceNo 
description (	Rdescription
amount (	Ramount=
payment_date (2.google.protobuf.TimestampRpaymentDate(
tender_type_code	 (	RtenderTypeCode
currency_id
 (R
currencyId*
payment_method_id (RpaymentMethodIdL
payment_account_date (2.google.protobuf.TimestampRpaymentAccountDate
	is_refund (RisRefund
	charge_id (RchargeId.
collecting_agent_id (RcollectingAgentId9
reference_bank_account_id (RreferenceBankAccountId7
customer_bank_account_id (RcustomerBankAccountId0
invoice_reference_id (RinvoiceReferenceId"�
UpdatePaymentRequest
id (Rid
bank_id (RbankId!
reference_no (	RreferenceNo 
description (	Rdescription
amount (	Ramount=
payment_date (2.google.protobuf.TimestampRpaymentDate(
tender_type_code (	RtenderTypeCode*
payment_method_id (RpaymentMethodIdL
payment_account_date	 (2.google.protobuf.TimestampRpaymentAccountDate
pos_id
 (RposId9
reference_bank_account_id (RreferenceBankAccountId0
invoice_reference_id (RinvoiceReferenceId"=
DeletePaymentRequest
id (Rid
pos_id (RposId"�
ListPaymentsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
pos_id (RposId
order_id	 (RorderId$
is_only_refund
 (RisOnlyRefund&
is_only_receipt (RisOnlyReceipt"�
ValidatePINRequest
pos_id (RposId
pin (	Rpin)
requested_access (	RrequestedAccess)
requested_amount (	RrequestedAmount
order_id (RorderId"�
ListPaymentsResponse!
record_count (RrecordCount)
payments (2.data.PaymentRpayments&
next_page_token (	RnextPageToken"�	
Payment
id (Rid
document_no (	R
documentNoR
collecting_agent (2'.core_functionality.SalesRepresentativeRcollectingAgent=
document_status (2.data.DocumentStatusRdocumentStatus*
customer (2.data.CustomerRcustomer
pos_id (RposId
order_id (RorderId

invoice_id (R	invoiceId
bank_id	 (RbankId!
reference_no
 (	RreferenceNo 
description (	Rdescription
amount (	Ramount=
payment_date (2.google.protobuf.TimestampRpaymentDateL
payment_account_date (2.google.protobuf.TimestampRpaymentAccountDate(
tender_type_code (	RtenderTypeCode8
currency (2.core_functionality.CurrencyRcurrency
	is_refund (RisRefund
name (	Rname)
converted_amount (	RconvertedAmount:
payment_method (2.data.PaymentMethodRpaymentMethodB
bank_account (2.core_functionality.BankAccountRbankAccountU
reference_bank_account (2.core_functionality.BankAccountRreferenceBankAccount2
charge (2.core_functionality.ChargeRchargeE
document_type (2 .core_functionality.DocumentTypeRdocumentType!
is_processed (RisProcessed*
order_document_no (	RorderDocumentNo.
invoice_document_no (	RinvoiceDocumentNo";
DeleteOrderRequest
id (Rid
pos_id (RposId"Z
DeleteOrderLineRequest
order_id (RorderId
id (Rid
pos_id (RposId"�
CreateOrderLineRequest
order_id (RorderId

product_id (R	productId
	charge_id (RchargeId 
description (	Rdescription
quantity (	Rquantity
price (	Rprice#
discount_rate (	RdiscountRate!
warehouse_id (RwarehouseId
pos_id	 (RposId4
resource_assignment_id
 (RresourceAssignmentId"�
UpdateOrderRequest
id (Rid
pos_id (RposId
customer_id (R
customerId(
document_type_id (RdocumentTypeId"
price_list_id (RpriceListId!
warehouse_id (RwarehouseId 
description (	Rdescription
campaign_id (R
campaignId#
discount_rate	 (	RdiscountRate*
discount_rate_off
 (	RdiscountRateOff.
discount_amount_off (	RdiscountAmountOff6
sales_representative_id (RsalesRepresentativeId"�
UpdateOrderLineRequest
order_id (RorderId
id (Rid 
description (	Rdescription
quantity (	Rquantity
price (	Rprice
uom_id (RuomId#
discount_rate (	RdiscountRate&
is_add_quantity (RisAddQuantity!
warehouse_id	 (RwarehouseId
pos_id
 (RposId"8
GetOrderRequest
id (Rid
pos_id (RposId"P
GetKeyLayoutRequest"
key_layout_id (RkeyLayoutId
pos_id (RposId"�	
Order
id (Rid
document_no (	R
documentNoE
document_type (2 .core_functionality.DocumentTypeRdocumentTypeZ
sales_representative (2'.core_functionality.SalesRepresentativeRsalesRepresentative=
document_status (2.data.DocumentStatusRdocumentStatus<

price_list (2.core_functionality.PriceListR	priceList;
	warehouse (2.core_functionality.WarehouseR	warehouse
total_lines (	R
totalLines
grand_total	 (	R
grandTotal2
grand_total_converted
 (	RgrandTotalConverted

tax_amount (	R	taxAmount'
discount_amount (	RdiscountAmount=
date_ordered (2.google.protobuf.TimestampRdateOrdered*
customer (2.data.CustomerRcustomer!
is_delivered (RisDelivered'
order_reference (	RorderReference 
description (	Rdescription*
campaign (2.data.CampaignRcampaign2
display_currency_rate (	RdisplayCurrencyRate
open_amount (	R
openAmount%
payment_amount (	RpaymentAmount#
refund_amount (	RrefundAmount#
charge_amount (	RchargeAmount#
credit_amount (	RcreditAmount"
source_rma_id (RsourceRmaId
is_rma (RisRma(
is_binding_offer (RisBindingOffer
is_order (RisOrder"�
	OrderLine
id (Rid
order_id (RorderId5
product (2.core_functionality.ProductRproduct2
charge (2.core_functionality.ChargeRcharge)
line_description (	RlineDescription 
description (	Rdescription;
	warehouse (2.core_functionality.WarehouseR	warehouse
quantity (	Rquantity)
quantity_ordered	 (	RquantityOrdered-
available_quantity
 (	RavailableQuantity
price (	Rprice$
price_with_tax (	RpriceWithTax

price_base (	R	priceBase-
price_base_with_tax (	RpriceBaseWithTax

price_list (	R	priceList-
price_list_with_tax (	RpriceListWithTax#
discount_rate (	RdiscountRate'
discount_amount (	RdiscountAmount

tax_amount (	R	taxAmount&
base_tax_amount (	RbaseTaxAmount&
list_tax_amount (	RlistTaxAmount6
tax_rate (2.core_functionality.TaxRateRtaxRate2
total_discount_amount (	RtotalDiscountAmount(
total_tax_amount (	RtotalTaxAmount*
total_base_amount (	RtotalBaseAmount:
total_base_amount_with_tax (	RtotalBaseAmountWithTax!
total_amount (	RtotalAmount4
total_amount_converted (	RtotalAmountConverted1
total_amount_with_tax (	RtotalAmountWithTaxD
total_amount_with_tax_converted (	RtotalAmountWithTaxConverted
line (Rline7
uom  (2%.core_functionality.ProductConversionRuomF
product_uom! (2%.core_functionality.ProductConversionR
productUomQ
resource_assignment" (2 .time_control.ResourceAssignmentRresourceAssignment+
source_rma_line_id# (RsourceRmaLineId"�
GetProductPriceRequest
pos_id (RposId!
search_value (	RsearchValue
upc (	Rupc
sku (	Rsku
value (	Rvalue
name (	Rname.
business_partner_id (RbusinessPartnerId

valid_from	 (	R	validFrom"
price_list_id
 (RpriceListId!
warehouse_id (RwarehouseId"�
	KeyLayout
id (Rid
name (	Rname 
description (	Rdescription
help (	Rhelp
layout_type (	R
layoutType
columns (Rcolumns
color (	Rcolor
keys (2	.data.KeyRkeys"�
Key
id (Rid
name (	Rname 
description (	Rdescription)
sub_key_layout_id (RsubKeyLayoutId
color (	Rcolor
sequence (Rsequence
span_x (RspanX
span_y (RspanY#
product_value	 (	RproductValue
quantity
 (	RquantityQ
resource_reference (2".file_management.ResourceReferenceRresourceReference"�
Stock

product_id (R	productId
quantity (Rquantity
is_in_stock (R	isInStock.
is_decimal_quantity (RisDecimalQuantityN
$is_show_default_notification_message (R isShowDefaultNotificationMessageB
is_use_config_minimum_quantity (RisUseConfigMinimumQuantity)
minimum_quantity (RminimumQuantityK
#is_use_config_minimum_sale_quantity (RisUseConfigMinimumSaleQuantity2
minimum_sale_quantity	 (RminimumSaleQuantityK
#is_use_config_maximum_sale_quantity
 (RisUseConfigMaximumSaleQuantity2
maximum_sale_quantity (RmaximumSaleQuantity7
is_use_config_backorders (RisUseConfigBackorders

backorders (R
backordersK
#is_use_config_notify_stock_quantity (RisUseConfigNotifyStockQuantity2
notify_stock_quantity (RnotifyStockQuantityH
!is_use_config_quantity_increments (RisUseConfigQuantityIncrements/
quantity_increments (RquantityIncrementsU
(is_use_config_enable_quantity_increments (R#isUseConfigEnableQuantityIncrementsA
is_enable_quantity_increments (RisEnableQuantityIncrements:
is_use_config_manage_stock (RisUseConfigManageStock&
is_manage_stock (RisManageStock@
low_stock_date (2.google.protobuf.TimestampRlowStockDate,
is_decimal_divided (RisDecimalDivided9
stock_status_changed_auto (RstockStatusChangedAuto!
warehouse_id (RwarehouseId%
warehouse_name (	RwarehouseName%
attribute_name (	RattributeName"�
ListStocksRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
pos_id (RposId
sku	 (	Rsku
value
 (	Rvalue"�
ListStocksResponse!
record_count (RrecordCount#
stocks (2.data.StockRstocks&
next_page_token (	RnextPageToken"�
ListAvailableCashRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
pos_id (RposId"�
ListAvailableCashResponse!
record_count (RrecordCount'
cash (2.data.AvailableCashRcash&
next_page_token (	RnextPageToken"�
AvailableCash
id (Rid
key (	Rkey
name (	Rname-
is_pos_required_pin (RisPosRequiredPinB
bank_account (2.core_functionality.BankAccountRbankAccount"n
CommandShortcut
id (Rid
pos_id (RposId
command (	Rcommand
shortcut (	Rshortcut"i
SaveCommandShortcutRequest
pos_id (RposId
command (	Rcommand
shortcut (	Rshortcut"E
DeleteCommandShortcutRequest
pos_id (RposId
id (Rid"�
ListCommandShortcutsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
pos_id (RposId"�
ListCommandShortcutsResponse!
record_count (RrecordCount/
records (2.data.CommandShortcutRrecords&
next_page_token (	RnextPageToken"�
Campaign
id (Rid
name (	Rname 
description (	Rdescription9

start_date (2.google.protobuf.TimestampR	startDate5
end_date (2.google.protobuf.TimestampRendDate"�
ListCampaignsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
pos_id (RposId"�
ListCampaignsResponse!
record_count (RrecordCount(
records (2.data.CampaignRrecords&
next_page_token (	RnextPageToken"�
CopyOrderRequest&
source_order_id (RsourceOrderId6
sales_representative_id (RsalesRepresentativeId
pos_id (RposId"R
GetOpenRMARequest&
source_order_id (RsourceOrderId
pos_id (RposId"�
CreateRMARequest&
source_order_id (RsourceOrderId6
sales_representative_id (RsalesRepresentativeId
pos_id (RposId:
is_create_lines_from_order (RisCreateLinesFromOrder"9
DeleteRMARequest
id (Rid
pos_id (RposId"T
DeleteRMALineRequest
id (Rid
pos_id (RposId
rma_id (RrmaId"�
UpdateRMALineRequest
id (Rid 
description (	Rdescription
quantity (	Rquantity
pos_id (RposId
rma_id (RrmaId"�
CreateRMALineRequest
rma_id (RrmaId/
source_order_line_id (RsourceOrderLineId 
description (	Rdescription
quantity (	Rquantity
pos_id (RposId"�
ListRMALinesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
pos_id (RposId
rma_id	 (RrmaId"�
ListRMALinesResponse!
record_count (RrecordCount*
	rma_lines (2.data.RMALineRrmaLines&
next_page_token (	RnextPageToken"�
ProcessRMARequest
rma_id (RrmaId 
description (	Rdescription'
document_action (	RdocumentAction
pos_id (RposId"�
CreateOrderFromRMARequest"
source_rma_id (RsourceRmaId6
sales_representative_id (RsalesRepresentativeId
pos_id (RposId"�
RMA
id (Rid
document_no (	R
documentNoE
document_type (2 .core_functionality.DocumentTypeRdocumentTypeZ
sales_representative (2'.core_functionality.SalesRepresentativeRsalesRepresentative=
document_status (2.data.DocumentStatusRdocumentStatus<

price_list (2.core_functionality.PriceListR	priceList;
	warehouse (2.core_functionality.WarehouseR	warehouse
total_lines (	R
totalLines
grand_total	 (	R
grandTotal

tax_amount
 (	R	taxAmount'
discount_amount (	RdiscountAmount=
date_ordered (2.google.protobuf.TimestampRdateOrdered*
customer (2.data.CustomerRcustomer!
is_delivered (RisDelivered'
order_reference (	RorderReference 
description (	Rdescription*
campaign (2.data.CampaignRcampaign2
display_currency_rate (	RdisplayCurrencyRate
open_amount (	R
openAmount%
payment_amount (	RpaymentAmount#
refund_amount (	RrefundAmount#
charge_amount (	RchargeAmount#
credit_amount (	RcreditAmount&
source_order_id (RsourceOrderId"�

RMALine
id (Rid5
product (2.core_functionality.ProductRproduct2
charge (2.core_functionality.ChargeRcharge)
line_description (	RlineDescription 
description (	Rdescription;
	warehouse (2.core_functionality.WarehouseR	warehouse
quantity (	Rquantity)
quantity_ordered (	RquantityOrdered-
available_quantity	 (	RavailableQuantity
price
 (	Rprice$
price_with_tax (	RpriceWithTax

price_base (	R	priceBase-
price_base_with_tax (	RpriceBaseWithTax

price_list (	R	priceList-
price_list_with_tax (	RpriceListWithTax#
discount_rate (	RdiscountRate'
discount_amount (	RdiscountAmount

tax_amount (	R	taxAmount&
base_tax_amount (	RbaseTaxAmount&
list_tax_amount (	RlistTaxAmount6
tax_rate (2.core_functionality.TaxRateRtaxRate2
total_discount_amount (	RtotalDiscountAmount(
total_tax_amount (	RtotalTaxAmount*
total_base_amount (	RtotalBaseAmount:
total_base_amount_with_tax (	RtotalBaseAmountWithTax!
total_amount (	RtotalAmount1
total_amount_with_tax (	RtotalAmountWithTax
line (Rline7
uom (2%.core_functionality.ProductConversionRuomF
product_uom (2%.core_functionality.ProductConversionR
productUom/
source_order_line_id (RsourceOrderLineId"�

CreditMemo
id (Rid
document_no (	R
documentNo 
description (	Rdescription?
document_date (2.google.protobuf.TimestampRdocumentDate
amount (	Ramount
open_amount (	R
openAmount8
currency (2.core_functionality.CurrencyRcurrency"�
ListCustomerCreditsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
pos_id (RposId
customer_id	 (R
customerId(
document_type_id
 (RdocumentTypeId"�
ListCustomerCreditsResponse!
record_count (RrecordCount*
records (2.data.CreditMemoRrecords&
next_page_token (	RnextPageToken2�R
Storeh
GetPointOfSales.data.PointOfSalesRequest.data.PointOfSales"&��� /point-of-sales/terminals/{id}t
ListPointOfSales.data.ListPointOfSalesRequest.data.ListPointOfSalesResponse"!���/point-of-sales/terminals�
GetProductPrice.data.GetProductPriceRequest .core_functionality.ProductPrice"�����6/point-of-sales/{pos_id}/product-prices/{search_value}Z31/point-of-sales/{pos_id}/product-prices/upc/{upc}Z31/point-of-sales/{pos_id}/product-prices/sku/{sku}Z75/point-of-sales/{pos_id}/product-prices/value/{value}Z53/point-of-sales/{pos_id}/product-prices/name/{name}�
ListProductPrice.data.ListProductPriceRequest.data.ListProductPriceResponse"/���)'/point-of-sales/{pos_id}/product-prices`
CreateOrder.data.CreateOrderRequest.data.Order"*���$"/point-of-sales/{pos_id}/orders:*\
GetOrder.data.GetOrderRequest.data.Order",���&$/point-of-sales/{pos_id}/orders/{id}h

ListOrders.data.ListOrdersRequest.data.ListOrdersResponse"'���!/point-of-sales/{pos_id}/orderse
UpdateOrder.data.UpdateOrderRequest.data.Order"/���)$/point-of-sales/{pos_id}/orders/{id}:*o
ReleaseOrder.data.ReleaseOrderRequest.data.Order"7���1,/point-of-sales/{pos_id}/orders/{id}/release:*f
	HoldOrder.data.HoldOrderRequest.data.Order"4���.)/point-of-sales/{pos_id}/orders/{id}/hold:*m
DeleteOrder.data.DeleteOrderRequest.google.protobuf.Empty",���&*$/point-of-sales/{pos_id}/orders/{id}}
CreateOrderLine.data.CreateOrderLineRequest.data.OrderLine";���5"0/point-of-sales/{pos_id}/orders/{order_id}/lines:*�
ListOrderLines.data.ListOrderLinesRequest.data.ListOrderLinesResponse"8���20/point-of-sales/{pos_id}/orders/{order_id}/lines�
UpdateOrderLine.data.UpdateOrderLineRequest.data.OrderLine"@���:5/point-of-sales/{pos_id}/orders/{order_id}/lines/{id}:*�
DeleteOrderLine.data.DeleteOrderLineRequest.google.protobuf.Empty"=���7*5/point-of-sales/{pos_id}/orders/{order_id}/lines/{id}h
GetKeyLayout.data.GetKeyLayoutRequest.data.KeyLayout",���&$/point-of-sales/{pos_id}/key-layoutsh
CreatePayment.data.CreatePaymentRequest.data.Payment",���&"!/point-of-sales/{pos_id}/payments:*m
UpdatePayment.data.UpdatePaymentRequest.data.Payment"1���+&/point-of-sales/{pos_id}/payments/{id}:*s
DeletePayment.data.DeletePaymentRequest.google.protobuf.Empty".���(*&/point-of-sales/{pos_id}/payments/{id}p
ListPayments.data.ListPaymentsRequest.data.ListPaymentsResponse")���#!/point-of-sales/{pos_id}/paymentso
ProcessOrder.data.ProcessOrderRequest.data.Order"7���1,/point-of-sales/{pos_id}/orders/{id}/process:*q
ValidatePIN.data.ValidatePINRequest.google.protobuf.Empty"0���*"%/point-of-sales/{pos_id}/validate-pin:*�
ListAvailableWarehouses$.data.ListAvailableWarehousesRequest%.data.ListAvailableWarehousesResponse"+���%#/point-of-sales/{pos_id}/warehouses�
ListAvailablePaymentMethods(.data.ListAvailablePaymentMethodsRequest).data.ListAvailablePaymentMethodsResponse"0���*(/point-of-sales/{pos_id}/payment-methods�
ListAvailablePriceList#.data.ListAvailablePriceListRequest$.data.ListAvailablePriceListResponse",���&$/point-of-sales/{pos_id}/price-lists�
ListAvailableCurrencies$.data.ListAvailableCurrenciesRequest%.data.ListAvailableCurrenciesResponse"+���%#/point-of-sales/{pos_id}/currencies�
ListAvailableDocumentTypes'.data.ListAvailableDocumentTypesRequest(.data.ListAvailableDocumentTypesResponse"/���)'/point-of-sales/{pos_id}/document-types�
ListAvailableDiscounts#.data.ListAvailableDiscountsRequest$.data.ListAvailableDiscountsResponse"*���$"/point-of-sales/{pos_id}/discounts�
ListAvailableSellers!.data.ListAvailableSellersRequest".data.ListAvailableSellersResponse"(���" /point-of-sales/{pos_id}/sellersc
CreateCustomer.data.CreateCustomerRequest.data.Customer"$���"/point-of-sales/customers:*�
GetCustomer.data.GetCustomerRequest.data.Customer"U���O(/point-of-sales/customers/{search_value}Z#!/point-of-sales/customers/id/{id}k
ListCustomers.data.ListCustomersRequest.data.ListCustomersResponse"!���/point-of-sales/customersh
UpdateCustomer.data.UpdateCustomerRequest.data.Customer")���#/point-of-sales/customers/{id}:*�
GetAvailableRefund.data.GetAvailableRefundRequest.data.AvailableRefund"2���,*/point-of-sales/{pos_id}/available-refundst
PrintTicket.data.PrintTicketRequest.data.PrintTicketResponse"0���*"%/point-of-sales/{pos_id}/print-ticket:*x
PrintPreview.data.PrintPreviewRequest.data.PrintPreviewResponse"1���+"&/point-of-sales/{pos_id}/print-preview:*d
	ListBanks.data.ListBanksRequest.data.ListBanksResponse"&��� /point-of-sales/{pos_id}/banksX
GetBank.data.GetBankRequest
.data.Bank"+���%#/point-of-sales/{pos_id}/banks/{id}�
ListBankAccounts.data.ListBankAccountsRequest.data.ListBankAccountsResponse">���86/point-of-sales/{pos_id}/banks/{bank_id}/bank-accounts�
GetBankAccount.data.GetBankAccountRequest
.data.Bank"x���r;/point-of-sales/{pos_id}/banks/{bank_id}/bank-accounts/{id}Z31/point-of-sales/{pos_id}/banks/bank-accounts/{id}�
CreateCustomerBankAccount&.data.CreateCustomerBankAccountRequest.data.CustomerBankAccount"I���C">/point-of-sales/{pos_id}/customers/{customer_id}/bank-accounts:*�
UpdateCustomerBankAccount&.data.UpdateCustomerBankAccountRequest.data.CustomerBankAccount"N���HC/point-of-sales/{pos_id}/customers/{customer_id}/bank-accounts/{id}:*�
GetCustomerBankAccount#.data.GetCustomerBankAccountRequest.data.CustomerBankAccount"K���EC/point-of-sales/{pos_id}/customers/{customer_id}/bank-accounts/{id}�
DeleteCustomerBankAccount&.data.DeleteCustomerBankAccountRequest.google.protobuf.Empty"K���E*C/point-of-sales/{pos_id}/customers/{customer_id}/bank-accounts/{id}�
ListCustomerBankAccounts%.data.ListCustomerBankAccountsRequest&.data.ListCustomerBankAccountsResponse"F���@>/point-of-sales/{pos_id}/customers/{customer_id}/bank-accountsl
CreateShipment.data.CreateShipmentRequest.data.Shipment"-���'""/point-of-sales/{pos_id}/shipments:*�
PrintShipmentPreview!.data.PrintShipmentPreviewRequest".data.PrintShipmentPreviewResponse"I���C">/point-of-sales/{pos_id}/shipments/{shipment_id}/print-preview:*q
DeleteShipment.data.DeleteShipmentRequest.google.protobuf.Empty"*���$*"/point-of-sales/{pos_id}/shipments�
CreateShipmentLine.data.CreateShipmentLineRequest.data.ShipmentLine"A���;"6/point-of-sales/{pos_id}/shipments/{shipment_id}/lines:*�
DeleteShipmentLine.data.DeleteShipmentLineRequest.google.protobuf.Empty"C���=*;/point-of-sales/{pos_id}/shipments/{shipment_id}/lines/{id}�
UpdateShipmentLine.data.UpdateShipmentLineRequest.data.ShipmentLine"F���@;/point-of-sales/{pos_id}/shipments/{shipment_id}/lines/{id}:*�
ListShipmentLines.data.ListShipmentLinesRequest.data.ListShipmentLinesResponse">���86/point-of-sales/{pos_id}/shipments/{shipment_id}/lines{
ProcessShipment.data.ProcessShipmentRequest.data.Shipment":���4//point-of-sales/{pos_id}/shipments/{id}/process:*o
ReverseSales.data.ReverseSalesRequest.data.Order"7���1,/point-of-sales/{pos_id}/orders/{id}/reverse:*�
ProcessCashOpening.data.CashOpeningRequest.google.protobuf.Empty"8���2-/point-of-sales/{pos_id}/cash/process-opening:*�
ProcessCashWithdrawal.data.CashWithdrawalRequest.google.protobuf.Empty"2���,'/point-of-sales/cash/process-withdrawal:*x
ProcessCashClosing.data.CashClosingRequest.data.CashClosing"5���/*/point-of-sales/cash/closings/{id}/process:*|
ListCashMovements.data.ListCashMovementsRequest.data.ListCashMovementsResponse"&��� /point-of-sales/cash/movements�
ListCashSummaryMovements%.data.ListCashSummaryMovementsRequest&.data.ListCashSummaryMovementsResponse".���(&/point-of-sales/cash/summary-movements�
AllocateSeller.data.AllocateSellerRequest.google.protobuf.Empty"=���72/point-of-sales/terminals/{pos_id}/allocate-seller:*�
DeallocateSeller.data.DeallocateSellerRequest.google.protobuf.Empty"?���94/point-of-sales/terminals/{pos_id}/deallocate-seller:*�
CreatePaymentReference#.data.CreatePaymentReferenceRequest.data.PaymentReference"7���1",/point-of-sales/orders/{order_id}/references:*�
DeletePaymentReference#.data.DeletePaymentReferenceRequest.google.protobuf.Empty"9���3*1/point-of-sales/orders/{order_id}/references/{id}�
ListPaymentReferences".data.ListPaymentReferencesRequest#.data.ListPaymentReferencesResponse""���/point-of-sales/referencesr

ListStocks.data.ListStocksRequest.data.ListStocksResponse"1���+)/point-of-sales/terminals/{pos_id}/stocks�
ListAvailableCash.data.ListAvailableCashRequest.data.ListAvailableCashResponse"0���*(/point-of-sales/terminals/{pos_id}/cashs�
SaveCommandShortcut .data.SaveCommandShortcutRequest.data.CommandShortcut"7���1",/point-of-sales/terminals/{pos_id}/shortcuts:*�
ListCommandShortcuts!.data.ListCommandShortcutsRequest".data.ListCommandShortcutsResponse"4���.,/point-of-sales/terminals/{pos_id}/shortcuts�
DeleteCommandShortcut".data.DeleteCommandShortcutRequest.google.protobuf.Empty"9���3*1/point-of-sales/terminals/{pos_id}/shortcuts/{id}~
ListCampaigns.data.ListCampaignsRequest.data.ListCampaignsResponse"4���.,/point-of-sales/terminals/{pos_id}/campaignsj
	CopyOrder.data.CopyOrderRequest.data.Order"8���2"-/point-of-sales/orders/{source_order_id}/copy:*R
	CreateRMA.data.CreateRMARequest	.data.RMA""���"/point-of-sales/returns:*a
	DeleteRMA.data.DeleteRMARequest.google.protobuf.Empty"$���*/point-of-sales/returns/{id}m
CreateRMALine.data.CreateRMALineRequest.data.RMALine"1���+"&/point-of-sales/returns/{rma_id}/lines:*x
DeleteRMALine.data.DeleteRMALineRequest.google.protobuf.Empty"3���-*+/point-of-sales/returns/{rma_id}/lines/{id}r
UpdateRMALine.data.UpdateRMALineRequest.data.RMALine"6���0+/point-of-sales/returns/{rma_id}/lines/{id}:*u
ListRMALines.data.ListRMALinesRequest.data.ListRMALinesResponse".���(&/point-of-sales/returns/{rma_id}/linese

ProcessRMA.data.ProcessRMARequest	.data.RMA"3���-(/point-of-sales/returns/{rma_id}/process:*�
CreateOrderFromRMA.data.CreateOrderFromRMARequest.data.Order"?���9"4/point-of-sales/returns/{source_rma_id}/create-order:*�
ListCustomerCredits .data.ListCustomerCreditsRequest!.data.ListCustomerCreditsResponse"@���:8/point-of-sales/{pos_id}/customers/{customer_id}/creditsB+
org.spin.backend.grpc.posBADempierePOSPJ��
 �
�	
 �	***********************************************************************************
 Copyright (C) 2012-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Yamel Senih ysenih@erpya.com                                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 2
	
 2

 -
	
 -
	
  %
	
 &
	
 )
	
 &
	
 
	
 "
	
 
	
 
&
! 2 Base URL
 /point-of-sales/

:
 $ �-	POS Service used for ADempiere integration 



 $
"
  &(		Get POS Definition


  &

  &/

  &:F

  'U

	  �ʼ"'U
#
 *,		List Point of Sales


 *

 *4

 *?W

 +P

	 �ʼ"+P
8
 .>	*	Get Product Price from Code / UPC / Name


 .

 .2

 .=\

 /=

	 �ʼ"/=
"
 @D		List Product Price


 @

 @4

 @?W

 AC

	 �ʼ"AC

 GL		Order


 G

 G*

 G5:

 HK

	 �ʼ"HK

 MO	

 M

 M$

 M/4

 N[

	 �ʼ"N[

 PR	

 P

 P(

 P3E

 QV

	 �ʼ"QV

 SX	

 S

 S*

 S5:

 TW

	 �ʼ"TW

 Y^	

 Y

 Y,

 Y7<

 Z]

	 �ʼ"Z]

 	_d	

 	_

 	_&

 	_16

 	`c

	 	�ʼ"`c

 
eg	

 
e

 
e*

 
e5J

 
f^

	 
�ʼ"f^

 jo		Order Line


 j

 j2

 j=F

 kn

	 �ʼ"kn

 pr	

 p

 p0

 p;Q

 qg

	 �ʼ"qg

 sx	

 s

 s2

 s=F

 tw

	 �ʼ"tw

 y{	

 y

 y2

 y=R

 zo

	 �ʼ"zo
!
 ~�		Get a Key Layout


 ~

 ~,

 ~7@

 [

	 �ʼ"[
*
 ��		Payments
	Create Payment


 �

 �.

 �9@

 ��

	 �ʼ"��
 
 ��		Update Payment


 �

 �.

 �9@

 ��

	 �ʼ"��
 
 ��		Delete Payment


 �

 �.

 �9N

 �`

	 �ʼ"�`

 ��		List Payments


 �

 �,

 �7K

 �X

	 �ʼ"�X

 ��		Process Order


 �

 �,

 �7<

 ��

	 �ʼ"��

 ��		Validate PIN


 �

 �*

 �5J

 ��

	 �ʼ"��
.
 ��		List of Available Warehouses


 �#

 �$B

 �Ml

 �Z

	 �ʼ"�Z
0
 ��	 	List of Available Tender Types


 �'

 �(J

 �Ux

 �_

	 �ʼ"�_
.
 ��		List of Available Price List


 �"

 �#@

 �Ki

 �[

	 �ʼ"�[
.
 ��		List of Available Currencies


 �#

 �$B

 �Ml

 �Z

	 �ʼ"�Z
2
 ��	"	List of Available Document Types


 �&

 �'H

 �Su

 �^

	 �ʼ"�^
-
 ��		List of Available Discounts


 �"

 �#@

 �Ki

 �Y

	 �ʼ"�Y
+
 ��		List of Available Sellers


 � 

 �!<

 �Gc

 �W

	 �ʼ"�W

 ��	
	Customer


 �

 �0

 �;C

 ��

	 �ʼ"��

 ��	

 �

 �*

 �5=

 ��

	 �ʼ"��

 ��	

 �

 �.

 �9N

 �P

	 �ʼ"�P

  ��	

  �

  �0

  �;C

  ��

	  �ʼ"��
"
 !��		Get Daily Refund


 !�

 !�8

 !�CR

 !�a

	 !�ʼ"�a

 "��		Print Ticket


 "�

 "�*

 "�5H

 "��

	 "�ʼ"��

 #��		Print Preview


 #�

 #�,

 #�7K

 #��

	 #�ʼ"��

 $��	 Bank


 $�

 $�&

 $�1B

 $�U

	 $�ʼ"�U

 %��	

 %�

 %�"

 %�-1

 %�Z

	 %�ʼ"�Z

 &��	

 &�

 &�4

 &�?W

 &�m

	 &�ʼ"�m

 '��	

 '�

 '�0

 '�;?

 '��

	 '�ʼ"��
)
 (��		Create Customer Account


 (�%

 (�&F

 (�Qd

 (��

	 (�ʼ"��
)
 )��		Update Customer Account


 )�%

 )�&F

 )�Qd

 )��

	 )�ʼ"��
&
 *��		Get Customer Account


 *�"

 *�#@

 *�K^

 *�z

	 *�ʼ"�z
)
 +��		Delete Customer Account


 +�%

 +�&F

 +�Qf

 +�}

	 +�ʼ"�}
(
 ,��		List Customer Accounts


 ,�$

 ,�%D

 ,�Oo

 ,�u

	 ,�ʼ"�u
+
 -��		shipment
	Create Shipment


 -�

 -�0

 -�;C

 -��

	 -�ʼ"��
,
 .��		Print Preview for Shipment


 .� 

 .�!<

 .�Gc

 .��

	 .�ʼ"��
!
 /��		Delete Shipment


 /�

 /�0

 /�;P

 /�\

	 /�ʼ"�\
&
 0��		Create Shipment Line


 0�

 0�8

 0�CO

 0��

	 0�ʼ"��
&
 1��		Delete Shipment Line


 1�

 1�8

 1�CX

 1�u

	 1�ʼ"�u
#
 2��		Update Order Line


 2�

 2�8

 2�CO

 2��

	 2�ʼ"��
$
 3��		List Shipment Line


 3�

 3�6

 3�AZ

 3�m

	 3�ʼ"�m
"
 4��		Process Shipment


 4�

 4�2

 4�=E

 4��

	 4�ʼ"��
9
 5��	)	Return Order
	Reverse Sales Transaction


 5�

 5�,

 5�7<

 5��

	 5�ʼ"��
!
 6��		Cash Management


 6�

 6�1

 6�<Q

 6��

	 6�ʼ"��
!
 7��		Cash Withdrawal


 7�!

 7�"7

 7�BW

 7��

	 7�ʼ"��

 8��		Cash Closing


 8�

 8�1

 8�<G

 8��

	 8�ʼ"��
)
 9��		List all cash movements


 9�

 9�6

 9�AZ

 9�U

	 9�ʼ"�U
#
 :��		List Cash Summary


 :�$

 :�%D

 :�Oo

 :�]

	 :�ʼ"�]
!
 ;��		Allocate Seller


 ;�

 ;�0

 ;�;P

 ;��

	 ;�ʼ"��
!
 <��		Allocate Seller


 <�

 <�4

 <�?T

 <��

	 <�ʼ"��
)
 =��		Create Refund Reference


 =�"

 =�#@

 =�K[

 =��

	 =�ʼ"��
)
 >��		Delete Refund Reference


 >�"

 >�#@

 >�K`

 >�k

	 >�ʼ"�k
(
 ?��		List Refund References


 ?�!

 ?�">

 ?�If

 ?�Q

	 ?�ʼ"�Q
.
 @��	  List Stock: GET /api/stocks


 @�

 @�(

 @�3E

 @�`

	 @�ʼ"�`
'
 A��	  List Available Cash 


 A�

 A�6

 A�AZ

 A�_

	 A�ʼ"�_
"
 B��	 Command Shortcut


 B�

 B� :

 B�ET

 B��

	 B�ʼ"��

 C��	

 C� 

 C�!<

 C�Gc

 C�c

	 C�ʼ"�c

 D��	

 D�!

 D�">

 D�I^

 D�k

	 D�ʼ"�k

 E��	
 Campaign


 E�

 E�.

 E�9N

 E�c

	 E�ʼ"�c

 F��		Copy Order


 F�

 F�&

 F�16

 F��

	 F�ʼ"��
'
 G��		Return
	Create Return


 G�

 G�&

 G�14

 G��

	 G�ʼ"��

 H��		Delete Return


 H�

 H�&

 H�1F

 H�V

	 H�ʼ"�V
$
 I��		Create Return Line


 I�

 I�.

 I�9@

 I��

	 I�ʼ"��
$
 J��		Delete Return Line


 J�

 J�.

 J�9N

 J�e

	 J�ʼ"�e
!
 K��		Update RMA Line


 K�

 K�.

 K�9@

 K��

	 K�ʼ"��
"
 L��		List Return Line


 L�

 L�,

 L�7K

 L�]

	 L�ʼ"�]
 
 M��		Process Return


 M�

 M�(

 M�36

 M��

	 M�ʼ"��
'
 N��		Create Order from RMA


 N�

 N�8

 N�CH

 N��

	 N�ʼ"��
G
 O��	7	Credit Memo as Payment Method
	List Refund References


 O�

 O� :

 O�E`

 O�o

	 O�ʼ"�o
/
 � �!	Delete Refund reference request


 �%

  �

  �

  �

  �

 �

 �

 �

 �

 �

 �

 �

 �
'
� �	Allocate Seller Request


�

 �

 �

 �

 �

�*

�

�%

�()
)
� �	Deallocate Seller Request


�

 �

 �

 �

 �

�*

�

�%

�()
.
� � 	List allocated sellers for POS


�#

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�#

�

�

�!"

�

�

�

�
"
� �	Discounts Response


�$

 �

 �

 �

 �

�-

�

� 

�!(

�+,

�#

�

�

�!"
#
� � Available Discounts


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�%

�

� 

�#$

�

�

�

�

�

�

�

�

�

�

�

�
(
� �	Refund reference request


�%

 �

 �

 �

 �

�*

�

�%

�()

�

�

�

�

�!

�

�

� 

�

�

�

�

�3

�!

�".

�12

�$

�

�

�"#

�

�

�

�

�%

�

� 

�#$

	�%

	�

	�

	�"$


�<


�!


�"6


�9;

�,

�

�&

�)+

�

�

�

�

�

�

�

�

�

�

�

�

�(

�

�"

�%'
 
� �	Refund Reference


�

 �

 �

 �

 �

�

�

�

�

�H

�.

�/C

�FG

�

�

�

�

�

�

�

�

�3

�!

�".

�12

�$

�

�

�"#

�1

�#

�$,

�/0

�)

�

�$

�'(

	�<

	�!

	�"6

	�9;


�,


�


�&


�)+

�

�

�

�

�

�

�

�

�

�

�

�

�"

�

�

�!

�

�

�

�

�

�

�

�

�%

�

�

�"$

�(

�

�"

�%'
-
� �	List Refund Reference Request


�$

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

�

�

�

�

	�

	�

	�

	�
.
	� � 	List Refund Reference Response


	�%

	 �

	 �

	 �

	 �

	�9

	�

	�!

	�"4

	�78

	�#

	�

	�

	�!"


� �	Payment Summary



�


 �$


 �


 �


 �"#


�'


�


�"


�%&


�$


�


�


�"#


�1


�#


�$,


�/0


�


�


�


�


�


�


�


�
+
� �	List Cash Movements Request


� 

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

�&

�

�!

�$%

	�$

	�

	�

	�!#


�!


�


�


� 

�+

�

�%

�(*
#
� �	List cash movements


�!

 �

 �

 �

 �

�,

�

�

�'

�*+

�#

�

�

�!"

� header values


�

�

�
3
� �%	List Cash Summary Movements Request


�'

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

�#

�

�

�!"

	�!

	�

	�

	� 
+
� �	List cash summary movements


�(

 �

 �

 �

 �

�

�

�

�

�3

�

�

� .

�12

�#

�

�

�!"

� �	Cash closing


�

 �

 �

 �

 �

�

�

�

�

�:

�'

�(5

�89

�+

�

�&

�)*

�

�

�

�
/
� �!	Request for create cash closing


�

 �

 �

 �

 �

�

�

�

�

�&

�

�!

�$%

�

�

�

�
2
� �$	Request for create cash withdrawal


�

 �

 �

 �

 �

�&

�

�!

�$%

�

�

�

�
/
� �!	Request for create cash opening


�

 �

 �

 �

 �

�&

�

�!

�$%

�

�

�

�
8
� �* Request for create a Shipment from Order


�

 �

 �

 �

 �

�*

�

�%

�()

�

�

�

�

�,

�

�'

�*+
8
� �* Request for create a Shipment from Order


�

 �

 �

 �

 �

�

�

�

�
-
� � Request for delete a Shipment


�

 �

 �

 �

 �

�

�

�

�
2
� �$ Request for delete a Shipment Line


�!

 �

 �

 �

 �

�

�

�

�

�

�

�

�
2
� �$ Request for delete a Shipment Line


�!

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�
2
� �$ Request for Create a Shipment Line


�!

 �

 �

 �

 �

� 

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�
+
� �	List Shipment Lines Request


� 

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

�

�

�

�
#
� �	List shipment Lines


�!

 �

 �

 �

 �

�1

�

�

�,

�/0

�#

�

�

�!"

� �
 Shipment


�

 �

 �

 �

 �

�

�

�

�

�:

�'

�(5

�89

�H

�.

�/C

�FG

�+

�

�&

�)*

�3

�$

�%.

�12

�4

�!

�"/

�23

�

�

�

�
.
� �  Request for Process a Shipment


�

 �

 �

 �

 �

�

�

�

�

�#

�

�

�!"

�

�

�

�
7
� �) Request for Reverse a Sales Transaction


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�
#
� � Sales Shipment Line


�

 �

 �

 �

 �

� 

�

�

�

�/

�"

�#*

�-.

�-

�!

�"(

�+,

�

�

�

�

�

�

�

�

�%

�

� 

�#$

�

�

�

�

�5

�,

�-0

�34

	�>

	�,

	�-8

	�;=

� � Bank


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

 � �

 �

  �

  �

  �

  �

!� �

!�

! �

! �

! �

! �

!�

!�

!�

!�

!�*

!�

!�

!�%

!�()

!�+

!�

!�

!�&

!�)*

!�

!�

!�

!�

!�

!�

!�

!�

!� 

!�

!�

!�

!�

!�

!�

!�

"� �

"�

" �

" �

" �

" �

"�"

"�

"�

"�

"� !

"�#

"�

"�

"�!"

#� � Bank Account


#�

# �

# �

# �

# �

$� �

$�

$ �

$ �

$ �

$ �

$�

$�

$�

$�

$�*

$�

$�

$�%

$�()

$�+

$�

$�

$�&

$�)*

$�

$�

$�

$�

$�

$�

$�

$�

$� 

$�

$�

$�

$�

$�

$�

$�

$�

$�

$�

$�

%� �

%� 

% �

% �

% �

% �

%�<

%�

%�/

%�07

%�:;

%�#

%�

%�

%�!"
.
&� � 	List Customer Accounts Request


&�'

& �

& �

& �

& �

&�

&�

&�

&�

&�*

&�

&�

&�%

&�()

&�+

&�

&�

&�&

&�)*

&�

&�

&�

&�

&�

&�

&�

&�

&� 

&�

&�

&�

&�

&�

&�

&�

&�

&�

&�

&�

&	�

&	�

&	�

&	�
/
'� �!	List Customer Accounts Response


'�(

' �

' �

' �

' �

'�@

'�

'�$

'�%;

'�>?

'�#

'�

'�

'�!"
'
(� �	Create Customer Account


(�(

( �

( �

( �

( �

(�

(�

(�

(�

(�

(�

(�

(�

(�

(�

(�

(�

(�

(�

(�

(�

(�"

(�

(�

(� !

(�*

(�

(�%

(�()

(�

(�

(�

(�

(�

(�

(�

(�

(	�

(	�

(	�

(	�

(
�

(
�

(
�

(
�

(�&

(�

(� 

(�#%

(�

(�

(�

(�

(�

(�

(�

(�

(�%

(�

(�

(�"$

(�!

(�

(�

(� 

(�

(�

(�

(�

(�

(�

(�

(�

(�%

(�

(�

(�"$

(�

(�

(�

(�
'
)� �	Update Customer Account


)�(

) �+

) �

) �&

) �)*

)�

)�

)�

)�

)�

)�

)�

)�

)�

)�

)�

)�

)�"

)�

)�

)� !

)�*

)�

)�%

)�()

)�

)�

)�

)�

)�

)�

)�

)�

)�

)�

)�

)�

)	�

)	�

)	�

)	�

)
�&

)
�

)
� 

)
�#%

)�

)�

)�

)�

)�

)�

)�

)�

)�%

)�

)�

)�"$

)�!

)�

)�

)� 

)�

)�

)�

)�

)�

)�

)�

)�

)�%

)�

)�

)�"$

)�

)�

)�

)�

)�

)�

)�

)�
'
*� �	Delete Customer Account


*�(

* �+

* �

* �&

* �)*

*�

*�

*�

*�
$
+� �	Get Customer Account


+�%

+ �

+ �

+ �

+ �

+�

+�

+�

+�

+�

+�

+�

+�
 
,� �	Customer Account


,�

, �

, �

, �

, �

,�

,�

,�

,�

,�

,�

,�

,�

,�

,�

,�

,�

,�

,�

,�

,�

,�"

,�

,�

,� !

,�*

,�

,�%

,�()

,�

,�

,�

,�

,�

,�

,�

,�

,	�

,	�

,	�

,	�

,
�

,
�

,
�

,
�

,�&

,�

,� 

,�#%

,�

,�

,�

,�

,�

,�

,�

,�

,�%

,�

,�

,�"$

,�!

,�

,�

,� 

,�

,�

,�

,�

,�

,�

,�

,�

,�%

,�

,�

,�"$

,�

,�

,�

,�

-� �	Print Ticket


-�

- �

- �

- �

- �

-�

-�

-�

-�

-�

-�

-�

-�

-�

-�

-�

-�

-�

-�

-�

-�

-�

-�

-�

-�
$
.� �	Response after print


.�

. �

. �

. �

. �

.�

.�

.�

.�

.�

.�

.�

.�

.�

.�

.�

.�

.� 

.�

.�

.�

.�

.�

.�

.�

.�0

.�

.�+

.�./
$
/� �	Print Preview Ticket


/�

/ �

/ �

/ �

/ �

/�

/�

/�

/�

/�

/�

/�

/�
&
0� �	Response after preview


0�

0 �

0 �

0 �

0 �

0�#

0�

0�

0�!"
1
1� �#	Print Preview Ticket for Shipment


1�#

1 �

1 �

1 �

1 �

1�

1�

1�

1�

1�

1�

1�

1�
&
2� �	Response after preview


2�$

2 �

2 �

2 �

2 �

2�#

2�

2�

2�!"
$
3� �	Request Daily Refund


3�!

3 �

3 �

3 �

3 �

3�+

3�!

3�"&

3�)*

4� �	Daily Refund


4�

4 �

4 �

4 �

4 �

4�:

4�

4�!

4�"5

4�89
"
5� �	Tender Type Refund


5�

5 �

5 �

5 �

5 �

5�

5�

5�

5�
/
6� �!	Address information for request


6�

6 �

6 �

6 �

6 �

6�!

6�

6�

6� 

6�

6�

6�

6�

6�

6�

6�

6�

6�

6�

6�

6�

6�

6�

6�

6�

6�

6�

6�

6�

6�

6�

6�

6�

6�

6�

6�

6�

6	�+

6	�

6	�%

6	�(*

6
�

6
�

6
�

6
�

6�

6�

6�

6�

6� 

6�

6�

6�

6�%

6�

6�

6�"$

6�&

6�

6� 

6�#%

6�!

6�

6�

6� 

6�

6�

6�

6�

6�

6�

6�

6�

6�:

6�

6�4

6�79

6�

6�

6�

6�
+
7� � Request for create Customer


7�

7 �

7 �

7 �

7 �

7�

7�

7�

7�

7�

7�

7�

7�

7�

7�

7�

7�

7�

7�

7�

7�

7�

7�

7�

7�

7�

7�

7�

7�

7�,

7�

7�'

7�*+

7�

7�

7�

7�

7	�/
	Location


7	�

7	�

7	� )

7	�,.

7
�:

7
�

7
�4

7
�79
+
8� � Request for update Customer


8�

8 �

8 �

8 �

8 �

8�

8�

8�

8�

8�

8�

8�

8�

8�

8�

8�

8�

8�

8�

8�

8�

8�

8�

8�

8�

8�

8�

8�

8�

8�

8�

8�

8�

8�.
	Location


8�

8�

8� )

8�,-

8	�:

8	�

8	�4

8	�79

8
�

8
�

8
�

8
�
&
9� � Request Get a Customer


9�

9 �

9 �

9 �

9 �

9� 

9�

9�

9�

9�

9�

9�

9�

9�

9�

9�

9�

9� 

9�

9�

9�

9�

9�

9�

9�

9�

9�

9�

9�

9�

9�

9�

9�

9�

9�

9�

9�

:� �
 Customer


:�

: �

: �

: �

: �

:�

:�

:�

:�

:�

:�

:�

:�

:�

:�

:�

:�

:�

:�

:�

:�

:�

:�

:�

:�

:�

:�

:�

:�

:�

:�

:�

:�

:�'

:�

:�

:�"

:�%&

:	�:

:	�

:	�4

:	�79

;� �

;�

; �

; �

; �

; �

;�

;�

;�

;�

;�*

;�

;�

;�%

;�()

;�+

;�

;�

;�&

;�)*

;�

;�

;�

;�

;�

;�

;�

;�

;� 

;�

;�

;�

;�

;�

;�

;�

;�

;�

;�

;�

;	�!

;	�

;	�

;	� 

;
�

;
�

;
�

;
�

;� 

;�

;�

;�

;�

;�

;�

;�

;�

;�

;�

;�

<� �

<�

< �

< �

< �

< �

<�(

<�

<�

<�#

<�&'

<�#

<�

<�

<�!"

=� �		Address


=�

= �

= �

= �

= �

=�!
	Location


=�

=�

=� 

=�

=�

=�

=�

=�

=�

=�

=�

=�

=�

=�

=�

=�

=�

=�

=�

=�

=�

=�

=�

=�

=�

=�

=�

=�

=�

=�

=�

=	� 

=	�

=	�

=	�

=
�+

=
�

=
�%

=
�(*

=�!

=�

=�

=� 

=�

=�

=�

=�

=�&

=�

=� 

=�#%

=�%

=�

=�

=�"$

=�!

=�

=�

=� 

=�

=�

=�

=�

=�"

=�

=�

=�!

=� 

=�

=�

=�

=�

=�

=�

=�

=�:

=�

=�4

=�79

>� �	City


>�

> �

> �

> �

> �

>�

>�

>�

>�

?�	 �		Region


?�	

? �	

? �	

? �	

? �	

?�	

?�	

?�	

?�	
#
@�	 �	 Available Warehouse


@�	

@ �	

@ �	

@ �	

@ �	

@�	

@�	

@�	

@�	

@�	

@�	

@�	

@�	

@�	%

@�	

@�	 

@�	#$
%
A�	 �	 Available Tender Type


A�	

A �	

A �	

A �	

A �	

A�	

A�	

A�	

A�	

A�	

A�	

A�	

A�	

A�	-

A�	

A�	(

A�	+,

A�	%

A�	

A�	 

A�	#$

A�	&

A�	

A�	!

A�	$%

A�	+

A�	

A�	&

A�	)*

A�	*

A�	

A�	%

A�	()

A�	0

A�	

A�	+

A�	./

A	�	C

A	�	#

A	�	$=

A	�	@B

A
�	<

A
�	#

A
�	$6

A
�	9;

A�	'

A�	

A�	!

A�	$&

A�	*

A�	

A�	$

A�	')

A�	$

A�	

A�	

A�	!#

B�	 �	

B�	

B �	

B �	

B �	

B �	

B�	

B�	

B�	

B�	

B�	

B�	

B�	

B�	

B�	

B�	

B�	

B�	

B�	

B�	

B�	

B�	

B�	

B�	

B�	

B�	
,
C�	 �		List discount schema for POS


C�	%

C �	

C �	

C �	

C �	

C�	

C�	

C�	

C�	

C�	*

C�	

C�	

C�	%

C�	()

C�	+

C�	

C�	

C�	&

C�	)*

C�	

C�	

C�	

C�	

C�	

C�	

C�	

C�	

C�	 

C�	

C�	

C�	

C�	

C�	

C�	

C�	
"
D�	 �		Discounts Response


D�	&

D �	

D �	

D �	

D �	

D�	1

D�	

D�	"

D�	#,

D�	/0

D�	#

D�	

D�	

D�	!"
#
E�	 �	 Available Discounts


E�	

E �	

E �	

E �	

E �	

E�	

E�	

E�	

E�	

E�	

E�	

E�	

E�	

E�	%

E�	

E�	 

E�	#$
'
F�	 �	 Available Document Type


F�	

F �	

F �	

F �	

F �	

F�	

F�	

F�	

F�	

F�	

F�	

F�	

F�	

F�	%

F�	

F�	 

F�	#$
$
G�	 �	 Available Price List


G�	

G �	

G �	

G �	

G �	

G�	

G�	

G�	

G�	

G�	

G�	

G�	

G�	

G�	%

G�	

G�	 

G�	#$
'
H�	 �		List warehouses for POS


H�	&

H �	

H �	

H �	

H �	

H�	

H�	

H�	

H�	

H�	*

H�	

H�	

H�	%

H�	()

H�	+

H�	

H�	

H�	&

H�	)*

H�	

H�	

H�	

H�	

H�	

H�	

H�	

H�	

H�	 

H�	

H�	

H�	

H�	

H�	

H�	

H�	
+
I�	 �		List document types for POS


I�	)

I �	

I �	

I �	

I �	

I�	

I�	

I�	

I�	

I�	*

I�	

I�	

I�	%

I�	()

I�	+

I�	

I�	

I�	&

I�	)*

I�	

I�	

I�	

I�	

I�	

I�	

I�	

I�	

I�	 

I�	

I�	

I�	

I�	

I�	

I�	

I�	
)
J�	 �		List Available Warehouses


J�	'

J �	

J �	

J �	

J �	

J�	3

J�	

J�	#

J�	$.

J�	12

J�	#

J�	

J�	

J�	!"
)
K�	 �		List payment type for POS


K�	*

K �	

K �	

K �	

K �	

K�	

K�	

K�	

K�	

K�	*

K�	

K�	

K�	%

K�	()

K�	+

K�	

K�	

K�	&

K�	)*

K�	

K�	

K�	

K�	

K�	

K�	

K�	

K�	

K�	 

K�	

K�	

K�	

K�	

K�	

K�	

K�	
+
L�
 �
	List Available Tender Types


L�
+

L �


L �


L �


L �


L�
<

L�


L�
'

L�
(7

L�
:;

L�
#

L�


L�


L�
!"
-
M�
 �
	List Available Document Types


M�
*

M �


M �


M �


M �


M�
:

M�


M�
&

M�
'5

M�
89

M�
#

M�


M�


M�
!"
'
N�
 �
	List price list for POS


N�
%

N �


N �


N �


N �


N�


N�


N�


N�


N�
*

N�


N�


N�
%

N�
()

N�
+

N�


N�


N�
&

N�
)*

N�


N�


N�


N�


N�


N�


N�


N�


N�
 

N�


N�


N�


N�


N�


N�


N�

#
O�
 �
	Price List Response


O�
&

O �


O �


O �


O �


O�
3

O�


O�
#

O�
$.

O�
12

O�
#

O�


O�


O�
!"
'
P�
 �
	List warehouses for POS


P�
&

P �


P �


P �


P �


P�


P�


P�


P�


P�
*

P�


P�


P�
%

P�
()

P�
+

P�


P�


P�
&

P�
)*

P�


P�


P�


P�


P�


P�


P�


P�


P�
 

P�


P�


P�


P�


P�


P�


P�

#
Q�
 �
	Currencies Response


Q�
'

Q �


Q �


Q �


Q �


Q�
<

Q�


Q�
,

Q�
-7

Q�
:;

Q�
#

Q�


Q�


Q�
!"
!
R�
 �
	List POS Response


R�
 

R �


R �


R �


R �


R�
1

R�


R�


R�
,

R�
/0

R�
#

R�


R�


R�
!"
+
S�
 �
	List Product Price Response


S�
 

S �


S �


S �


S �


S�
D

S�


S�
0

S�
1?

S�
BC

S�
#

S�


S�


S�
!"
$
T�
 �
	List Orders Response


T�


T �


T �


T �


T �


T�
"

T�


T�


T�


T�
 !

T�
#

T�


T�


T�
!"
#
U�
 �
 List Orders Request


U�


U �


U �


U �


U �


U�


U�


U�


U�


U�
*

U�


U�


U�
%

U�
()

U�
+

U�


U�


U�
&

U�
)*

U�


U�


U�


U�


U�


U�


U�


U�


U�
 

U�


U�


U�


U�


U�


U�


U�


U�


U�


U�


U�


U	�
$

U	�


U	�


U	�
!#

U
�
'

U
�


U
�
!

U
�
$&

U�
 

U�


U�


U�


U�
 

U�


U�


U�


U�
%

U�


U�


U�
"$

U�
$

U�


U�


U�
!#

U�
'

U�


U�
!

U�
$&

U�
)

U�


U�
#

U�
&(

U�
*

U�


U�
$

U�
')

U�
#

U�


U�


U�
 "

U�


U�


U�


U�


U�


U�


U�


U�


U�


U�


U�


U�


U�
9

U�
!

U�
"3

U�
68

U�
7

U�
!

U�
"1

U�
46

U�
+

U�


U�
%

U�
(*
)
V�
 �
	List Order Lines Response


V�


V �


V �


V �


V �


V�
+

V�


V�


V�
&

V�
)*

V�
#

V�


V�


V�
!"
#
W�
 �
 List Orders Request


W�


W �


W �


W �


W �


W�


W�


W�


W�


W�
*

W�


W�


W�
%

W�
()

W�
+

W�


W�


W�
&

W�
)*

W�


W�


W�


W�


W�


W�


W�


W�


W�
 

W�


W�


W�


W�


W�


W�


W�


W�


W�


W�


W�

*
X�
 � List Product Price Request


X�


X �


X �


X �


X �


X�


X�


X�


X�


X�
*

X�


X�


X�
%

X�
()

X�+

X�

X�

X�&

X�)*

X�

X�

X�

X�

X�

X�

X�

X�

X� 

X�

X�

X�

X�

X�

X�

X�

X�&

X�

X�!

X�$%

X	�

X	�

X	�

X	�

X
�!

X
�

X
�

X
� 

X� 

X�

X�

X�
 
Y� � POS from user id


Y�

Y �

Y �

Y �

Y �

Y�

Y�

Y�

Y�

Y�*

Y�

Y�

Y�%

Y�()

Y�+

Y�

Y�

Y�&

Y�)*

Y�

Y�

Y�

Y�

Y�

Y�

Y�

Y�

Y� 

Y�

Y�

Y�
&
Z� � Point of Sales request


Z�

Z �

Z �

Z �

Z �
)
[� � Point of Sales definition


[�

[ �

[ �

[ �

[ �

[�

[�

[�

[�

[�

[�

[�

[�

[�

[�

[�

[�

[�!

[�

[�

[� 

[�%

[�

[� 

[�#$

[�!

[�

[�

[� 

[�

[�

[�

[�

[�:

[�'

[�(5

[�89

[	�>

[	�&

[	�'8

[	�;=

[
�G

[
�&

[
�'A

[
�DF

[�I

[�.

[�/C

[�FH

[�(

[�

[�"

[�%'

[�5

[�$

[�%/

[�24

[�4

[�$

[�%.

[�13

[�:

[�#

[�$4

[�79

[�&

[�

[� 

[�#%

[�!

[�

[�

[� 

[�,

[�

[�&

[�)+

[�)

[�

[�#

[�&(

[�*

[�

[�$

[�')

[�)

[�

[�#

[�&(

[�-

[�

[�'

[�*,

[�(

[�

[�"

[�%'

[�&

[�

[� 

[�#%

[�+

[�

[�%

[�(*

[�1

[�

[�+

[�.0

[�C

[�#

[�$=

[�@B

[�B

[�'

[�(<

[�?A

[�'

[�

[�!

[�$&

[�-

[�

[�'

[�*,

[�0

[�

[�*

[�-/

[ �-

[ �

[ �'

[ �*,

[!�/

[!�

[!�)

[!�,.

["�,

["�

["�&

["�)+

[#�+

[#�

[#�%

[#�(*

[$�/

[$�

[$�)

[$�,.

[%�)

[%�

[%�#

[%�&(

[&�)

[&�

[&�#

[&�&(

['�,

['�

['�&

['�)+

[(�+

[(�

[(�%

[(�(*

[)�,

[)�

[)�&

[)�)+

[*�+

[*�

[*�%

[*�(*

[+�-

[+�

[+�'

[+�*,

[,�!

[,�

[,�

[,� 

[-�,

[-�

[-�&

[-�)+

[.�.

[.�

[.�(

[.�+-

[/�2

[/�

[/�,

[/�/1

[0�,

[0�

[0�&

[0�)+

[1�0

[1�

[1�*

[1�-/

[2�3

[2�

[2�-

[2�02

[3�*

[3�

[3�$

[3�')

[4�-

[4�

[4�'

[4�*,
*
\� � Request for create a order


\�

\ �

\ �

\ �

\ �

\�

\�

\�

\�

\�#

\�

\�

\�!"

\� 

\�

\�

\�

\�

\�

\�

\�

\�*

\�

\�%

\�()

\�

\�

\�

\�
+
]� � Request for release a order


]�

] �

] �

] �

] �

]�*

]�

]�%

]�()

]�

]�

]�

]�
(
^� � Request for hold a order


^�

^ �

^ �

^ �

^ �

^�*

^�

^�%

^�()

^�

^�

^�

^�
+
_� � Request for process a order


_�

_ �

_ �

_ �

_ �

_�

_�

_�

_�

_�!

_�

_�

_� 

_� 

_�

_�

_�

_�3

_�

_�%

_�&.

_�12

`� �	Create Payment


`�

` �

` �

` �

` �

`�

`�

`�

`�

`�

`�

`�

`�

`�

`�

`�

`�

`� 

`�

`�

`�

`�

`�

`�

`�

`�

`�

`�

`�

`�3

`�!

`�".

`�12

`�$

`�

`�

`�"#

`	�

`	�

`	�

`	�

`
�%

`
�

`
�

`
�"$

`�<

`�!

`�"6

`�9;

`�

`�

`�

`�

`�

`�

`�

`�

`�'

`�

`�!

`�$&

`�-

`�

`�'

`�*,

`�,

`�

`�&

`�)+

`�(

`�

`�"

`�%'

a� �	Update Payment


a�

a �

a �

a �

a �

a�

a�

a�

a�

a� 

a�

a�

a�

a�

a�

a�

a�

a�

a�

a�

a�

a�3

a�!

a�".

a�12

a�$

a�

a�

a�"#

a�$

a�

a�

a�"#

a�;

a�!

a�"6

a�9:

a	�

a	�

a	�

a	�

a
�-

a
�

a
�'

a
�*,

a�(

a�

a�"

a�%'
,
b� � Request for delete a payment


b�

b �

b �

b �

b �

b�

b�

b�

b�
%
c� � List Payments Request


c�

c �

c �

c �

c �

c�

c�

c�

c�

c�*

c�

c�

c�%

c�()

c�+

c�

c�

c�&

c�)*

c�

c�

c�

c�

c�

c�

c�

c�

c� 

c�

c�

c�

c�

c�

c�

c�

c�

c�

c�

c�

c	�!

c	�

c	�

c	� 

c
�"

c
�

c
�

c
�!
$
d� � Validate PIN Request


d�

d �

d �

d �

d �

d�

d�

d�

d�

d�$

d�

d�

d�"#

d�$

d�

d�

d�"#

d�

d�

d�

d�
&
e� �	List Payments Response


e�

e �

e �

e �

e �

e�&

e�

e�

e�!

e�$%

e�#

e�

e�

e�!"

f� �		Payment


f�

f �

f �

f �

f �

f�

f�

f�

f�

f�D

f�.

f�/?

f�BC

f�+

f�

f�&

f�)*

f�

f�

f�

f�

f�

f�

f�

f�

f�

f�

f�

f�

f�

f�

f�

f�

f�

f�

f�

f�

f	�!

f	�

f	�

f	� 

f
� 

f
�

f
�

f
�

f�

f�

f�

f�

f�4

f�!

f�".

f�13

f�<

f�!

f�"6

f�9;

f�%

f�

f�

f�"$

f�2

f�#

f�$,

f�/1

f�

f�

f�

f�

f�

f�

f�

f�

f�%

f�

f�

f�"$

f�*

f�

f�$

f�')

f�9

f�&

f�'3

f�68

f�C

f�&

f�'=

f�@B

f�.

f�!

f�"(

f�+-

f�;

f�'

f�(5

f�8:

f�

f�

f�

f�

f�&

f�

f� 

f�#%

f�(

f�

f�"

f�%'
*
g� � Request for delete a order


g�

g �

g �

g �

g �

g�

g�

g�

g�
*
h� � Request for delete a order


h�

h �

h �

h �

h �

h�

h�

h�

h�

h�

h�

h�

h�
/
i� �! Request for create a order line


i�

i �

i �

i �

i �

i�

i�

i�

i�

i�

i�

i�

i�

i�

i�

i�

i�

i�

i�

i�

i�

i�

i�

i�

i�

i�!

i�

i�

i� 

i�

i�

i�

i�

i�

i�

i�

i�

i	�*

i	�

i	�$

i	�')
*
j� � Request for update a order


j�

j �

j �

j �

j �

j�

j�

j�

j�

j�

j�

j�

j�

j�#

j�

j�

j�!"

j� 

j�

j�

j�

j�

j�

j�

j�

j�

j�

j�

j�

j�

j�

j�

j�

j�!

j�

j�

j� 

j	�&

j	�

j	� 

j	�#%

j
�(

j
�

j
�"

j
�%'

j�+

j�

j�%

j�(*
/
k� �! Request for update a order line


k�

k �

k �

k �

k �

k�

k�

k�

k�

k�

k�

k�

k�

k�

k�

k�

k�

k�

k�

k�

k�

k�

k�

k�

k�

k�!

k�

k�

k� 

k�!

k�

k�

k� 

k�

k�

k�

k�

k	�

k	�

k	�

k	�
'
l� � Request for get a order


l�

l �

l �

l �

l �

l�

l�

l�

l�
,
m� � Request for get a key layout


m�

m � 

m �

m �

m �

m�

m�

m�

m�

n� � Sales Order


n�

n �

n �

n �

n �

n�

n�

n�

n�

n�:

n�'

n�(5

n�89

n�H

n�.

n�/C

n�FG

n�+

n�

n�&

n�)*

n�4

n�$

n�%/

n�23

n�3

n�$

n�%.

n�12

n�

n�

n�

n�

n�

n�

n�

n�

n	�*

n	�

n	�$

n	�')

n
�

n
�

n
�

n
�

n�$

n�

n�

n�!#

n�4

n�!

n�".

n�13

n�

n�

n�

n�

n�

n�

n�

n�

n�$

n�

n�

n�!#

n� 

n�

n�

n�

n�

n�

n�

n�

n�*

n�

n�$

n�')

n� 

n�

n�

n�

n�#

n�

n�

n� "

n�"

n�

n�

n�!

n�"

n�

n�

n�!

n�"

n�

n�

n�!

n�!

n�

n�

n� 

n�

n�

n�

n�

n�#

n�

n�

n� "

n�

n�

n�

n�
 
o� � Sales Order Line


o�

o �

o �

o �

o �

o�

o�

o�

o�

o�/

o�"

o�#*

o�-.

o�-

o�!

o�"(

o�+,

o�$

o�

o�

o�"#

o�

o�

o�

o�

o�3

o�$

o�%.

o�12

o�

o�

o�

o�

o�$

o�

o�

o�"#

o	�'

o	�

o	�!

o	�$&

o
�

o
�

o
�

o
�

o�#

o�

o�

o� "

o�

o�

o�

o�

o�(

o�

o�"

o�%'

o�

o�

o�

o�

o�(

o�

o�"

o�%'

o�"

o�

o�

o�!

o�$

o�

o�

o�!#

o�

o�

o�

o�

o�$

o�

o�

o�!#

o�$

o�

o�

o�!#

o�1

o�"

o�#+

o�.0

o�*	Totals


o�

o�$

o�')

o�%

o�

o�

o�"$

o�&

o�

o� 

o�#%

o�/

o�

o�)

o�,.

o�!

o�

o�

o� 

o�+

o�

o�%

o�(*

o�*

o�

o�$

o�')

o�4

o�

o�.

o�13

o�

o�

o�

o�

o�6

o�,

o�-0

o�35

o �>

o �,

o �-8

o �;=

o!�A

o!�'

o!�(;

o!�>@

o"�&

o"�

o"� 

o"�#%
%
p� � Request Product Price


p�

p �

p �

p �

p �

p� 

p�

p�

p�

p�

p�

p�

p�

p�

p�

p�

p�

p�

p�

p�

p�

p�

p�

p�

p�

p�&

p�

p�!

p�$%

p�

p�

p�

p�

p�!

p�

p�

p� 

p	� 

p	�

p	�

p	�

q� � Layout for POS


q�

q �

q �

q �

q �

q�

q�

q�

q�

q�

q�

q�

q�

q�

q�

q�

q�

q�

q�

q�

q�

q�

q�

q�

q�

q�

q�

q�

q�

q�

q�

q�

q�

q�

r� � Key for layout


r�

r �

r �

r �

r �

r�

r�

r�

r�

r�

r�

r�

r�

r�$

r�

r�

r�"#

r�

r�

r�

r�

r�

r�

r�

r�

r�

r�

r�

r�

r�

r�

r�

r�

r�!

r�

r�

r� 

r	�

r	�

r	�

r	�

r
�B

r
�)

r
�*<

r
�?A

s� �	Stock


s�

s �

s �

s �

s �

s�

s�

s�

s�

s�

s�

s�

s�

s�%

s�

s� 

s�#$

s�6

s�

s�1

s�45

s�0

s�

s�+

s�./

s�$

s�

s�

s�"#

s�5

s�

s�0

s�34

s�)

s�

s�$

s�'(

s	�6

s	�

s	�0

s	�35

s
�*

s
�

s
�$

s
�')

s�+

s�

s�%

s�(*

s�

s�

s�

s�

s�6

s�

s�0

s�35

s�*

s�

s�$

s�')

s�4

s�

s�.

s�13

s�(

s�

s�"

s�%'

s�;

s�

s�5

s�8:

s�0

s�

s�*

s�-/

s�-

s�

s�'

s�*,

s�"

s�

s�

s�!

s�6

s�!

s�"0

s�35

s�%

s�

s�

s�"$

s�.

s�

s�(

s�+-

s� 

s�

s�

s�

s�#

s�

s�

s� "

s�#

s�

s�

s� "

t� �

t�

t �

t �

t �

t �

t�

t�

t�

t�

t�*

t�

t�

t�%

t�()

t�+

t�

t�

t�&

t�)*

t�

t�

t�

t�

t�

t�

t�

t�

t� 

t�

t�

t�

t�

t�

t�

t�

t�

t�

t�

t�

t	�

t	�

t	�

t	�

u� �	List of Stock


u�

u �

u �

u �

u �

u�"

u�

u�

u�

u� !

u�#

u�

u�

u�!"
*
v� �	List Cash Register for POS


v� 

v �

v �

v �

v �

v�

v�

v�

v�

v�*

v�

v�

v�%

v�()

v�+

v�

v�

v�&

v�)*

v�

v�

v�

v�

v�

v�

v�

v�

v� 

v�

v�

v�

v�

v�

v�

v�
)
w� �	List Available Warehouses


w�!

w �

w �

w �

w �

w�(

w�

w�

w�#

w�&'

w�#

w�

w�

w�!"
#
x� � Available Warehouse


x�

x �

x �

x �

x �

x�

x�

x�

x�

x�

x�

x�

x�

x�%

x�

x� 

x�#$

x�8

x�&

x�'3

x�67
!
y� � Mnemonic Commands


y�

y �

y �

y �

y �

y�

y�

y�

y�

y�

y�

y�

y�

y�

y�

y�

y�

z� �

z�"

z �

z �

z �

z �

z�

z�

z�

z�

z�

z�

z�

z�

{� �

{�$

{ �

{ �

{ �

{ �

{�

{�

{�

{�

|� �

|�#

| �

| �

| �

| �

|�

|�

|�

|�

|�*

|�

|�

|�%

|�()

|�+

|�

|�

|�&

|�)*

|�

|�

|�

|�

|�

|�

|�

|�

|� 

|�

|�

|�

|�

|�

|�

|�

}� �

}�$

} �

} �

} �

} �

}�-

}�

}� 

}�!(

}�+,

}�#

}�

}�

}�!"

~� �
 Campaign


~�

~ �

~ �

~ �

~ �

~�

~�

~�

~�

~�

~�

~�

~�

~�1

~�!

~�",

~�/0

~�/

~�!

~�"*

~�-.

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

�� �

��

� �

� �

� �

� �

��&

��

��

��!

��$%

��#

��

��

��!"
G
�� �8	Copy Order
 Request for Copy a Order from Source Order


��

� �"

� �

� �

� � !

��*

��

��%

��()

��

��

��

��
D
�� �% Request for get a Return from Order
2	Return Order


��

� �"

� �

� �

� � !

��

��

��

��
7
�� �( Request for create a Return from Order


��

� �"

� �

� �

� � !

��*

��

��%

��()

��

��

��

��

��,

��

��'

��*+
,
�� � Request for delete a Return


��

� �

� �

� �

� �

��

��

��

��
1
�� �" Request for delete a Return Line


��

� �

� �

� �

� �

��

��

��

��

��

��

��

��
1
�� �" Request for delete a Return Line


��

� �

� �

� �

� �

��

��

��

��

��

��

��

��

��

��

��

��

��

��

��

��
1
�� �" Request for Create a Return Line


��

� �

� �

� �

� �

��'

��

��"

��%&

��

��

��

��

��

��

��

��

��

��

��

��
*
�� �	List Return Lines Request


��

� �

� �

� �

� �

��

��

��

��

��*

��

��

��%

��()

��+

��

��

��&

��)*

��

��

��

��

��

��

��

��

�� 

��

��

��

��

��

��

��

��

��

��

��

�� �	List RMA Lines


��

� �

� �

� �

� �

��'

��

��

��"

��%&

��#

��

��

��!"
-
�� � Request for Process a Return


��

� �

� �

� �

� �

��

��

��

��

��#

��

��

��!"

��

��

��

��
@
�� �1 Request for Create a new Sales Order from a RMA


��!

� � 

� �

� �

� �

��*

��

��%

��()

��

��

��

��

�� � Return Order


��

� �

� �

� �

� �

��

��

��

��

��:

��'

��(5

��89

��H

��.

��/C

��FG

��+

��

��&

��)*

��4

��$

��%/

��23

��3

��$

��%.

��12

��

��

��

��

��

��

��

��

�	�

�	�

�	�

�	�

�
�$

�
�

�
�

�
�!#

��4

��!

��".

��13

��

��

��

��

��

��

��

��

��$

��

��

��!#

�� 

��

��

��

��

��

��

��

��*

��

��$

��')

�� 

��

��

��

��#

��

��

�� "

��"

��

��

��!

��"

��

��

��!

��"

��

��

��!

��#

��

��

�� "
"
�� � Return Order Line


��

� �

� �

� �

� �

��/

��"

��#*

��-.

��-

��!

��"(

��+,

��$

��

��

��"#

��

��

��

��

��3

��$

��%.

��12

��

��

��

��

��$

��

��

��"#

��&

��

��!

��$%

�	�

�	�

�	�

�	�

�
�#

�
�

�
�

�
� "

��

��

��

��

��(

��

��"

��%'

��

��

��

��

��(

��

��"

��%'

��"

��

��

��!

��$

��

��

��!#

��

��

��

��

��$

��

��

��!#

��$

��

��

��!#

��1

��"

��#+

��.0

��*	Totals


��

��$

��')

��%

��

��

��"$

��&

��

�� 

��#%

��/

��

��)

��,.

��!

��

��

�� 

��*

��

��$

��')

��

��

��

��

��6

��,

��-0

��35

��>

��,

��-8

��;=

��(

��

��"

��%'
%
�� � Customer Credit Memo


��

� �

� �

� �

� �

��

��

��

��

��

��

��

��

��4

��!

��"/

��23

��

��

��

��

��

��

��

��

��1

��#

��$,

��/0

�� �

��"

� �

� �

� �

� �

��

��

��

��

��*

��

��

��%

��()

��+

��

��

��&

��)*

��

��

��

��

��

��

��

��

�� 

��

��

��

��

��

��

��

��

��

��

��

�	�$

�	�

�	�

�	�!#

�� �

��#

� �

� �

� �

� �

��(

��

��

��#

��&'

��#

��

��

��!"bproto3
�/
preference_management.protopreference_managementgoogle/api/annotations.protogoogle/protobuf/empty.proto"�
GetPreferenceRequest!
container_id (RcontainerId
column_name (	R
columnName-
is_for_current_user (RisForCurrentUser1
is_for_current_client (RisForCurrentClient=
is_for_current_organization (RisForCurrentOrganization7
is_for_current_container (RisForCurrentContainer9
type (2%.preference_management.PreferenceTypeRtype"�
SetPreferenceRequest!
container_id (RcontainerId
column_name (	R
columnName-
is_for_current_user (RisForCurrentUser1
is_for_current_client (RisForCurrentClient=
is_for_current_organization (RisForCurrentOrganization7
is_for_current_container (RisForCurrentContainer9
type (2%.preference_management.PreferenceTypeRtype
value (	Rvalue"�
DeletePreferenceRequest!
container_id (RcontainerId
column_name (	R
columnName-
is_for_current_user (RisForCurrentUser1
is_for_current_client (RisForCurrentClient=
is_for_current_organization (RisForCurrentOrganization7
is_for_current_container (RisForCurrentContainer9
type (2%.preference_management.PreferenceTypeRtype"�

Preference
	client_id (RclientId'
organization_id (RorganizationId
user_id (RuserId!
container_id (RcontainerId
column_name (	R
columnName
value (	Rvalue9
type (2%.preference_management.PreferenceTypeRtype*H
PreferenceType

CUSTOM 

WINDOW
PROCESS
SMART_BROWSER2�
PreferenceManagement�
GetPreference+.preference_management.GetPreferenceRequest!.preference_management.Preference"�����6/preference-management/preference/{type}/{column_name}ZGE/preference-management/preference/{type}/{container_id}/{column_name}�
SetPreference+.preference_management.SetPreferenceRequest!.preference_management.Preference"�����"6/preference-management/preference/{type}/{column_name}:*ZJ"E/preference-management/preference/{type}/{container_id}/{column_name}:*�
DeletePreference..preference_management.DeletePreferenceRequest.google.protobuf.Empty"�����*6/preference-management/preference/{type}/{column_name}ZG*E/preference-management/preference/{type}/{container_id}/{column_name}BN
+org.spin.backend.grpc.preference_managementBADempierePreferenceManagementPJ�
 p
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 D
	
 D

 >
	
 >
	
  &
	
 %
-
 2# Base URL
 /preference-management/

#
  =	Preference Management



 
)
  &		Get Preference from field


  

  .

  9C

   %

	  �ʼ" %
)
 )2		Set Preference from field


 )

 ).

 )9C

 *1

	 �ʼ"*1
,
 5<		Delete Preference from field


 5

 54

 5?T

 6;

	 �ʼ"6;


 @ H


 @

  A

  A

  A

  A

 B

 B

 B

 B

 C%

 C

 C 

 C#$

 D'

 D

 D"

 D%&

 E-

 E

 E(

 E+,

 F*

 F

 F%

 F()

 G 

 G

 G

 G
(
K T Request for set preference



K

 L

 L

 L

 L

M

M

M

M

N%

N

N 

N#$

O'

O

O"

O%&

P-

P

P(

P+,

Q*

Q

Q%

Q()

R 

R

R

R

S

S

S

S
+
W _ Request for delete preference



W

 X

 X

 X

 X

Y

Y

Y

Y

Z%

Z

Z 

Z#$

['

[

["

[%&

\-

\

\(

\+,

]*

]

]%

]()

^ 

^

^

^

 b g Preference



 b

  c

  c

  c

 d

 d

 d

 e

 e

 e

 f

 f

 f


h p


h

 i

 i

 i

 i

j"

j

j

j !

k

k

k

k

l

l

l

l

m

m

m

m

n

n

n

n

o 

o

o

obproto3
�@
record_management.protorecord_managementgoogle/api/annotations.protogoogle/protobuf/struct.proto"i
ToggleIsActiveRecordRequest

table_name (	R	tableName
	is_active (RisActive
id (Rid"q
!ToggleIsActiveRecordsBatchRequest

table_name (	R	tableName
	is_active (RisActive
ids (Rids"8
ToggleIsActiveRecordResponse
message (	Rmessage"c
"ToggleIsActiveRecordsBatchResponse
message (	Rmessage#
total_changes (RtotalChanges"�
RecordReferenceInfo
id (Rid
uuid (	Ruuid
	window_id (RwindowId
tab_id (RtabId

table_name (	R	tableName!
where_clause (	RwhereClause!
record_count (RrecordCount
column_name (	R
columnName!
display_name	 (	RdisplayName,
value
 (2.google.protobuf.ValueRvalue"S
ExistsRecordReferencesRequest
tab_id (RtabId
	record_id (RrecordId"C
ExistsRecordReferencesResponse!
record_count (RrecordCount"�
ListRecordReferencesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
tab_id (RtabId
	record_id	 (RrecordId"�
ListRecordReferencesResponse!
record_count (RrecordCountF

references (2&.record_management.RecordReferenceInfoR
references&
next_page_token (	RnextPageToken"R
ListZoomWindowsRequest

table_name (	R	tableName
table_id (RtableId"�

ZoomWindow
id (Rid
uuid (	Ruuid
name (	Rname 
description (	Rdescription0
is_sales_transaction (RisSalesTransaction
tab_id (RtabId
tab_uuid (	RtabUuid
tab_name (	RtabName"
is_parent_tab	 (RisParentTab"�
ListZoomWindowsResponse

table_name (	R	tableName
table_id (RtableId&
key_column_name (	RkeyColumnName
key_columns (	R
keyColumns.
display_column_name (	RdisplayColumnName@
zoom_windows (2.record_management.ZoomWindowRzoomWindows2�
RecordManagement�
ToggleIsActiveRecord..record_management.ToggleIsActiveRecordRequest/.record_management.ToggleIsActiveRecordResponse"6���0"+/record-management/{table_name}/{id}/toogle:*�
ToggleIsActiveRecordsBatch4.record_management.ToggleIsActiveRecordsBatchRequest5.record_management.ToggleIsActiveRecordsBatchResponse"1���+"&/record-management/{table_name}/toogle:*�
ListZoomWindows).record_management.ListZoomWindowsRequest*.record_management.ListZoomWindowsResponse"W���Q%/record-management/zooms/{table_name}Z(&/record-management/zooms/id/{table_id}�
ExistsRecordReferences0.record_management.ExistsRecordReferencesRequest1.record_management.ExistsRecordReferencesResponse"A���;9/record-management/references/{tab_id}/{record_id}/exists�
ListRecordReferences..record_management.ListRecordReferencesRequest/.record_management.ListRecordReferencesResponse":���42/record-management/references/{tab_id}/{record_id}BF
'org.spin.backend.grpc.record_managementBADempiereRecordManagementPJ�(
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 @
	
 @

 :
	
 :
	
  &
	
 &
)
 2 Base URL
 /record-management/



  ;


 

  "	

   

  !<

  Gc

  !

	  �ʼ"!

 #(	

 #&

 #'H

 #Su

 $'

	 �ʼ"$'
%
 +2	 Zoom Window on Record


 +

 +2

 +=T

 ,1

	 �ʼ",1
$
 57	 References on Record


 5"

 5#@

 5Ki

 6p

	 �ʼ"6p

 8:	

 8 

 8!<

 8Gc

 9i

	 �ʼ"9i
$
 ? C Active/Inactive Record



 ?#

  @

  @

  @

  @

 A

 A

 A

 A

 B

 B

 B

 B


E I


E)

 F

 F

 F

 F

G

G

G

G

H

H

H

H

H


K M


K$

 L

 L

 L

 L


O R


O*

 P

 P

 P

 P

Q 

Q

Q

Q
/
V a# Record Reference Zoom Information



V

 W

 W

 W

 W

X

X

X

X

Y

Y

Y

Y

Z

Z

Z

Z

[

[

[

[

\ 

\

\

\

]

]

]

]

^

^

^

^

_ 

_

_

_

	`)

	`

	`#

	`&(


c f


c%

 d

 d

 d

 d

e

e

e

e


h j


h&

 i

 i

 i

 i


l v


l#

 m

 m

 m

 m

n

n

n

n

o*

o

o

o%

o()

p+

p

p

p&

p)*

q

q

q

q

r

r

r

r

s 

s

s

s

t

t

t

t

u

u

u

u


x |


x$

 y

 y

 y

 y

z4

z

z$

z%/

z23

{#

{

{

{!"

	 �	Zoom Window



	

	 �

	 �

	 �

	 �

	�

	�

	�

	�


� �


�


 �


 �


 �


 �


�


�


�


�


�


�


�


�


�


�


�


�


�&


�


�!


�$%


� tab



�


�


�


�


�


�


�


�


�


�


�


�


�


�


�

� �

�

 �

 �

 �

 �

�

�

�

�

�#

�

�

�!"

�(

�

�

�#

�&'

�'

�

�"

�%&

�-

�

�

�(

�+,bproto3
�c
report_management.protoreport_managementgoogle/api/annotations.protogoogle/protobuf/struct.protobase_data_type.proto"�
GenerateReportRequest
id (Rid7

parameters (2.google.protobuf.StructR
parameters
report_type (	R
reportType&
print_format_id (RprintFormatId$
report_view_id (RreportViewId

is_summary (R	isSummary

table_name	 (	R	tableName
	record_id
 (RrecordId"�
GetReportOutputRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
	report_id (RreportId.
process_instance_id	 (RprocessInstanceId&
print_format_id
 (RprintFormatId$
report_view_id (RreportViewId

is_summary (R	isSummary
report_name (	R
reportName
report_type (	R
reportType

table_name (	R	tableName"�
PrintFormat
id (Rid
uuid (	Ruuid
name (	Rname 
description (	Rdescription

table_name (	R	tableName

is_default (R	isDefault$
report_view_id (RreportViewId"�
ListPrintFormatsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue

table_name (	R	tableName$
report_view_id	 (RreportViewId
	report_id
 (RreportId"�
ListPrintFormatsResponse!
record_count (RrecordCountC
print_formats (2.report_management.PrintFormatRprintFormats&
next_page_token (	RnextPageToken"�

ReportView
id (Rid
uuid (	Ruuid
name (	Rname 
description (	Rdescription

table_name (	R	tableName"�
ListReportViewsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue

table_name (	R	tableName
	report_id	 (RreportId"�
ListReportViewsResponse!
record_count (RrecordCount@
report_views (2.report_management.ReportViewRreportViews&
next_page_token (	RnextPageToken"J

DrillTable

table_name (	R	tableName

print_name (	R	printName"�
ListDrillTablesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue

table_name (	R	tableName"�
ListDrillTablesResponse!
record_count (RrecordCount@
drill_tables (2.report_management.DrillTableRdrillTables&
next_page_token (	RnextPageToken"�
CreateReportArchiveRequest6
attachment_reference_id (RattachmentReferenceId.
process_instance_id (RprocessInstanceId 
description (	Rdescription
help (	Rhelp"R
CreateReportArchiveResponse
summary (	Rsummary
is_error (RisError"�
SendNotificationRequest
send_to (	RsendTo 
send_to_copy (	R
sendToCopy
subject (	Rsubject
text (	Rtext6
attachment_reference_id (RattachmentReferenceId.
process_instance_id (RprocessInstanceId"O
SendNotificationResponse
summary (	Rsummary
is_error (RisError2�	
ReportManagementw
GenerateReport(.report_management.GenerateReportRequest.data.ProcessLog")���#"/report-management/report/{id}:*�
ListPrintFormats*.report_management.ListPrintFormatsRequest+.report_management.ListPrintFormatsResponse"�����,/report-management/print-formats/{report_id}Z53/report-management/print-formats/table/{table_name}Z?=/report-management/print-formats/report-view/{report_view_id}�
ListReportViews).report_management.ListReportViewsRequest*.report_management.ListReportViewsResponse"i���c+/report-management/report-views/{report_id}Z42/report-management/report-views/table/{table_name}�
ListDrillTables).report_management.ListDrillTablesRequest*.report_management.ListDrillTablesResponse"4���.,/report-management/drill-tables/{table_name}�
GetReportOutput).report_management.GetReportOutputRequest.data.ReportOutput"A���;9/report-management/report-output/{report_id}/{table_name}�
CreateReportArchive-.report_management.CreateReportArchiveRequest..report_management.CreateReportArchiveResponse",���&"!/report-management/report/archive:*�
SendNotification*.report_management.SendNotificationRequest+.report_management.SendNotificationResponse")���#"/report-management/report/send:*BF
'org.spin.backend.grpc.report_managementBADempiereReportManagementPJ�=
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 @
	
 @

 :
	
 :
	
  &
	
 &
	
 
)
 2 Base URL
 /report-management/

.
   Q" The greeting service definition.



  

  "'		Generate Report


  "

  "0

  ";J

  #&

	  �ʼ"#&
)
 )3		Request Print Format List


 )

 )4

 )?W

 *2

	 �ʼ"*2
(
 5<		Request Report View List


 5

 52

 5=T

 6;

	 �ʼ"6;
)
 >@		Request Drill Tables List


 >

 >2

 >=T

 ?c

	 �ʼ"?c
%
 BD		Request Report Output


 B

 B2

 B=N

 Cp

	 �ʼ"Cp

 EJ	

 E

 E :

 EE`

 FI

	 �ʼ"FI

 KP	

 K

 K4

 K?W

 LO

	 �ʼ"LO
%
 U _ Generate Report Request



 U

  V

  V

  V

  V

 W.

 W

 W)

 W,-

 X

 X

 X

 X

 Y"

 Y

 Y

 Y !

 Z!

 Z

 Z

 Z 

 [

 [

 [

 [

 ] window


 ]

 ]

 ]

 ^

 ^

 ^

 ^
'
c s Get Report Output Request



c

 d

 d

 d

 d

e

e

e

e

f*

f

f

f%

f()

g+

g

g

g&

g)*

h

h

h

h

i

i

i

i

j 

j

j

j

k

k

k

k

l&

l

l!

l$%

	m#

	m

	m

	m "


n"


n


n


n!

o

o

o

o

p 

p

p

p

q 

q

q

q

r

r

r

r

w  Print Formats



w

 x

 x

 x

 x

y

y

y

y

z

z

z

z

{

{

{

{

|

|

|

|

}

}

}

}

~!

~

~

~ 

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

�!

�

�

� 

	�

	�

	�

	�

� �

� 

 �

 �

 �

 �

�/

�

�

�*

�-.

�#

�

�

�!"

� � Report View


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�-

�

�

�(

�+,

�#

�

�

�!"

� � Drill Table


�

 �

 �

 �

 �

�

�

�

�

	� �

	�

	 �

	 �

	 �

	 �

	�

	�

	�

	�

	�*

	�

	�

	�%

	�()

	�+

	�

	�

	�&

	�)*

	�

	�

	�

	�

	�

	�

	�

	�

	� 

	�

	�

	�

	�

	�

	�

	�


� �


�


 �


 �


 �


 �


�-


�


�


�(


�+,


�#


�


�


�!"

� � Archive Report


�"

 �*

 �

 �%

 �()

�&

�

�!

�$%

�

�

�

�

�

�

�

�

� �

�#

 �

 �

 �

 �

�

�

�

�
!
� � Send Notification


�

 �$

 �

 �

 �

 �"#

�)

�

�

�$

�'(

�

�

�

�

�

�

�

�

�*

�

�%

�()

�'

�

�!

�$&

� �

� 

 �

 �

 �

 �

�

�

�

�bproto3
��
security.protosecuritygoogle/api/annotations.protogoogle/protobuf/struct.proto"
Session
token (	Rtoken"�
LoginRequest
	user_name (	RuserName
	user_pass (	RuserPass
token (	Rtoken
role_id (RroleId'
organization_id (RorganizationId!
warehouse_id (RwarehouseId
language (	Rlanguage%
client_version (	RclientVersion"
LogoutRequest"
SessionInfoRequest"�
ChangeRoleRequest
role_id (RroleId'
organization_id (RorganizationId!
warehouse_id (RwarehouseId
language (	Rlanguage"
UserInfoRequest"�
UserInfo
id (Rid
uuid (	Ruuid
value (	Rvalue
name (	Rname 
description (	Rdescription
comments (	Rcomments
image (	Rimage-
connection_timeout (RconnectionTimeout
client_uuid	 (	R
clientUuid"�
SessionInfo
id (Rid
uuid (	Ruuid
name (	Rname/
	user_info (2.security.UserInfoRuserInfo"
role (2.security.RoleRrole
	processed (R	processed
language (	Rlanguage

country_id (R	countryId!
country_code	 (	RcountryCode!
country_name
 (	RcountryName)
display_sequence (	RdisplaySequence#
currency_name (	RcurrencyName*
currency_iso_code (	RcurrencyIsoCode'
currency_symbol (	RcurrencySymbol-
standard_precision (RstandardPrecision+
costing_precision (RcostingPrecision@
default_context (2.google.protobuf.StructRdefaultContext"[
SetSessionAttributeRequest
language (	Rlanguage!
warehouse_id (RwarehouseId"�
Client
id (Rid
uuid (	Ruuid
name (	Rname 
description (	Rdescription
logo (	Rlogo
logo_report (	R
logoReport
logo_web (	RlogoWeb"�
Role
id (Rid
uuid (	Ruuid
name (	Rname 
description (	Rdescription(
client (2.security.ClientRclient"
is_can_report (RisCanReport"
is_can_export (RisCanExport(
is_personal_lock (RisPersonalLock,
is_personal_access	 (RisPersonalAccess1
is_allow_info_account
 (RisAllowInfoAccountB
is_allow_info_business_partner (RisAllowInfoBusinessPartner.
is_allow_info_in_out (RisAllowInfoInOut-
is_allow_info_order (RisAllowInfoOrder1
is_allow_info_product (RisAllowInfoProduct3
is_allow_info_schedule (RisAllowInfoSchedule)
is_allow_info_mrp (RisAllowInfoMrp+
is_allow_html_view (RisAllowHtmlView-
is_allow_info_asset (RisAllowInfoAsset:
is_allow_info_cash_journal (RisAllowInfoCashJournal1
is_allow_info_invoice (RisAllowInfoInvoice1
is_allow_info_payment (RisAllowInfoPayment3
is_allow_info_resource (RisAllowInfoResource)
is_allow_info_crp (RisAllowInfoCrp)
is_allow_xls_view (RisAllowXlsView,
is_show_accounting (RisShowAccounting"�
ListRolesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListRolesResponse!
record_count (RrecordCount$
roles (2.security.RoleRroles&
next_page_token (	RnextPageToken"�
Organization
id (Rid
uuid (	Ruuid
value (	Rvalue
name (	Rname 
description (	Rdescription 
is_read_only (R
isReadOnly
duns (	Rduns
tax_id (	RtaxId
phone	 (	Rphone
phone2
 (	Rphone2
fax (	Rfax8
corporate_branding_image (	RcorporateBrandingImage"�
ListOrganizationsResponse!
record_count (RrecordCount<
organizations (2.security.OrganizationRorganizations&
next_page_token (	RnextPageToken"�
ListOrganizationsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
role_id (RroleId"{
	Warehouse
id (Rid
uuid (	Ruuid
value (	Rvalue
name (	Rname 
description (	Rdescription"�
ListWarehousesResponse!
record_count (RrecordCount3

warehouses (2.security.WarehouseR
warehouses&
next_page_token (	RnextPageToken"�
ListWarehousesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue'
organization_id (RorganizationId"�
DictionaryEntity
id (Rid
uuid (	Ruuid
name (	Rname 
description (	Rdescription
help (	Rhelp"�
Menu
id (Rid
uuid (	Ruuid
	parent_id (RparentId
sequence (	Rsequence
name (	Rname 
description (	Rdescription

is_summary (R	isSummary0
is_sales_transaction (RisSalesTransaction 
is_read_only	 (R
isReadOnly
action
 (	H Raction� 
	action_id (HRactionId�$
action_uuid (	HR
actionUuid�7
window (2.security.DictionaryEntityHRwindow�9
process (2.security.DictionaryEntityHRprocess�3
form (2.security.DictionaryEntityHRform�9
browser (2.security.DictionaryEntityHRbrowser�;
workflow (2.security.DictionaryEntityHRworkflow�*
children (2.security.MenuRchildrenB	
_actionB

_action_idB
_action_uuidB	
_windowB

_processB
_formB

_browserB
	_workflow"
MenuRequest"4
MenuResponse$
menus (2.security.MenuRmenus"�
ListServicesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"E
ListServicesResponse-
services (2.security.ServiceRservices"i
Service
id (Rid!
display_name (	RdisplayName+
authorization_uri (	RauthorizationUri"�
LoginOpenIDRequest%
code_parameter (	RcodeParameter'
state_parameter (	RstateParameter
language (	Rlanguage%
client_version (	RclientVersion"o
GetDictionaryAccessRequestA
dictionary_type (2.security.DictionaryTypeRdictionaryType
id (Rid"T
GetDictionaryAccessResponse
	is_access (RisAccess
message (	Rmessage*V
DictionaryType

UNKNOW 
MENU

WINDOW
PROCESS
BROWSER
FORM2�

SecurityQ
RunLogin.security.LoginRequest.security.Session"���"/security/login:*Q
	RunLogout.security.LogoutRequest.security.Session"���"/security/logoutY
GetUserInfo.security.UserInfoRequest.security.UserInfo"���/security/user-infoQ
GetMenu.security.MenuRequest.security.MenuResponse"���/security/menusa
RunChangeRole.security.ChangeRoleRequest.security.Session" ���/security/change-role:*e
GetSessionInfo.security.SessionInfoRequest.security.SessionInfo"���/security/session-infov
SetSessionAttribute$.security.SetSessionAttributeRequest.security.Session"&��� /security/session-attribute:*]
	ListRoles.security.ListRolesRequest.security.ListRolesResponse"���/security/roles}
ListOrganizations".security.ListOrganizationsRequest#.security.ListOrganizationsResponse"���/security/organizationsq
ListWarehouses.security.ListWarehousesRequest .security.ListWarehousesResponse"���/security/warehousesi
ListServices.security.ListServicesRequest.security.ListServicesResponse"���/security/servicese
RunLoginOpenID.security.LoginOpenIDRequest.security.Session""���"/security/login-open-id:*�
GetDictionaryAccess$.security.GetDictionaryAccessRequest%.security.GetDictionaryAccessResponse"3���-+/security/dictionary/{dictionary_type}/{id}B5
org.spin.backend.grpc.securityBADempiereSecurityPJ�o
 �
�	
 �	************************************************************************************
 Copyright (C) 2012-2023 E.R.P. Consultores y Asociados, C.A.                      *
 Contributor(s): Yamel Senih ysenih@erpya.com                                      *
 This program is free software: you can redistribute it and/or modify              *
 it under the terms of the GNU General Public License as published by              *
 the Free Software Foundation, either version 2 of the License, or                 *
 (at your option) any later version.                                               *
 This program is distributed in the hope that it will be useful,                   *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                    *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                      *
 GNU General Public License for more details.                                      *
 You should have received a copy of the GNU General Public License                 *
 along with this program. If not, see <https://www.gnu.org/licenses/>.             *
**********************************************************************************

 "
	

 "

 7
	
 7

 2
	
 2
	
  &
	
 &
 
 2 Base URL
 /security/

.
  d" The greeting service definition.



 
'
  $	 Request login from user


  

  !

  ,3

   #

	  �ʼ" #

 &(	 Request a Role


 &

 &#

 &.5

 'H

	 �ʼ"'H
3
 *,	% Request user roles from SessionInfo


 *

 *'

 *2:

 +J

	 �ʼ"+J
(
 .2	 Request Menu from Parent


 .

 .

 .*6

 /1

	 �ʼ"/1
#
 49	 Request change role


 4

 4+

 46=

 58

	 �ʼ"58

 ;=	 Request session


 ;

 ;-

 ;8C

 <M

	 �ʼ"<M

 >C	

 >

 > :

 >EL

 ?B

	 �ʼ"?B

 FH	 List Roles


 F

 F&

 F1B

 GF

	 �ʼ"GF
"
 JL		List Organizations


 J

 J6

 JAZ

 KN

	 �ʼ"KN

 	NP		Warehouses


 	N

 	N0

 	N;Q

 	OK

	 	�ʼ"OK
'
 
SU	 List Available Services


 
S

 
S,

 
S7K

 
TI

	 
�ʼ"TI
*
 W\	 Request login from Open ID


 W

 W-

 W8?

 X[

	 �ʼ"X[
*
 _c		Validate dictionary access


 _

 _ :

 _E`

 `b

	 �ʼ"`b
!
 h j	Token after session



 h

  i

  i

  i

  i
)
n w Request a Login SessionInfo



n

 o

 o

 o

 o

p

p

p

p

q

q

q

q

r

r

r

r

s"

s

s

s !

t

t

t

t

u

u

u

u

v"

v

v

v !

z { Request a Logout



z
#
~  Request a SessionInfo



~
%
� � Request a Change Role


�

 �

 �

 �

 �

�"

�

�

� !

�

�

�

�

�

�

�

�
!
� � Request User Info


�
 
� � User information


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�%

�

� 

�#$
%
� client of user record


�

�

�

� � Session Info


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� 

�

�

�

	�!

	�

	�

	� 


�%


�


�


�"$

�"

�

�

�!

�&

�

� 

�#%

�$

�

�

�!#

�&

�

� 

�#%

�%

�

�

�"$

�4

�

�.

�13

� �

�"

 �

 �

 �

 �

�

�

�

�

	� �

	�

	 �

	 �

	 �

	 �

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�


� � Role



�


 �


 �


 �


 �


�


�


�


�


�


�


�


�


�


�


�


�


�


�


�


�


�


�


�


�


�


�


�


�


�"


�


�


� !


�$


�


�


�"#


	�(


	�


	�"


	�%'



�1



�



�+



�.0


�'


�


�!


�$&


�&


�


� 


�#%


�(


�


�"


�%'


�)


�


�#


�&(


�$


�


�


�!#


�%


�


�


�"$


�&


�


� 


�#%


�-


�


�'


�*,


�(


�


�"


�%'


�(


�


�"


�%'


�)


�


�#


�&(


�$


�


�


�!#


�$


�


�


�!#


�%


�


�


�"$

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

� �

�

 �

 �

 �

 �

� 

�

�

�

�

�#

�

�

�!"

� � Organization


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

	�

	�

	�

	�


�


�


�


�

�-

�

�'

�*,

� �

�!

 �

 �

 �

 �

�0

�

�

�+

�./

�#

�

�

�!"

� �

� 

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

� � Warehouse


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �

 �

�*

�

�

�%

�()

�#

�

�

�!"

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�"

�

�

� !
<
� �. As Window, Process, Report, Browse, Workflow


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

� � Menu


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�&

�

�!

�$%

�

�

�

�
$
	�$ Supported References


	�

	�

	�

	�!#


�&


�


�


� 


�#%

�)

�

�

�#

�&(

�.

�

�!

�"(

�+-

�/

�

�!

�")

�,.

�,

�

�!

�"&

�)+

�/

�

�!

�")

�,.

�0

�

�!

�"*

�-/
 
�$ Tree menu childs


�

�

�

�!#

� �

�

� �

�

 � 

 �

 �

 �

 �

� �		Open ID


�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

� �

�

 �&

 �

 �

 �!

 �$%

� �

�

 �

 �

 �

 �

� 

�

�

�

�%

�

� 

�#$

� �

�

 �"

 �

 �

 � !

�#

�

�

�!"

�

�

�

�

�"

�

�

� !

 � �

 �

  �

  �

  �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

� �

�"

 �+

 �

 �&

 �)*

�

�

�

�

� �

�#

 �

 �

 �

 �

�

�

�

�bproto3
�+
send_notifications.protosend_notificationsgoogle/api/annotations.protobase_data_type.proto"�
ListUsersRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes"]
NotifcationType
value (	Rvalue
name (	Rname 
description (	Rdescription"�
ListNotificationsTypesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes"�
ListNotificationsTypesResponse!
record_count (RrecordCount=
records (2#.send_notifications.NotifcationTypeRrecords&
next_page_token (	RnextPageToken"M
	Recipient

contact_id (R	contactId!
account_name (	RaccountName"�
SendNotificationRequest
user_id (RuserId+
notification_type (	RnotificationType
title (	Rtitle
body (	Rbody=

recipients (2.send_notifications.RecipientR
recipients 
attachments (	Rattachments"C
SendNotificationResponse'
notification_id (RnotificationId2�
SendNotificationss
	ListUsers$.send_notifications.ListUsersRequest.data.ListLookupItemsResponse"!���/send-notifications/users�
ListNotificationsTypes1.send_notifications.ListNotificationsTypesRequest2.send_notifications.ListNotificationsTypesResponse"/���)'/send-notifications/notifications-types�
SendNotification+.send_notifications.SendNotificationRequest,.send_notifications.SendNotificationResponse",���&"!/send-notifications/notifications:*BH
(org.spin.backend.grpc.send_notificationsBADempiereSendNotificationsPJ�
 i
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 A
	
 A

 ;
	
 ;
	
  &
	
 
*
 2  Base URL
 /send-notifications/



 0


 	

  "	

  

  &

  1M

  !

	  �ʼ"!

 $(	

 $"

 $#@

 $Ki

 %'

	 �ʼ"%'

 */	

 *

 *4

 *?W

 +.

	 �ʼ"+.

 4 = User



 4

  5

  5

  5

  5

 6

 6

 6

 6

 7*

 7

 7

 7%

 7()

 8+

 8

 8

 8&

 8)*

 9

 9

 9

 9

 :

 :

 :

 :

 ; 

 ;

 ;

 ;

 <&

 <

 <!

 <$%

A E Notification Type



A

 B

 B

 B

 B

C

C

C

C

D

D

D

D


F O


F%

 G

 G

 G

 G

H

H

H

H

I*

I

I

I%

I()

J+

J

J

J&

J)*

K

K

K

K

L

L

L

L

M 

M

M

M

N&

N

N!

N$%


P T


P&

 Q

 Q

 Q

 Q

R-

R

R 

R!(

R+,

S#

S

S

S!"

X [ Recipient



X

 Y

 Y

 Y

 Y

Z 

Z

Z

Z

_ f Send Notification



_

 `

 `

 `

 `

a%

a

a 

a#$

b

b

b

b

c

c

c

c

d*

d

d

d%

d()

e(

e

e

e#

e&'


g i


g 

 h"

 h

 h

 h !bproto3
�0
task_management.prototask_managementgoogle/api/annotations.protogoogle/protobuf/timestamp.proto"�
Project
id (Rid
uuid (	Ruuid
value (	Rvalue 
description (	RdescriptionJ
date_start_schedule (2.google.protobuf.TimestampRdateStartScheduleL
date_finish_schedule (2.google.protobuf.TimestampRdateFinishSchedule"�
Request
id (Rid
uuid (	Ruuid
document_no (	R
documentNo
subject (	Rsubject
summary (	RsummaryB
date_start_plan (2.google.protobuf.TimestampRdateStartPlanH
date_complete_plan (2.google.protobuf.TimestampRdateCompletePlan"�
ResourceAssignment
id (Rid
uuid (	Ruuid
name (	Rname 
description (	Rdescription
quantity (	RquantityD
assign_date_form (2.google.protobuf.TimestampRassignDateForm@
assign_date_to (2.google.protobuf.TimestampRassignDateTo!
is_confirmed (RisConfirmed
resource_id	 (R
resourceId"�
Task6
	task_type (2.task_management.TaskTypeRtaskType
name (	Rname 
description (	Rdescription9

start_date (2.google.protobuf.TimestampR	startDate5
end_date (2.google.protobuf.TimestampRendDate4
project (2.task_management.ProjectH Rproject4
request (2.task_management.RequestH RrequestV
resource_assignment (2#.task_management.ResourceAssignmentH RresourceAssignmentB
task"�
ListTasksRequest
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue.
date (2.google.protobuf.TimestampRdate(
is_with_projects (RisWithProjects(
is_with_requests (RisWithRequests?
is_with_resource_assignments (RisWithResourceAssignments"�
ListTasksResponse!
record_count (RrecordCount+
tasks (2.task_management.TaskRtasks&
next_page_token (	RnextPageToken*I
TaskType

UNKNOW 
PROJECT
REQUEST
RESOURCE_ASSIGNMENT2�
TaskManagementr
	ListTasks!.task_management.ListTasksRequest".task_management.ListTasksResponse"���/task-management/tasksBG
*org.spin.backend.grpc.form.task_managementBADempiereTaskManagementPJ�
 f
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 C
	
 C

 8
	
 8
	
  &
	
 )
'
 2 Base URL
 /task-management/

4
  "( The Task Management service definition



 

  !	

  

  &

  1B

   M

	  �ʼ" M


 $ +


 $

  %

  %

  %

  %

 &

 &

 &

 &

 '

 '

 '

 '

 (

 (

 (

 (

 ):

 )!

 )"5

 )89

 *;

 *!

 *"6

 *9:


- 5


-

 .

 .

 .

 .

/

/

/

/

0

0

0

0

1

1

1

1

2

2

2

2

36

3!

3"1

345

49

4!

4"4

478


7 A


7

 8

 8

 8

 8

9

9

9

9

:

:

:

:

;

;

;

;

<

<

<

<

=7

=!

="2

=56

>5

>!

>"0

>34

?

?

?

?

@

@

@

@


 C H


 C

  D

  D

  D

 E

 E

 E

 F

 F

 F

 G 

 G

 G


J U


J

 K

 K

 K

 K

L

L

L

L

M

M

M

M

N1

N!

N",

N/0

O/

O!

O"*

O-.

 PT	

 P

Q$

Q

Q

Q"#

R$

R

R

R"#

S;

S"

S#6

S9:


W `


W

 X

 X

 X

 X

Y

Y

Y

Y

Z 

Z

Z

Z

\+	 filters


\!

\"&

\)*

]"

]

]

] !

^"

^

^

^ !

_.

_

_)

_,-


b f


b

 c

 c

 c

 c

d 

d

d

d

d

e#

e

e

e!"bproto3
�H
time_record.prototime_recordgoogle/api/annotations.protogoogle/protobuf/timestamp.protocore_functionality.proto"l
Issue
id (Rid
document_no (	R
documentNo
subject (	Rsubject
summary (	Rsummary"�
ListIssuesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListIssuesResponse!
record_count (RrecordCount,
records (2.time_record.IssueRrecords&
next_page_token (	RnextPageToken"C
Project
id (Rid
value (	Rvalue
name (	Rname"�
ListProjectsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListProjectsResponse!
record_count (RrecordCount.
records (2.time_record.ProjectRrecords&
next_page_token (	RnextPageToken"�
ResourceType
id (Rid
value (	Rvalue
name (	Rname 
description (	RdescriptionI
unit_of_measure (2!.core_functionality.UnitOfMeasureRunitOfMeasure"b
User
id (Rid
value (	Rvalue
name (	Rname 
description (	Rdescription"�
Resource
id (Rid>
resource_type (2.time_record.ResourceTypeRresourceType%
user (2.time_record.UserRuser
name (	Rname 
description (	Rdescription"�
ResourceAssignment
id (Rid1
resource (2.time_record.ResourceRresource
name (	Rname 
description (	RdescriptionD
assign_date_from (2.google.protobuf.TimestampRassignDateFrom@
assign_date_to (2.google.protobuf.TimestampRassignDateTo!
is_confirmed (RisConfirmed
quantity (	Rquantity"�
CreateTimeRecordRequest

request_id (R	requestId

project_id (R	projectId
quantity (	Rquantity
name (	Rname 
description (	Rdescription.
date (2.google.protobuf.TimestampRdate"�
ListTimeRecordRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
quantity (Rquantity7
	date_from	 (2.google.protobuf.TimestampRdateFrom3
date_to
 (2.google.protobuf.TimestampRdateTo"�
ListTimeRecordResponse!
record_count (RrecordCount9
records (2.time_record.ResourceAssignmentRrecords&
next_page_token (	RnextPageToken2�

TimeRecordj

ListIssues.time_record.ListIssuesRequest.time_record.ListIssuesResponse"���/time-record/issuesr
ListProjects .time_record.ListProjectsRequest!.time_record.ListProjectsResponse"���/time-record/projects
CreateTimeRecord$.time_record.CreateTimeRecordRequest.time_record.ResourceAssignment"$���"/time-record/time-records:*|
ListTimeRecord".time_record.ListTimeRecordRequest#.time_record.ListTimeRecordResponse"!���/time-record/time-recordsB?
&org.spin.backend.grpc.form.time_recordBADempiereTimeRecordPJ�/
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 ?
	
 ?

 4
	
 4
	
  &
	
 )
	
 "
#
 2 Base URL
 /time-record/

0
   1$ The Time Record service definition



  

  !#	

  !

  !(

  !3E

  "J

	  �ʼ""J

 $&	

 $

 $,

 $7K

 %L

	 �ʼ"%L
"
 (-	 Resource Assigment


 (

 (4

 (?Q

 ),

	 �ʼ"),

 .0	

 .

 .0

 .;Q

 /P

	 �ʼ"/P

 4 9 Issue (Request)



 4

  5

  5

  5

  5

 6

 6

 6

 6

 7

 7

 7

 7

 8

 8

 8

 8


; C


;

 <

 <

 <

 <

=

=

=

=

>*

>

>

>%

>()

?+

?

?

?&

?)*

@

@

@

@

A

A

A

A

B 

B

B

B


E I


E

 F

 F

 F

 F

G#

G

G

G

G!"

H#

H

H

H!"

M Q	 Project



M

 N

 N

 N

 N

O

O

O

O

P

P

P

P


S [


S

 T

 T

 T

 T

U

U

U

U

V*

V

V

V%

V()

W+

W

W

W&

W)*

X

X

X

X

Y

Y

Y

Y

Z 

Z

Z

Z


] a


]

 ^

 ^

 ^

 ^

_%

_

_

_ 

_#$

`#

`

`

`!"
 
e k Resource Assigment



e

 f

 f

 f

 f

g

g

g

g

h

h

h

h

i

i

i

i

j=

j(

j)8

j;<


m r


m

 n

 n

 n

 n

o

o

o

o

p

p

p

p

q

q

q

q


t z


t

 u

 u

 u

 u

v'

v

v"

v%&

w

w

w

w

x

x

x

x

y

y

y

y

	| �


	|

	 }

	 }

	 }

	 }

	~

	~

	~

	~

	

	

	

	

	�

	�

	�

	�

	�7

	�!

	�"2

	�56

	�5

	�!

	�"0

	�34

	�

	�

	�

	�

	�

	�

	�

	�


� �


�


 �


 �


 �


 �


�


�


�


�


�


�


�


�


�


�


�


�


�


�


�


�


�+


�!


�"&


�)*

� �

�

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

�0

�!

�"+

�./

	�/

	�!

	�")

	�,.

� �

�

 �

 �

 �

 �

�0

�

�#

�$+

�./

�#

�

�

�!"bproto3
�c
trial_balance_drillable.prototrial_balance_drillablegoogle/api/annotations.protobase_data_type.proto"�
ListOrganizationsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListBudgetsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListUser1Request
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListPeriodsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListAccoutingKeysRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListReportCubesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue-
context_attributes (	RcontextAttributes3
is_only_active_records	 (RisOnlyActiveRecords"�
ListFactAcctSummaryRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue'
organization_id (RorganizationId
	budget_id	 (RbudgetId
	period_id
 (RperiodId*
accouting_from_id (RaccoutingFromId&
accouting_to_id (RaccoutingToId$
report_cube_id (RreportCubeId
user1_id (Ruser1Id"�
FactAcctSummary
id (Rid
value (	Rvalue
name (	Rname 
user_list_id (R
userListId$
user_list_name (	RuserListName0
period_actual_amount (	RperiodActualAmount0
period_budget_amount (	RperiodBudgetAmount4
period_variance_amount (	RperiodVarianceAmount*
ytd_actual_amount	 (	RytdActualAmount*
ytd_budget_amount
 (	RytdBudgetAmount'
variance_amount (	RvarianceAmount"�
ListFactAcctSummaryResponse!
record_count (RrecordCountB
records (2(.trial_balance_drillable.FactAcctSummaryRrecords&
next_page_token (	RnextPageToken"�
ExportRequest!
search_value (	RsearchValue'
organization_id (RorganizationId
	budget_id (RbudgetId
	period_id (RperiodId*
accouting_from_id (RaccoutingFromId&
accouting_to_id (RaccoutingToId$
report_cube_id (RreportCubeId
user1_id (Ruser1Id"
ExportResponse2�	
TrialBalanceDrillable�
ListOrganizations1.trial_balance_drillable.ListOrganizationsRequest.data.ListLookupItemsResponse".���(&/trial-balance-drillable/organizations�
ListBudgets+.trial_balance_drillable.ListBudgetsRequest.data.ListLookupItemsResponse"(���" /trial-balance-drillable/budgets~
	ListUser1).trial_balance_drillable.ListUser1Request.data.ListLookupItemsResponse"'���!/trial-balance-drillable/user-1�
ListPeriods+.trial_balance_drillable.ListPeriodsRequest.data.ListLookupItemsResponse"(���" /trial-balance-drillable/periods�
ListAccoutingKeys1.trial_balance_drillable.ListAccoutingKeysRequest.data.ListLookupItemsResponse"/���)'/trial-balance-drillable/accouting-keys�
ListReportCubes/.trial_balance_drillable.ListReportCubesRequest.data.ListLookupItemsResponse"-���'%/trial-balance-drillable/report-cubes�
ListFactAcctSummary3.trial_balance_drillable.ListFactAcctSummaryRequest4.trial_balance_drillable.ListFactAcctSummaryResponse"7���1//trial-balance-drillable/accouting-fact-summary�
Export&.trial_balance_drillable.ExportRequest'.trial_balance_drillable.ExportResponse"*���$"/trial-balance-drillable/export:*BR
2org.spin.backend.grpc.form.trial_balance_drillableBADempierePaymentAllocationPJ�=
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 K
	
 K

 ;
	
 ;
	
  &
	
 
/
  2% Base URL
 /trial-balance-drillable/

x
  @l The Trial Balance Drillable Report form service definition.
 - org.adempiere.webui.apps.form.WTrialBalance



 

  !#	
 criteria


  !

  !6

  !A]

  "]

	  �ʼ""]

 $&	

 $

 $*

 $5Q

 %W

	 �ʼ"%W

 ')	

 '

 '&

 '1M

 (V

	 �ʼ"(V

 *,	

 *

 **

 *5Q

 +W

	 �ʼ"+W

 -/	

 -

 -6

 -A]

 .^

	 �ʼ".^

 02	

 0

 02

 0=Y

 1\

	 �ʼ"1\

 57	 result


 5

 5 :

 5E`

 6f

	 �ʼ"6f

 :?	 manage


 :

 : 

 :+9

 ;>

	 �ʼ";>


 C M


 C 

  D

  D

  D

  D

 E

 E

 E

 E

 F*

 F

 F

 F%

 F()

 G+

 G

 G

 G&

 G)*

 H

 H

 H

 H

 I

 I

 I

 I

 J 

 J

 J

 J

 K&

 K

 K!

 K$%

 L(

 L

 L#

 L&'


O Y


O

 P

 P

 P

 P

Q

Q

Q

Q

R*

R

R

R%

R()

S+

S

S

S&

S)*

T

T

T

T

U

U

U

U

V 

V

V

V

W&

W

W!

W$%

X(

X

X#

X&'


[ e


[

 \

 \

 \

 \

]

]

]

]

^*

^

^

^%

^()

_+

_

_

_&

_)*

`

`

`

`

a

a

a

a

b 

b

b

b

c&

c

c!

c$%

d(

d

d#

d&'


g q


g

 h

 h

 h

 h

i

i

i

i

j*

j

j

j%

j()

k+

k

k

k&

k)*

l

l

l

l

m

m

m

m

n 

n

n

n

o&

o

o!

o$%

p(

p

p#

p&'


s }


s 

 t

 t

 t

 t

u

u

u

u

v*

v

v

v%

v()

w+

w

w

w&

w)*

x

x

x

x

y

y

y

y

z 

z

z

z

{&

{

{!

{$%

|(

|

|#

|&'

 �




 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�&

�

�!

�$%

�(

�

�#

�&'

� �

�"

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�"

�

�

� !

�

�

�

�

	�

	�

	�

	�


�%


�


�


�"$

�#

�

�

� "

�"

�

�

�!

�

�

�

�

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�"

�

�

� !

�(

�

�#

�&'

�(

�

�#

�&'

�*

�

�%

�()

�%

�

� 

�#$

	�&

	�

	� 

	�#%


�$


�


�


�!#

� �

�#

 �

 �

 �

 �

�-

�

� 

�!(

�+,

�#

�

�

�!"

	� �

	�

	 � 

	 �

	 �

	 �

	�"

	�

	�

	� !

	�

	�

	�

	�

	�

	�

	�

	�

	�$

	�

	�

	�"#

	�"

	�

	�

	� !

	�!

	�

	�

	� 

	�

	�

	�

	�


� �


�bproto3
�N
update_center.protoupdatesgoogle/api/annotations.proto"�
ListPackagesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
language (	Rlanguage

release_no	 (	R	releaseNo
version
 (	Rversion"�
Package
id (Rid
entity_type (	R
entityType#
model_package (	RmodelPackage
version (	Rversion
name (	Rname 
description (	Rdescription
help (	Rhelp3
versions (2.updates.PackageVersionRversions"�
PackageVersion
id (Rid
version (	Rversion
sequence (Rsequence
name (	Rname 
description (	Rdescription
help (	Rhelp"�
ListPackagesResponse!
record_count (RrecordCount,
packages (2.updates.PackageRpackages&
next_page_token (	RnextPageToken"�
ListUpdatesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
language (	Rlanguage

release_no	 (	R	releaseNo
version
 (	Rversion
entity_type (	R
entityType"�
ListUpdatesResponse!
record_count (RrecordCount)
updates (2.updates.UpdateRupdates&
next_page_token (	RnextPageToken"�
Update
id (Rid
entity_type (	R
entityType

release_no (	R	releaseNo
sequence (Rsequence
name (	Rname
comments (	Rcomments#
step_quantity (RstepQuantity"�
ListStepsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
	update_id (RupdateId
	from_step	 (RfromStep"�
ListStepsResponse!
record_count (RrecordCount#
steps (2.updates.StepRsteps&
next_page_token (	RnextPageToken"�
Step
id (Rid
	step_type (	RstepType
action (	Raction
table_id (RtableId
	record_id (RrecordId
	column_id (RcolumnId#
database_type (	RdatabaseType
sequence (Rsequence
comments	 (	Rcomments
	is_parsed
 (RisParsed#
sql_statement (	RsqlStatement-
rollback_statement (	RrollbackStatement3
step_values (2.updates.StepValueR
stepValues"�
	StepValue
id (Rid
	column_id (RcolumnId
	old_value (	RoldValue
	new_value (	RnewValue!
backup_value (	RbackupValue
is_old_null (R	isOldNull
is_new_null (R	isNewNull$
is_backup_null (RisBackupNull2�
UpdateCenterf
ListPackages.updates.ListPackagesRequest.updates.ListPackagesResponse"���/updates/packagesb
ListUpdates.updates.ListUpdatesRequest.updates.ListUpdatesResponse"���/updates/updatesZ
	ListSteps.updates.ListStepsRequest.updates.ListStepsResponse"���/updates/stepsB1
org.spin.backend.grpc.updateBADempiereUpdatePJ�5
 �
�	
 �	************************************************************************************
 Copyright (C) 2012-2018 E.R.P. Consultores y Asociados, C.A.                      *
 Contributor(s): Yamel Senih ysenih@erpya.com                                      *
 This program is free software: you can redistribute it and/or modify              *
 it under the terms of the GNU General Public License as published by              *
 the Free Software Foundation, either version 2 of the License, or                 *
 (at your option) any later version.                                               *
 This program is distributed in the hope that it will be useful,                   *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                    *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                      *
 You should have received a copy of the GNU General Public License                 *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 5
	
 5

 0
	
 0
	
  &

 2 Base URL
 /updates/

,
  )  The Update service definition.



 
'
    List Available Packages


  

  &

  1E

  @

	  �ʼ"@
&
 "$ List Available Updates


 "

 "$

 "/B

 #?

	 �ʼ"#?

 &( List Steps


 &

 & 

 &+<

 '=

	 �ʼ"'=

 , 7 Packages Request



 ,

  -

  -

  -

  -

 .

 .

 .

 .

 /*

 /

 /

 /%

 /()

 0+

 0

 0

 0&

 0)*

 1

 1

 1

 1

 2

 2

 2

 2

 3 

 3

 3

 3

 4

 4

 4

 4

 5

 5

 5

 5

 	6

 	6

 	6

 	6

: C	 Package



:

 ;

 ;

 ;

 ;

<

<

<

<

=!

=

=

= 

>

>

>

>

?

?

?

?

@

@

@

@

A

A

A

A

B-

B

B

B (

B+,

F M Package Version



F

 G

 G

 G

 G

H

H

H

H

I

I

I

I

J

J

J

J

K

K

K

K

L

L

L

L
$
P T	List Packages Response



P

 Q

 Q

 Q

 Q

R&

R

R

R!

R$%

S#

S

S

S!"

W c Updates Request



W

 X

 X

 X

 X

Y

Y

Y

Y

Z*

Z

Z

Z%

Z()

[+

[

[

[&

[)*

\

\

\

\

]

]

]

]

^ 

^

^

^

_

_

_

_

`

`

`

`

	a

	a

	a

	a


b 


b


b


b
#
f j	List Updates Response



f

 g

 g

 g

 g

h$

h

h

h

h"#

i#

i

i

i!"

m u Update



m

 n

 n

 n

 n

o

o

o

o

p

p

p

p

q

q

q

q

r

r

r

r

s

s

s

s

t 

t

t

t

x � Steps Request



x

 y

 y

 y

 y

z

z

z

z

{*

{

{

{%

{()

|+

|

|

|&

|)*

}

}

}

}

~

~

~

~

 







�

�

�

�

�

�

�

�
#
� �	List Steps Response


�

 �

 �

 �

 �

� 

�

�

�

�

�#

�

�

�!"

	� � Step


	�

	 �

	 �

	 �

	 �

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�!

	�

	�

	� 

	�

	�

	�

	�

	�

	�

	�

	�

		�

		�

		�

		�

	
�"

	
�

	
�

	
�!

	�'

	�

	�!

	�$&

	�,

	�

	�

	�&

	�)+


� � Step Value



�


 �


 �


 �


 �


�


�


�


�


�


�


�


�


�


�


�


�


� 


�


�


�


�


�


�


�


�


�


�


�


� 


�


�


�bproto3
�T
user_customization.protouser_customizationgoogle/api/annotations.protogoogle/protobuf/empty.proto"b
User
id (Rid
value (	Rvalue
name (	Rname 
description (	Rdescription"�
ListUsersRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListUsersResponse!
record_count (RrecordCount2
records (2.user_customization.UserRrecords&
next_page_token (	RnextPageToken"b
Role
id (Rid
value (	Rvalue
name (	Rname 
description (	Rdescription"�
ListRolesRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListRolesResponse!
record_count (RrecordCount2
records (2.user_customization.RoleRrecords&
next_page_token (	RnextPageToken"p
LevelCustomization
id (Rid
value (	Rvalue
name (	Rname 
description (	Rdescription"�
ListCustomizationsLevelRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue"�
ListCustomizationsLevelResponse!
record_count (RrecordCount@
records (2&.user_customization.LevelCustomizationRrecords&
next_page_token (	RnextPageToken"�
FieldAttributes
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken
id (Rid
column_name (	R
columnName
color	 (	Rcolor!
display_size
 (RdisplaySize4
display_component_type (	RdisplayComponentType6
component_template_code (	RcomponentTemplateCode%
sequence_panel (RsequencePanel@
is_default_displayed_as_panel (	RisDefaultDisplayedAsPanel%
sequence_table (RsequenceTable@
is_default_displayed_as_table (	RisDefaultDisplayedAsTable"�
SaveWindowCustomizationRequest
tab_id (RtabId<

level_type (2.user_customization.LevelTypeR	levelType
level_value (R
levelValueN
field_attributes (2#.user_customization.FieldAttributesRfieldAttributes"�
SaveBrowseCustomizationRequest
	browse_id (RbrowseId<

level_type (2.user_customization.LevelTypeR	levelType
level_value (R
levelValueN
field_attributes (2#.user_customization.FieldAttributesRfieldAttributes"�
SaveProcessCustomizationRequest

process_id (R	processId<

level_type (2.user_customization.LevelTypeR	levelType
level_value (R
levelValueN
field_attributes (2#.user_customization.FieldAttributesRfieldAttributes*7
	LevelType

UNKNOW 
USER
ROLE

CLIENT2�
UserCustomization{
	ListUsers$.user_customization.ListUsersRequest%.user_customization.ListUsersResponse"!���/user-customization/users{
	ListRoles$.user_customization.ListRolesRequest%.user_customization.ListRolesResponse"!���/user-customization/roles�
ListCustomizationsLevel2.user_customization.ListCustomizationsLevelRequest3.user_customization.ListCustomizationsLevelResponse""���/user-customization/levels�
SaveWindowCustomization2.user_customization.SaveWindowCustomizationRequest.google.protobuf.Empty"J���D"?/user-customization/windows/{tab_id}/{level_type}/{level_value}:*�
SaveBrowseCustomization2.user_customization.SaveBrowseCustomizationRequest.google.protobuf.Empty"N���H"C/user-customization/browsers/{browse_id}/{level_type}/{level_value}:*�
SaveProcessCustomization3.user_customization.SaveProcessCustomizationRequest.google.protobuf.Empty"P���J"E/user-customization/processes/{process_id}/{level_type}/{level_value}:*BH
(org.spin.backend.grpc.user_customizationBADempiereUserCustomizationPJ�4
 �
�	
 �	***********************************************************************************
 Copyright (C) 2018-present E.R.P. Consultores y Asociados, C.A.                  *
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 A
	
 A

 ;
	
 ;
	
  &
	
 %
*
 2  Base URL
 /user-customization/

8
  ;, The User Customization service definition.



 

  !	

  

  &

  1B

   P

	  �ʼ" P

 "$	

 "

 "&

 "1B

 #P

	 �ʼ"#P

 %'	

 %#

 %$B

 %Ml

 &Q

	 �ʼ"&Q
"
 ).	 User Customization


 )#

 )$B

 )Mb

 *-

	 �ʼ"*-

 /4	

 /#

 /$B

 /Mb

 03

	 �ʼ"03

 5:	

 5$

 5%D

 5Od

 69

	 �ʼ"69

 ? D User



 ?

  @

  @

  @

  @

 A

 A

 A

 A

 B

 B

 B

 B

 C

 C

 C

 C


F N


F

 G

 G

 G

 G

H

H

H

H

I*

I

I

I%

I()

J+

J

J

J&

J)*

K

K

K

K

L

L

L

L

M 

M

M

M


P T


P

 Q

 Q

 Q

 Q

R"

R

R

R

R !

S#

S

S

S!"

X ] Role



X

 Y

 Y

 Y

 Y

Z

Z

Z

Z

[

[

[

[

\

\

\

\


_ g


_

 `

 `

 `

 `

a

a

a

a

b*

b

b

b%

b()

c+

c

c

c&

c)*

d

d

d

d

e

e

e

e

f 

f

f

f


i m


i

 j

 j

 j

 j

k"

k

k

k

k !

l#

l

l

l!"
!
q v Level Customization



q

 r

 r

 r

 r

s

s

s

s

t

t

t

t

u

u

u

u

x �


x&

 y

 y

 y

 y

z

z

z

z

{*

{

{

{%

{()

|+

|

|

|&

|)*

}

}

}

}

~

~

~

~

 







� �

�'

 �

 �

 �

 �

�0

�

�#

�$+

�./

�#

�

�

�!"

 � �

 �

  �

  �

  �

 �

 �

 �

 �

 �

 �

 �

 �

 �

	� �

	�

	 �

	 �

	 �

	 �

	�

	�

	�

	�

	�*

	�

	�

	�%

	�()

	�+

	�

	�

	�&

	�)*

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

	�

		� 

		�

		�

		�

	
�+

	
�

	
�%

	
�(*

	�,

	�

	�&

	�)+

	�" panel sequence


	�

	�

	�!

	�2

	�

	�,

	�/1

	�" table sequence


	�

	�

	�!

	�2

	�

	�,

	�/1


� �


�&


 �


 �


 �


 �


�!


�


�


� 


�


�


�


�


�6


�


� 


�!1


�45

� �

�&

 �

 �

 �

 �

�!

�

�

� 

�

�

�

�

�6

�

� 

�!1

�45

� �

�'

 �

 �

 �

 �

�!

�

�

� 

�

�

�

�

�6

�

� 

�!1

�45bproto3
�.
warehouse_management.protowmsgoogle/api/annotations.protogoogle/protobuf/empty.protogoogle/protobuf/timestamp.protobase_data_type.protocore_functionality.proto"�
CreateOutBoundOrderRequest(
document_type_id (RdocumentTypeId!
warehouse_id (RwarehouseId6
sales_representative_id (RsalesRepresentativeId"�
OutBoundOrder
id (Rid
document_no (	R
documentNoE
document_type (2 .core_functionality.DocumentTypeRdocumentTypeZ
sales_representative (2'.core_functionality.SalesRepresentativeRsalesRepresentative=
document_status (2.data.DocumentStatusRdocumentStatus=
date_ordered (2.google.protobuf.TimestampRdateOrdered"7
DeleteOutBoundOrderRequest
order_id (RorderId"4
GetOutBoundOrderRequest
order_id (RorderId"�
ListOutBoundOrdersRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue!
warehouse_id (RwarehouseId
document_no	 (	R
documentNo,
order_reference_id
 (RorderReferenceId!
is_processed (RisProcessed@
pick_date_from (2.google.protobuf.TimestampRpickDateFrom<
pick_date_to (2.google.protobuf.TimestampR
pickDateTo6
sales_representative_id (RsalesRepresentativeId"�
ListOutBoundOrdersResponse!
record_count (RrecordCount;
outbound_orders (2.wms.OutBoundOrderRoutboundOrders&
next_page_token (	RnextPageToken2�
WarehouseManagements
CreateOutBoundOrder.wms.CreateOutBoundOrderRequest.wms.OutBoundOrder"'���!"/warehouse-management/orders:*y
DeleteOutBoundOrder.wms.DeleteOutBoundOrderRequest.google.protobuf.Empty")���#*!/warehouse-management/orders/{id}o
GetOutBoundOrder.wms.GetOutBoundOrderRequest.wms.OutBoundOrder")���#!/warehouse-management/orders/{id}{
ListOutBoundOrders.wms.ListOutBoundOrdersRequest.wms.ListOutBoundOrdersResponse"$���/warehouse-management/ordersB+
org.spin.backend.grpc.wmsBADempiereWMSPJ�
 i
�	
 �	************************************************************************************
 Copyright (C) 2012-2018 E.R.P. Consultores y Asociados, C.A.                      *
 Contributor(s): Yamel Senih ysenih@erpya.com                                      *
 This program is free software: you can redistribute it and/or modify              *
 it under the terms of the GNU General Public License as published by              *
 the Free Software Foundation, either version 2 of the License, or                 *
 (at your option) any later version.                                               *
 This program is distributed in the hope that it will be useful,                   *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                    *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                      *
 You should have received a copy of the GNU General Public License                 *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 2
	
 2

 -
	
 -
	
  &
	
 %
	
 )
	
 
	
 "
,
 2" Base URL
 /warehouse-management/

,
 ! 5  The Update service definition.



 !
%
  #(		Create OutBound Order


  #

  # :

  #ER

  $'

	  �ʼ"$'
%
 *,		Delete OutBound Order


 *

 * :

 *EZ

 +[

	 �ʼ"+[
$
 .0		Get a OutBound Order


 .

 .4

 .?L

 /X

	 �ʼ"/X
$
 24		List OutBound Orders


 2

 28

 2C]

 3S

	 �ʼ"3S
.
 8 <"	OutBound Order request to create



 8"

  9#

  9

  9

  9!"

 :

 :

 :

 :

 ;*

 ;

 ;%

 ;()

? F	OutBound Order



?

 @

 @

 @

 @

A

A

A

A

B:

B'

B(5

B89

CH

C.

C/C

CFG

D0

D

D+

D./

E3

E!

E".

E12
1
I K% Request for delete a outbound order



I"

 J

 J

 J

 J
.
N P" Request for get a outbound order



N

 O

 O

 O

 O
*
S b List OutBound Orders Request



S!

 T

 T

 T

 T

U

U

U

U

V*

V

V

V%

V()

W+

W

W

W&

W)*

X

X

X

X

Y

Y

Y

Y

Z 

Z

Z

Z

[

[

[

[

\

\

\

\

	]&

	]

	] 

	]#%


^


^


^


^

_6

_!

_"0

_35

`4

`!

`".

`13

a+

a

a%

a(*
+
e i	List OutBound Orders Response



e"

 f

 f

 f

 f

g3

g

g

g.

g12

h#

h

h

h!"bproto3
��
web_store.protostoregoogle/api/annotations.protogoogle/protobuf/empty.protogoogle/protobuf/timestamp.proto"�
ListOrdersRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
cart_id (RcartId"�
ListOrdersResponse!
record_count (RrecordCount$
orders (2.store.OrderRorders&
next_page_token (	RnextPageToken"a
DeleteCartItemRequest
cart_id (RcartId
sku (	Rsku

product_id (R	productId"
Empty"/
GetCartTotalsRequest
cart_id (RcartId"�
GetShippingInformationRequest
cart_id (RcartId@
shipping_address (2.store.AddressRequestRshippingAddress>
billing_address (2.store.AddressRequestRbillingAddress!
carrier_code (	RcarrierCode
method_code (	R
methodCode"�
UpdateCustomerRequest
id (Rid9
business_partner_group_id (RbusinessPartnerGroupId4
created (2.google.protobuf.TimestampRcreated4
updated (2.google.protobuf.TimestampRupdated+
organization_name (	RorganizationName
email (	Remail

first_name (	R	firstName
	last_name	 (	RlastName 
web_store_id
 (R
webStoreId

website_id (R	websiteId'
default_billing (RdefaultBilling)
default_shipping (RdefaultShipping3
	addresses (2.store.AddressRequestR	addresses"�
AddressRequest
id (Rid

first_name (	R	firstName
	last_name (	RlastName
location_id (R
locationId!
country_code (	RcountryCode
	region_id (RregionId
region_name (	R
regionName
	city_name (	RcityName
postal_code	 (	R
postalCode
phone
 (	Rphone
address1 (	Raddress1
address2 (	Raddress2
address3 (	Raddress3
address4 (	Raddress4,
is_default_billing (RisDefaultBilling.
is_default_shipping (RisDefaultShipping"�
ShippingInformation
cart (2.store.CartRcart=
payment_methods (2.store.PaymentMethodRpaymentMethods:
total_segments (2.store.TotalSegmentRtotalSegments"i

CartTotals
cart (2.store.CartRcart:
total_segments (2.store.TotalSegmentRtotalSegments"�
TotalSegment
code (	Rcode
name (	Rname
value (Rvalue
area (	Rarea/
taxes (2.store.ExtensionAttributeRtaxes"j
ExtensionAttribute
amount (Ramount
group_id (RgroupId!
rates (2.store.RateRrates".
Rate
rate (Rrate
name (	Rname"�
ListShippingMethodsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
cart_id	 (RcartId@
shipping_address
 (2.store.AddressRequestRshippingAddress"�
ListShippingMethodsResponse!
record_count (RrecordCount@
shipping_methods (2.store.ShippingMethodRshippingMethods&
next_page_token (	RnextPageToken"�
ShippingMethod
id (Rid!
carrier_code (	RcarrierCode
method_code (	R
methodCode!
carrier_name (	RcarrierName
method_name (	R
methodName
amount (Ramount
tax_rate (RtaxRate!
is_available (RisAvailable"�
ListPaymentMethodsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
cart_id (RcartId"�
ListPaymentMethodsResponse!
record_count (RrecordCount=
payment_methods (2.store.PaymentMethodRpaymentMethods&
next_page_token (	RnextPageToken"G
PaymentMethod
id (Rid
code (	Rcode
name (	Rname"�
CreateOrderRequest
cart_id (RcartId
customer_id (R
customerId
user_id (RuserId@
shipping_address (2.store.AddressRequestRshippingAddress>
billing_address (2.store.AddressRequestRbillingAddress
method_code (	R
methodCode!
carrier_code (	RcarrierCode.
payment_method_code (	RpaymentMethodCode3
products	 (2.store.ProductOrderLineRproducts1
payments
 (2.store.PaymentRequestRpayments"�
ProductOrderLine
id (Rid
quantity (Rquantity
sku (	RskuY
configurable_item_options (2.store.ConfigurableItemOptionRconfigurableItemOptions"�
PaymentRequest
bank_id (RbankId!
reference_no (	RreferenceNo 
description (	Rdescription
amount (Ramount=
payment_date (2.google.protobuf.TimestampRpaymentDate.
payment_method_code (	RpaymentMethodCode#
currency_code (	RcurrencyCode>
billing_address (2.store.AddressRequestRbillingAddress"�
Order
id (Rid
document_no (	R
documentNo4
created (2.google.protobuf.TimestampRcreated4
updated (2.google.protobuf.TimestampRupdated:

transmited (2.google.protobuf.TimestampR
transmited9
shipping_address (2.store.AddressRshippingAddress7
billing_address (2.store.AddressRbillingAddress
method_code (	R
methodCode!
carrier_code	 (	RcarrierCode.
payment_method_code
 (	RpaymentMethodCode1
order_lines (2.store.OrderLineR
orderLines"�
	OrderLine
sku (	Rsku
name (	Rname
quantity (Rquantity
price (Rprice?
product_type (2.store.OrderLine.ProductTypeRproductType"m
ProductType

SIMPLE 
CONFIGURABLE
GROUPED
VIRTUAL

BUNDLE
DOWNLOADABLE
GIFT"�
UpdateCartRequest
cart_id (RcartId
is_guest (RisGuest
sku (	Rsku
quantity (RquantityY
configurable_item_options (2.store.ConfigurableItemOptionRconfigurableItemOptions">
ConfigurableItemOption
id (	Rid
value (	Rvalue"D
GetCartRequest
cart_id (RcartId
is_guest (RisGuest".
CreateCartRequest
is_guest (RisGuest"�
Cart
id (Rid
grand_total (R
grandTotal
subtotal (Rsubtotal'
discount_amount (RdiscountAmount4
subtotal_with_discount (RsubtotalWithDiscount

tax_amount (R	taxAmount'
shipping_amount (RshippingAmount8
shipping_discount_amount (RshippingDiscountAmount.
shipping_tax_amount	 (RshippingTaxAmount7
base_shipping_tax_amount
 (RbaseShippingTaxAmount*
subtotal_incl_tax (RsubtotalInclTax*
shipping_incl_tax (RshippingInclTax,
base_currency_code (	RbaseCurrencyCode.
quote_currency_code (	RquoteCurrencyCode%
items_quantity (RitemsQuantity%
items (2.store.CartItemRitems"�
CartItem

product_id (R	productId
sku (	Rsku
quantity (Rquantity
name (	Rname
price (Rprice>
product_type (2.store.CartItem.ProductTypeRproductType
	row_total (RrowTotal5
row_total_with_discount (RrowTotalWithDiscount

tax_amount	 (R	taxAmount
tax_percent
 (R
taxPercent'
discount_amount (RdiscountAmount)
discount_percent (RdiscountPercent$
price_incl_tax (RpriceInclTax+
row_total_incl_tax (RrowTotalInclTax4
base_row_total_incl_tax (RbaseRowTotalInclTaxY
configurable_item_options (2.store.ConfigurableItemOptionRconfigurableItemOptions"m
ProductType

SIMPLE 
CONFIGURABLE
GROUPED
VIRTUAL

BUNDLE
DOWNLOADABLE
GIFT"�
GetResourceRequest
resource_id (R
resourceId#
resource_name (	RresourceName
width (Rwidth
height (RheightA
	operation (2#.store.GetResourceRequest.OperationR	operation"8
	Operation

RESIZE 
CROP
FIX
IDENTIFY"
Resource
data (Rdata"�
CreateCustomerRequest
email (	Remail

first_name (	R	firstName
	last_name (	RlastName
password (	Rpassword"
GetCustomerRequest"B
GetStockRequest
sku (	Rsku

store_code (	R	storeCode"�
ListStocksRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
sku (	Rsku

store_code	 (	R	storeCode"�
ListStocksResponse!
record_count (RrecordCount$
stocks (2.store.StockRstocks&
next_page_token (	RnextPageToken"�
ListProductsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
skus (	Rskus"�
ListProductsResponse!
record_count (RrecordCount*
products (2.store.ProductRproducts&
next_page_token (	RnextPageToken"�

Stock

product_id (R	productId
store_id (RstoreId
quantity (Rquantity
is_in_stock (R	isInStock.
is_decimal_quantity (RisDecimalQuantityN
$is_show_default_notification_message (R isShowDefaultNotificationMessageB
is_use_config_minimum_quantity (RisUseConfigMinimumQuantity)
minimum_quantity (RminimumQuantityK
#is_use_config_minimum_sale_quantity	 (RisUseConfigMinimumSaleQuantity2
minimum_sale_quantity
 (RminimumSaleQuantityK
#is_use_config_maximum_sale_quantity (RisUseConfigMaximumSaleQuantity2
maximum_sale_quantity (RmaximumSaleQuantity7
is_use_config_backorders (RisUseConfigBackorders

backorders (R
backordersK
#is_use_config_notify_stock_quantity (RisUseConfigNotifyStockQuantity2
notify_stock_quantity (RnotifyStockQuantityH
!is_use_config_quantity_increments (RisUseConfigQuantityIncrements/
quantity_increments (RquantityIncrementsU
(is_use_config_enable_quantity_increments (R#isUseConfigEnableQuantityIncrementsA
is_enable_quantity_increments (RisEnableQuantityIncrements:
is_use_config_manage_stock (RisUseConfigManageStock&
is_manage_stock (RisManageStock@
low_stock_date (2.google.protobuf.TimestampRlowStockDate,
is_decimal_divided (RisDecimalDivided9
stock_status_changed_auto (RstockStatusChangedAuto"�
Product
id (Rid
sku (	Rsku
name (	Rname
price (Rprice-
status (2.store.Product.StatusRstatus9

visibility (2.store.Product.VisibilityR
visibility(
product_group_id (RproductGroupId4
created (2.google.protobuf.TimestampRcreated4
updated	 (2.google.protobuf.TimestampRupdated#
product_links
 (	RproductLinks
tier_prices (	R
tierPrices=
custom_attributes (2.store.AttributeRcustomAttributes8
search_criteria (2.store.CriteriaRsearchCriteria"6
Status
STATUS_UNKNOW 
ENABLED
DISABLED"]

Visibility
VISIBILITY_UNKNOW 
NOT_VISIBLE

IN_CATALOG
	IN_SEARCH
BOTH"�
ListRenderProductsRequest
filters (	Rfilters
sort_by (	RsortBy#
group_columns (	RgroupColumns%
select_columns (	RselectColumns
	page_size (RpageSize

page_token (	R	pageToken!
search_value (	RsearchValue
skus (	Rskus"�
ListRenderProductsResponse!
record_count (RrecordCount=
render_products (2.store.RenderProductRrenderProducts&
next_page_token (	RnextPageToken"�
RenderProduct
id (Rid
name (	Rname
type (	Rtype
store_id (RstoreId
url (	RurlC
product_type (2 .store.RenderProduct.ProductTypeRproductType/

price_info (2.store.PriceInfoR	priceInfo"m
ProductType

SIMPLE 
CONFIGURABLE
GROUPED
VIRTUAL

BUNDLE
DOWNLOADABLE
GIFT"�
	PriceInfo
final_price (R
finalPrice
	max_price (RmaxPrice*
max_regular_price (RmaxRegularPrice2
minimal_regular_price (RminimalRegularPrice#
special_price (RspecialPrice#
minimal_price (RminimalPrice#
regular_price (RregularPrice>
formatted_price (2.store.FormattedPriceRformattedPrice;
tax_adjustment	 (2.store.TaxAdjustmentRtaxAdjustment#
currency_code
 (	RcurrencyCode"�
FormattedPrice
final_price (	R
finalPrice
	max_price (	RmaxPrice#
minimal_price (	RminimalPrice*
max_regular_price (	RmaxRegularPrice2
minimal_regular_price (	RminimalRegularPrice#
special_price (	RspecialPrice#
regular_price (	RregularPrice"�
TaxAdjustment
final_price (R
finalPrice
	max_price (RmaxPrice*
max_regular_price (RmaxRegularPrice2
minimal_regular_price (RminimalRegularPrice#
special_price (RspecialPrice#
minimal_price (RminimalPrice#
regular_price (RregularPrice'
weee_adjustment (	RweeeAdjustment>
formatted_price	 (2.store.FormattedPriceRformattedPrice"`
	Attribute%
attribute_code (	RattributeCode
value (	Rvalue
values (	Rvalues"<
Criteria0

conditions (2.store.ConditionR
conditions"�
	Condition

columnName (	R
columnName
value (	Rvalue5
operator (2.store.Condition.OperatorRoperator"�
Operator	
EQUAL 
	NOT_EQUAL
LIKE
NOT_LIKE
GREATER
GREATER_EQUAL
LESS

LESS_EQUAL
BETWEEN
NOT_NULL	
NULL

IN

NOT_IN"�
Customer
id (Rid9
business_partner_group_id (RbusinessPartnerGroupId4
created (2.google.protobuf.TimestampRcreated4
updated (2.google.protobuf.TimestampRupdated+
organization_name (	RorganizationName
email (	Remail

first_name (	R	firstName
	last_name (	RlastName 
web_store_id	 (R
webStoreId

website_id
 (R	websiteId,
	addresses (2.store.AddressR	addresses"�
Address
id (Rid

first_name (	R	firstName
	last_name (	RlastName%
region (2.store.RegionRregion
city (2.store.CityRcity
address1 (	Raddress1
address2 (	Raddress2
address3 (	Raddress3
address4	 (	Raddress4
phone
 (	Rphone
postal_code (	R
postalCode!
country_code (	RcountryCode.
is_default_shipping (RisDefaultShipping,
is_default_billing (RisDefaultBilling"*
City
id (Rid
name (	Rname",
Region
id (Rid
name (	Rname"I
ResetPasswordRequest
	user_name (	RuserName
email (	Remail"�
ResetPasswordResponseN
response_type (2).store.ResetPasswordResponse.ResponseTypeRresponseType"J
ResponseType
OK 
USER_NOT_FOUND
TOKEN_NOT_FOUND	
ERROR"e
ChangePasswordRequest)
current_password (	RcurrentPassword!
new_password (	RnewPassword"�
ChangePasswordResponseO
response_type (2*.store.ChangePasswordResponse.ResponseTypeRresponseType"J
ResponseType
OK 
USER_NOT_FOUND
TOKEN_NOT_FOUND	
ERROR2�
WebStorea
CreateCustomer.store.CreateCustomerRequest.store.Customer" ���"/store/web-store/user:*{
ResetPassword.store.ResetPasswordRequest.store.ResetPasswordResponse"/���)"$/store/web-store/user/reset-password:*
ChangePassword.store.ChangePasswordRequest.store.ChangePasswordResponse"0���*"%/store/web-store/user/change-password:*[
GetCustomer.store.GetCustomerRequest.store.Customer" ���/store/web-store/user/med
UpdateCustomer.store.UpdateCustomerRequest.store.Customer"#���"/store/web-store/user/me:*V
GetStock.store.GetStockRequest.store.Stock"$���/store/web-store/stock/{sku}l

ListStocks.store.ListStocksRequest.store.ListStocksResponse")���#!/store/web-store/stock/list/{sku}n
ListProducts.store.ListProductsRequest.store.ListProductsResponse"%���/store/web-store/product/list�
ListRenderProducts .store.ListRenderProductsRequest!.store.ListRenderProductsResponse",���&$/store/web-store/product/render-listY
GetResource.store.GetResourceRequest.store.Resource"���/store/web-store/img0\

CreateCart.store.CreateCartRequest.store.Cart"'���!"/store/web-store/cart/create:*Q
GetCart.store.GetCartRequest.store.Cart""���/store/web-store/cart/pull`

UpdateCart.store.UpdateCartRequest.store.CartItem"'���!"/store/web-store/cart/update:*`
CreateOrder.store.CreateOrderRequest.store.Order"(���""/store/web-store/order/create:*�
ListPaymentMethods .store.ListPaymentMethodsRequest!.store.ListPaymentMethodsResponse"-���'%/store/web-store/cart/payment-methods�
ListShippingMethods!.store.ListShippingMethodsRequest".store.ListShippingMethodsResponse".���(&/store/web-store/cart/shipping-methods�
GetShippingInformation$.store.GetShippingInformationRequest.store.ShippingInformation"2���,*/store/web-store/cart/shipping-informatione
GetCartTotals.store.GetCartTotalsRequest.store.CartTotals"$���/store/web-store/cart/totalso
DeleteCartItem.store.DeleteCartItemRequest.google.protobuf.Empty"'���!"/store/web-store/cart/delete:*n

ListOrders.store.ListOrdersRequest.store.ListOrdersResponse"+���%#/store/web-store/user/order-historyB2
org.spin.backend.grpc.storeBADempiereWebStorePJ��
 �
�	
 �	***********************************************************************************
 Copyright (C) 2012-2018 E.R.P. Consultores y Asociados, C.A.                     *
 Contributor(s): Yamel Senih ysenih@erpya.com                                     *
 This program is free software: you can redistribute it and/or modify             *
 it under the terms of the GNU General Public License as published by             *
 the Free Software Foundation, either version 2 of the License, or                *
 (at your option) any later version.                                              *
 This program is distributed in the hope that it will be useful,                  *
 but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                     *
 GNU General Public License for more details.                                     *
 You should have received a copy of the GNU General Public License                *
 along with this program. If not, see <https://www.gnu.org/licenses/>.            *
**********************************************************************************

 "
	

 "

 4
	
 4

 2
	
 2
	
  &
	
 %
	
 )
'
 2 Base URL
 /store/web-store/

X
  �K	Web Store Service used for ADempiere integration with vue store front api



 
6
   %	(	Create Customer: POST /api/user/create


   

   0

   ;C

  !$

	  �ʼ"!$
I
 ',	;  Reset Password from Store: POST /api/user/reset-password


 '

 '.

 '9N

 (+

	 �ʼ"(+
@
 .3	2  Change Password: POST /api/user/change-password


 .

 .0

 .;Q

 /2

	 �ʼ"/2
/
 57	!  Get Customer: GET /api/user/me


 5

 5*

 55=

 6O

	 �ʼ"6O
6
 9>	(	Update Cutomer Info: POST /api/user/me


 9

 90

 9;C

 :=

	 �ʼ":=
4
 @B	&  Get Stock: GET /api/stock/check/sku


 @

 @$

 @/4

 AS

	 �ʼ"AS
0
 DF	"  List Stock: GET /api/stock/list


 D

 D(

 D3E

 EX

	 �ʼ"EX
5
 HJ	'  List Products: GET /api/product/list


 H

 H,

 H7K

 IT

	 �ʼ"IT
<
 LN	.  List Products: GET /api/product/render-list


 L

 L8

 LC]

 M[

	 �ʼ"M[
E
 	PR	7	Service for get a resource from resource id: GET /img


 	P

 	P*

 	P5;

 	P<D

 	QK

	 	�ʼ"QK
2
 
TY	$	Create Cart: POST /api/cart/create


 
T

 
T(

 
T37

 
UX

	 
�ʼ"UX
-
 []		Pull Cart: GET /api/cart/pull


 [

 ["

 [-1

 \Q

	 �ʼ"\Q
2
 _d	$	Update Cart: POST /api/cart/update


 _

 _(

 _3;

 `c

	 �ʼ"`c
4
 fk	&	Create Order: POST /api/order/create


 f

 f*

 f5:

 gj

	 �ʼ"gj
B
 mo	4	Get Payment Methods: GET /api/cart/payment-methods


 m

 m8

 mC]

 n\

	 �ʼ"n\
E
 qs	7	Get Shipping Methods: POST /api/cart/shipping-methods


 q

 q :

 qE`

 r]

	 �ʼ"r]
M
 uw	?	Get Shipping Information: POST /api/cart/shipping-information


 u"

 u#@

 uK^

 va

	 �ʼ"va
5
 y{	'	Get Cart Totals: GET /api/cart/totals


 y

 y.

 y9C

 zS

	 �ʼ"zS
1
 }�	"	Post Cart: POST /api/cart/delete


 }

 }0

 };P

 ~�

	 �ʼ"~�
A
 ��	1	GET Orders History: GET /api/user/order-history


 �

 �(

 �3E

 �Z

	 �ʼ"�Z
d
 � �V	https://sfa-docs.now.sh/guide/default-modules/api.html#get-vsbridgeuserorder-history


 �

  �

  �

  �

  �

 �

 �

 �

 �

 �*

 �

 �

 �%

 �()

 �+

 �

 �

 �&

 �)*

 �

 �

 �

 �

 �

 �

 �

 �

 � 

 �

 �

 �

 �

 �

 �

 �

� �	List of Orders


�

 �

 �

 �

 �

�"

�

�

�

� !

�#

�

�

�!"
b
� �T	https://docs.storefrontapi.com/guide/default-modules/api.html#post-api-cart-delete


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

� �  Empty message


�
a
� �S	https://docs.storefrontapi.com/guide/default-modules/api.html#get-api-cart-totals


�

 �

 �

 �

 �
p
� �b	https://docs.storefrontapi.com/guide/default-modules/api.html#post-api-cart-shipping-information


�%

 �

 �

 �

 �

�,

�

�'

�*+

�+

�

�&

�)*

� 

�

�

�

�

�

�

�
^
� �P	https://docs.storefrontapi.com/guide/default-modules/api.html#post-api-user-me


�

 �

 �

 �

 �

�,

�

�'

�*+

�.

�!

�")

�,-

�.

�!

�")

�,-

�%

�

� 

�#$

�

�

�

�

�

�

�

�

�

�

�

�

� 

�

�

�

	�

	�

	�

	�


�#


�


�


� "

�$

�

�

�!#

�/

�

�

� )

�,.
/
� �!	Address information for request


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

	�

	�

	�

	�


�


�


�


�

�

�

�

�

�

�

�

�

�

�

�

�

�%

�

�

�"$

�&

�

� 

�#%
.
� � 	Shipping Information for Order


�

 �

 �

 �

 �

�3

�

�

�.

�12

�1

�

�

�,

�/0

	� �	Cart Totals


	�

	 �

	 �

	 �

	 �

	�1

	�

	�

	�,

	�/0
!

� �	Segment for Total



�


 �


 �


 �


 �


�


�


�


�


�


�


�


�


�


�


�


�


�.


�


�#


�$)


�,-
,
� �	Attribute for Total Segments


�

 �

 �

 �

 �

�

�

�

�

� 

�

�

�

�

� �
	Tax Rate


�

 �

 �

 �

 �

�

�

�

�
l
� �^	https://docs.storefrontapi.com/guide/default-modules/api.html#post-api-cart-shipping-methods


�"

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

�-

�

�'

�*,
'
� �	List of Payment Methods


�#

 �

 �

 �

 �

�5

�

�

� 0

�34

�#

�

�

�!"

� �	Shipping Method


�

 �

 �

 �

 �

� 

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�
j
� �\	https://docs.storefrontapi.com/guide/default-modules/api.html#get-api-cart-payment-methods


�!

 �

 �

 �

 �

�

�

�

�

�*

�

�

�%

�()

�+

�

�

�&

�)*

�

�

�

�

�

�

�

�

� 

�

�

�

�

�

�

�
'
� �	List of Payment Methods


�"

 �

 �

 �

 �

�3

�

�

�.

�12

�#

�

�

�!"

� �	Payment Method


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�
c
� �U	https://docs.storefrontapi.com/guide/default-modules/api.html#post-api-order-create


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�,

�

�'

�*+

�+

�

�&

�)*

�

�

�

�

� 

�

�

�

�'

�

�"

�%&

�/

�

�!

�"*

�-.

	�.

	�

	�

	� (

	�+-
2
� �$	Product used for create order line


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�F

�

�'

�(A

�DE
*
� �	Payment detail for request


�

 �

 �

 �

 �

� 

�

�

�

�

�

�

�

�

�

�

�

�3

�!

�".

�12

�'

�

�"

�%&

�!

�

�

� 

�+

�

�&

�)*

� �	Order


�

 �

 �

 �

 �

�

�

�

�

�.

�!

�")

�,-

�.

�!

�")

�,-

�1

�!

�",

�/0

�%

�

� 

�#$

�$

�

�

�"#

�

�

�

�

� 

�

�

�

	�(

	�

	�"

	�%'


�,


�


�


�&


�)+
#
� �	Order Line response


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

 ��	

 � 
 
  �	Simple Product


  �

  �
&
 �!	Configurable Product


 �

 � 
!
 �	Grouped Product


 �

 �
!
 �	Virtual Product


 �

 �
 
 �	Bundle Product


 �

 �
&
 �!	Downloadable Product


 �

 � 

 �	Gift Cards


 �

 �

�%

�

� 

�#$
b
� �T	https://docs.storefrontapi.com/guide/default-modules/api.html#post-api-cart-update


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�F

�

�'

�(A

�DE
,
� �	Configurable Product Options


�

 �

 �

 �

 �

�

�

�

�
_
� �Q	https://docs.storefrontapi.com/guide/default-modules/api.html#get-api-cart-pull


�

 �

 �

 �

 �

�

�

�

�
b
� �T https://docs.storefrontapi.com/guide/default-modules/api.html#post-api-cart-create


�

 �

 �

 �

 �

� �	Cart for store


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�#

�

�

�!"

�*

�

�%

�()

�

�

�

�

�#

�

�

�!"

�,

�

�'

�*+

�'

�

�"

�%&

	�-

	�

	�'

	�*,


�&


�


� 


�#%

�&

�

� 

�#%

�'

�

�!

�$&

�(

�

�"

�%'

�"

�

�

�!

�%

�

�

�

�"$

� �	Cart Item


�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

 ��	

 �
 
  �	Simple Product


  �

  �
&
 �!	Configurable Product


 �

 � 
!
 �	Grouped Product


 �

 �
!
 �	Virtual Product


 �

 �
 
 �	Bundle Product


 �

 �
&
 �!	Downloadable Product


 �

 � 

 �	Gift Cards


 �

 �

�%

�

� 

�#$

�

�

�

�

�+

�

�&

�)*

�

�

�

�

	� 

	�

	�

	�


�$


�


�


�!#

�%

�

�

�"$

�#

�

�

� "

�'

�

�!

�$&

�,

�

�&

�)+

�G

�

�'

�(A

�DF
Z
� �L https://docs.storefrontapi.com/guide/default-modules/api.html#image-module


�

 �

 �

 �

 �

�!

�

�

� 

�

�

�

�

�

�

�

�

 ��	

 �

  �

  �

  �

 �

 �

 �

 �

 �

 �

 �

 �

 �

� 	Operation


�

�

�

� � Resource Chunk


�

 �

 �	

 �


 �
b
 � �T	https://docs.storefrontapi.com/guide/default-modules/api.html#post-api-user-create


 �

  �

  �

  �

  �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �
]
!� �O	https://docs.storefrontapi.com/guide/default-modules/api.html#get-api-user-me


!�
e
"� �W	https://docs.storefrontapi.com/guide/default-modules/api.html#get-api-stock-check-sku


"�

" �

" �

" �

" �

"�

"�

"�

"�
`
#� �R	https://docs.storefrontapi.com/guide/default-modules/api.html#get-api-stock-list


#�

# �

# �

# �

# �

#�

#�

#�

#�

#�*

#�

#�

#�%

#�()

#�+

#�

#�

#�&

#�)*

#�

#�

#�

#�

#�

#�

#�

#�

#� 

#�

#�

#�

#�

#�

#�

#�

#�

#�

#�

#�

$� �	List of Stock


$�

$ �

$ �

$ �

$ �

$�"

$�

$�

$�

$� !

$�#

$�

$�

$�!"
^
%� �P	https://docs.storefrontapi.com/guide/default-modules/api.html#api-product-list


%�

% �

% �

% �

% �

%�

%�

%�

%�

%�*

%�

%�

%�%

%�()

%�+

%�

%�

%�&

%�)*

%�

%�

%�

%�

%�

%�

%�

%�

%� 

%�

%�

%�

%�!

%�

%�

%�

%� 
 
&� �	List of Products


&�

& �

& �

& �

& �

&�&

&�

&�

&�!

&�$%

&�#

&�

&�

&�!"

'� �	Stock


'�

' �

' �

' �

' �

'�

'�

'�

'�

'�

'�

'�

'�

'�

'�

'�

'�

'�%

'�

'� 

'�#$

'�6

'�

'�1

'�45

'�0

'�

'�+

'�./

'� 

'�


'�

'�

'�1

'�

'�	,

'�/0

'	�&

'	�


'	� 

'	�#%

'
�2

'
�

'
�	,

'
�/1

'�&

'�


'� 

'�#%

'�'

'�

'�	!

'�$&

'�

'�


'�

'�

'�2

'�

'�	,

'�/1

'�&

'�


'� 

'�#%

'�0

'�

'�	*

'�-/

'�$

'�


'�

'�!#

'�7

'�

'�	1

'�46

'�,

'�

'�	&

'�)+

'�)

'�

'�	#

'�&(

'�

'�

'�	

'�

'�2

'�

'�,

'�/1

'�!

'�

'�	

'� 

'�*

'�


'�$

'�')

(� �		Product


(�

( �

( �

( �

( �

(�

(�

(�

(�

(�

(�

(�

(�

(�

(�

(�

(�

( ��	

( �

(  �"

(  �

(  � !

( �

( �

( �

( �

( �

( �

(�

(�

(�

(�

(��	

(�

( �&

( �!

( �$%

(� 

(�

(�

(�

(�

(�

(�

(�

(�

(�

(�

(�

(�"

(�

(�

(� !

(�#

(�

(�

(�!"

(�.

(�!

(�")

(�,-

(�.

(�!

(�")

(�,-

(	�+

(	�

(	�

(	�%

(	�(*

(
�)

(
�

(
�

(
�#

(
�&(

(�2

(�

(�

(�,

(�/1

(�&

(�

(� 

(�#%
^
)� �P	https://docs.storefrontapi.com/guide/default-modules/api.html#api-product-list


)�!

) �

) �

) �

) �

)�

)�

)�

)�

)�*

)�

)�

)�%

)�()

)�+

)�

)�

)�&

)�)*

)�

)�

)�

)�

)�

)�

)�

)�

)� 

)�

)�

)�

)�!

)�

)�

)�

)� 
)
*� �	List of Products Rendered


*�"

* �

* �

* �

* �

*�3

*�

*�

*�.

*�12

*�#

*�

*�

*�!"
 
+� �	Product Rendered


+�

+ �

+ �

+ �

+ �

+�

+�

+�

+�

+�

+�

+�

+�

+�

+�

+�

+�

+�

+�

+�

+�

+ ��	

+ �
 
+  �	Simple Product


+  �

+  �
&
+ �!	Configurable Product


+ �

+ � 
!
+ �	Grouped Product


+ �

+ �
!
+ �	Virtual Product


+ �

+ �
 
+ �	Bundle Product


+ �

+ �
&
+ �!	Downloadable Product


+ �

+ � 

+ �	Gift Cards


+ �

+ �

+�%

+�

+� 

+�#$

+�!

+�

+�

+� 
"
,� �	Product Price Info


,�

, �

, �

, �

, �

,�

,�

,�

,�

,�%

,�

,� 

,�#$

,�)

,�

,�$

,�'(

,�!

,�

,�

,� 

,�!

,�

,�

,� 

,�!

,�

,�

,� 

,�+

,�

,�&

,�)*

,�)

,�

,�$

,�'(

,	�"

,	�

,	�

,	�!

-� �	Formatted Price


-�

- �

- �

- �

- �

-�

-�

-�

-�

-�!

-�

-�

-� 

-�%

-�

-� 

-�#$

-�)

-�

-�$

-�'(

-�!

-�

-�

-� 

-�!

-�

-�

-� 

.� �	Tax Adjustments


.�

. �

. �

. �

. �

.�

.�

.�

.�

.�%

.�

.� 

.�#$

.�)

.�

.�$

.�'(

.�!

.�

.�

.� 

.�!

.�

.�

.� 

.�!

.�

.�

.� 

.�#

.�

.�

.�!"

.�+

.�

.�&

.�)*

/� �	Attribute


/�

/ �"

/ �

/ �

/ � !

/�

/�

/�

/�

/�#

/�

/�

/�

/�!"

0� �	Condition


0�

0 �*

0 �

0 �

0 �%

0 �()
(
1� � Condition for query data


1�

1 �

1 �

1 �

1 �

1�

1�

1�

1�

1 ��	

1 �

1  �

1  �

1  �

1 �

1 �

1 �

1 �

1 �

1 �

1 �

1 �

1 �

1 �

1 �

1 �

1 �"

1 �

1 � !

1 �

1 �

1 �

1 �

1 �

1 �

1 �

1 �

1 �

1 	�

1 	�

1 	�

1 
�

1 
�

1 
�

1 �

1 �

1 �

1 �

1 �

1 �

1�	Operators


1�

1�

1�

2� �


2�

2 �

2 �

2 �

2 �

2�,

2�

2�'

2�*+

2�.

2�!

2�")

2�,-

2�.

2�!

2�")

2�,-

2�%

2�

2� 

2�#$

2�

2�

2�

2�

2�

2�

2�

2�

2�

2�

2�

2�

2�

2�

2�

2�

2	�

2	�

2	�

2	�

2
�(

2
�

2
�

2
�"

2
�%'

3� �		Address


3�

3 �

3 �

3 �

3 �

3�

3�

3�

3�

3�

3�

3�

3�

3�
	Location


3�

3�

3�

3�

3�

3�

3�

3�

3�

3�

3�

3�

3�

3�

3�

3�

3�

3�

3�

3�

3�

3�

3�

3	�

3	�

3	�

3	�

3
� 

3
�

3
�

3
�

3�!

3�

3�

3� 

3�&

3�

3� 

3�#%

3�%

3�

3�

3�"$

4� �	City


4�

4 �

4 �

4 �

4 �

4�

4�

4�

4�

5� �	Region


5�

5 �

5 �

5 �

5 �

5�

5�

5�

5�
j
6� �\ https://docs.storefrontapi.com/guide/default-modules/api.html#post-api-user-reset-password


6�

6 �

6 �

6 �

6 �

6�

6�

6�

6�
'
7� � Reset Password Response


7�

7 ��	

7 �

7  �

7  �

7  �

7 �#

7 �

7 �!"

7 �$

7 �

7 �"#

7 �

7 �

7 �

7 �'

7 �

7 �"

7 �%&
k
8� �] https://docs.storefrontapi.com/guide/default-modules/api.html#post-api-user-change-password


8�

8 �$

8 �

8 �

8 �"#

8� 

8�

8�

8�
(
9� � Change Password Response


9�

9 ��	

9 �

9  �

9  �

9  �

9 �#

9 �

9 �!"

9 �$

9 �

9 �"#

9 �

9 �

9 �

9 �'

9 �

9 �"

9 �%&bproto3