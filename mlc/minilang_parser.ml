/*
Copyright 2026 Nils Kopal

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// Tokenizer, AST records and recursive-descent parser for MiniLang syntax.
//! Provides the mlc minilang_parser package.

package mlc.minilang_parser
import std.string as s
import std.string_builder as sb
import mlc.tools as t

#if TARGET_OS == "windows"
/// Returns parse strtod.
/// @internal
extern function _parse_strtod(text as cstr, endptr as ptr) from "msvcrt.dll" symbol "strtod" returns double
#else
/// Returns parse strtod.
/// @internal
extern function _parse_strtod(text as cstr, endptr as ptr) from "libc.so.6" symbol "strtod" returns double
#endif

/// Parser failure with absolute source offset and originating filename.
struct ParseError
  /// Diagnostic message carried by `ParseError`.
  message,
  /// Pos associated with `ParseError`.
  pos,
  /// Filename associated with `ParseError`.
  filename,
end struct

/// Lexical token preserving raw value and absolute source offset.
struct Token
  /// Kind associated with `Token`.
  kind,
  /// Value associated with `Token`.
  value,
  /// Pos associated with `Token`.
  pos,
end struct

/// Structure-of-arrays token arena. Parser cursors are integer IDs; kinds use one byte and positions/text IDs use packed u32 columns. Identifier, keyword and operator spellings are module-local symbols instead of per-token strings.
struct TokenArena
  /// Kinds associated with `TokenArena`.
  kinds,
  /// Value ids associated with `TokenArena`.
  value_ids,
  /// Positions associated with `TokenArena`.
  positions,
  /// Texts associated with `TokenArena`.
  texts,
  /// Text index associated with `TokenArena`.
  text_index,
  /// Count associated with `TokenArena`.
  count,
  /// Allocated capacity of `TokenArena`.
  cap,
end struct

/// Converts tok text part.
/// @internal
function _tok_text_part(v)
  tv = typeof(v)
  if tv == "string" then return v end if
  if tv == "int" then return "" + v end if
  if tv == "bool" then return "" + v end if
  if tv == "float" then return "" + v end if
  if tv == "void" then return "void" end if
  return "<value>"
end function

/// Converts tok desc.
/// @internal
function _tok_desc(tok)
  k = _tok_kind(tok)
  v = _tok_value(tok)
  if typeof(k) != "string" or k == "" then return "<token>" end if
  return _tok_text_part(k) + ":" + _tok_text_part(v)
end function

/// Capacity-backed parser list tail used to avoid repeated array concatenation.
struct ParserChunkTail
  /// Backing data owned by `ParserChunkTail`.
  data,
  /// Number of populated entries in `ParserChunkTail`.
  used,
  /// Allocated capacity of `ParserChunkTail`.
  cap,
end struct

/// Internal marker that distinguishes spare capacity from a real void element.
struct ParserChunkVoidSentinel
  /// Tag associated with `ParserChunkVoidSentinel`.
  tag,
end struct

/// Expression AST. Every node carries source coordinates for later diagnostics.
struct Num
  /// Node kind associated with `Num`.
  node_kind,
  /// Value associated with `Num`.
  value,
  /// Pos associated with `Num`.
  _pos,
  /// Filename associated with `Num`.
  _filename,
end struct

/// Represents str.
struct Str
  /// Node kind associated with `Str`.
  node_kind,
  /// Value associated with `Str`.
  value,
  /// Pos associated with `Str`.
  _pos,
  /// Filename associated with `Str`.
  _filename,
end struct

/// Represents bool.
struct Bool
  /// Node kind associated with `Bool`.
  node_kind,
  /// Value associated with `Bool`.
  value,
  /// Pos associated with `Bool`.
  _pos,
  /// Filename associated with `Bool`.
  _filename,
end struct

/// Represents void lit.
struct VoidLit
  /// Node kind associated with `VoidLit`.
  node_kind,
  /// Pos associated with `VoidLit`.
  _pos,
  /// Filename associated with `VoidLit`.
  _filename,
end struct

/// Represents var.
struct Var
  /// Node kind associated with `Var`.
  node_kind,
  /// Name associated with `Var`.
  name,
  /// Pos associated with `Var`.
  _pos,
  /// Filename associated with `Var`.
  _filename,
end struct

/// Represents array lit.
struct ArrayLit
  /// Node kind associated with `ArrayLit`.
  node_kind,
  /// Items associated with `ArrayLit`.
  items,
  // Internal-only marker: a proven non-escaping variadic tail may live in the
  // caller's rooted expression stack instead of allocating a heap array.
  /// Stack variadic associated with `ArrayLit`.
  stack_variadic,
  /// Pos associated with `ArrayLit`.
  _pos,
  /// Filename associated with `ArrayLit`.
  _filename,
end struct

/// Represents unary.
struct Unary
  /// Node kind associated with `Unary`.
  node_kind,
  /// Op associated with `Unary`.
  op,
  /// Right associated with `Unary`.
  right,
  /// Pos associated with `Unary`.
  _pos,
  /// Filename associated with `Unary`.
  _filename,
end struct

/// Represents bin.
struct Bin
  /// Node kind associated with `Bin`.
  node_kind,
  /// Left associated with `Bin`.
  left,
  /// Op associated with `Bin`.
  op,
  /// Right associated with `Bin`.
  right,
  /// Pos associated with `Bin`.
  _pos,
  /// Filename associated with `Bin`.
  _filename,
end struct

/// Represents is type.
struct IsType
  /// Node kind associated with `IsType`.
  node_kind,
  /// Expr associated with `IsType`.
  expr,
  /// Type name associated with `IsType`.
  type_name,
  /// Negated associated with `IsType`.
  negated,
  /// Pos associated with `IsType`.
  _pos,
  /// Filename associated with `IsType`.
  _filename,
end struct

/// Runtime guard inserted at explicitly annotated type boundaries.
struct TypeGuard
  /// Node kind associated with `TypeGuard`.
  node_kind,
  /// Expr associated with `TypeGuard`.
  expr,
  /// Type name associated with `TypeGuard`.
  type_name,
  /// Optional associated with `TypeGuard`.
  optional,
  /// Pos associated with `TypeGuard`.
  _pos,
  /// Filename associated with `TypeGuard`.
  _filename,
end struct

/// Lazy void coalescing (`left ?? right`).
struct Coalesce
  /// Node kind associated with `Coalesce`.
  node_kind,
  /// Left associated with `Coalesce`.
  left,
  /// Right associated with `Coalesce`.
  right,
  /// Pos associated with `Coalesce`.
  _pos,
  /// Filename associated with `Coalesce`.
  _filename,
end struct

/// Represents call.
struct Call
  /// Node kind associated with `Call`.
  node_kind,
  /// Callee associated with `Call`.
  callee,
  /// Args associated with `Call`.
  args,
  /// Arg names associated with `Call`.
  arg_names,
  /// Pos associated with `Call`.
  _pos,
  /// Filename associated with `Call`.
  _filename,
end struct

/// Represents index.
struct Index
  /// Node kind associated with `Index`.
  node_kind,
  /// Target associated with `Index`.
  target,
  /// Index associated with `Index`.
  index,
  /// Pos associated with `Index`.
  _pos,
  /// Filename associated with `Index`.
  _filename,
end struct

/// Represents member.
struct Member
  /// Node kind associated with `Member`.
  node_kind,
  /// Target associated with `Member`.
  target,
  /// Name associated with `Member`.
  name,
  /// Pos associated with `Member`.
  _pos,
  /// Filename associated with `Member`.
  _filename,
end struct

/// Void-safe member access (`value?.member`).
struct SafeMember
  /// Node kind associated with `SafeMember`.
  node_kind,
  /// Target associated with `SafeMember`.
  target,
  /// Name associated with `SafeMember`.
  name,
  /// Pos associated with `SafeMember`.
  _pos,
  /// Filename associated with `SafeMember`.
  _filename,
end struct

/// Parser-only anonymous function lowered to an ordinary nested closure.
struct Lambda
  /// Node kind associated with `Lambda`.
  node_kind,
  /// Params associated with `Lambda`.
  params,
  /// Body associated with `Lambda`.
  body,
  /// Param types associated with `Lambda`.
  param_types,
  /// Param optional associated with `Lambda`.
  param_optional,
  /// Param defaults associated with `Lambda`.
  param_defaults,
  /// Variadic index associated with `Lambda`.
  variadic_index,
  /// Return type associated with `Lambda`.
  return_type,
  /// Return optional associated with `Lambda`.
  return_optional,
  /// Pos associated with `Lambda`.
  _pos,
  /// Filename associated with `Lambda`.
  _filename,
end struct

/// Compiler-internal expression used while emitting deferred calls.
struct DeferredCapture
  /// Node kind associated with `DeferredCapture`.
  node_kind,
  /// Offset associated with `DeferredCapture`.
  offset,
  /// Pos associated with `DeferredCapture`.
  _pos,
  /// Filename associated with `DeferredCapture`.
  _filename,
end struct

/// Statement/declaration AST shared by analysis and code generation.
struct Import
  /// Node kind associated with `Import`.
  node_kind,
  /// Path associated with `Import`.
  path,
  /// Alias associated with `Import`.
  alias,
  /// Module associated with `Import`.
  module,
  /// Pos associated with `Import`.
  _pos,
  /// Filename associated with `Import`.
  _filename,
end struct

/// Represents namespace decl.
struct NamespaceDecl
  /// Node kind associated with `NamespaceDecl`.
  node_kind,
  /// Name associated with `NamespaceDecl`.
  name,
  /// Pos associated with `NamespaceDecl`.
  _pos,
  /// Filename associated with `NamespaceDecl`.
  _filename,
end struct

/// Represents namespace def.
struct NamespaceDef
  /// Node kind associated with `NamespaceDef`.
  node_kind,
  /// Name associated with `NamespaceDef`.
  name,
  /// Body associated with `NamespaceDef`.
  body,
  /// Pos associated with `NamespaceDef`.
  _pos,
  /// Filename associated with `NamespaceDef`.
  _filename,
end struct

/// Represents print.
struct Print
  /// Node kind associated with `Print`.
  node_kind,
  /// Expr associated with `Print`.
  expr,
  /// Pos associated with `Print`.
  _pos,
  /// Filename associated with `Print`.
  _filename,
end struct

/// Represents assign.
struct Assign
  /// Node kind associated with `Assign`.
  node_kind,
  /// Name associated with `Assign`.
  name,
  /// Expr associated with `Assign`.
  expr,
  /// Declared type associated with `Assign`.
  declared_type,
  /// Declared optional associated with `Assign`.
  declared_optional,
  /// Pos associated with `Assign`.
  _pos,
  /// Filename associated with `Assign`.
  _filename,
end struct

/// Represents synchronized decl.
struct SynchronizedDecl
  /// Node kind associated with `SynchronizedDecl`.
  node_kind,
  /// Name associated with `SynchronizedDecl`.
  name,
  /// Expr associated with `SynchronizedDecl`.
  expr,
  /// Pos associated with `SynchronizedDecl`.
  _pos,
  /// Filename associated with `SynchronizedDecl`.
  _filename,
end struct

/// Represents synchronized block.
struct SynchronizedBlock
  /// Node kind associated with `SynchronizedBlock`.
  node_kind,
  /// Lock associated with `SynchronizedBlock`.
  lock,
  /// Body associated with `SynchronizedBlock`.
  body,
  /// Cleanup associated with `SynchronizedBlock`.
  cleanup,
  /// Pos associated with `SynchronizedBlock`.
  _pos,
  /// Filename associated with `SynchronizedBlock`.
  _filename,
end struct

/// Represents set member.
struct SetMember
  /// Node kind associated with `SetMember`.
  node_kind,
  /// Obj associated with `SetMember`.
  obj,
  /// Field associated with `SetMember`.
  field,
  /// Expr associated with `SetMember`.
  expr,
  /// Pos associated with `SetMember`.
  _pos,
  /// Filename associated with `SetMember`.
  _filename,
end struct

/// Represents set index.
struct SetIndex
  /// Node kind associated with `SetIndex`.
  node_kind,
  /// Target associated with `SetIndex`.
  target,
  /// Index associated with `SetIndex`.
  index,
  /// Expr associated with `SetIndex`.
  expr,
  /// Pos associated with `SetIndex`.
  _pos,
  /// Filename associated with `SetIndex`.
  _filename,
end struct

/// Represents const decl.
struct ConstDecl
  /// Node kind associated with `ConstDecl`.
  node_kind,
  /// Name associated with `ConstDecl`.
  name,
  /// Expr associated with `ConstDecl`.
  expr,
  /// Pos associated with `ConstDecl`.
  _pos,
  /// Filename associated with `ConstDecl`.
  _filename,
end struct

/// Represents expr stmt.
struct ExprStmt
  /// Node kind associated with `ExprStmt`.
  node_kind,
  /// Expr associated with `ExprStmt`.
  expr,
  /// Pos associated with `ExprStmt`.
  _pos,
  /// Filename associated with `ExprStmt`.
  _filename,
end struct

/// Represents function def.
struct FunctionDef
  /// Node kind associated with `FunctionDef`.
  node_kind,
  /// Name associated with `FunctionDef`.
  name,
  /// Params associated with `FunctionDef`.
  params,
  /// Body associated with `FunctionDef`.
  body,
  /// Whether `FunctionDef.is_static` indicates static.
  is_static,
  /// Whether `FunctionDef.is_inline` indicates inline.
  is_inline,
  /// Whether `FunctionDef.is_synchronized` indicates synchronized.
  is_synchronized,
  /// Param types associated with `FunctionDef`.
  param_types,
  /// Param optional associated with `FunctionDef`.
  param_optional,
  /// Param defaults associated with `FunctionDef`.
  param_defaults,
  /// Variadic index associated with `FunctionDef`.
  variadic_index,
  /// Return type associated with `FunctionDef`.
  return_type,
  /// Return optional associated with `FunctionDef`.
  return_optional,
  /// Whether `FunctionDef.is_async` indicates async.
  is_async,
  /// Whether `FunctionDef.is_iterator` indicates iterator.
  is_iterator,
  /// Ml locals associated with `FunctionDef`.
  _ml_locals,
  /// Ml globals declared associated with `FunctionDef`.
  _ml_globals_declared,
  /// Ml captures associated with `FunctionDef`.
  _ml_captures,
  /// Ml capture depth associated with `FunctionDef`.
  _ml_capture_depth,
  /// Ml nested functions associated with `FunctionDef`.
  _ml_nested_functions,
  /// Ml parent fn associated with `FunctionDef`.
  _ml_parent_fn,
  /// Ml boxed associated with `FunctionDef`.
  _ml_boxed,
  /// Ml env slots associated with `FunctionDef`.
  _ml_env_slots,
  /// Ml env index associated with `FunctionDef`.
  _ml_env_index,
  /// Ml capture index associated with `FunctionDef`.
  _ml_capture_index,
  /// Ml env hop associated with `FunctionDef`.
  _ml_env_hop,
  /// Pos associated with `FunctionDef`.
  _pos,
  /// Filename associated with `FunctionDef`.
  _filename,
end struct

/// Represents return.
struct Return
  /// Node kind associated with `Return`.
  node_kind,
  /// Expr associated with `Return`.
  expr,
  /// Pos associated with `Return`.
  _pos,
  /// Filename associated with `Return`.
  _filename,
end struct

/// Represents yield.
struct Yield
  /// Node kind associated with `Yield`.
  node_kind,
  /// Expr associated with `Yield`.
  expr,
  /// Pos associated with `Yield`.
  _pos,
  /// Filename associated with `Yield`.
  _filename,
end struct

/// Represents defer.
struct Defer
  /// Node kind associated with `Defer`.
  node_kind,
  /// Expr associated with `Defer`.
  expr,
  /// Site id associated with `Defer`.
  site_id,
  /// Offsets associated with `Defer`.
  offsets,
  /// Capture kind associated with `Defer`.
  capture_kind,
  /// Pos associated with `Defer`.
  _pos,
  /// Filename associated with `Defer`.
  _filename,
end struct

/// Represents if.
struct If
  /// Node kind associated with `If`.
  node_kind,
  /// Cond associated with `If`.
  cond,
  /// Then body associated with `If`.
  then_body,
  /// Elifs associated with `If`.
  elifs,
  /// Else body associated with `If`.
  else_body,
  /// Pos associated with `If`.
  _pos,
  /// Filename associated with `If`.
  _filename,
end struct

/// Represents while.
struct While
  /// Node kind associated with `While`.
  node_kind,
  /// Cond associated with `While`.
  cond,
  /// Body associated with `While`.
  body,
  /// Pos associated with `While`.
  _pos,
  /// Filename associated with `While`.
  _filename,
end struct

/// Represents for.
struct For
  /// Node kind associated with `For`.
  node_kind,
  /// Var associated with `For`.
  var,
  /// Start associated with `For`.
  start,
  /// End expr associated with `For`.
  end_expr,
  /// Body associated with `For`.
  body,
  /// Pos associated with `For`.
  _pos,
  /// Filename associated with `For`.
  _filename,
end struct

/// Represents for each.
struct ForEach
  /// Node kind associated with `ForEach`.
  node_kind,
  /// Var associated with `ForEach`.
  var,
  /// Iterable associated with `ForEach`.
  iterable,
  /// Body associated with `ForEach`.
  body,
  /// Pos associated with `ForEach`.
  _pos,
  /// Filename associated with `ForEach`.
  _filename,
end struct

/// Represents break.
struct Break
  /// Node kind associated with `Break`.
  node_kind,
  /// Count associated with `Break`.
  count,
  /// Pos associated with `Break`.
  _pos,
  /// Filename associated with `Break`.
  _filename,
end struct

/// Represents continue.
struct Continue
  /// Node kind associated with `Continue`.
  node_kind,
  /// Pos associated with `Continue`.
  _pos,
  /// Filename associated with `Continue`.
  _filename,
end struct

/// Represents global decl.
struct GlobalDecl
  /// Node kind associated with `GlobalDecl`.
  node_kind,
  /// Names associated with `GlobalDecl`.
  names,
  /// Pos associated with `GlobalDecl`.
  _pos,
  /// Filename associated with `GlobalDecl`.
  _filename,
end struct

/// Represents do while.
struct DoWhile
  /// Node kind associated with `DoWhile`.
  node_kind,
  /// Body associated with `DoWhile`.
  body,
  /// Cond associated with `DoWhile`.
  cond,
  /// Pos associated with `DoWhile`.
  _pos,
  /// Filename associated with `DoWhile`.
  _filename,
end struct

/// Represents switch case.
struct SwitchCase
  /// Node kind associated with `SwitchCase`.
  node_kind,
  /// Kind associated with `SwitchCase`.
  kind,
  /// Values associated with `SwitchCase`.
  values,
  /// Range start associated with `SwitchCase`.
  range_start,
  /// Range end associated with `SwitchCase`.
  range_end,
  /// Body associated with `SwitchCase`.
  body,
  /// Pos associated with `SwitchCase`.
  _pos,
  /// Filename associated with `SwitchCase`.
  _filename,
end struct

/// Represents switch.
struct Switch
  /// Node kind associated with `Switch`.
  node_kind,
  /// Expr associated with `Switch`.
  expr,
  /// Cases associated with `Switch`.
  cases,
  /// Default body associated with `Switch`.
  default_body,
  /// Pos associated with `Switch`.
  _pos,
  /// Filename associated with `Switch`.
  _filename,
end struct

/// Represents struct def.
struct StructDef
  /// Node kind associated with `StructDef`.
  node_kind,
  /// Name associated with `StructDef`.
  name,
  /// Fields associated with `StructDef`.
  fields,
  /// Methods associated with `StructDef`.
  methods,
  /// Field types associated with `StructDef`.
  field_types,
  /// Field optional associated with `StructDef`.
  field_optional,
  /// Interfaces associated with `StructDef`.
  interfaces,
  /// Extern field types associated with `StructDef`.
  _extern_field_types,
  /// Pos associated with `StructDef`.
  _pos,
  /// Filename associated with `StructDef`.
  _filename,
end struct

/// Compile-time structural contract with no runtime representation.
struct InterfaceDef
  /// Node kind associated with `InterfaceDef`.
  node_kind,
  /// Name associated with `InterfaceDef`.
  name,
  /// Methods associated with `InterfaceDef`.
  methods,
  /// Pos associated with `InterfaceDef`.
  _pos,
  /// Filename associated with `InterfaceDef`.
  _filename,
end struct

/// Compact parser results for rich parameter and call-argument lists.
struct ParameterList
  /// Names associated with `ParameterList`.
  names,
  /// Types associated with `ParameterList`.
  types,
  /// Optionals associated with `ParameterList`.
  optionals,
  /// Defaults associated with `ParameterList`.
  defaults,
  /// Variadic index associated with `ParameterList`.
  variadic_index,
end struct

/// Represents call arguments.
struct CallArguments
  /// Values associated with `CallArguments`.
  values,
  /// Names associated with `CallArguments`.
  names,
end struct

/// Represents enum def.
struct EnumDef
  /// Node kind associated with `EnumDef`.
  node_kind,
  /// Name associated with `EnumDef`.
  name,
  /// Variants associated with `EnumDef`.
  variants,
  /// Values associated with `EnumDef`.
  values,
  /// Pos associated with `EnumDef`.
  _pos,
  /// Filename associated with `EnumDef`.
  _filename,
end struct

/// Represents extern param.
struct ExternParam
  /// Node kind associated with `ExternParam`.
  node_kind,
  /// Name associated with `ExternParam`.
  name,
  /// Ty associated with `ExternParam`.
  ty,
  /// Whether `ExternParam.is_out` indicates out.
  is_out,
end struct

/// Represents extern function def.
struct ExternFunctionDef
  /// Node kind associated with `ExternFunctionDef`.
  node_kind,
  /// Name associated with `ExternFunctionDef`.
  name,
  /// Params associated with `ExternFunctionDef`.
  params,
  /// Dll associated with `ExternFunctionDef`.
  dll,
  /// Symbol name associated with `ExternFunctionDef`.
  symbol_name,
  /// Ret ty associated with `ExternFunctionDef`.
  ret_ty,
  /// Pos associated with `ExternFunctionDef`.
  _pos,
  /// Filename associated with `ExternFunctionDef`.
  _filename,
end struct

/// Represents parse keep result.
struct ParseKeepResult
  /// Program associated with `ParseKeepResult`.
  program,
  /// Errors associated with `ParseKeepResult`.
  errors,
end struct

/// One typed value available while evaluating conditional-compilation directives.
struct CompileValue
  /// Name associated with `CompileValue`.
  name,
  /// Value associated with `CompileValue`.
  value,
end struct

/// Mutable state for one nested #if/#elif/#else group.
struct CompileFrame
  /// Parent active associated with `CompileFrame`.
  parent_active,
  /// Active associated with `CompileFrame`.
  active,
  /// Taken associated with `CompileFrame`.
  taken,
  /// Else seen associated with `CompileFrame`.
  else_seen,
  /// Pos associated with `CompileFrame`.
  pos,
end struct

/// Track compile external values compiler state.
_compile_external_values = []
/// Track compile target os compiler state.
_compile_target_os = "windows"
/// Track compile target abi compiler state.
_compile_target_abi = "win64"
/// Track compile target format compiler state.
_compile_target_format = "pe"

/// Track keywords compiler state.
_keywords =[
"print", "if", "then", "else", "end", "while", "loop", "true", "false", "and", "or", "not",
"function", "return", "global", "const", "for", "to", "each", "in", "break", "continue",
"switch", "case", "default", "struct", "enum", "are", "namespace", "import", "as", "package",
"extern", "from", "returns", "symbol", "out", "static", "inline", "synchronized", "void", "is", "defer",
"interface", "implements", "iterator", "yield", "async", "await", "operator"
]

/// Creates new token.
/// @param kind Value supplied for `kind`.
/// @param value Value to process.
/// @param pos Value supplied for `pos`.
function newToken(kind, value, pos)
  return Token(kind, value, pos)
end function

/// Creates new parse error.
/// @param message Value supplied for `message`.
/// @param pos Value supplied for `pos`.
/// @param filename Value supplied for `filename`.
function newParseError(message, pos, filename)
  return ParseError(message, pos, filename)
end function

/// Keep compiler-internal closure fields centralized when surface syntax creates ordinary, lambda, iterator or async functions.
/// @internal
function _new_function_node(name, params, body, is_static, is_inline, is_synchronized, param_types, param_optional, param_defaults, variadic_index, return_type, return_optional, is_async, is_iterator, pos, filename)
  return FunctionDef("FunctionDef", name, params, body, is_static, is_inline, is_synchronized, param_types, param_optional, param_defaults, variadic_index, return_type, return_optional, is_async, is_iterator, [], [], [], [], [], 0, [], [], [], [], false, pos, filename)
end function

/// Parse or represent substr in the MiniLang front end.
/// @internal
function _substr(text, start, length)
  if typeof(text) != "string" then return "" end if
  if start < 0 then start = 0 end if
  if length <= 0 or start >= len(text) then return "" end if
  return s.substr(text, start, length)
end function

/// Parse or represent char code in the MiniLang front end.
/// @internal
function _charCode(ch)
  b = bytes(ch)
  if len(b) <= 0 then return -1 end if
  return b[0]
end function

/// Reports whether is digit.
/// @internal
function _isDigit(ch)
  c = _charCode(ch)
  return c >= 48 and c <= 57
end function

/// Reports whether is hex digit.
/// @internal
function _isHexDigit(ch)
  c = _charCode(ch)
  return (c >= 48 and c <= 57) or(c >= 65 and c <= 70) or(c >= 97 and c <= 102)
end function

/// Reports whether is alpha.
/// @internal
function _isAlpha(ch)
  c = _charCode(ch)
  return (c >= 65 and c <= 90) or(c >= 97 and c <= 122)
end function

/// Reports whether is ident start.
/// @internal
function _isIdentStart(ch as string) returns bool
  return _isAlpha(ch) or ch == "_"
end function

/// Reports whether is ident part.
/// @internal
function _isIdentPart(ch as string) returns bool
  return _isIdentStart(ch) or _isDigit(ch)
end function

/// Reports whether is keyword.
/// @internal
function _isKeyword(word)
  for i = 0 to len(_keywords) - 1
    if _keywords[i] == word then
      return true
    end if
  end for
  return false
end function

/// Parse or represent unknown char in the MiniLang front end.
/// @internal
function _unknownChar(code, pos)
  return ParseError("Unknown character: '" + _substr(code, pos, 10) + "'", pos, "")
end function

/// Compact discriminants stored in the token arena's byte kind column.
const TK_NL = 1
/// Track tk number.
const TK_NUMBER = 2
/// Track tk string.
const TK_STRING = 3
/// Track tk kw.
const TK_KW = 4
/// Track tk ident.
const TK_IDENT = 5
/// Track tk op.
const TK_OP = 6
/// Track tk dot.
const TK_DOT = 7
/// Track tk lparen.
const TK_LPAREN = 8
/// Track tk rparen.
const TK_RPAREN = 9
/// Track tk lbrack.
const TK_LBRACK = 10
/// Track tk rbrack.
const TK_RBRACK = 11
/// Track tk comma.
const TK_COMMA = 12
/// Track tk semi.
const TK_SEMI = 13
/// Track tk eof.
const TK_EOF = 14
/// Track parser chunk void sentinel compiler state.
_parser_chunk_void_sentinel = ParserChunkVoidSentinel(0x50A9)

/// Returns parser chunk wrap value.
/// @internal
function _parser_chunk_wrap_value(value)
  if typeof(value) == "void" then
    return _parser_chunk_void_sentinel
  end if
  return value
end function

/// Returns parser chunk unwrap value.
/// @internal
function _parser_chunk_unwrap_value(value)
  if typeof(value) == "struct" and value == _parser_chunk_void_sentinel then
    return
  end if
  if typeof(value) == "void" then
    return
  end if
  return value
end function

/// Returns parser chunk tail new.
/// @internal
function _parser_chunk_tail_new(cap)
  ccap = cap
  if typeof(ccap) != "int" or ccap <= 0 then ccap = 64 end if
  return ParserChunkTail(array(ccap, 0), 0, ccap)
end function

/// Returns parser chunk tail from array.
/// @internal
function _parser_chunk_tail_from_array(arr, cap)
  t = _parser_chunk_tail_new(cap)
  if typeof(arr) != "array" or len(arr) <= 0 then return t end if
  copy_n = len(arr)
  if copy_n > t.cap then copy_n = t.cap end if
  for i = 0 to copy_n - 1
    t.data[i] = _parser_chunk_wrap_value(arr[i])
  end for
  t.used = copy_n
  return t
end function

/// Returns parser chunk tail len.
/// @internal
function _parser_chunk_tail_len(tail)
  if typeof(tail) == "array" then return len(tail) end if
  if typeof(tail) != "struct" then return 0 end if
  if typeof(tail.used) != "int" or tail.used <= 0 then return 0 end if
  n = tail.used
  if typeof(tail.cap) == "int" and tail.cap >= 0 and n > tail.cap then n = tail.cap end if
  if typeof(tail.data) == "array" and n > len(tail.data) then n = len(tail.data) end if
  if n < 0 then n = 0 end if
  return n
end function

/// Returns parser chunk tail to array.
/// @internal
function _parser_chunk_tail_to_array(tail)
  if typeof(tail) == "array" then return tail end if
  if typeof(tail) != "struct" or typeof(tail.data) != "array" then return [] end if
  n = _parser_chunk_tail_len(tail)
  if n <= 0 then return [] end if
  has_void = false
  for i = 0 to n - 1
    cell = tail.data[i]
    if typeof(cell) == "struct" and cell == _parser_chunk_void_sentinel then
      has_void = true
      break
    end if
    if typeof(cell) == "void" then
      has_void = true
      break
    end if
  end for
  if has_void == false then
    outv = array(n, 0)
    for i = 0 to n - 1
      outv[i] = tail.data[i]
    end for
    return outv
  end if
  outv = array(n, void)
  for i = 0 to n - 1
    cell2 = tail.data[i]
    if typeof(cell2) == "struct" and cell2 == _parser_chunk_void_sentinel then continue end if
    if typeof(cell2) == "void" then continue end if
    outv[i] = cell2
  end for
  return outv
end function

/// Parse or represent chunked push in the MiniLang front end.
/// @internal
function _chunked_push(chunks, tail, value, cap)
  if typeof(chunks) != "array" then chunks = [] end if
  ccap = cap
  if typeof(ccap) != "int" or ccap <= 0 then ccap = 64 end if
  t = tail
  if typeof(t) == "array" then t = _parser_chunk_tail_from_array(t, ccap) end if
  if typeof(t) != "struct" or typeof(t.data) != "array" then t = _parser_chunk_tail_new(ccap) end if
  if typeof(t.cap) != "int" or t.cap <= 0 then t.cap = ccap end if
  if typeof(t.used) != "int" or t.used < 0 then t.used = 0 end if
  if t.cap != ccap then
    if t.used > 0 then
      chunks = chunks + [_parser_chunk_tail_to_array(t)]
    end if
    t = _parser_chunk_tail_new(ccap)
  end if
  if t.used >= ccap then
    chunks = chunks + [_parser_chunk_tail_to_array(t)]
    t = _parser_chunk_tail_new(ccap)
  end if
  t.data[t.used] = _parser_chunk_wrap_value(value)
  t.used = t.used + 1
  return [chunks, t]
end function

/// Parse or represent chunked merge balanced in the MiniLang front end.
/// @internal
function _chunked_merge_balanced(chunks)
  if typeof(chunks) != "array" then return [] end if
  if len(chunks) <= 0 then return [] end if
  total = 0
  for i = 0 to len(chunks) - 1
    if typeof(chunks[i]) == "array" then
      total = total + len(chunks[i])
    else
      total = total + 1
    end if
  end for
  if total <= 0 then return [] end if

  // Allocate the final token/node vector once. Native cell copies avoid the
  // transient full-size prefixes previously created by every concatenation.
  outv = array(total, 0)
  oi = 0
  for i = 0 to len(chunks) - 1
    part = chunks[i]
    if typeof(part) == "array" then
      copyArray(outv, oi, part, 0, len(part))
      oi = oi + len(part)
    else
      outv[oi] = part
      oi = oi + 1
    end if
  end for
  return outv
end function

/// Parse or represent chunked merge with tail in the MiniLang front end.
/// @internal
function _chunked_merge_with_tail(chunks, tail_arr)
  total = 0
  if typeof(tail_arr) == "array" then total = len(tail_arr) end if
  if typeof(chunks) == "array" and len(chunks) > 0 then
    for i = 0 to len(chunks) - 1
      part = chunks[i]
      if typeof(part) == "array" then total = total + len(part) else total = total + 1 end if
    end for
  end if
  if total <= 0 then return [] end if
  outv = array(total, 0)
  oi = 0
  if typeof(chunks) == "array" and len(chunks) > 0 then
    for i = 0 to len(chunks) - 1
      part = chunks[i]
      if typeof(part) == "array" then
        copyArray(outv, oi, part, 0, len(part))
        oi = oi + len(part)
      else
        outv[oi] = part
        oi = oi + 1
      end if
    end for
  end if
  if typeof(tail_arr) == "array" and len(tail_arr) > 0 then
    copyArray(outv, oi, tail_arr, 0, len(tail_arr))
  end if
  return outv
end function

/// Parse or represent chunked finish in the MiniLang front end.
/// @internal
function _chunked_finish(chunks, tail)
  if typeof(chunks) != "array" then chunks = [] end if
  tail_arr = _parser_chunk_tail_to_array(tail)
  if typeof(tail_arr) == "array" and len(tail_arr) > 0 then
    return _chunked_merge_with_tail(chunks, tail_arr)
  end if
  return _chunked_merge_balanced(chunks)
end function

/// Converts token kind name.
/// @internal
function _token_kind_name(kind_id)
  if kind_id == TK_NL then return "NL" end if
  if kind_id == TK_NUMBER then return "NUMBER" end if
  if kind_id == TK_STRING then return "STRING" end if
  if kind_id == TK_KW then return "KW" end if
  if kind_id == TK_IDENT then return "IDENT" end if
  if kind_id == TK_OP then return "OP" end if
  if kind_id == TK_DOT then return "DOT" end if
  if kind_id == TK_LPAREN then return "LPAREN" end if
  if kind_id == TK_RPAREN then return "RPAREN" end if
  if kind_id == TK_LBRACK then return "LBRACK" end if
  if kind_id == TK_RBRACK then return "RBRACK" end if
  if kind_id == TK_COMMA then return "COMMA" end if
  if kind_id == TK_SEMI then return "SEMI" end if
  if kind_id == TK_EOF then return "EOF" end if
  return ""
end function

/// Converts token arena new.
/// @internal
function _token_arena_new(source_len)
  // Typical MiniLang modules use about 0.21-0.31 tokens per source byte.
  // Three eighths leaves headroom for the densest compiler modules without
  // over-reserving the tagged value column; generated input can still grow.
  cap = (((source_len + 7) >> 3) * 3) + 16
  if cap < 64 then cap = 64 end if
  return TokenArena(bytes(cap, 0), bytes(cap * 4, 0), bytes(cap * 4, 0), t.arr_vec_new(256), t.fastmap_new(256), 0, cap)
end function

/// Converts token u32 write.
/// @internal
function _token_u32_write(buf, index, value)
  off = index << 2
  buf[off] = value & 0xFF
  buf[off + 1] = (value >> 8) & 0xFF
  buf[off + 2] = (value >> 16) & 0xFF
  buf[off + 3] = (value >> 24) & 0xFF
end function

/// Parse or represent inline in the MiniLang front end.
/// @internal
function inline _token_u32_read(buf, index)
  off = index << 2
  return buf[off] | (buf[off + 1] << 8) | (buf[off + 2] << 16) | (buf[off + 3] << 24)
end function

/// Converts token pos write.
/// @internal
function _token_pos_write(buf, index, value)
  _token_u32_write(buf, index, value)
end function

/// Parse or represent inline in the MiniLang front end.
/// @internal
function inline _token_pos_read(buf, index)
  return _token_u32_read(buf, index)
end function

/// Converts token text store.
/// @internal
function _token_text_store(arena, kind, value)
  // Fixed punctuation is reconstructed from the kind and needs no pool slot.
  if kind == TK_NL or kind == TK_DOT or kind == TK_LPAREN or kind == TK_RPAREN then return [arena, 0] end if
  if kind == TK_LBRACK or kind == TK_RBRACK or kind == TK_COMMA or kind == TK_SEMI or kind == TK_EOF then return [arena, 0] end if

  text = value
  if typeof(text) != "string" then text = _tok_text_part(text) end if
  if kind == TK_IDENT or kind == TK_KW or kind == TK_OP then
    existing = t.fastmap_get(arena.text_index, text, -1)
    if typeof(existing) == "int" and existing >= 0 then return [arena, existing] end if
  end if

  id = t.arr_vec_count(arena.texts) + 1
  arena.texts = t.arr_vec_push(arena.texts, text)
  if kind == TK_IDENT or kind == TK_KW or kind == TK_OP then
    arena.text_index = t.fastmap_set(arena.text_index, text, id)
  end if
  return [arena, id]
end function

/// Parse or represent inline in the MiniLang front end.
/// @internal
function inline _token_fixed_value(kind)
  if kind == TK_NL then return "\\n" end if
  if kind == TK_DOT then return "." end if
  if kind == TK_LPAREN then return "(" end if
  if kind == TK_RPAREN then return ")" end if
  if kind == TK_LBRACK then return "[" end if
  if kind == TK_RBRACK then return "]" end if
  if kind == TK_COMMA then return "," end if
  if kind == TK_SEMI then return ";" end if
  return ""
end function

/// Converts token arena grow.
/// @internal
function _token_arena_grow(arena)
  next_cap = arena.cap << 1
  next_kinds = bytes(next_cap, 0)
  next_value_ids = bytes(next_cap * 4, 0)
  next_positions = bytes(next_cap * 4, 0)
  if arena.count > 0 then
    copyBytes(next_kinds, 0, arena.kinds, 0, arena.count)
    copyBytes(next_value_ids, 0, arena.value_ids, 0, arena.count * 4)
    copyBytes(next_positions, 0, arena.positions, 0, arena.count * 4)
  end if
  arena.kinds = next_kinds
  arena.value_ids = next_value_ids
  arena.positions = next_positions
  arena.cap = next_cap
  return arena
end function

/// Converts token push.
/// @internal
function _token_push(arena, tail, kind, value, pos)
  a = arena
  if a.count >= a.cap then a = _token_arena_grow(a) end if
  stored = _token_text_store(a, kind, value)
  a = stored[0]
  value_id = stored[1]
  slot = a.count
  a.kinds[slot] = kind
  _token_u32_write(a.value_ids, slot, value_id)
  _token_pos_write(a.positions, slot, pos)
  a.count = slot + 1
  return [a, tail]
end function

/// Converts tokenize.
/// @param code Source code to process.
function tokenize(code)
  if typeof(code) != "string" then
    return ParseError("tokenize expects source string, got " + _tok_text_part(code), 0, "")
  end if

  i = 0
  n = len(code)
  token_chunks = _token_arena_new(n)
  token_tail = []
  while i < n
    ch = code[i]

    if ch == " " or ch == "\t" then
      i = i + 1
      continue
    end if
    if ch == "\n" then
      app = _token_push(token_chunks, token_tail, TK_NL, "\\n", i)
      token_chunks = app[0]
      token_tail = app[1]
      i = i + 1
      continue
    end if

    // MiniDoc consumes declaration comments from the original source. Keep an
    // explicit branch for `///` so the syntax is part of the language contract,
    // while leaving documentation text out of the executable AST.
    if ch == "/" and i + 2 < n and code[i + 1] == "/" and code[i + 2] == "/" then
      i = i + 3
      while i < n and code[i] != "\n"
        i = i + 1
      end while
      continue
    end if

    if ch == "/" and i + 1 < n and code[i + 1] == "/" then
      i = i + 2
      while i < n and code[i] != "\n"
        i = i + 1
      end while
      continue
    end if

    if ch == "/" and i + 1 < n and code[i + 1] == "*" then
      i = i + 2
      closed = false
      while i + 1 < n
        if code[i] == "\n" then
          app = _token_push(token_chunks, token_tail, TK_NL, "\\n", i)
          token_chunks = app[0]
          token_tail = app[1]
        end if
        if code[i] == "*" and code[i + 1] == "/" then
          i = i + 2
          closed = true
          break
        end if
        i = i + 1
      end while
      if closed == false then
        return _unknownChar(code, n - 1)
      end if
      continue
    end if

    if _isDigit(ch) then
      start = i
      if ch == "0" and i + 2 < n and(code[i + 1] == "x" or code[i + 1] == "X") and _isHexDigit(code[i + 2]) then
        i = i + 3
        while i < n and _isHexDigit(code[i])
          i = i + 1
        end while
        app = _token_push(token_chunks, token_tail, TK_NUMBER, _substr(code, start, i - start), start)
        token_chunks = app[0]
        token_tail = app[1]
        continue
      end if
      if ch == "0" and i + 2 < n and(code[i + 1] == "b" or code[i + 1] == "B") and(code[i + 2] == "0" or code[i + 2] == "1") then
        i = i + 3
        while i < n and(code[i] == "0" or code[i] == "1")
          i = i + 1
        end while
        app = _token_push(token_chunks, token_tail, TK_NUMBER, _substr(code, start, i - start), start)
        token_chunks = app[0]
        token_tail = app[1]
        continue
      end if
      while i < n and _isDigit(code[i])
        i = i + 1
      end while
      if i + 1 < n and code[i] == "." and _isDigit(code[i + 1]) then
        i = i + 1
        while i < n and _isDigit(code[i])
          i = i + 1
        end while
      end if
      app = _token_push(token_chunks, token_tail, TK_NUMBER, _substr(code, start, i - start), start)
      token_chunks = app[0]
      token_tail = app[1]
      continue
    end if

    if ch == "\"" then
      start = i
      i = i + 1
      closed = false
      while i < n
        c = code[i]
        if c == "\\" then
          if i + 1 >= n then
            return _unknownChar(code, start)
          end if
          i = i + 2
          continue
        end if
        if c == "\"" then
          i = i + 1
          closed = true
          break
        end if
        i = i + 1
      end while
      if closed == false then
        return _unknownChar(code, start)
      end if
      app = _token_push(token_chunks, token_tail, TK_STRING, _substr(code, start, i - start), start)
      token_chunks = app[0]
      token_tail = app[1]
      continue
    end if

    if _isIdentStart(ch) then
      start = i
      i = i + 1
      while i < n and _isIdentPart(code[i])
        i = i + 1
      end while
      text = _substr(code, start, i - start)
      if _isKeyword(text) then
        app = _token_push(token_chunks, token_tail, TK_KW, text, start)
        token_chunks = app[0]
        token_tail = app[1]
      else
        app = _token_push(token_chunks, token_tail, TK_IDENT, text, start)
        token_chunks = app[0]
        token_tail = app[1]
      end if
      continue
    end if

    if i + 2 < n and ch == "." and code[i + 1] == "." and code[i + 2] == "." then
      app = _token_push(token_chunks, token_tail, TK_OP, "...", i)
      token_chunks = app[0]
      token_tail = app[1]
      i = i + 3
      continue
    end if

    if i + 2 < n then
      three = ch + code[i + 1] + code[i + 2]
      if three == "<<=" or three == ">>=" then
        app = _token_push(token_chunks, token_tail, TK_OP, three, i)
        token_chunks = app[0]
        token_tail = app[1]
        i = i + 3
        continue
      end if
    end if

    if i + 1 < n then
      two = ch + code[i + 1]
      if two == "==" or two == "!=" or two == ">=" or two == "<=" or two == "<<" or two == ">>" or two == "=>" or two == "??" or two == "?." or two == "+=" or two == "-=" or two == "*=" or two == "/=" or two == "%=" or two == "&=" or two == "|=" or two == "^=" then
        app = _token_push(token_chunks, token_tail, TK_OP, two, i)
        token_chunks = app[0]
        token_tail = app[1]
        i = i + 2
        continue
      end if
    end if

    if ch == "." then
      app = _token_push(token_chunks, token_tail, TK_DOT, ".", i)
      token_chunks = app[0]
      token_tail = app[1]
      i = i + 1
      continue
    end if
    if ch == "(" then
      app = _token_push(token_chunks, token_tail, TK_LPAREN, "(", i)
      token_chunks = app[0]
      token_tail = app[1]
      i = i + 1
      continue
    end if
    if ch == ")" then
      app = _token_push(token_chunks, token_tail, TK_RPAREN, ")", i)
      token_chunks = app[0]
      token_tail = app[1]
      i = i + 1
      continue
    end if
    if ch == "[" then
      app = _token_push(token_chunks, token_tail, TK_LBRACK, "[", i)
      token_chunks = app[0]
      token_tail = app[1]
      i = i + 1
      continue
    end if
    if ch == "]" then
      app = _token_push(token_chunks, token_tail, TK_RBRACK, "]", i)
      token_chunks = app[0]
      token_tail = app[1]
      i = i + 1
      continue
    end if
    if ch == "," then
      app = _token_push(token_chunks, token_tail, TK_COMMA, ",", i)
      token_chunks = app[0]
      token_tail = app[1]
      i = i + 1
      continue
    end if
    if ch == ";" then
      app = _token_push(token_chunks, token_tail, TK_SEMI, ";", i)
      token_chunks = app[0]
      token_tail = app[1]
      i = i + 1
      continue
    end if

    if ch == "+" or ch == "-" or ch == "*" or ch == "/" or ch == "%" or ch == "=" or ch == "<" or ch == ">" or ch == "&" or ch == "|" or ch == "^" or ch == "~" or ch == "?" then
      app = _token_push(token_chunks, token_tail, TK_OP, ch, i)
      token_chunks = app[0]
      token_tail = app[1]
      i = i + 1
      continue
    end if

    return _unknownChar(code, i)
  end while

  app = _token_push(token_chunks, token_tail, TK_EOF, "", n)
  token_chunks = app[0]
  token_tail = app[1]
  return token_chunks
end function

/// Parse or represent repeat in the MiniLang front end.
/// @internal
function _repeat(text, n)
  // MiniLang's inclusive `for` range also visits descending bounds. An empty
  // physical line must therefore bypass the loop so directive pruning keeps
  // every following source byte at its original offset.
  if typeof(n) != "int" or n <= 0 then return "" end if
  rep = ""
  for i = 1 to n
    rep = rep + text
  end for
  return rep
end function

/// Parse or represent line col in the MiniLang front end.
/// @internal
function _line_col(source, pos)
  if pos < 0 then pos = 0 end if
  if pos > len(source) then pos = len(source) end if
  line = 1
  col = 1
  for i = 0 to pos - 1
    if source[i] == "\n" then
      line = line + 1
      col = 1
    else
      col = col + 1
    end if
  end for
  return [line, col]
end function

/// Converts format error.
/// @param source Source value to process.
/// @param filename Value supplied for `filename`.
/// @param pos Value supplied for `pos`.
/// @param message Value supplied for `message`.
/// @param kind Value supplied for `kind`.
function format_error(source, filename, pos, message, kind)
  if pos < 0 then pos = 0 end if
  if pos > len(source) then pos = len(source) end if
  lc = _line_col(source, pos)
  line_no = lc[0]
  col_no = lc[1]

  line_start = pos
  while line_start > 0 and source[line_start - 1] != "\n"
    line_start = line_start - 1
  end while
  line_end = pos
  while line_end < len(source) and source[line_end] != "\n"
    line_end = line_end + 1
  end while

  line_text = _substr(source, line_start, line_end - line_start)
  caret = _repeat(" ", col_no - 1) + "^"

  return kind + ": " + message + "\n" +"  at " + filename + ":" + line_no + ":" + col_no + "\n" +"  " + line_text + "\n" +"  " + caret
end function

/// Track tokens compiler state.
_tokens =[]
/// Track i compiler state.
_i = 0
/// Track source compiler state.
_source = ""
/// Track filename compiler state.
_filename = ""
/// Track last error compiler state.
_last_error = 0
/// Track has last error compiler state.
_has_last_error = false
/// Track func depth compiler state.
_func_depth = 0
/// Track ns depth compiler state.
_ns_depth = 0
/// Track seen package compiler state.
_seen_package = false
/// Track seen nonpackage toplevel stmt compiler state.
_seen_nonpackage_toplevel_stmt = false
/// Track collect errors compiler state.
_collect_errors = false
/// Track max errors compiler state.
_max_errors = 50
/// Track errors compiler state.
_errors =[]

/// Parse or represent inline in the MiniLang front end.
/// @internal
function inline _token_count(tokens)
  return tokens.count
end function

/// Parse or represent inline in the MiniLang front end.
/// @internal
function inline _tok_kind_id(tok)
  /// Current tokens used by this routine.
  /// @internal
  global _tokens
  if typeof(tok) == "int" and tok >= 0 and tok < _tokens.count then return _tokens.kinds[tok] end if
  return TK_EOF
end function

/// Converts tok kind.
/// @internal
function _tok_kind(tok)
  return _token_kind_name(_tok_kind_id(tok))
end function

/// Parse or represent inline in the MiniLang front end.
/// @internal
function inline _tok_value(tok)
  /// Current tokens used by this routine.
  /// @internal
  global _tokens
  if typeof(tok) == "int" and tok >= 0 and tok < _tokens.count then
    kind = _tokens.kinds[tok]
    value_id = _token_u32_read(_tokens.value_ids, tok)
    if value_id <= 0 then return _token_fixed_value(kind) end if
    return t.arr_vec_get(_tokens.texts, value_id - 1, "")
  end if
  return
end function

/// Parse or represent inline in the MiniLang front end.
/// @internal
function inline _tok_pos(tok)
  /// Current tokens used by this routine.
  /// @internal
  global _tokens
  if typeof(tok) == "int" and tok >= 0 and tok < _tokens.count then return _token_pos_read(_tokens.positions, tok) end if
  return 0
end function

/// Updates set error.
/// @internal
function _set_error(message, pos)
  /// Current last error used by this routine.
  /// @internal
  global _last_error, _has_last_error, _filename
  if _has_last_error then return end if
  _last_error = ParseError(message, pos, _filename)
  _has_last_error = true
end function

/// Releases or resets clear error.
/// @internal
function _clear_error()
  /// Current last error used by this routine.
  /// @internal
  global _last_error, _has_last_error
  _last_error = 0
  _has_last_error = false
end function

/// Reports whether has error.
/// @internal
function _has_error()
  /// Current has last error used by this routine.
  /// @internal
  global _has_last_error
  return _has_last_error
end function

/// Releases or resets reset.
/// @internal
function _reset(tokens, source, filename, collect_errors, max_errors)
  /// Current tokens used by this routine.
  /// @internal
  global _tokens, _i, _source, _filename, _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _collect_errors, _max_errors, _errors
  _tokens = tokens
  _i = 0
  _source = source
  _filename = filename
  _func_depth = 0
  _ns_depth = 0
  _seen_package = false
  _seen_nonpackage_toplevel_stmt = false
  _collect_errors = collect_errors
  _max_errors = max_errors
  _errors =[]
  _clear_error()
end function

/// Parse or represent peek in the MiniLang front end.
/// @internal
function _peek()
  /// Current tokens used by this routine.
  /// @internal
  global _tokens, _i
  count = _token_count(_tokens)
  if count <= 0 then return -1 end if
  if _i >= count then return count - 1 end if
  return _i
end function

/// Parse or represent peek2 in the MiniLang front end.
/// @internal
function _peek2()
  /// Current tokens used by this routine.
  /// @internal
  global _tokens, _i
  count = _token_count(_tokens)
  if count <= 0 then return -1 end if
  if _i + 1 < count then return _i + 1 end if
  return count - 1
end function

/// Parse or represent advance in the MiniLang front end.
/// @internal
function _advance()
  /// Current tokens used by this routine.
  /// @internal
  global _tokens, _i
  t = _peek()
  if _i < _token_count(_tokens) then _i = _i + 1 end if
  return t
end function

/// Parse or represent match kind in the MiniLang front end.
/// @internal
function _match_kind(kind)
  t = _peek()
  if _tok_kind_id(t) != kind then return false end if
  _advance()
  return true
end function

/// Parse or represent match value in the MiniLang front end.
/// @internal
function _match_value(kind, value)
  t = _peek()
  if _tok_kind_id(t) != kind then return false end if
  if _tok_value(t) != value then return false end if
  _advance()
  return true
end function

/// Parse or represent expect kind in the MiniLang front end.
/// @internal
function _expect_kind(kind)
  t = _peek()
  if _tok_kind_id(t) != kind then
    _set_error("Expected " + _token_kind_name(kind) + ", got " + _tok_kind(t) + ":" + _tok_value(t), _tok_pos(t))
    return
  end if
  return _advance()
end function

/// Parse or represent expect value in the MiniLang front end.
/// @internal
function _expect_value(kind, value)
  t = _peek()
  if _tok_kind_id(t) != kind or _tok_value(t) != value then
    _set_error("Expected " + _token_kind_name(kind) + " " + value + ", got " + _tok_kind(t) + ":" + _tok_value(t), _tok_pos(t))
    return
  end if
  return _advance()
end function

/// Parse or represent skip newlines in the MiniLang front end.
/// @internal
function _skip_newlines()
  while _match_kind(TK_NL)
  end while
end function

/// Parse or represent hex value in the MiniLang front end.
/// @internal
function _hex_value(ch)
  c = _charCode(ch)
  if c >= 48 and c <= 57 then return c - 48 end if
  if c >= 65 and c <= 70 then return c - 65 + 10 end if
  if c >= 97 and c <= 102 then return c - 97 + 10 end if
  return -1
end function

/// Parse or represent char from code in the MiniLang front end.
/// @internal
function _charFromCode(v)
  // Build the UTF-8 sequence used by MiniLang strings. This also keeps \x
  // escapes above ASCII aligned with Python's chr(...).encode("utf-8").
  if v < 0 or v > 0x10FFFF then return "" end if
  if v >= 0xD800 and v <= 0xDFFF then return "" end if
  b = bytes(0, 0)
  if v <= 0x7F then
    b = bytes(1, 0)
    b[0] = v
  else if v <= 0x7FF then
    b = bytes(2, 0)
    b[0] = 0xC0 | (v >> 6)
    b[1] = 0x80 | (v & 0x3F)
  else if v <= 0xFFFF then
    b = bytes(3, 0)
    b[0] = 0xE0 | (v >> 12)
    b[1] = 0x80 | ((v >> 6) & 0x3F)
    b[2] = 0x80 | (v & 0x3F)
  else
    b = bytes(4, 0)
    b[0] = 0xF0 | (v >> 18)
    b[1] = 0x80 | ((v >> 12) & 0x3F)
    b[2] = 0x80 | ((v >> 6) & 0x3F)
    b[3] = 0x80 | (v & 0x3F)
  end if
  d = decode(b)
  if typeof(d) != "string" then return "" end if
  return d
end function

/// Returns decode string raw.
/// @internal
function _decode_string_raw(raw, pos)
  // Preserve UTF-8 bytes while decoding escapes into one geometrically grown
  // buffer. Repeated immutable concatenation made long literals quadratic.
  decoded = sb.StringBuilder.withCapacity(len(raw))
  i = 0
  while i < len(raw)
    ch = raw[i]
    if ch != "\\" then
      decoded.appendString(ch)
      i = i + 1
      continue
    end if
    if i + 1 >= len(raw) then
      _set_error("Invalid escape at end of string", pos + i)
      return
    end if
    esc = raw[i + 1]
    if esc == "n" then decoded.appendString("\n") ; i = i + 2 ; continue end if
    if esc == "r" then decoded.appendString("\r") ; i = i + 2 ; continue end if
    if esc == "t" then decoded.appendString("\t") ; i = i + 2 ; continue end if
    if esc == "0" then decoded.appendString("\0") ; i = i + 2 ; continue end if
    if esc == "\\" then decoded.appendString("\\") ; i = i + 2 ; continue end if
    if esc == "\"" then decoded.appendString("\"") ; i = i + 2 ; continue end if
    if esc == "x" then
      if i + 3 >= len(raw) then _set_error("Invalid \\x escape", pos + i) ; return end if
      h1 = _hex_value(raw[i + 2])
      h2 = _hex_value(raw[i + 3])
      if h1 < 0 or h2 < 0 then _set_error("Invalid \\x escape", pos + i) ; return end if
      decoded.appendString(_charFromCode(h1 * 16 + h2))
      i = i + 4
      continue
    end if
    if esc == "u" then
      if i + 5 >= len(raw) then _set_error("Invalid \\u escape", pos + i) ; return end if
      cp = 0
      for j = 2 to 5
        hd = _hex_value(raw[i + j])
        if hd < 0 then _set_error("Invalid \\u escape", pos + i) ; return end if
        cp = cp * 16 + hd
      end for
      uch = _charFromCode(cp)
      if uch == "" then _set_error("Invalid \\u escape", pos + i) ; return end if
      decoded.appendString(uch)
      i = i + 6
      continue
    end if
    if esc == "U" then
      if i + 9 >= len(raw) then _set_error("Invalid \\U escape", pos + i) ; return end if
      cp = 0
      for j = 2 to 9
        hd = _hex_value(raw[i + j])
        if hd < 0 then _set_error("Invalid \\U escape", pos + i) ; return end if
        cp = cp * 16 + hd
      end for
      uch = _charFromCode(cp)
      if uch == "" then _set_error("Invalid \\U escape", pos + i) ; return end if
      decoded.appendString(uch)
      i = i + 10
      continue
    end if
    // Keep the historical permissive fallback used by paths and regexes:
    // an unknown escape drops the backslash and retains the following value.
    decoded.appendString(esc)
    i = i + 2
  end while
  return decoded.toString()
end function

/// Parse or represent peek3 in the MiniLang front end.
/// @internal
function _peek3()
  /// Current tokens used by this routine.
  /// @internal
  global _tokens, _i
  count = _token_count(_tokens)
  if count <= 0 then return -1 end if
  if _i + 2 < count then return _i + 2 end if
  return count - 1
end function

/// Returns decode string token.
/// @internal
function _decode_string_token(tok)
  if _tok_kind_id(tok) != TK_STRING then
    _set_error("Expect STRING literal", _tok_pos(tok))
    return
  end if
  value = _tok_value(tok)
  raw = _substr(value, 1, len(value) - 2)
  return _decode_string_raw(raw, _tok_pos(tok))
end function

/// Returns parse base int.
/// @internal
function _parse_base_int(raw, start_index, base)
  v = 0
  for i = start_index to len(raw) - 1
    d = _hex_value(raw[i])
    if d < 0 or d >= base then return end if
    v = v * base + d
  end for
  return v
end function

/// Returns parse int literal.
/// @internal
function _parse_int_literal(raw)
  if _substr(raw, 0, 2) == "0x" or _substr(raw, 0, 2) == "0X" then
    return _parse_base_int(raw, 2, 16)
  end if
  if _substr(raw, 0, 2) == "0b" or _substr(raw, 0, 2) == "0B" then
    return _parse_base_int(raw, 2, 2)
  end if
  return toNumber(raw)
end function

/// Returns parse float literal.
/// @internal
function _parse_float_literal(raw)
  // Use the CRT's correctly-rounded binary64 conversion. The generic
  // MiniLang toFloat() parser can differ by one ULP for long decimals.
  return _parse_strtod(raw, void)
end function

/// Parse or represent precedence in the MiniLang front end.
/// @internal
function _precedence(op)
  if op == "??" then return 0 end if
  if op == "or" then return 1 end if
  if op == "and" then return 2 end if
  if op == "|" then return 3 end if
  if op == "^" then return 4 end if
  if op == "&" then return 5 end if
  if op == "==" or op == "!=" or op == "is" then return 6 end if
  if op == ">" or op == "<" or op == ">=" or op == "<=" then return 7 end if
  if op == "<<" or op == ">>" then return 8 end if
  if op == "+" or op == "-" then return 9 end if
  if op == "*" or op == "/" or op == "%" then return 10 end if
  return -1
end function

/// Maps one supported source operator and arity to its reserved static method.
/// @internal
function operator_method_name(op_symbol, arity)
  if arity == 1 then
    if op_symbol == "+" then return "__operator_pos" end if
    if op_symbol == "-" then return "__operator_neg" end if
    if op_symbol == "not" then return "__operator_not" end if
    if op_symbol == "~" then return "__operator_bitnot" end if
    return ""
  end if
  if arity != 2 then return "" end if
  if op_symbol == "+" then return "__operator_add" end if
  if op_symbol == "-" then return "__operator_sub" end if
  if op_symbol == "*" then return "__operator_mul" end if
  if op_symbol == "/" then return "__operator_div" end if
  if op_symbol == "%" then return "__operator_mod" end if
  if op_symbol == "==" then return "__operator_eq" end if
  if op_symbol == "!=" then return "__operator_ne" end if
  if op_symbol == "<" then return "__operator_lt" end if
  if op_symbol == "<=" then return "__operator_le" end if
  if op_symbol == ">" then return "__operator_gt" end if
  if op_symbol == ">=" then return "__operator_ge" end if
  if op_symbol == "&" then return "__operator_bitand" end if
  if op_symbol == "|" then return "__operator_bitor" end if
  if op_symbol == "^" then return "__operator_bitxor" end if
  if op_symbol == "<<" then return "__operator_shl" end if
  if op_symbol == ">>" then return "__operator_shr" end if
  return ""
end function

/// Returns the binary operator represented by a compound assignment token.
/// @internal
function _compound_assignment_base(op_symbol)
  if op_symbol == "+=" then return "+" end if
  if op_symbol == "-=" then return "-" end if
  if op_symbol == "*=" then return "*" end if
  if op_symbol == "/=" then return "/" end if
  if op_symbol == "%=" then return "%" end if
  if op_symbol == "&=" then return "&" end if
  if op_symbol == "|=" then return "|" end if
  if op_symbol == "^=" then return "^" end if
  if op_symbol == "<<=" then return "<<" end if
  if op_symbol == ">>=" then return ">>" end if
  return ""
end function

/// Returns parse expr list.
/// @internal
function _parse_expr_list(end_kind)
  items_chunks = []
  items_tail = []
  _skip_newlines()
  if _match_kind(end_kind) then return _chunked_finish(items_chunks, items_tail) end if
  while true
    it = _parse_expr(0)
    if _has_error() then return end if
    app = _chunked_push(items_chunks, items_tail, it, 32)
    items_chunks = app[0]
    items_tail = app[1]
    _skip_newlines()
    if _match_kind(TK_COMMA) then
      _skip_newlines()
      if _match_kind(end_kind) then break end if
      continue
    end if
    _expect_kind(end_kind)
    if _has_error() then return end if
    break
  end while
  return _chunked_finish(items_chunks, items_tail)
end function

/// Returns parse primary.
/// @internal
function _parse_primary()
  tok = _peek()

  if _tok_kind_id(tok) == TK_LPAREN then
    sp = _tok_pos(tok)
    _advance()
    e = _parse_expr(0)
    if _has_error() then return end if
    _expect_kind(TK_RPAREN)
    if _has_error() then return end if
    if typeof(e) == "struct" and typeof(e._pos) != "int" then e._pos = sp end if
    return e
  end if

  if _tok_kind_id(tok) == TK_LBRACK then
    sp = _tok_pos(tok)
    _advance()
    items = _parse_expr_list(TK_RBRACK)
    if _has_error() then return end if
    return ArrayLit("ArrayLit", items, false, sp, _filename)
  end if

  if _tok_kind_id(tok) == TK_KW and _tok_value(tok) == "function" then
    sp = _tok_pos(tok)
    _advance()
    _expect_kind(TK_LPAREN)
    if _has_error() then return end if
    parsed = _parse_parameter_list()
    if _has_error() then return end if
    has_lambda_default = false
    if len(parsed.defaults) > 0 then
      for default_i = 0 to len(parsed.defaults) - 1
        if typeof(parsed.defaults[default_i]) != "void" then has_lambda_default = true break end if
      end for
    end if
    if parsed.variadic_index >= 0 or has_lambda_default then
      _set_error("Lambda parameters do not support default or variadic arguments", sp)
      return
    end if
    return_type = void
    return_optional = false
    if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "returns" then
      _advance()
      rt = _parse_type_ref()
      if _has_error() then return end if
      return_type = rt[0]
      return_optional = rt[1]
    end if
    _expect_value(TK_OP, "=>")
    if _has_error() then return end if
    value = _parse_expr(0)
    if _has_error() then return end if
    if typeof(return_type) == "string" then
      value = TypeGuard("TypeGuard", value, return_type, return_optional, sp, _filename)
    end if
    body = [Return("Return", value, sp, _filename)]
    return Lambda("Lambda", parsed.names, body, parsed.types, parsed.optionals, parsed.defaults, parsed.variadic_index, return_type, return_optional, sp, _filename)
  end if

  if (_tok_kind_id(tok) == TK_KW or _tok_kind_id(tok) == TK_IDENT) and _tok_value(tok) == "select" and _tok_kind_id(_peek2()) == TK_LPAREN then
    sp = _tok_pos(tok)
    _advance()
    _expect_kind(TK_LPAREN)
    if _has_error() then return end if
    parsed_args = _parse_call_arguments()
    if _has_error() then return end if
    if len(parsed_args.names) > 0 then
      for i = 0 to len(parsed_args.names) - 1
        if typeof(parsed_args.names[i]) == "string" then _set_error("select does not accept named arguments", sp) return end if
      end for
    end if
    callee = t.ast_leaf_new("Var", "__ml_select", sp, _filename)
    return Call("Call", callee, [ArrayLit("ArrayLit", parsed_args.values, false, sp, _filename)], [], sp, _filename)
  end if

  if _tok_kind_id(tok) == TK_NUMBER then
    sp = _tok_pos(tok)
    value = _tok_value(tok)
    _advance()
    if _match_number_has_dot(value) then
      return t.ast_leaf_new("Num", _parse_float_literal(value), sp, _filename)
    end if
    return t.ast_leaf_new("Num", _parse_int_literal(value), sp, _filename)
  end if

  if _tok_kind_id(tok) == TK_STRING then
    sp = _tok_pos(tok)
    value = _tok_value(tok)
    _advance()
    raw = _substr(value, 1, len(value) - 2)
    val = _decode_string_raw(raw, sp)
    if _has_error() then return end if
    return t.ast_leaf_new("Str", val, sp, _filename)
  end if

  if _tok_kind_id(tok) == TK_KW and(_tok_value(tok) == "true" or _tok_value(tok) == "false") then
    sp = _tok_pos(tok)
    value = _tok_value(tok)
    _advance()
    return t.ast_leaf_new("Bool", value == "true", sp, _filename)
  end if

  if _tok_kind_id(tok) == TK_KW and _tok_value(tok) == "void" then
    sp = _tok_pos(tok)
    _advance()
    return t.ast_leaf_new("VoidLit", 0, sp, _filename)
  end if

  if _tok_kind_id(tok) == TK_IDENT then
    sp = _tok_pos(tok)
    value = _tok_value(tok)
    _advance()
    return t.ast_leaf_new("Var", value, sp, _filename)
  end if

  _set_error("Unexpected expression: " + _tok_desc(tok), _tok_pos(tok))
end function

/// Returns parse type ref.
/// @internal
function _parse_type_ref()
  tok = _peek()
  if _tok_kind_id(tok) != TK_IDENT and _tok_kind_id(tok) != TK_KW then
    _set_error("Expected type name", _tok_pos(tok))
    return
  end if
  name = _tok_value(_advance())
  while _match_kind(TK_DOT)
    seg = _expect_kind(TK_IDENT)
    if _has_error() then return end if
    name = name + "." + _tok_value(seg)
  end while
  optional = _match_value(TK_OP, "?")
  return [name, optional]
end function

/// Returns parse parameter list.
/// @internal
function _parse_parameter_list()
  names_chunks = []
  names_tail = []
  types_chunks = []
  types_tail = []
  optional_chunks = []
  optional_tail = []
  defaults_chunks = []
  defaults_tail = []
  variadic_index = -1
  saw_default = false
  index = 0
  _skip_newlines()
  if _match_kind(TK_RPAREN) then return ParameterList([], [], [], [], -1) end if
  while true
    name_tok = _expect_kind(TK_IDENT)
    if _has_error() then return end if
    name = _tok_value(name_tok)
    ty = void
    optional = false
    if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "as" then
      _advance()
      tref = _parse_type_ref()
      if _has_error() then return end if
      ty = tref[0]
      optional = tref[1]
    end if
    variadic = _match_value(TK_OP, "...")
    default_value = void
    if _match_value(TK_OP, "=") then
      if variadic then _set_error("A variadic parameter cannot have a default value", _tok_pos(_peek())) return end if
      default_value = _parse_expr(0)
      if _has_error() then return end if
      saw_default = true
    else if saw_default and not variadic then
      _set_error("Required parameters cannot follow default parameters", _tok_pos(name_tok))
      return
    end if
    if variadic then variadic_index = index end if

    appn = _chunked_push(names_chunks, names_tail, name, 16)
    names_chunks = appn[0]
    names_tail = appn[1]
    appt = _chunked_push(types_chunks, types_tail, ty, 16)
    types_chunks = appt[0]
    types_tail = appt[1]
    appo = _chunked_push(optional_chunks, optional_tail, optional, 16)
    optional_chunks = appo[0]
    optional_tail = appo[1]
    appd = _chunked_push(defaults_chunks, defaults_tail, default_value, 16)
    defaults_chunks = appd[0]
    defaults_tail = appd[1]
    index = index + 1

    _skip_newlines()
    if _match_kind(TK_COMMA) then
      _skip_newlines()
      if _match_kind(TK_RPAREN) then break end if
      continue
    end if
    _expect_kind(TK_RPAREN)
    if _has_error() then return end if
    break
  end while
  names = _chunked_finish(names_chunks, names_tail)
  if variadic_index >= 0 and variadic_index != len(names) - 1 then
    _set_error("The variadic parameter must be last", _tok_pos(_peek()))
    return
  end if
  if len(names) > 1 then
    for i = 0 to len(names) - 2
      for j = i + 1 to len(names) - 1
        if names[i] == names[j] then _set_error("Duplicate function parameter", _tok_pos(_peek())) return end if
      end for
    end for
  end if
  return ParameterList(names, _chunked_finish(types_chunks, types_tail), _chunked_finish(optional_chunks, optional_tail), _chunked_finish(defaults_chunks, defaults_tail), variadic_index)
end function

/// Returns parse call arguments.
/// @internal
function _parse_call_arguments()
  values_chunks = []
  values_tail = []
  names_chunks = []
  names_tail = []
  named_seen = false
  _skip_newlines()
  if _match_kind(TK_RPAREN) then return CallArguments([], []) end if
  while true
    arg_name = void
    if _tok_kind_id(_peek()) == TK_IDENT and _tok_kind_id(_peek2()) == TK_OP and _tok_value(_peek2()) == "=" then
      arg_name = _tok_value(_advance())
      _advance()
      named_seen = true
    else if named_seen then
      _set_error("Positional arguments cannot follow named arguments", _tok_pos(_peek()))
      return
    end if
    value = _parse_expr(0)
    if _has_error() then return end if
    appv = _chunked_push(values_chunks, values_tail, value, 16)
    values_chunks = appv[0]
    values_tail = appv[1]
    appn = _chunked_push(names_chunks, names_tail, arg_name, 16)
    names_chunks = appn[0]
    names_tail = appn[1]
    _skip_newlines()
    if _match_kind(TK_COMMA) then
      _skip_newlines()
      if _match_kind(TK_RPAREN) then break end if
      continue
    end if
    _expect_kind(TK_RPAREN)
    if _has_error() then return end if
    break
  end while
  return CallArguments(_chunked_finish(values_chunks, values_tail), _chunked_finish(names_chunks, names_tail))
end function

/// Parse or represent match number has dot in the MiniLang front end.
/// @internal
function _match_number_has_dot(text)
  if len(text) <= 0 then return false end if
  for i = 0 to len(text) - 1
    if text[i] == "." then return true end if
  end for
  return false
end function

/// Reports whether contains dot.
/// @internal
function _containsDot(text)
  if len(text) <= 0 then return false end if
  for i = 0 to len(text) - 1
    if text[i] == "." then return true end if
  end for
  return false
end function

/// Returns parse postfix.
/// @internal
function _parse_postfix()
  expr = _parse_primary()
  if _has_error() then return end if
  while true
    tok = _peek()
    if _tok_kind_id(tok) == TK_LPAREN then
      sp = t.ast_pos(expr)
      if typeof(sp) != "int" then sp = _tok_pos(tok) end if
      _advance()
      parsed_args = _parse_call_arguments()
      if _has_error() then return end if
      expr = Call("Call", expr, parsed_args.values, parsed_args.names, sp, _filename)
      continue
    end if
    if _tok_kind_id(tok) == TK_LBRACK then
      sp = t.ast_pos(expr)
      if typeof(sp) != "int" then sp = _tok_pos(tok) end if
      _advance()
      _skip_newlines()
      idx = _parse_expr(0)
      if _has_error() then return end if
      _skip_newlines()
      _expect_kind(TK_RBRACK)
      if _has_error() then return end if
      expr = Index("Index", expr, idx, sp, _filename)
      continue
    end if
    if _tok_kind_id(tok) == TK_DOT then
      sp = t.ast_pos(expr)
      if typeof(sp) != "int" then sp = _tok_pos(tok) end if
      _advance()
      nm = _expect_kind(TK_IDENT)
      if _has_error() then return end if
      expr = Member("Member", expr, _tok_value(nm), sp, _filename)
      continue
    end if
    if _tok_kind_id(tok) == TK_OP and _tok_value(tok) == "?." then
      sp = t.ast_pos(expr)
      if typeof(sp) != "int" then sp = _tok_pos(tok) end if
      _advance()
      nm = _expect_kind(TK_IDENT)
      if _has_error() then return end if
      expr = SafeMember("SafeMember", expr, _tok_value(nm), sp, _filename)
      continue
    end if
    break
  end while
  return expr
end function

/// Returns parse unary.
/// @internal
function _parse_unary()
  t = _peek()
  if _tok_kind_id(t) == TK_OP and _tok_value(t) == "+" then
    sp = _tok_pos(t)
    _advance()
    _skip_newlines()
    r = _parse_unary()
    if _has_error() then return end if
    return Unary("Unary", "+", r, sp, _filename)
  end if
  if _tok_kind_id(t) == TK_OP and _tok_value(t) == "-" then
    sp = _tok_pos(t)
    _advance()
    _skip_newlines()
    r = _parse_unary()
    if _has_error() then return end if
    return Unary("Unary", "-", r, sp, _filename)
  end if
  if _tok_kind_id(t) == TK_OP and _tok_value(t) == "~" then
    sp = _tok_pos(t)
    _advance()
    _skip_newlines()
    r = _parse_unary()
    if _has_error() then return end if
    return Unary("Unary", "~", r, sp, _filename)
  end if
  if _tok_kind_id(t) == TK_KW and _tok_value(t) == "not" then
    sp = _tok_pos(t)
    _advance()
    _skip_newlines()
    r = _parse_unary()
    if _has_error() then return end if
    return Unary("Unary", "not", r, sp, _filename)
  end if
  if _tok_kind_id(t) == TK_KW and _tok_value(t) == "await" then
    sp = _tok_pos(t)
    _advance()
    _skip_newlines()
    r = _parse_unary()
    if _has_error() then return end if
    callee = Var("Var", "__ml_await", sp, _filename)
    return Call("Call", callee, [r], [], sp, _filename)
  end if
  return _parse_postfix()
end function

/// Reports whether canonical type name.
/// @internal
function _canonical_type_name(raw_ty)
  if raw_ty == "integer" then return "int" end if
  if raw_ty == "boolean" then return "bool" end if
  if raw_ty == "str" then return "string" end if
  return raw_ty
end function

/// Reports whether is allowed type name.
/// @internal
function _is_allowed_type_name(ty)
  return ty == "int" or ty == "float" or ty == "bool" or ty == "string" or ty == "array" or ty == "bytes" or ty == "function" or ty == "struct" or ty == "enum" or ty == "error" or ty == "thread" or ty == "void" or ty == "unknown"
end function

/// Returns parse expr.
/// @internal
function _parse_expr(min_prec)
  left = _parse_unary()
  if _has_error() then return end if
  while true
    tok = _peek()
    op = ""
    if _tok_kind_id(tok) == TK_OP then op = _tok_value(tok) end if
    if _tok_kind_id(tok) == TK_KW and(_tok_value(tok) == "and" or _tok_value(tok) == "or" or _tok_value(tok) == "is") then op = _tok_value(tok) end if
    if op == "" then break end if
    prec = _precedence(op)
    if prec < min_prec or prec < 0 then break end if
    _advance()
    _skip_newlines()

    if op == "is" then
      is_start = _tok_pos(tok)
      is_not = false
      if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "not" then
        is_not = true
        _advance()
        _skip_newlines()
      end if

      ty_tok = _peek()
      if _tok_kind_id(ty_tok) != TK_IDENT and _tok_kind_id(ty_tok) != TK_KW then
        _set_error("Expected type name after 'is'", _tok_pos(ty_tok))
        return
      end if

      ty_raw = _tok_value(_advance())
      while _match_kind(TK_DOT)
        seg = _expect_kind(TK_IDENT)
        if _has_error() then return end if
        ty_raw = ty_raw + "." + _tok_value(seg)
      end while

      ty_l = s.toLowerAscii(ty_raw)
      ty_canon = ty_raw
      if _containsDot(ty_raw) == false then
        ty_canon = _canonical_type_name(ty_l)
      end if

      sp = t.ast_pos(left)
      if typeof(sp) != "int" then sp = is_start end if

      if _is_allowed_type_name(ty_canon) then
        tvar = t.ast_leaf_new("Var", "typeof", is_start, _filename)
        tcall = Call("Call", tvar,[left], [], sp, _filename)
        rhs = t.ast_leaf_new("Str", ty_canon, _tok_pos(ty_tok), _filename)
        cmp = t.ast_bin_new(tcall, "==", rhs, sp, _filename)
        if is_not then
          left = Unary("Unary", "not", cmp, sp, _filename)
        else
          left = cmp
        end if
      else
        left = IsType("IsType", left, ty_raw, is_not, sp, _filename)
      end if
      continue
    end if

    right = _parse_expr(prec + 1)
    if _has_error() then return end if
    sp = t.ast_pos(left)
    if typeof(sp) != "int" then sp = _tok_pos(tok) end if
    if op == "??" then
      left = Coalesce("Coalesce", left, right, sp, _filename)
    else
      left = t.ast_bin_new(left, op, right, sp, _filename)
    end if
  end while
  return left
end function

/// Returns parse ident list.
/// @internal
function _parse_ident_list(end_kind)
  items_chunks = []
  items_tail = []
  _skip_newlines()
  if _match_kind(end_kind) then return _chunked_finish(items_chunks, items_tail) end if
  while true
    t = _expect_kind(TK_IDENT)
    if _has_error() then return end if
    app = _chunked_push(items_chunks, items_tail, _tok_value(t), 32)
    items_chunks = app[0]
    items_tail = app[1]
    _skip_newlines()
    if _match_kind(TK_COMMA) then
      _skip_newlines()
      if _match_kind(end_kind) then break end if
      continue
    end if
    _expect_kind(end_kind)
    if _has_error() then return end if
    break
  end while
  return _chunked_finish(items_chunks, items_tail)
end function

/// Parse or represent skip stmt seps in the MiniLang front end.
/// @internal
function _skip_stmt_seps()
  while true
    if _match_kind(TK_NL) then continue end if
    if _match_kind(TK_SEMI) then continue end if
    break
  end while
end function

/// Parse or represent expect block nl in the MiniLang front end.
/// @internal
function _expect_block_nl()
  if _match_kind(TK_NL) or _match_kind(TK_SEMI) then
    _skip_stmt_seps()
    return
  end if
end function

/// Reports whether is end of.
/// @internal
function _is_end_of(what)
  next_kind = _tok_kind_id(_peek2())
  return _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "end" and (next_kind == TK_KW or next_kind == TK_IDENT) and _tok_value(_peek2()) == what
end function

/// Parse or represent expect end of in the MiniLang front end.
/// @internal
function _expect_end_of(what)
  _expect_value(TK_KW, "end")
  if _has_error() then return end if
  tok = _peek()
  kind = _tok_kind_id(tok)
  if (kind != TK_KW and kind != TK_IDENT) or _tok_value(tok) != what then
    _set_error("Expected '" + what + "'", _tok_pos(tok))
    return
  end if
  _advance()
end function

/// Returns parse dotted name.
/// @internal
function _parse_dotted_name()
  t = _expect_kind(TK_IDENT)
  if _has_error() then return end if
  out_name = _tok_value(t)
  while _match_kind(TK_DOT)
    seg = _expect_kind(TK_IDENT)
    if _has_error() then return end if
    out_name = out_name + "." + _tok_value(seg)
  end while
  return out_name
end function

/// Parse or represent peek non nl in the MiniLang front end.
/// @internal
function _peek_non_nl()
  /// Current tokens used by this routine.
  /// @internal
  global _tokens, _i
  j = _i
  while j < _token_count(_tokens) and _tok_kind_id(j) == TK_NL
    j = j + 1
  end while
  if j >= _token_count(_tokens) then
    return _token_count(_tokens) - 1
  end if
  return j
end function

/// Returns parse extern param.
/// @internal
function _parse_extern_param()
  is_out = false
  if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "out" then
    is_out = true
    _advance()
  end if
  t = _peek()
  if _tok_kind_id(t) != TK_IDENT and _tok_kind_id(t) != TK_KW then
    _set_error("external parameter expects a type or '<name> as <type>'", _tok_pos(t))
    return
  end if
  first = _tok_value(_advance())
  if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "as" then
    _advance()
    ty_tok = _peek()
    if _tok_kind_id(ty_tok) != TK_IDENT and _tok_kind_id(ty_tok) != TK_KW then
      _set_error("external parameter expects a type name after 'as'", _tok_pos(ty_tok))
      return
    end if
    ty = _tok_value(_advance())
    return ExternParam("ExternParam", first, ty, is_out)
  end if
  return ExternParam("ExternParam", 0, first, is_out)
end function

/// Returns parse extern param list.
/// @internal
function _parse_extern_param_list(end_kind)
  items_chunks = []
  items_tail = []
  _skip_newlines()
  if _match_kind(end_kind) then return _chunked_finish(items_chunks, items_tail) end if
  while true
    p = _parse_extern_param()
    if _has_error() then return end if
    app = _chunked_push(items_chunks, items_tail, p, 32)
    items_chunks = app[0]
    items_tail = app[1]
    _skip_newlines()
    if _match_kind(TK_COMMA) then
      _skip_newlines()
      if _match_kind(end_kind) then break end if
      continue
    end if
    _expect_kind(end_kind)
    if _has_error() then return end if
    break
  end while
  return _chunked_finish(items_chunks, items_tail)
end function

/// Returns parse namespace def.
/// @internal
function _parse_namespace_def(start_pos)
  /// Current ns depth used by this routine.
  /// @internal
  global _ns_depth, _func_depth
  _expect_value(TK_KW, "namespace")
  if _has_error() then return end if
  if _func_depth > 0 then
    _set_error("'namespace' is only permitted at the top level", start_pos)
    return
  end if

  ns_name = _parse_dotted_name()
  if _has_error() then return end if
  _expect_block_nl()

  _ns_depth = _ns_depth + 1
  body_chunks = []
  body_tail = []
  _skip_stmt_seps()
  while not _is_end_of("namespace")
    if _tok_kind_id(_peek()) == TK_EOF then
      _set_error("namespace ends unexpectedly (missing 'end namespace'?)", _tok_pos(_peek()))
      break
    end if
    t = _peek()
    if _tok_kind_id(t) == TK_KW and _tok_value(t) == "import" then
      _set_error("'import' is not allowed inside a namespace", _tok_pos(t))
      if _collect_errors then
        _record_error(_last_error)
        _clear_error()
        _sync_stmt([], "namespace")
        if len(_errors) >= _max_errors then
          break
        end if
        _skip_stmt_seps()
        continue
      end if
      break
    end if

    if _tok_kind_id(t) == TK_KW and(_tok_value(t) == "function" or _tok_value(t) == "struct" or _tok_value(t) == "interface" or _tok_value(t) == "enum" or _tok_value(t) == "namespace" or _tok_value(t) == "extern" or _tok_value(t) == "const") then
      if _collect_errors then
        st = _parse_stmt_recover([], "namespace")
        if st != 0 then
          app = _chunked_push(body_chunks, body_tail, st, 32)
          body_chunks = app[0]
          body_tail = app[1]
        else
          if len(_errors) >= _max_errors then
            break
          end if
        end if
      else
        st = _parse_stmt()
        if _has_error() then break end if
        app = _chunked_push(body_chunks, body_tail, st, 32)
        body_chunks = app[0]
        body_tail = app[1]
      end if
      _skip_stmt_seps()
      continue
    end if

    if _tok_kind_id(t) == TK_IDENT then
      st = 0
      if _collect_errors then
        st = _parse_stmt_recover([], "namespace")
        if st == 0 then
          if len(_errors) >= _max_errors then
            break
          end if
          _skip_stmt_seps()
          continue
        end if
      else
        st = _parse_stmt()
        if _has_error() then break end if
      end if
      if st.node_kind == "Assign" then
        app2 = _chunked_push(body_chunks, body_tail, st, 32)
        body_chunks = app2[0]
        body_tail = app2[1]
        _skip_stmt_seps()
        continue
      end if
      _set_error("Inside a namespace, only declarations/globals are allowed (e.g. 'x = ...')", _tok_pos(t))
      if _collect_errors then
        _record_error(_last_error)
        _clear_error()
        _sync_stmt([], "namespace")
        if len(_errors) >= _max_errors then
          break
        end if
        _skip_stmt_seps()
        continue
      end if
      break
    end if

    _set_error("Inside a namespace, only declarations are allowed", _tok_pos(t))
    if _collect_errors then
      _record_error(_last_error)
      _clear_error()
      _sync_stmt([], "namespace")
      if len(_errors) >= _max_errors then
        break
      end if
      _skip_stmt_seps()
      continue
    end if
    break
  end while
  _ns_depth = _ns_depth - 1
  if _has_error() then return end if
  _expect_end_of("namespace")
  if _has_error() then return end if
  return NamespaceDef("NamespaceDef", ns_name, _chunked_finish(body_chunks, body_tail), start_pos, _filename)
end function

/// Returns parse block until end.
/// @internal
function _parse_block_until_end(end_type, start_pos)
  stmts_chunks = []
  stmts_tail = []
  _skip_stmt_seps()
  while true
    if _is_end_of(end_type) then break end if
    if _tok_kind_id(_peek()) == TK_EOF then
      _set_error("Block ended unexpectedly (missing 'end " + end_type + "'?)", _tok_pos(_peek()))
      return
    end if
    if _collect_errors then
      st = _parse_stmt_recover([], end_type)
      if st != 0 then
        app = _chunked_push(stmts_chunks, stmts_tail, st, 64)
        stmts_chunks = app[0]
        stmts_tail = app[1]
      else
        if len(_errors) >= _max_errors then
          break
        end if
      end if
    else
      st = _parse_stmt()
      if _has_error() then return end if
      app2 = _chunked_push(stmts_chunks, stmts_tail, st, 64)
      stmts_chunks = app2[0]
      stmts_tail = app2[1]
    end if
    _skip_stmt_seps()
  end while
  return _chunked_finish(stmts_chunks, stmts_tail)
end function

/// Reports whether contains.
/// @internal
function _contains(arr, value)
  if len(arr) <= 0 then return false end if
  for i = 0 to len(arr) - 1
    if arr[i] == value then return true end if
  end for
  return false
end function

/// Parse or represent record error in the MiniLang front end.
/// @internal
function _record_error(err)
  /// Current errors used by this routine.
  /// @internal
  global _errors, _max_errors
  if typeof(err) != "struct" then return end if
  if len(_errors) >= _max_errors then return end if
  _errors = _errors +[err]
end function

/// Parse or represent sync stmt in the MiniLang front end.
/// @internal
function _sync_stmt(stop_keywords, end_type)
  /// Current i used by this routine.
  /// @internal
  global _i
  start_i = _i
  while true
    t = _peek()
    if _tok_kind_id(t) == TK_EOF then
      return
    end if

    if _tok_kind_id(t) == TK_NL or _tok_kind_id(t) == TK_SEMI then
      _skip_stmt_seps()
      return
    end if

    if _tok_kind_id(t) == TK_KW then
      if _contains(stop_keywords, _tok_value(t)) then
        return
      end if
      if _tok_value(t) == "end" or _tok_value(t) == "else" or _tok_value(t) == "case" or _tok_value(t) == "default" then
        return
      end if
      if typeof(end_type) == "string" and _is_end_of(end_type) then
        return
      end if
    end if

    _advance()
    if _i == start_i and _tok_kind_id(_peek()) != TK_EOF then
      _advance()
    end if
    start_i = _i
  end while
end function

/// Reports whether is case value continuation start.
/// @internal
function _is_case_value_continuation_start(tok)
  if _tok_kind_id(tok) == TK_NUMBER or _tok_kind_id(tok) == TK_STRING or _tok_kind_id(tok) == TK_LPAREN or _tok_kind_id(tok) == TK_LBRACK then
    return true
  end if
  if _tok_kind_id(tok) == TK_OP and(_tok_value(tok) == "-" or _tok_value(tok) == "~") then
    return true
  end if
  if _tok_kind_id(tok) == TK_KW and(_tok_value(tok) == "true" or _tok_value(tok) == "false" or _tok_value(tok) == "not") then
    return true
  end if
  return false
end function

/// Returns parse block until.
/// @internal
function _parse_block_until(stop_keywords, end_type, start_pos)
  stmts_chunks = []
  stmts_tail = []
  _skip_stmt_seps()
  while true
    t = _peek()
    if _tok_kind_id(t) == TK_KW and _contains(stop_keywords, _tok_value(t)) then break end if
    if typeof(end_type) == "string" and _is_end_of(end_type) then break end if
    if _tok_kind_id(t) == TK_EOF then
      if typeof(end_type) == "string" then
        _set_error("Block ended unexpectedly (missing 'end " + end_type + "'?)", _tok_pos(t))
      else
        _set_error("Block ended unexpectedly", _tok_pos(t))
      end if
      return
    end if
    if _collect_errors then
      st = _parse_stmt_recover(stop_keywords, end_type)
      if st != 0 then
        app = _chunked_push(stmts_chunks, stmts_tail, st, 64)
        stmts_chunks = app[0]
        stmts_tail = app[1]
      else
        if len(_errors) >= _max_errors then
          break
        end if
      end if
    else
      st = _parse_stmt()
      if _has_error() then return end if
      app2 = _chunked_push(stmts_chunks, stmts_tail, st, 64)
      stmts_chunks = app2[0]
      stmts_tail = app2[1]
    end if
    _skip_stmt_seps()
  end while
  return _chunked_finish(stmts_chunks, stmts_tail)
end function

/// Returns parse stmt.
/// @internal
function _parse_stmt()
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt
  t = _peek()
  start_pos = _tok_pos(t)
  kind = _tok_kind_id(t)
  value = _tok_value(t)

  if kind == TK_KW and value == "package" then
    return _parse_stmt_package(start_pos, t)
  end if

  if kind == TK_KW and value == "namespace" then
    return _parse_stmt_namespace(start_pos, t)
  end if

  if kind == TK_KW and value == "import" then
    return _parse_stmt_import(start_pos, t)
  end if

  if kind == TK_KW and value == "const" then
    return _parse_stmt_const(start_pos, t)
  end if

  if kind == TK_KW and value == "synchronized" then
    return _parse_stmt_synchronized(start_pos, t)
  end if

  if kind == TK_KW and value == "print" then
    return _parse_stmt_print(start_pos, t)
  end if

  if kind == TK_KW and value == "break" then
    return _parse_stmt_break(start_pos, t)
  end if

  if kind == TK_KW and value == "continue" then
    return _parse_stmt_continue(start_pos, t)
  end if

  if kind == TK_KW and value == "global" then
    return _parse_stmt_global(start_pos, t)
  end if

  if kind == TK_KW and value == "return" then
    return _parse_stmt_return(start_pos, t)
  end if

  if kind == TK_KW and value == "yield" then
    return _parse_stmt_yield(start_pos, t)
  end if

  if kind == TK_KW and value == "defer" then
    return _parse_stmt_defer(start_pos, t)
  end if

  if kind == TK_KW and value == "extern" then
    return _parse_stmt_extern(start_pos, t)
  end if

  if kind == TK_KW and value == "struct" then
    return _parse_stmt_struct(start_pos, t)
  end if

  if kind == TK_KW and value == "interface" then
    return _parse_stmt_interface(start_pos, t)
  end if

  if kind == TK_KW and value == "enum" then
    return _parse_stmt_enum(start_pos, t)
  end if

  is_lazy_iterator = kind == TK_IDENT and value == "lazy" and _tok_kind_id(_peek2()) == TK_KW and _tok_value(_peek2()) == "iterator" and _tok_kind_id(_peek3()) == TK_KW and _tok_value(_peek3()) == "function"
  if (kind == TK_KW and(value == "function" or value == "async" or value == "iterator")) or is_lazy_iterator then
    return _parse_stmt_function(start_pos, t)
  end if

  if kind == TK_KW and value == "loop" then
    return _parse_stmt_loop(start_pos, t)
  end if

  if (kind == TK_KW and value == "switch") or ((kind == TK_KW or kind == TK_IDENT) and value == "match" and _tok_kind_id(_peek2()) != TK_OP and _tok_kind_id(_peek2()) != TK_DOT) then
    return _parse_stmt_switch(start_pos, t)
  end if

  if kind == TK_KW and value == "if" then
    return _parse_stmt_if(start_pos, t)
  end if

  if kind == TK_KW and value == "while" then
    return _parse_stmt_while(start_pos, t)
  end if

  if kind == TK_KW and value == "for" then
    return _parse_stmt_for(start_pos, t)
  end if

  if kind == TK_IDENT then
    return _parse_stmt_ident(start_pos, t)
  end if

  _set_error("Unknown statement: " + _tok_desc(t), start_pos)
end function

/// Returns parse stmt package.
/// @internal
function _parse_stmt_package(start_pos, t)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  if _func_depth > 0 or _ns_depth > 0 then
    _set_error("'package' is only allowed at top level", _tok_pos(t))
    return
  end if
  if _seen_package then
    _set_error("'package' may only appear once per file", _tok_pos(t))
    return
  end if
  if _seen_nonpackage_toplevel_stmt then
    _set_error("'package' must be the first statement in the file", _tok_pos(t))
    return
  end if
  _seen_package = true
  _advance()
  name = _parse_dotted_name()
  if _has_error() then return end if
  return NamespaceDecl("NamespaceDecl", name, start_pos, _filename)
end function

/// Returns parse stmt namespace.
/// @internal
function _parse_stmt_namespace(start_pos, t)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  return _parse_namespace_def(start_pos)
end function

/// Returns parse stmt import.
/// @internal
function _parse_stmt_import(start_pos, t)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  if _func_depth > 0 or _ns_depth > 0 then
    _set_error("'import' is only allowed at top level", _tok_pos(t))
    return
  end if
  _advance()
  module_name = 0
  path = ""
  if _tok_kind_id(_peek()) == TK_STRING then
    st = _advance()
    path = _decode_string_token(st)
    if _has_error() then return end if
  else
    module_name = _parse_dotted_name()
    if _has_error() then return end if
    path = _replaceDotsWithSlash(module_name) + ".ml"
  end if
  alias = 0
  if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "as" then
    _advance()
    a = _expect_kind(TK_IDENT)
    if _has_error() then return end if
    alias = _tok_value(a)
  end if
  return Import("Import", path, alias, module_name, start_pos, _filename)
end function

/// Returns parse stmt const.
/// @internal
function _parse_stmt_const(start_pos, t)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  _advance()
  n = _expect_kind(TK_IDENT)
  if _has_error() then return end if
  _expect_value(TK_OP, "=")
  if _has_error() then return end if
  e = _parse_expr(0)
  if _has_error() then return end if
  return ConstDecl("ConstDecl", _tok_value(n), e, start_pos, _filename)
end function

/// Returns parse stmt synchronized.
/// @internal
function _parse_stmt_synchronized(start_pos, t)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  _advance()
  if _match_kind(TK_LPAREN) then
    lock_expr = _parse_expr(0)
    if _has_error() then return end if
    _expect_kind(TK_RPAREN)
    if _has_error() then return end if
    _expect_block_nl()
    body = _parse_block_until_end("synchronized", start_pos)
    if _has_error() then return end if
    _expect_end_of("synchronized")
    if _has_error() then return end if
    return SynchronizedBlock("SynchronizedBlock", lock_expr, body, 0, start_pos, _filename)
  end if
  n = _expect_kind(TK_IDENT)
  if _has_error() then return end if
  _expect_value(TK_OP, "=")
  if _has_error() then return end if
  e = _parse_expr(0)
  if _has_error() then return end if
  return SynchronizedDecl("SynchronizedDecl", _tok_value(n), e, start_pos, _filename)
end function

/// Returns parse stmt print.
/// @internal
function _parse_stmt_print(start_pos, t)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  _advance()
  e = _parse_expr(0)
  if _has_error() then return end if
  return Print("Print", e, start_pos, _filename)
end function

/// Returns parse stmt break.
/// @internal
function _parse_stmt_break(start_pos, t)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  _advance()
  if _tok_kind_id(_peek()) == TK_NUMBER and not _match_number_has_dot(_tok_value(_peek())) then
    nraw = _tok_value(_advance())
    n = _parse_int_literal(nraw)
    if typeof(n) != "int" then n = 1 end if
    if n < 1 then n = 1 end if
    return Break("Break", n, start_pos, _filename)
  end if
  return Break("Break", 1, start_pos, _filename)
end function

/// Returns parse stmt continue.
/// @internal
function _parse_stmt_continue(start_pos, t)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  _advance()
  return Continue("Continue", start_pos, _filename)
end function

/// Returns parse stmt global.
/// @internal
function _parse_stmt_global(start_pos, t)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  if _func_depth <= 0 then
    _set_error("'global' is only allowed inside functions", _tok_pos(t))
    return
  end if
  _advance()
  n0 = _expect_kind(TK_IDENT)
  if _has_error() then return end if
  names_chunks = []
  names_tail = []
  appn0 = _chunked_push(names_chunks, names_tail, _tok_value(n0), 16)
  names_chunks = appn0[0]
  names_tail = appn0[1]
  while _match_kind(TK_COMMA)
    if _tok_kind_id(_peek()) == TK_NL or _tok_kind_id(_peek()) == TK_SEMI or _tok_kind_id(_peek()) == TK_EOF then
      break
    end if
    ni = _expect_kind(TK_IDENT)
    if _has_error() then return end if
    appn = _chunked_push(names_chunks, names_tail, _tok_value(ni), 16)
    names_chunks = appn[0]
    names_tail = appn[1]
  end while
  return GlobalDecl("GlobalDecl", _chunked_finish(names_chunks, names_tail), start_pos, _filename)
end function

/// Returns parse stmt return.
/// @internal
function _parse_stmt_return(start_pos, t)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  _advance()
  nxt = _peek()
  if _tok_kind_id(nxt) == TK_NL or _tok_kind_id(nxt) == TK_SEMI or _tok_kind_id(nxt) == TK_EOF then
    return Return("Return", 0, start_pos, _filename)
  end if
  if _tok_kind_id(nxt) == TK_KW and(_tok_value(nxt) == "end" or _tok_value(nxt) == "else" or _tok_value(nxt) == "case" or _tok_value(nxt) == "default") then
    return Return("Return", 0, start_pos, _filename)
  end if
  e = _parse_expr(0)
  if _has_error() then return end if
  return Return("Return", e, start_pos, _filename)
end function

/// Returns parse stmt yield.
/// @internal
function _parse_stmt_yield(start_pos, tok)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth
  if _func_depth <= 0 then _set_error("'yield' is only allowed inside iterator functions", start_pos) return end if
  _advance()
  nxt = _peek()
  if _tok_kind_id(nxt) == TK_NL or _tok_kind_id(nxt) == TK_SEMI or _tok_kind_id(nxt) == TK_EOF then
    return Yield("Yield", 0, start_pos, _filename)
  end if
  if _tok_kind_id(nxt) == TK_KW and(_tok_value(nxt) == "end" or _tok_value(nxt) == "else" or _tok_value(nxt) == "case" or _tok_value(nxt) == "default") then
    return Yield("Yield", 0, start_pos, _filename)
  end if
  value = _parse_expr(0)
  if _has_error() then return end if
  return Yield("Yield", value, start_pos, _filename)
end function

/// Returns parse stmt defer.
/// @internal
function _parse_stmt_defer(start_pos, t)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  if _func_depth <= 0 then
    _set_error("'defer' is only allowed inside functions", _tok_pos(t))
    return
  end if
  _advance()
  e = _parse_expr(0)
  if _has_error() then return end if
  if typeof(e) != "struct" or try(e.node_kind) != "Call" then
    _set_error("'defer' expects a function or method call", start_pos)
    return
  end if
  return Defer("Defer", e, -1, [], "", start_pos, _filename)
end function

/// Returns parse stmt extern.
/// @internal
function _parse_stmt_extern(start_pos, t)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  if _func_depth > 0 then
    _set_error("'extern' is only allowed at top-level / inside namespace", _tok_pos(t))
    return
  end if
  _advance()

  if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "struct" then
    _advance()
    nm = _expect_kind(TK_IDENT)
    if _has_error() then return end if
    _expect_block_nl()
    fields_chunks = []
    fields_tail = []
    field_tys_chunks = []
    field_tys_tail = []
    while not _is_end_of("struct")
      _skip_stmt_seps()
      if _is_end_of("struct") then break end if
      if _tok_kind_id(_peek()) == TK_EOF then
        _set_error("extern struct ended unexpectedly (missing 'end struct'?)", _tok_pos(_peek()))
        return
      end if
      fn = _expect_kind(TK_IDENT)
      if _has_error() then return end if
      _expect_value(TK_KW, "as")
      if _has_error() then return end if
      ty_tok = _peek()
      if _tok_kind_id(ty_tok) != TK_IDENT and _tok_kind_id(ty_tok) != TK_KW then
        _set_error("extern struct field expects typename after 'as'", _tok_pos(ty_tok))
        return
      end if
      fty = _tok_value(_advance())
      appf = _chunked_push(fields_chunks, fields_tail, _tok_value(fn), 16)
      fields_chunks = appf[0]
      fields_tail = appf[1]
      appty = _chunked_push(field_tys_chunks, field_tys_tail, fty, 16)
      field_tys_chunks = appty[0]
      field_tys_tail = appty[1]
      _expect_block_nl()
    end while
    _expect_end_of("struct")
    if _has_error() then return end if
    return StructDef("StructDef", _tok_value(nm), _chunked_finish(fields_chunks, fields_tail), [], [], [], [], _chunked_finish(field_tys_chunks, field_tys_tail), start_pos, _filename)
  end if

  _expect_value(TK_KW, "function")
  if _has_error() then return end if
  nm = _expect_kind(TK_IDENT)
  if _has_error() then return end if
  _expect_kind(TK_LPAREN)
  if _has_error() then return end if
  params = _parse_extern_param_list(TK_RPAREN)
  if _has_error() then return end if

  if not(_tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "from") then
    _set_error("extern function expects 'from \"...\"'", _tok_pos(_peek()))
    return
  end if
  _advance()

  dll_tok = _expect_kind(TK_STRING)
  if _has_error() then return end if
  dll = _decode_string_token(dll_tok)
  if _has_error() then return end if

  sym_name = 0
  if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "symbol" then
    _advance()
    st = _expect_kind(TK_STRING)
    if _has_error() then return end if
    sym_name = _decode_string_token(st)
    if _has_error() then return end if
  end if

  ret_ty = "int"
  if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "returns" then
    _advance()
    rt = _peek()
    if _tok_kind_id(rt) != TK_IDENT and _tok_kind_id(rt) != TK_KW then
      _set_error("returns expects typename", _tok_pos(rt))
      return
    end if
    ret_ty = _tok_value(_advance())
  end if

  return ExternFunctionDef("ExternFunctionDef", _tok_value(nm), params, dll, sym_name, ret_ty, start_pos, _filename)
end function

/// Returns parse stmt interface.
/// @internal
function _parse_stmt_interface(start_pos, tok)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth
  if _func_depth > 0 then _set_error("'interface' is only allowed at declaration scope", start_pos) return end if
  _advance()
  name_tok = _expect_kind(TK_IDENT)
  if _has_error() then return end if
  _expect_block_nl()
  methods_chunks = []
  methods_tail = []
  while not _is_end_of("interface")
    _skip_stmt_seps()
    if _is_end_of("interface") then break end if
    _expect_value(TK_KW, "function")
    if _has_error() then return end if
    mpos = _tok_pos(_peek())
    method_name = _expect_kind(TK_IDENT)
    if _has_error() then return end if
    _expect_kind(TK_LPAREN)
    if _has_error() then return end if
    parsed = _parse_parameter_list()
    if _has_error() then return end if
    if len(parsed.defaults) > 0 then
      for i = 0 to len(parsed.defaults) - 1
        if typeof(parsed.defaults[i]) != "void" then _set_error("Interface methods cannot declare default values", mpos) return end if
      end for
    end if
    return_type = void
    return_optional = false
    if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "returns" then
      _advance()
      rt = _parse_type_ref()
      if _has_error() then return end if
      return_type = rt[0]
      return_optional = rt[1]
    end if
    method = _new_function_node(_tok_value(method_name), parsed.names, [], false, false, false, parsed.types, parsed.optionals, [], parsed.variadic_index, return_type, return_optional, false, false, mpos, _filename)
    app = _chunked_push(methods_chunks, methods_tail, method, 16)
    methods_chunks = app[0]
    methods_tail = app[1]
    _expect_block_nl()
  end while
  _expect_end_of("interface")
  if _has_error() then return end if
  return InterfaceDef("InterfaceDef", _tok_value(name_tok), _chunked_finish(methods_chunks, methods_tail), start_pos, _filename)
end function

/// Returns parse stmt struct.
/// @internal
function _parse_stmt_struct(start_pos, t)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  _advance()
  nm = _expect_kind(TK_IDENT)
  if _has_error() then return end if
  interfaces = []
  if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "implements" then
    _advance()
    while true
      iface = _parse_type_ref()
      if _has_error() then return end if
      if iface[1] then _set_error("An implemented interface cannot be optional", _tok_pos(_peek())) return end if
      interfaces = interfaces + [iface[0]]
      if not _match_kind(TK_COMMA) then break end if
    end while
  end if
  if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "are" then
    _advance()
  end if
  _expect_block_nl()

  fields_chunks = []
  fields_tail = []
  field_types_chunks = []
  field_types_tail = []
  field_optional_chunks = []
  field_optional_tail = []
  methods_chunks = []
  methods_tail = []
  while not _is_end_of("struct")
    _skip_stmt_seps()
    if _is_end_of("struct") then break end if
    if _tok_kind_id(_peek()) == TK_EOF then
      _set_error("struct ended unexpectedly (missing 'end struct'?)", _tok_pos(_peek()))
      return
    end if

    if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "operator" then
      operator_pos = _tok_pos(_advance())
      operator_inline = false
      if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "inline" then
        _advance()
        operator_inline = true
      end if
      operator_tok = _peek()
      operator_symbol = ""
      if _tok_kind_id(operator_tok) == TK_OP or (_tok_kind_id(operator_tok) == TK_KW and _tok_value(operator_tok) == "not") then
        operator_symbol = _tok_value(_advance())
      else
        _set_error("Expected a supported operator after 'operator'", _tok_pos(operator_tok))
        return
      end if
      _expect_kind(TK_LPAREN)
      if _has_error() then return end if
      operator_params = _parse_parameter_list()
      if _has_error() then return end if
      operator_name_base = operator_method_name(operator_symbol, len(operator_params.names))
      if operator_name_base == "" then
        _set_error("Operator '" + operator_symbol + "' does not support " + len(operator_params.names) + " operand(s)", operator_pos)
        return
      end if
      if operator_params.variadic_index >= 0 then
        _set_error("Operator parameters cannot be variadic or have default values", operator_pos)
        return
      end if
      for operator_i = 0 to len(operator_params.names) - 1
        if typeof(operator_params.types[operator_i]) != "string" or operator_params.optionals[operator_i] then
          _set_error("Every operator operand requires a non-optional type", operator_pos)
          return
        end if
        if typeof(operator_params.defaults[operator_i]) != "void" then
          _set_error("Operator parameters cannot be variadic or have default values", operator_pos)
          return
        end if
      end for
      first_operator_type = operator_params.types[0]
      first_operator_dot = s.lastIndexOf(first_operator_type, ".")
      if first_operator_dot >= 0 then first_operator_type = s.substr(first_operator_type, first_operator_dot + 1, len(first_operator_type) - first_operator_dot - 1) end if
      if first_operator_type != _tok_value(nm) then
        _set_error("The first operator operand must have the owning struct type '" + _tok_value(nm) + "'", operator_pos)
        return
      end if
      if _tok_kind_id(_peek()) != TK_KW or _tok_value(_peek()) != "returns" then
        _set_error("Operator declarations require an explicit return type", _tok_pos(_peek()))
        return
      end if
      _advance()
      operator_return = _parse_type_ref()
      if _has_error() then return end if
      if operator_return[1] then
        _set_error("Operator return types cannot be optional", operator_pos)
        return
      end if
      operator_return_name = s.toLowerAscii(operator_return[0])
      if operator_return_name == "void" then
        _set_error("Operator return types cannot be void", operator_pos)
        return
      end if
      if (operator_symbol == "==" or operator_symbol == "!=" or operator_symbol == "<" or operator_symbol == "<=" or operator_symbol == ">" or operator_symbol == ">=" or operator_symbol == "not") and operator_return_name != "bool" and operator_return_name != "boolean" then
        _set_error("Operator '" + operator_symbol + "' must return bool", operator_pos)
        return
      end if
      same_operator_count = 0
      existing_methods = _chunked_finish(methods_chunks, methods_tail)
      if len(existing_methods) > 0 then
        for existing_i = 0 to len(existing_methods) - 1
          existing_method = existing_methods[existing_i]
          if s.startsWith(existing_method.name, operator_name_base + "__overload_") then
            same_operator_count = same_operator_count + 1
            same_signature = len(existing_method.param_types) == len(operator_params.types)
            if same_signature and len(operator_params.types) > 0 then
              for signature_i = 0 to len(operator_params.types) - 1
                if existing_method.param_types[signature_i] != operator_params.types[signature_i] then same_signature = false break end if
              end for
            end if
            if same_signature then
              _set_error("Duplicate operator '" + operator_symbol + "' signature", operator_pos)
              return
            end if
          end if
        end for
      end if
      operator_name = operator_name_base + "__overload_" + same_operator_count
      _expect_block_nl()
      _func_depth = _func_depth + 1
      operator_body = _parse_block_until_end("operator", operator_pos)
      _func_depth = _func_depth - 1
      if _has_error() then return end if
      _expect_end_of("operator")
      if _has_error() then return end if
      operator_node = _new_function_node(operator_name, operator_params.names, operator_body, true, operator_inline, false, operator_params.types, operator_params.optionals, operator_params.defaults, -1, operator_return[0], false, false, false, operator_pos, _filename)
      app_operator = _chunked_push(methods_chunks, methods_tail, operator_node, 16)
      methods_chunks = app_operator[0]
      methods_tail = app_operator[1]
      continue
    end if

    if _tok_kind_id(_peek()) == TK_KW and(_tok_value(_peek()) == "function" or _tok_value(_peek()) == "static") then
      mpos = _tok_pos(_peek())
      is_static = false
      if _tok_value(_peek()) == "static" then
        is_static = true
        _advance()
        _skip_newlines()
        _expect_value(TK_KW, "function")
        if _has_error() then return end if
      else
        _advance()
      end if

      is_inline = false
      is_synchronized = false
      while _tok_kind_id(_peek()) == TK_KW and(_tok_value(_peek()) == "inline" or _tok_value(_peek()) == "synchronized")
        modifier = _tok_value(_advance())
        if modifier == "inline" then
          if is_inline then _set_error("duplicate function modifier 'inline'", _tok_pos(_peek())) return end if
          is_inline = true
        else
          if is_synchronized then _set_error("duplicate function modifier 'synchronized'", _tok_pos(_peek())) return end if
          is_synchronized = true
        end if
      end while

      mn = _expect_kind(TK_IDENT)
      if _has_error() then return end if
      if s.startsWith(_tok_value(mn), "__operator_") then
        _set_error("Method names beginning with '__operator_' are reserved", _tok_pos(mn))
        return
      end if
      _expect_kind(TK_LPAREN)
      if _has_error() then return end if
      parsed = _parse_parameter_list()
      if _has_error() then return end if
      method_return_type = void
      method_return_optional = false
      if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "returns" then
        _advance()
        mrt = _parse_type_ref()
        if _has_error() then return end if
        method_return_type = mrt[0]
        method_return_optional = mrt[1]
      end if
      _expect_block_nl()
      _func_depth = _func_depth + 1
      mb = _parse_block_until_end("function", mpos)
      _func_depth = _func_depth - 1
      if _has_error() then return end if
      _expect_end_of("function")
      if _has_error() then return end if
      appm = _chunked_push(methods_chunks, methods_tail, _new_function_node(_tok_value(mn), parsed.names, mb, is_static, is_inline, is_synchronized, parsed.types, parsed.optionals, parsed.defaults, parsed.variadic_index, method_return_type, method_return_optional, false, false, mpos, _filename), 16)
      methods_chunks = appm[0]
      methods_tail = appm[1]
      continue
    end if

    f = _expect_kind(TK_IDENT)
    if _has_error() then return end if
    appf0 = _chunked_push(fields_chunks, fields_tail, _tok_value(f), 16)
    fields_chunks = appf0[0]
    fields_tail = appf0[1]
    fty = void
    foptional = false
    if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "as" then
      _advance()
      ftref = _parse_type_ref()
      if _has_error() then return end if
      fty = ftref[0]
      foptional = ftref[1]
    end if
    appft0 = _chunked_push(field_types_chunks, field_types_tail, fty, 16)
    field_types_chunks = appft0[0]
    field_types_tail = appft0[1]
    appfo0 = _chunked_push(field_optional_chunks, field_optional_tail, foptional, 16)
    field_optional_chunks = appfo0[0]
    field_optional_tail = appfo0[1]
    while _match_kind(TK_COMMA)
      if _tok_kind_id(_peek()) == TK_NL then
        nxt = _peek_non_nl()
        if _tok_kind_id(nxt) != TK_IDENT then break end if
        _skip_newlines()
      end if
      if _tok_kind_id(_peek()) != TK_IDENT then break end if
      fi = _expect_kind(TK_IDENT)
      if _has_error() then return end if
      appf = _chunked_push(fields_chunks, fields_tail, _tok_value(fi), 16)
      fields_chunks = appf[0]
      fields_tail = appf[1]
      fty = void
      foptional = false
      if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "as" then
        _advance()
        ftref = _parse_type_ref()
        if _has_error() then return end if
        fty = ftref[0]
        foptional = ftref[1]
      end if
      appft = _chunked_push(field_types_chunks, field_types_tail, fty, 16)
      field_types_chunks = appft[0]
      field_types_tail = appft[1]
      appfo = _chunked_push(field_optional_chunks, field_optional_tail, foptional, 16)
      field_optional_chunks = appfo[0]
      field_optional_tail = appfo[1]
    end while
    _expect_block_nl()
  end while

  _expect_end_of("struct")
  if _has_error() then return end if
  return StructDef(
    "StructDef",
    _tok_value(nm),
    _chunked_finish(fields_chunks, fields_tail),
    _chunked_finish(methods_chunks, methods_tail),
    _chunked_finish(field_types_chunks, field_types_tail),
    _chunked_finish(field_optional_chunks, field_optional_tail),
    interfaces,
    [],
    start_pos,
    _filename
  )
end function

/// Returns parse stmt enum.
/// @internal
function _parse_stmt_enum(start_pos, t)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  _advance()
  nm = _expect_kind(TK_IDENT)
  if _has_error() then return end if
  if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "are" then
    _advance()
  end if
  _expect_block_nl()

  variants_chunks = []
  variants_tail = []
  values_chunks = []
  values_tail = []
  while not _is_end_of("enum")
    _skip_stmt_seps()
    if _is_end_of("enum") then break end if
    if _tok_kind_id(_peek()) == TK_EOF then
      _set_error("enum ended unexpectedly (missing 'end enum'?)", _tok_pos(_peek()))
      return
    end if
    vn = _expect_kind(TK_IDENT)
    if _has_error() then return end if
    vv = void
    if _match_value(TK_OP, "=") then
      vv = _parse_expr(0)
      if _has_error() then return end if
    end if
    appv0 = _chunked_push(variants_chunks, variants_tail, _tok_value(vn), 32)
    variants_chunks = appv0[0]
    variants_tail = appv0[1]
    appval0 = _chunked_push(values_chunks, values_tail, vv, 32)
    values_chunks = appval0[0]
    values_tail = appval0[1]

    while _match_kind(TK_COMMA)
      if _tok_kind_id(_peek()) == TK_NL then
        nxt = _peek_non_nl()
        if _tok_kind_id(nxt) != TK_IDENT then break end if
        _skip_newlines()
      end if
      if _tok_kind_id(_peek()) != TK_IDENT then break end if
      vn2 = _expect_kind(TK_IDENT)
      if _has_error() then return end if
      vv2 = void
      if _match_value(TK_OP, "=") then
        vv2 = _parse_expr(0)
        if _has_error() then return end if
      end if
      appv = _chunked_push(variants_chunks, variants_tail, _tok_value(vn2), 32)
      variants_chunks = appv[0]
      variants_tail = appv[1]
      appval = _chunked_push(values_chunks, values_tail, vv2, 32)
      values_chunks = appval[0]
      values_tail = appval[1]
    end while
    _expect_block_nl()
  end while

  _expect_end_of("enum")
  if _has_error() then return end if
  return EnumDef(
    "EnumDef",
    _tok_value(nm),
    _chunked_finish(variants_chunks, variants_tail),
    _chunked_finish(values_chunks, values_tail),
    start_pos,
    _filename
  )
end function

/// Returns parse stmt function.
/// @internal
function _parse_stmt_function(start_pos, t)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  prefix = _tok_value(t)
  is_async = prefix == "async"
  is_lazy_iterator = prefix == "lazy"
  is_iterator = false
  if is_lazy_iterator then is_iterator = 2 else is_iterator = prefix == "iterator" end if
  _advance()
  if is_lazy_iterator then
    _expect_value(TK_KW, "iterator")
    if _has_error() then return end if
    _expect_value(TK_KW, "function")
    if _has_error() then return end if
  else if is_async or is_iterator then
    _expect_value(TK_KW, "function")
    if _has_error() then return end if
  end if
  is_inline = false
  is_synchronized = false
  while _tok_kind_id(_peek()) == TK_KW and(_tok_value(_peek()) == "inline" or _tok_value(_peek()) == "synchronized")
    modifier = _tok_value(_advance())
    if modifier == "inline" then
      if is_inline then _set_error("duplicate function modifier 'inline'", _tok_pos(_peek())) return end if
      is_inline = true
    else
      if is_synchronized then _set_error("duplicate function modifier 'synchronized'", _tok_pos(_peek())) return end if
      is_synchronized = true
    end if
  end while
  nm = _expect_kind(TK_IDENT)
  if _has_error() then return end if
  _expect_kind(TK_LPAREN)
  if _has_error() then return end if
  parsed = _parse_parameter_list()
  if _has_error() then return end if
  return_type = void
  return_optional = false
  if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "returns" then
    _advance()
    rt = _parse_type_ref()
    if _has_error() then return end if
    return_type = rt[0]
    return_optional = rt[1]
  end if
  _expect_block_nl()
  _func_depth = _func_depth + 1
  body = _parse_block_until_end("function", start_pos)
  _func_depth = _func_depth - 1
  if _has_error() then return end if
  _expect_end_of("function")
  if _has_error() then return end if
  return _new_function_node(_tok_value(nm), parsed.names, body, false, is_inline, is_synchronized, parsed.types, parsed.optionals, parsed.defaults, parsed.variadic_index, return_type, return_optional, is_async, is_iterator, start_pos, _filename)
end function

/// Returns parse stmt loop.
/// @internal
function _parse_stmt_loop(start_pos, t)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  /// Current i used by this routine.
  /// @internal
  global _i
  _advance()
  _expect_block_nl()
  body_chunks = []
  body_tail = []
  _skip_stmt_seps()
  while true
    if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "while" then
      save_i = _i
      _advance()
      cond = _parse_expr(0)
      if _has_error() then return end if
      _skip_stmt_seps()
      if _is_end_of("loop") then
        _expect_end_of("loop")
        if _has_error() then return end if
        return DoWhile("DoWhile", _chunked_finish(body_chunks, body_tail), cond, start_pos, _filename)
      end if
      _i = save_i
    end if

    if _is_end_of("loop") then
      _expect_end_of("loop")
      if _has_error() then return end if
      _expect_value(TK_KW, "while")
      if _has_error() then return end if
      cond = _parse_expr(0)
      if _has_error() then return end if
      return DoWhile("DoWhile", _chunked_finish(body_chunks, body_tail), cond, start_pos, _filename)
    end if

    if _tok_kind_id(_peek()) == TK_EOF then
      _set_error("loop ended unexpectedly (missing 'end loop'?)", _tok_pos(_peek()))
      return
    end if

    st = _parse_stmt()
    if _has_error() then return end if
    appb = _chunked_push(body_chunks, body_tail, st, 64)
    body_chunks = appb[0]
    body_tail = appb[1]
    _skip_stmt_seps()
  end while
end function

/// Returns parse stmt switch.
/// @internal
function _parse_stmt_switch(start_pos, t)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  block_kind = _tok_value(t)
  _advance()
  ex = _parse_expr(0)
  if _has_error() then return end if
  _expect_block_nl()
  cases_chunks = []
  cases_tail = []
  default_body =[]

  while true
    if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "case" then
      case_pos = _tok_pos(_peek())
      _advance()

      if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "default" then
        _advance()
        _expect_block_nl()
        default_body = _parse_block_until_end("case", case_pos)
        if _has_error() then return end if
        _expect_end_of("case")
        if _has_error() then return end if
        _skip_stmt_seps()
        continue
      end if

      first = _parse_expr(0)
      if _has_error() then return end if

      if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "to" then
        _advance()
        end_expr = _parse_expr(0)
        if _has_error() then return end if
        _expect_block_nl()
        body = _parse_block_until_end("case", case_pos)
        if _has_error() then return end if
        _expect_end_of("case")
        if _has_error() then return end if
        appcr = _chunked_push(cases_chunks, cases_tail, SwitchCase("SwitchCase", "range", [], first, end_expr, body, case_pos, _filename), 32)
        cases_chunks = appcr[0]
        cases_tail = appcr[1]
        _skip_stmt_seps()
        continue
      end if

      vals_chunks = []
      vals_tail = []
      appv0 = _chunked_push(vals_chunks, vals_tail, first, 16)
      vals_chunks = appv0[0]
      vals_tail = appv0[1]
      while _match_kind(TK_COMMA)
        if _tok_kind_id(_peek()) == TK_NL then
          nxt = _peek_non_nl()
          if not _is_case_value_continuation_start(nxt) then
            break
          end if
          _skip_newlines()
        end if
        v = _parse_expr(0)
        if _has_error() then return end if
        appv = _chunked_push(vals_chunks, vals_tail, v, 16)
        vals_chunks = appv[0]
        vals_tail = appv[1]
      end while

      _expect_block_nl()
      body = _parse_block_until_end("case", case_pos)
      if _has_error() then return end if
      _expect_end_of("case")
      if _has_error() then return end if
      appcv = _chunked_push(
        cases_chunks,
        cases_tail,
        SwitchCase("SwitchCase", "values", _chunked_finish(vals_chunks, vals_tail), 0, 0, body, case_pos, _filename),
        32
      )
      cases_chunks = appcv[0]
      cases_tail = appcv[1]
      _skip_stmt_seps()
      continue
    end if

    break
  end while

  _expect_end_of(block_kind)
  if _has_error() then return end if
  return Switch("Switch", ex, _chunked_finish(cases_chunks, cases_tail), default_body, start_pos, _filename)
end function

/// Returns parse stmt if.
/// @internal
function _parse_stmt_if(start_pos, t)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  _advance()
  cond = _parse_expr(0)
  if _has_error() then return end if
  _expect_value(TK_KW, "then")
  if _has_error() then return end if
  then_body = _parse_block_until(["else"], "if", start_pos)
  if _has_error() then return end if

  elifs_chunks = []
  elifs_tail = []
  else_body =[]
  while _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "else"
    _advance()
    if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "if" then
      _advance()
      ec = _parse_expr(0)
      if _has_error() then return end if
      _expect_value(TK_KW, "then")
      if _has_error() then return end if
      eb = _parse_block_until(["else"], "if", start_pos)
      if _has_error() then return end if
      appe = _chunked_push(elifs_chunks, elifs_tail, [ec, eb], 16)
      elifs_chunks = appe[0]
      elifs_tail = appe[1]
      continue
    end if
    else_body = _parse_block_until([], "if", start_pos)
    if _has_error() then return end if
    break
  end while

  _expect_end_of("if")
  if _has_error() then return end if
  return If("If", cond, then_body, _chunked_finish(elifs_chunks, elifs_tail), else_body, start_pos, _filename)
end function

/// Returns parse stmt while.
/// @internal
function _parse_stmt_while(start_pos, t)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  _advance()
  cond = _parse_expr(0)
  if _has_error() then return end if
  _expect_block_nl()
  body = _parse_block_until_end("while", start_pos)
  if _has_error() then return end if
  _expect_end_of("while")
  if _has_error() then return end if
  return While("While", cond, body, start_pos, _filename)
end function

/// Returns parse stmt for.
/// @internal
function _parse_stmt_for(start_pos, t)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  _advance()
  if _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "each" then
    _advance()
    vn = _expect_kind(TK_IDENT)
    if _has_error() then return end if
    _expect_value(TK_KW, "in")
    if _has_error() then return end if
    it = _parse_expr(0)
    if _has_error() then return end if
    _expect_block_nl()
    body = _parse_block_until_end("for", start_pos)
    if _has_error() then return end if
    _expect_end_of("for")
    if _has_error() then return end if
    return ForEach("ForEach", _tok_value(vn), it, body, start_pos, _filename)
  end if
  vn = _expect_kind(TK_IDENT)
  if _has_error() then return end if
  _expect_value(TK_OP, "=")
  if _has_error() then return end if
  st = _parse_expr(0)
  if _has_error() then return end if
  _expect_value(TK_KW, "to")
  if _has_error() then return end if
  en = _parse_expr(0)
  if _has_error() then return end if
  _expect_block_nl()
  body = _parse_block_until_end("for", start_pos)
  if _has_error() then return end if
  _expect_end_of("for")
  if _has_error() then return end if
  return For("For", _tok_value(vn), st, en, body, start_pos, _filename)
end function

/// Returns parse stmt ident.
/// @internal
function _parse_stmt_ident(start_pos, first_tok)
  /// Current func depth used by this routine.
  /// @internal
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _i
  expr = _parse_postfix()
  if _has_error() then return end if
  declared_type = void
  declared_optional = false
  if t.ast_kind(expr) == "Var" and _tok_kind_id(_peek()) == TK_KW and _tok_value(_peek()) == "as" then
    _advance()
    tref = _parse_type_ref()
    if _has_error() then return end if
    declared_type = tref[0]
    declared_optional = tref[1]
  end if
  assignment_symbol = ""
  compound_base = ""
  if _tok_kind_id(_peek()) == TK_OP then
    assignment_symbol = _tok_value(_peek())
    compound_base = _compound_assignment_base(assignment_symbol)
    if assignment_symbol == "=" or compound_base != "" then _advance() else assignment_symbol = "" end if
  end if
  if assignment_symbol != "" then
    rhs = _parse_expr(0)
    if _has_error() then return end if
    if assignment_symbol != "=" then
      if typeof(declared_type) == "string" then
        _set_error("A compound assignment cannot redeclare a variable type", start_pos)
        return
      end if
      if t.ast_kind(expr) != "Var" then
        _set_error("Compound assignment currently requires a variable target", start_pos)
        return
      end if
      rhs = Bin("Bin", expr, compound_base, rhs, start_pos, _filename)
    end if
    if t.ast_kind(expr) == "Var" then
      if typeof(declared_type) == "string" then
        rhs = TypeGuard("TypeGuard", rhs, declared_type, declared_optional, start_pos, _filename)
      end if
      return Assign("Assign", t.ast_name(expr), rhs, declared_type, declared_optional, start_pos, _filename)
    end if
    if t.ast_kind(expr) == "Member" then
      return SetMember("SetMember", expr.target, expr.name, rhs, start_pos, _filename)
    end if
    if t.ast_kind(expr) == "Index" then
      return SetIndex("SetIndex", expr.target, expr.index, rhs, start_pos, _filename)
    end if
    _set_error("Invalid assignment target (lvalue)", start_pos)
    return
  end if
  if typeof(declared_type) == "string" then
    _set_error("A typed variable declaration requires '='", start_pos)
    return
  end if
  if t.ast_kind(expr) == "Call" then
    return ExprStmt("ExprStmt", expr, start_pos, _filename)
  end if
  _set_error("Only assignments or function calls are allowed as a statement", start_pos)
  return
end function


/// Returns parse stmt recover.
/// @internal
function _parse_stmt_recover(stop_keywords, end_type)
  /// Current i used by this routine.
  /// @internal
  global _i
  start_i = _i
  st = _parse_stmt()
  if _has_error() then
    _record_error(_last_error)
    _clear_error()
    _sync_stmt(stop_keywords, end_type)
    if _i == start_i and _tok_kind_id(_peek()) != TK_EOF then
      _advance()
      _skip_stmt_seps()
    end if
    return 0
  end if
  return st
end function

/// Parse or represent replace dots with slash in the MiniLang front end.
/// @internal
function _replaceDotsWithSlash(name)
  if len(name) <= 0 then return "" end if
  slash_name = ""
  for i = 0 to len(name) - 1
    if name[i] == "." then
      slash_name = slash_name + "/"
    else
      slash_name = slash_name + name[i]
    end if
  end for
  return slash_name
end function

/// Returns parse expression.
/// @param source Source value to process.
/// @param filename Value supplied for `filename`.
function parse_expression(source, filename)
  toks = tokenize(source)
  if typeof(toks) == "struct" and typeof(try(toks.message)) == "string" then
    toks.filename = filename
    return toks
  end if
  _reset(toks, source, filename, false, 50)
  _skip_newlines()
  e = _parse_expr(0)
  if _has_error() then return _last_error end if
  _skip_newlines()
  if _tok_kind_id(_peek()) != TK_EOF then
    return ParseError("Trailing tokens after expression", _tok_pos(_peek()), filename)
  end if
  return e
end function

/// Parse or represent compile is error in the MiniLang front end.
/// @internal
function _compile_is_error(value)
  return typeof(value) == "struct" and typeof(try(value.message)) == "string" and typeof(try(value.pos)) == "int"
end function

/// Parse or represent compile valid name in the MiniLang front end.
/// @internal
function _compile_valid_name(name)
  if typeof(name) != "string" or len(name) <= 0 or _isIdentStart(name[0]) == false then return false end if
  if len(name) > 1 then
    for i = 1 to len(name) - 1
      if _isIdentPart(name[i]) == false then return false end if
    end for
  end if
  return true
end function

/// Parse or represent compile value type in the MiniLang front end.
/// @internal
function _compile_value_type(value)
  ty = typeof(value)
  if ty == "bool" or ty == "int" or ty == "string" then return ty end if
  return ""
end function

/// Parse or represent compile is predefined in the MiniLang front end.
/// @internal
function _compile_is_predefined(name)
  return name == "TARGET_OS" or name == "TARGET_ARCH" or name == "TARGET_ABI" or name == "TARGET_FORMAT" or name == "POINTER_SIZE" or name == "MINILANG_VERSION"
end function

/// Parse or represent compile env find in the MiniLang front end.
/// @internal
function _compile_env_find(env, name)
  if typeof(env) != "array" or len(env) <= 0 then return -1 end if
  for i = 0 to len(env) - 1
    if typeof(env[i]) == "struct" and try(env[i].name) == name then return i end if
  end for
  return -1
end function

/// Parse or represent compile env has in the MiniLang front end.
/// @internal
function _compile_env_has(env, name)
  return _compile_env_find(env, name) >= 0
end function

/// Parse or represent compile env get in the MiniLang front end.
/// @internal
function _compile_env_get(env, name)
  idx = _compile_env_find(env, name)
  if idx < 0 then return void end if
  return env[idx].value
end function

/// Parse or represent compile env set in the MiniLang front end.
/// @internal
function _compile_env_set(env, name, value)
  idx = _compile_env_find(env, name)
  if idx >= 0 then
    item = env[idx]
    item.value = value
    env[idx] = item
    return env
  end if
  return env + [CompileValue(name, value)]
end function

/// Parse or represent compile predefined values in the MiniLang front end.
/// @internal
function _compile_predefined_values()
  return [
    CompileValue("TARGET_OS", _compile_target_os),
    CompileValue("TARGET_ARCH", "x64"),
    CompileValue("TARGET_ABI", _compile_target_abi),
    CompileValue("TARGET_FORMAT", _compile_target_format),
    CompileValue("POINTER_SIZE", 8),
    CompileValue("MINILANG_VERSION", "1.2.4")
  ]
end function

/// Select immutable values for subsequent source parses.
/// @param target Value supplied for `target`.
function set_compile_target(target)
  /// Current compile target os used by this routine.
  /// @internal
  global _compile_target_os
  /// Current compile target abi used by this routine.
  /// @internal
  global _compile_target_abi
  /// Current compile target format used by this routine.
  /// @internal
  global _compile_target_format
  normalized = s.toLowerAscii(s.trim("" + target))
  if normalized == "windows-x64" or normalized == "windows" or normalized == "win64" then
    _compile_target_os = "windows"
    _compile_target_abi = "win64"
    _compile_target_format = "pe"
    return true
  end if
  if normalized == "linux-x64" or normalized == "linux" or normalized == "linux64" then
    _compile_target_os = "linux"
    _compile_target_abi = "sysv"
    _compile_target_format = "elf"
    return true
  end if
  return ParseError("unsupported target: " + normalized, 0, "<command-line>")
end function

/// Parse or represent compile node pos in the MiniLang front end.
/// @internal
function _compile_node_pos(expr, base_pos)
  p = t.ast_pos(expr)
  if typeof(p) != "int" then p = 0 end if
  return base_pos + p
end function

/// Parse or represent compile string compare in the MiniLang front end.
/// @internal
function _compile_string_compare(left, right)
  left_bytes = bytes(left)
  right_bytes = bytes(right)
  count = len(left_bytes)
  if len(right_bytes) < count then count = len(right_bytes) end if
  if count > 0 then
    for i = 0 to count - 1
      if left_bytes[i] < right_bytes[i] then return -1 end if
      if left_bytes[i] > right_bytes[i] then return 1 end if
    end for
  end if
  if len(left_bytes) < len(right_bytes) then return -1 end if
  if len(left_bytes) > len(right_bytes) then return 1 end if
  return 0
end function

/// Parse or represent compile eval node in the MiniLang front end.
/// @internal
function _compile_eval_node(expr, env, filename, base_pos)
  if t.ast_is_node(expr) == false then return ParseError("unsupported compile-time expression", base_pos, filename) end if
  kind = t.ast_kind(expr)
  pos = _compile_node_pos(expr, base_pos)
  if kind == "Bool" then return t.ast_value(expr) end if
  if kind == "Num" then
    if typeof(t.ast_value(expr)) == "int" then return t.ast_value(expr) end if
    return ParseError("compile-time values do not support floats", pos, filename)
  end if
  if kind == "Str" then return t.ast_value(expr) end if
  if kind == "Var" then
    expr_name = t.ast_name(expr)
    if _compile_env_has(env, expr_name) == false then
      return ParseError("unknown compile-time value: " + expr_name, pos, filename)
    end if
    return _compile_env_get(env, expr_name)
  end if
  if kind == "Call" and t.ast_kind(expr.callee) == "Var" and t.ast_name(expr.callee) == "defined" then
    if typeof(expr.args) != "array" or len(expr.args) != 1 or t.ast_is_node(expr.args[0]) == false then
      return ParseError("defined(...) expects one name or string", pos, filename)
    end if
    arg = expr.args[0]
    arg_kind = t.ast_kind(arg)
    if arg_kind == "Var" then return _compile_env_has(env, t.ast_name(arg)) end if
    if arg_kind == "Str" then return _compile_env_has(env, t.ast_value(arg)) end if
    return ParseError("defined(...) expects one name or string", pos, filename)
  end if
  if kind == "Unary" then
    value = _compile_eval_node(t.ast_right(expr), env, filename, base_pos)
    if _compile_is_error(value) then return value end if
    if t.ast_op(expr) == "not" and typeof(value) == "bool" then return value == false end if
    if t.ast_op(expr) == "-" and typeof(value) == "int" then return 0 - value end if
    if t.ast_op(expr) == "~" and typeof(value) == "int" then return ~value end if
    return ParseError("invalid compile-time unary operation: " + t.ast_op(expr), pos, filename)
  end if
  if kind == "Bin" then
    left = _compile_eval_node(t.ast_left(expr), env, filename, base_pos)
    if _compile_is_error(left) then return left end if
    if t.ast_op(expr) == "and" then
      if typeof(left) != "bool" then return ParseError("compile-time 'and' expects booleans", pos, filename) end if
      if left == false then return false end if
      right_and = _compile_eval_node(t.ast_right(expr), env, filename, base_pos)
      if _compile_is_error(right_and) then return right_and end if
      if typeof(right_and) != "bool" then return ParseError("compile-time 'and' expects booleans", pos, filename) end if
      return right_and
    end if
    if t.ast_op(expr) == "or" then
      if typeof(left) != "bool" then return ParseError("compile-time 'or' expects booleans", pos, filename) end if
      if left then return true end if
      right_or = _compile_eval_node(t.ast_right(expr), env, filename, base_pos)
      if _compile_is_error(right_or) then return right_or end if
      if typeof(right_or) != "bool" then return ParseError("compile-time 'or' expects booleans", pos, filename) end if
      return right_or
    end if

    right = _compile_eval_node(t.ast_right(expr), env, filename, base_pos)
    if _compile_is_error(right) then return right end if
    if t.ast_op(expr) == "==" or t.ast_op(expr) == "!=" then
      equal = typeof(left) == typeof(right) and left == right
      if t.ast_op(expr) == "==" then return equal end if
      return equal == false
    end if
    if t.ast_op(expr) == "<" or t.ast_op(expr) == "<=" or t.ast_op(expr) == ">" or t.ast_op(expr) == ">=" then
      if typeof(left) != typeof(right) or (typeof(left) != "int" and typeof(left) != "string") then
        return ParseError("compile-time '" + t.ast_op(expr) + "' expects matching int or string operands", pos, filename)
      end if
      if typeof(left) == "string" then
        ordering = _compile_string_compare(left, right)
        if t.ast_op(expr) == "<" then return ordering < 0 end if
        if t.ast_op(expr) == "<=" then return ordering <= 0 end if
        if t.ast_op(expr) == ">" then return ordering > 0 end if
        return ordering >= 0
      end if
      if t.ast_op(expr) == "<" then return left < right end if
      if t.ast_op(expr) == "<=" then return left <= right end if
      if t.ast_op(expr) == ">" then return left > right end if
      return left >= right
    end if
    if t.ast_op(expr) == "+" and typeof(left) == "string" and typeof(right) == "string" then return left + right end if
    if typeof(left) != "int" or typeof(right) != "int" then
      return ParseError("compile-time '" + t.ast_op(expr) + "' expects integer operands", pos, filename)
    end if
    if t.ast_op(expr) == "+" then return left + right end if
    if t.ast_op(expr) == "-" then return left - right end if
    if t.ast_op(expr) == "*" then return left * right end if
    if t.ast_op(expr) == "%" then
      if right == 0 then return ParseError("compile-time modulo by zero", pos, filename) end if
      return left % right
    end if
    if t.ast_op(expr) == "&" then return left & right end if
    if t.ast_op(expr) == "|" then return left | right end if
    if t.ast_op(expr) == "^" then return left ^ right end if
    if t.ast_op(expr) == "<<" or t.ast_op(expr) == ">>" then
      if right < 0 then return ParseError("negative compile-time shift count", pos, filename) end if
      if t.ast_op(expr) == "<<" then return left << (right & 63) end if
      return left >> (right & 63)
    end if
    return ParseError("unsupported compile-time operation: " + t.ast_op(expr), pos, filename)
  end if
  return ParseError("unsupported compile-time expression", pos, filename)
end function

/// Parse or represent compile eval in the MiniLang front end.
/// @internal
function _compile_eval(text, env, filename, base_pos)
  expr = parse_expression(text, filename)
  if _compile_is_error(expr) then
    expr.pos = base_pos + expr.pos
    return expr
  end if
  return _compile_eval_node(expr, env, filename, base_pos)
end function

/// Parse or represent compile numeric text in the MiniLang front end.
/// @internal
function _compile_numeric_text(raw)
  if typeof(raw) != "string" or len(raw) <= 0 then return false end if
  i = 0
  if raw[0] == "-" then
    if len(raw) <= 1 then return false end if
    i = 1
  end if
  return _isDigit(raw[i])
end function

/// Parse or represent compile parse cli value in the MiniLang front end.
/// @internal
function _compile_parse_cli_value(raw)
  raw = s.trim(raw)
  if raw == "true" then return true end if
  if raw == "false" then return false end if
  if raw == "" then return ParseError("compile definition value must not be empty", 0, "<command-line>") end if
  quoted = len(raw) >= 2 and raw[0] == "\"" and raw[len(raw) - 1] == "\""
  if quoted or _compile_numeric_text(raw) then
    value = _compile_eval(raw, [], "<command-line>", 0)
    if _compile_is_error(value) then return value end if
    if quoted and typeof(value) != "string" then return ParseError("quoted compile definition must be a string", 0, "<command-line>") end if
    if quoted == false and typeof(value) != "int" then return ParseError("invalid numeric compile definition", 0, "<command-line>") end if
    return value
  end if
  return raw
end function

/// Install command-line/project values. Later -D occurrences override earlier ones.
/// @param specs Value supplied for `specs`.
function set_compile_defines(specs)
  /// Current compile external values used by this routine.
  /// @internal
  global _compile_external_values
  values = []
  if typeof(specs) != "array" then specs = [] end if
  if len(specs) > 0 then
    for i = 0 to len(specs) - 1
      raw = specs[i]
      if typeof(raw) != "string" then return ParseError("compile definition must be a string", 0, "<command-line>") end if
      name = ""
      value = true
      eq = s.indexOf(raw, "=", 0)
      if typeof(eq) == "int" and eq >= 0 then
        name = s.trim(_substr(raw, 0, eq))
        value = _compile_parse_cli_value(_substr(raw, eq + 1, len(raw) - eq - 1))
        if _compile_is_error(value) then return value end if
      else
        name = s.trim(raw)
        value = true
      end if
      if _compile_valid_name(name) == false then return ParseError("invalid compile definition name: " + name, 0, "<command-line>") end if
      if _compile_is_predefined(name) then return ParseError("predefined compile value " + name + " cannot be overridden", 0, "<command-line>") end if
      values = _compile_env_set(values, name, value)
    end for
  end if
  _compile_external_values = values
  return true
end function

/// Parse or represent compile external has in the MiniLang front end.
/// @internal
function _compile_external_has(name)
  return _compile_env_has(_compile_external_values, name)
end function

/// Parse or represent compile ltrim index in the MiniLang front end.
/// @internal
function _compile_ltrim_index(line)
  i = 0
  while i < len(line) and (line[i] == " " or line[i] == "\t")
    i = i + 1
  end while
  return i
end function

/// Parse or represent compile split command in the MiniLang front end.
/// @internal
function _compile_split_command(body)
  body = s.trim(body)
  i = 0
  while i < len(body) and body[i] != " " and body[i] != "\t"
    i = i + 1
  end while
  command = s.toLowerAscii(_substr(body, 0, i))
  return [command, s.trim(_substr(body, i, len(body) - i))]
end function

/// Parse or represent compile block comment state in the MiniLang front end.
/// @internal
function _compile_block_comment_state(line, in_block)
  i = 0
  in_string = false
  escaped = false
  while i < len(line)
    if in_block then
      close_pos = s.indexOf(line, "*/", i)
      if typeof(close_pos) != "int" or close_pos < 0 then return true end if
      in_block = false
      i = close_pos + 2
      continue
    end if
    ch = line[i]
    if in_string then
      if escaped then
        escaped = false
      else if ch == "\\" then
        escaped = true
      else if ch == "\"" then
        in_string = false
      end if
      i = i + 1
      continue
    end if
    if ch == "\"" then
      in_string = true
      i = i + 1
      continue
    end if
    if ch == "/" and i + 1 < len(line) and line[i + 1] == "/" then return false end if
    if ch == "/" and i + 1 < len(line) and line[i + 1] == "*" then
      in_block = true
      i = i + 2
      continue
    end if
    i = i + 1
  end while
  return in_block
end function

/// Parse or represent compile frames active in the MiniLang front end.
/// @internal
function _compile_frames_active(frames)
  if typeof(frames) != "array" or len(frames) <= 0 then return true end if
  return frames[len(frames) - 1].active
end function

/// Parse or represent compile frames pop in the MiniLang front end.
/// @internal
function _compile_frames_pop(frames)
  if typeof(frames) != "array" or len(frames) <= 1 then return [] end if
  kept = []
  for i = 0 to len(frames) - 2
    kept = kept + [frames[i]]
  end for
  return kept
end function

/// Parse or represent compile argument pos in the MiniLang front end.
/// @internal
function _compile_argument_pos(line, argument, line_start, hash_col)
  if argument == "" then return line_start + hash_col end if
  p = s.indexOf(line, argument, 0)
  if typeof(p) != "int" or p < 0 then p = hash_col + 1 end if
  return line_start + p
end function

/// Parse or represent compile option parts in the MiniLang front end.
/// @internal
function _compile_option_parts(argument, filename, argument_pos)
  eq = s.indexOf(argument, "=", 0)
  if typeof(eq) != "int" or eq <= 0 or eq + 1 >= len(argument) then
    return ParseError("#option expects NAME: bool|int|string = expression", argument_pos, filename)
  end if
  left = s.trim(_substr(argument, 0, eq))
  value_text = s.trim(_substr(argument, eq + 1, len(argument) - eq - 1))
  colon = s.indexOf(left, ":", 0)
  if typeof(colon) != "int" or colon <= 0 or colon + 1 >= len(left) then
    return ParseError("#option expects NAME: bool|int|string = expression", argument_pos, filename)
  end if
  name = s.trim(_substr(left, 0, colon))
  declared_type = s.trim(_substr(left, colon + 1, len(left) - colon - 1))
  if _compile_valid_name(name) == false or (declared_type != "bool" and declared_type != "int" and declared_type != "string") or value_text == "" then
    return ParseError("#option expects NAME: bool|int|string = expression", argument_pos, filename)
  end if
  return [name, declared_type, value_text]
end function

/// Parse or represent compile maybe has directive in the MiniLang front end.
/// @internal
function _compile_maybe_has_directive(code)
  search_from = 0
  while search_from < len(code)
    pos = s.indexOf(code, "#", search_from)
    if typeof(pos) != "int" or pos < 0 then return false end if
    before = pos - 1
    while before >= 0 and (code[before] == " " or code[before] == "\t")
      before = before - 1
    end while
    if before < 0 or code[before] == "\n" then return true end if
    search_from = pos + 1
  end while
  return false
end function

/// Evaluate line-oriented directives and retain every original byte offset.
/// @param code Source code to process.
/// @param filename Value supplied for `filename`.
function preprocess_compile_directives(code, filename)
  if typeof(code) != "string" then return "" end if
  if _compile_maybe_has_directive(code) == false then return code end if
  env = _compile_predefined_values()
  if len(_compile_external_values) > 0 then
    for ei = 0 to len(_compile_external_values) - 1
      env = _compile_env_set(env, _compile_external_values[ei].name, _compile_external_values[ei].value)
    end for
  end if
  option_names = []
  frames = []
  chunks = []
  tail = []
  line_start = 0
  in_block_comment = false
  lines = s.split(code, "\n")
  for li = 0 to len(lines) - 1
    line = lines[li]
    ending = ""
    if li + 1 < len(lines) then ending = "\n" end if
    active = _compile_frames_active(frames)
    hash_col = _compile_ltrim_index(line)
    stripped = _substr(line, hash_col, len(line) - hash_col)
    is_directive = len(stripped) > 0 and stripped[0] == "#" and (active == false or in_block_comment == false)
    blank = _repeat(" ", len(line)) + ending

    if is_directive == false then
      if active then
        app_line = t.arr_chunked_push(chunks, tail, line + ending, 256)
        chunks = app_line[0]
        tail = app_line[1]
        in_block_comment = _compile_block_comment_state(line, in_block_comment)
      else
        app_blank = t.arr_chunked_push(chunks, tail, blank, 256)
        chunks = app_blank[0]
        tail = app_blank[1]
      end if
      line_start = line_start + len(line) + len(ending)
      continue
    end if

    app_directive = t.arr_chunked_push(chunks, tail, blank, 256)
    chunks = app_directive[0]
    tail = app_directive[1]
    split = _compile_split_command(_substr(stripped, 1, len(stripped) - 1))
    command = split[0]
    argument = split[1]
    directive_pos = line_start + hash_col
    argument_pos = _compile_argument_pos(line, argument, line_start, hash_col)

    if command == "if" then
      parent_active = active
      condition = false
      if parent_active then
        value_if = _compile_eval(argument, env, filename, argument_pos)
        if _compile_is_error(value_if) then return value_if end if
        if typeof(value_if) != "bool" then return ParseError("#if expression must produce bool", argument_pos, filename) end if
        condition = value_if
      end if
      frames = frames + [CompileFrame(parent_active, parent_active and condition, parent_active and condition, false, directive_pos)]
    else if command == "elif" then
      if len(frames) <= 0 then return ParseError("#elif without matching #if", directive_pos, filename) end if
      fi = len(frames) - 1
      frame = frames[fi]
      if frame.else_seen then return ParseError("#elif is not allowed after #else", directive_pos, filename) end if
      condition_elif = false
      if frame.parent_active and frame.taken == false then
        value_elif = _compile_eval(argument, env, filename, argument_pos)
        if _compile_is_error(value_elif) then return value_elif end if
        if typeof(value_elif) != "bool" then return ParseError("#elif expression must produce bool", argument_pos, filename) end if
        condition_elif = value_elif
      end if
      frame.active = frame.parent_active and frame.taken == false and condition_elif
      frame.taken = frame.taken or frame.active
      frames[fi] = frame
    else if command == "else" then
      if argument != "" then return ParseError("#else does not accept an expression", argument_pos, filename) end if
      if len(frames) <= 0 then return ParseError("#else without matching #if", directive_pos, filename) end if
      fe = len(frames) - 1
      frame_else = frames[fe]
      if frame_else.else_seen then return ParseError("duplicate #else", directive_pos, filename) end if
      frame_else.else_seen = true
      frame_else.active = frame_else.parent_active and frame_else.taken == false
      frame_else.taken = frame_else.taken or frame_else.active
      frames[fe] = frame_else
    else if command == "endif" then
      if argument != "" then return ParseError("#endif does not accept an expression", argument_pos, filename) end if
      if len(frames) <= 0 then return ParseError("#endif without matching #if", directive_pos, filename) end if
      frames = _compile_frames_pop(frames)
    else if command == "option" or command == "const" or command == "error" then
      if active then
        if command == "option" then
          parts = _compile_option_parts(argument, filename, argument_pos)
          if _compile_is_error(parts) then return parts end if
          name_option = parts[0]
          declared_type = parts[1]
          default_text = parts[2]
          if _compile_is_predefined(name_option) then return ParseError("predefined compile value " + name_option + " cannot be declared as an option", argument_pos, filename) end if
          if _compile_env_has(option_names, name_option) then return ParseError("duplicate compile option: " + name_option, argument_pos, filename) end if
          default_offset = s.indexOf(line, default_text, 0)
          if typeof(default_offset) != "int" or default_offset < 0 then default_offset = hash_col end if
          default_value = _compile_eval(default_text, env, filename, line_start + default_offset)
          if _compile_is_error(default_value) then return default_value end if
          option_names = option_names + [CompileValue(name_option, true)]
          selected_value = default_value
          if _compile_external_has(name_option) then selected_value = _compile_env_get(env, name_option) end if
          actual_type = _compile_value_type(selected_value)
          if actual_type != declared_type then return ParseError("compile option " + name_option + " expects " + declared_type + ", got " + actual_type, argument_pos, filename) end if
          env = _compile_env_set(env, name_option, selected_value)
        else if command == "const" then
          eq_const = s.indexOf(argument, "=", 0)
          if typeof(eq_const) != "int" or eq_const <= 0 or eq_const + 1 >= len(argument) then return ParseError("#const expects NAME = expression", argument_pos, filename) end if
          name_const = s.trim(_substr(argument, 0, eq_const))
          value_text = s.trim(_substr(argument, eq_const + 1, len(argument) - eq_const - 1))
          if _compile_valid_name(name_const) == false or value_text == "" then return ParseError("#const expects NAME = expression", argument_pos, filename) end if
          if _compile_env_has(env, name_const) then return ParseError("compile-time value already defined: " + name_const, argument_pos, filename) end if
          value_offset = s.indexOf(line, value_text, 0)
          if typeof(value_offset) != "int" or value_offset < 0 then value_offset = hash_col end if
          const_value = _compile_eval(value_text, env, filename, line_start + value_offset)
          if _compile_is_error(const_value) then return const_value end if
          env = _compile_env_set(env, name_const, const_value)
        else
          error_value = _compile_eval(argument, env, filename, argument_pos)
          if _compile_is_error(error_value) then return error_value end if
          if typeof(error_value) != "string" then return ParseError("#error expects a string expression", argument_pos, filename) end if
          return ParseError(error_value, directive_pos, filename)
        end if
      end if
    else
      unknown = command
      if unknown == "" then unknown = "<empty>" end if
      return ParseError("unknown compile directive: #" + unknown, directive_pos, filename)
    end if
    line_start = line_start + len(line) + len(ending)
  end for
  if len(frames) > 0 then return ParseError("unterminated #if (missing #endif)", frames[len(frames) - 1].pos, filename) end if
  return s.join(t.arr_chunked_finish(chunks, tail), "")
end function

/// Track language serial compiler state.
_language_serial = 0
/// Track language needs await compiler state.
_language_needs_await = false
/// Track language needs select compiler state.
_language_needs_select = false
/// Track language needs async pool compiler state.
_language_needs_async_pool = false
/// Track language async pool name compiler state.
_language_async_pool_name = "__ml_async_pool_global"
/// Track language await pos compiler state.
_language_await_pos = 0
/// Track language await file compiler state.
_language_await_file = ""
/// Track language select pos compiler state.
_language_select_pos = 0
/// Track language select file compiler state.
_language_select_file = ""
/// Track language failure compiler state.
_language_failure = ""

/// Parse or represent lang fail in the MiniLang front end.
/// @internal
function _lang_fail(message)
  /// Current language failure used by this routine.
  /// @internal
  global _language_failure
  if _language_failure == "" then _language_failure = message end if
end function

/// Parse or represent lang fresh in the MiniLang front end.
/// @internal
function _lang_fresh(stem)
  /// Current language serial used by this routine.
  /// @internal
  global _language_serial
  _language_serial = _language_serial + 1
  return "__ml_" + stem + "_" + _language_serial
end function

/// Parse or represent lang var in the MiniLang front end.
/// @internal
function _lang_var(name, node)
  return t.ast_leaf_new("Var", name, t.ast_pos(node), t.ast_filename(node))
end function

/// Parse or represent lang num in the MiniLang front end.
/// @internal
function _lang_num(value, node)
  return t.ast_leaf_new("Num", value, t.ast_pos(node), t.ast_filename(node))
end function

/// Parse or represent lang void in the MiniLang front end.
/// @internal
function _lang_void(node)
  return t.ast_leaf_new("VoidLit", 0, t.ast_pos(node), t.ast_filename(node))
end function

/// Parse or represent lang call in the MiniLang front end.
/// @internal
function _lang_call(name, args, node)
  // Calls introduced after source-line annotation intentionally have no own
  // line, matching the Python lowerer. Their surrounding source statement
  // remains responsible for runtime error locations.
  return Call("Call", _lang_var(name, node), args, [], t.ast_pos(node), "__ml_generated__")
end function

/// Parse or represent lang guard returns in the MiniLang front end.
/// @internal
function _lang_guard_returns(body, return_type, return_optional)
  if typeof(return_type) != "string" or typeof(body) != "array" then return body end if
  if len(body) <= 0 then return body end if
  for i = 0 to len(body) - 1
    st = body[i]
    kind = t.ast_kind(st)
    if kind == "Return" then
      value = try(st.expr)
      if typeof(value) == "void" or value == 0 then value = _lang_void(st) end if
      st.expr = TypeGuard("TypeGuard", value, return_type, return_optional, t.ast_pos(st), t.ast_filename(st))
      body[i] = st
      continue
    end if
    if kind == "FunctionDef" then continue end if
    if kind == "If" then
      st.then_body = _lang_guard_returns(st.then_body, return_type, return_optional)
      if typeof(st.elifs) == "array" and len(st.elifs) > 0 then
        for j = 0 to len(st.elifs) - 1
          pair = st.elifs[j]
          pair[1] = _lang_guard_returns(pair[1], return_type, return_optional)
          st.elifs[j] = pair
        end for
      end if
      st.else_body = _lang_guard_returns(st.else_body, return_type, return_optional)
      body[i] = st
      continue
    end if
    if kind == "Switch" then
      if len(st.cases) > 0 then
        for j = 0 to len(st.cases) - 1
          cs = st.cases[j]
          cs.body = _lang_guard_returns(cs.body, return_type, return_optional)
          st.cases[j] = cs
        end for
      end if
      st.default_body = _lang_guard_returns(st.default_body, return_type, return_optional)
      body[i] = st
      continue
    end if
    if kind == "While" or kind == "DoWhile" or kind == "For" or kind == "ForEach" or kind == "SynchronizedBlock" then
      st.body = _lang_guard_returns(st.body, return_type, return_optional)
      body[i] = st
    end if
  end for
  return body
end function

/// Parse or represent lang apply parameter contracts in the MiniLang front end.
/// @internal
function _lang_apply_parameter_contracts(fn)
  guards = []
  if typeof(fn.params) == "array" and len(fn.params) > 0 then
    for i = 0 to len(fn.params) - 1
      ty = void
      optional = false
      if typeof(fn.param_types) == "array" and i < len(fn.param_types) then ty = fn.param_types[i] end if
      if typeof(fn.param_optional) == "array" and i < len(fn.param_optional) then optional = fn.param_optional[i] end if
      if typeof(ty) == "string" then
        value = _lang_var(fn.params[i], fn)
        guarded = TypeGuard("TypeGuard", value, ty, optional, t.ast_pos(fn), t.ast_filename(fn))
        // Parameter guards are compiler-generated statements. Keep their source
        // position empty so debug-line emission matches the Python compiler and
        // the first real source statement remains the active runtime location.
        guards = guards + [Assign("Assign", fn.params[i], guarded, ty, optional, t.ast_pos(fn), t.ast_filename(fn))]
      end if
    end for
  end if
  if len(guards) > 0 then fn.body = guards + fn.body end if
  return fn
end function

/// Parse or represent lang apply contracts in the MiniLang front end.
/// @internal
function _lang_apply_contracts(fn)
  fn = _lang_apply_parameter_contracts(fn)
  if fn.is_iterator == false then fn.body = _lang_guard_returns(fn.body, fn.return_type, fn.return_optional) end if
  return fn
end function

/// Parse or represent lang lower expr in the MiniLang front end.
/// @internal
function _lang_lower_expr(expr, prelude)
  /// Current language needs await used by this routine.
  /// @internal
  global _language_needs_await, _language_needs_select, _language_await_pos, _language_await_file, _language_select_pos, _language_select_file
  if t.ast_is_node(expr) == false then return [expr, prelude] end if
  kind = t.ast_kind(expr)
  if kind == "Lambda" then
    name = _lang_fresh("lambda")
    body = _lang_lower_block(expr.body, 1)
    fn = _new_function_node(name, expr.params, body, false, false, false, expr.param_types, expr.param_optional, expr.param_defaults, expr.variadic_index, expr.return_type, expr.return_optional, false, false, t.ast_pos(expr), t.ast_filename(expr))
    // The expression-bodied lambda parser already guarded its return value.
    // Only parameter contracts still need to be inserted at this stage.
    fn = _lang_apply_parameter_contracts(fn)
    prelude = prelude + [fn]
    return [_lang_var(name, expr), prelude]
  end if
  if kind == "Call" then
    lowered = _lang_lower_expr(expr.callee, prelude)
    expr.callee = lowered[0]
    prelude = lowered[1]
    if typeof(expr.args) == "array" and len(expr.args) > 0 then
      for i = 0 to len(expr.args) - 1
        lowered = _lang_lower_expr(expr.args[i], prelude)
        expr.args[i] = lowered[0]
        prelude = lowered[1]
      end for
    end if
    if t.ast_kind(expr.callee) == "Var" and t.ast_name(expr.callee) == "__ml_await" then
      if _language_needs_await == false then
        _language_await_pos = t.ast_pos(expr)
        _language_await_file = t.ast_filename(expr)
      end if
      _language_needs_await = true
    end if
    if t.ast_kind(expr.callee) == "Var" and t.ast_name(expr.callee) == "__ml_select" then
      if _language_needs_select == false then
        _language_select_pos = t.ast_pos(expr)
        _language_select_file = t.ast_filename(expr)
      end if
      _language_needs_select = true
    end if
    return [expr, prelude]
  end if
  if kind == "Bin" then
    old_left = t.ast_left(expr)
    old_right = t.ast_right(expr)
    left_result = _lang_lower_expr(old_left, prelude)
    right_result = _lang_lower_expr(old_right, left_result[1])
    if left_result[0] == old_left and right_result[0] == old_right then return [expr, right_result[1]] end if
    return [t.ast_bin_new(left_result[0], t.ast_op(expr), right_result[0], t.ast_pos(expr), t.ast_filename(expr)), right_result[1]]
  end if
  if kind == "Coalesce" then
    left_result = _lang_lower_expr(expr.left, prelude)
    right_result = _lang_lower_expr(expr.right, left_result[1])
    expr.left = left_result[0]
    expr.right = right_result[0]
    return [expr, right_result[1]]
  end if
  if kind == "Unary" then
    lowered = _lang_lower_expr(expr.right, prelude)
    expr.right = lowered[0]
    return [expr, lowered[1]]
  end if
  if kind == "IsType" or kind == "TypeGuard" then
    lowered = _lang_lower_expr(expr.expr, prelude)
    expr.expr = lowered[0]
    return [expr, lowered[1]]
  end if
  if kind == "Member" or kind == "SafeMember" then
    lowered = _lang_lower_expr(expr.target, prelude)
    expr.target = lowered[0]
    return [expr, lowered[1]]
  end if
  if kind == "Index" then
    lowered = _lang_lower_expr(expr.target, prelude)
    expr.target = lowered[0]
    lowered2 = _lang_lower_expr(expr.index, lowered[1])
    expr.index = lowered2[0]
    return [expr, lowered2[1]]
  end if
  if kind == "ArrayLit" then
    if len(expr.items) > 0 then
      for i = 0 to len(expr.items) - 1
        lowered = _lang_lower_expr(expr.items[i], prelude)
        expr.items[i] = lowered[0]
        prelude = lowered[1]
      end for
    end if
    return [expr, prelude]
  end if
  return [expr, prelude]
end function

/// Parse or represent lang iterator append in the MiniLang front end.
/// @internal
function _lang_iterator_append(yield_stmt, fn, names)
  buf = names[0]
  count = names[1]
  grown = names[2]
  copy_i = names[3]
  value = try(yield_stmt.expr)
  if typeof(value) == "void" or value == 0 then value = _lang_void(yield_stmt) end if
  if typeof(fn.return_type) == "string" then
    value = TypeGuard("TypeGuard", value, fn.return_type, fn.return_optional, t.ast_pos(yield_stmt), t.ast_filename(yield_stmt))
  end if
  len_buf = _lang_call("len", [_lang_var(buf, yield_stmt)], yield_stmt)
  double_cap = t.ast_bin_new(len_buf, "*", _lang_num(2, yield_stmt), t.ast_pos(yield_stmt), t.ast_filename(yield_stmt))
  allocate = _lang_call("array", [double_cap, _lang_void(yield_stmt)], yield_stmt)
  grow_assign = Assign("Assign", grown, allocate, 0, false, t.ast_pos(yield_stmt), "__ml_generated__")
  copy_value = Index("Index", _lang_var(buf, yield_stmt), _lang_var(copy_i, yield_stmt), t.ast_pos(yield_stmt), "__ml_generated__")
  copy_set = SetIndex("SetIndex", _lang_var(grown, yield_stmt), _lang_var(copy_i, yield_stmt), copy_value, t.ast_pos(yield_stmt), "__ml_generated__")
  copy_end = t.ast_bin_new(_lang_var(count, yield_stmt), "-", _lang_num(1, yield_stmt), t.ast_pos(yield_stmt), t.ast_filename(yield_stmt))
  copy_loop = For("For", copy_i, _lang_num(0, yield_stmt), copy_end, [copy_set], t.ast_pos(yield_stmt), "__ml_generated__")
  replace_buf = Assign("Assign", buf, _lang_var(grown, yield_stmt), 0, false, t.ast_pos(yield_stmt), "__ml_generated__")
  full = t.ast_bin_new(_lang_var(count, yield_stmt), "==", _lang_call("len", [_lang_var(buf, yield_stmt)], yield_stmt), t.ast_pos(yield_stmt), t.ast_filename(yield_stmt))
  grow_if = If("If", full, [grow_assign, copy_loop, replace_buf], [], [], t.ast_pos(yield_stmt), "__ml_generated__")
  store = SetIndex("SetIndex", _lang_var(buf, yield_stmt), _lang_var(count, yield_stmt), value, t.ast_pos(yield_stmt), "__ml_generated__")
  increment = t.ast_bin_new(_lang_var(count, yield_stmt), "+", _lang_num(1, yield_stmt), t.ast_pos(yield_stmt), t.ast_filename(yield_stmt))
  count_assign = Assign("Assign", count, increment, 0, false, t.ast_pos(yield_stmt), "__ml_generated__")
  return [grow_if, store, count_assign]
end function

/// Parse or represent lang rewrite yields in the MiniLang front end.
/// @internal
function _lang_rewrite_yields(body, fn, names)
  if typeof(body) != "array" or len(body) <= 0 then return [] end if
  result_items = []
  for i = 0 to len(body) - 1
    st = body[i]
    kind = t.ast_kind(st)
    if kind == "Yield" then
      result_items = result_items + _lang_iterator_append(st, fn, names)
      continue
    end if
    if kind == "Return" then
      _lang_fail("iterator functions use yield and cannot return a value")
      result_items = result_items + [st]
      continue
    end if
    if kind == "FunctionDef" then result_items = result_items + [st] continue end if
    if kind == "If" then
      st.then_body = _lang_rewrite_yields(st.then_body, fn, names)
      if len(st.elifs) > 0 then
        for j = 0 to len(st.elifs) - 1
          pair = st.elifs[j]
          pair[1] = _lang_rewrite_yields(pair[1], fn, names)
          st.elifs[j] = pair
        end for
      end if
      st.else_body = _lang_rewrite_yields(st.else_body, fn, names)
    else if kind == "Switch" then
      if len(st.cases) > 0 then
        for j = 0 to len(st.cases) - 1
          cs = st.cases[j]
          cs.body = _lang_rewrite_yields(cs.body, fn, names)
          st.cases[j] = cs
        end for
      end if
      st.default_body = _lang_rewrite_yields(st.default_body, fn, names)
    else if kind == "While" or kind == "DoWhile" or kind == "For" or kind == "ForEach" or kind == "SynchronizedBlock" then
      st.body = _lang_rewrite_yields(st.body, fn, names)
    end if
    result_items = result_items + [st]
  end for
  return result_items
end function

/// Parse or represent lang lower iterator in the MiniLang front end.
/// @internal
function _lang_lower_iterator(fn)
  if fn.is_async then _lang_fail("A function cannot be both async and iterator") return fn end if
  suffix = _lang_fresh("iter")
  buf = suffix + "_buf"
  count = suffix + "_count"
  grown = suffix + "_grown"
  copy_i = suffix + "_copy_i"
  result = suffix + "_result"
  names = [buf, count, grown, copy_i]
  original = _lang_rewrite_yields(fn.body, fn, names)
  init_buf = Assign("Assign", buf, _lang_call("array", [_lang_num(8, fn), _lang_void(fn)], fn), 0, false, t.ast_pos(fn), "__ml_generated__")
  init_count = Assign("Assign", count, _lang_num(0, fn), 0, false, t.ast_pos(fn), "__ml_generated__")
  result_alloc = Assign("Assign", result, _lang_call("array", [_lang_var(count, fn), _lang_void(fn)], fn), 0, false, t.ast_pos(fn), "__ml_generated__")
  copy_value = Index("Index", _lang_var(buf, fn), _lang_var(copy_i, fn), t.ast_pos(fn), "__ml_generated__")
  copy_set = SetIndex("SetIndex", _lang_var(result, fn), _lang_var(copy_i, fn), copy_value, t.ast_pos(fn), "__ml_generated__")
  copy_end = t.ast_bin_new(_lang_var(count, fn), "-", _lang_num(1, fn), t.ast_pos(fn), t.ast_filename(fn))
  copy_loop = For("For", copy_i, _lang_num(0, fn), copy_end, [copy_set], t.ast_pos(fn), "__ml_generated__")
  final_return = Return("Return", _lang_var(result, fn), t.ast_pos(fn), "__ml_generated__")
  fn.body = [init_buf, init_count] + original + [result_alloc, copy_loop, final_return]
  fn.is_iterator = false
  return fn
end function

/// Mutable construction state for a lazy iterator's pull-closure state machine. Integer state IDs keep suspension/resumption explicit and avoid materializing yielded elements in an intermediate array.
struct LazyIteratorState
  /// Fn associated with `LazyIteratorState`.
  fn,
  /// State name associated with `LazyIteratorState`.
  state_name,
  /// Blocks associated with `LazyIteratorState`.
  blocks,
  /// Persistent associated with `LazyIteratorState`.
  persistent,
  /// Globals declared associated with `LazyIteratorState`.
  globals_declared,
end struct

/// Parse or represent lang add unique in the MiniLang front end.
/// @internal
function _lang_add_unique(items, value)
  if _contains(items, value) == false then items = items + [value] end if
  return items
end function

/// Parse or represent lang sort strings in the MiniLang front end.
/// @internal
function _lang_sort_strings(items)
  result = []
  if typeof(items) != "array" then return result end if
  if len(items) > 0 then
    for i = 0 to len(items) - 1
      value = items[i]
      inserted = false
      next = []
      if len(result) > 0 then
        for j = 0 to len(result) - 1
          if inserted == false and _compile_string_compare(value, result[j]) < 0 then
            next = next + [value]
            inserted = true
          end if
          next = next + [result[j]]
        end for
      end if
      if inserted == false then next = next + [value] end if
      result = next
    end for
  end if
  return result
end function

/// Parse or represent lang lazy reserve in the MiniLang front end.
/// @internal
function _lang_lazy_reserve(state)
  state.blocks = state.blocks + [[]]
  return [state, len(state.blocks) - 1]
end function

/// Parse or represent lang lazy jump in the MiniLang front end.
/// @internal
function _lang_lazy_jump(state, target, node)
  generated_file = "__ml_generated__"
  target_node = t.ast_leaf_new("Num", target, 0, generated_file)
  assign_state = Assign("Assign", state.state_name, target_node, 0, false, 0, generated_file)
  return [assign_state, Continue("Continue", 0, generated_file)]
end function

/// Parse or represent lang lazy contains yield in the MiniLang front end.
/// @internal
function _lang_lazy_contains_yield(st)
  kind = t.ast_kind(st)
  if kind == "Yield" then return true end if
  if kind == "FunctionDef" then return false end if
  if kind == "If" then
    if typeof(st.then_body) == "array" and len(st.then_body) > 0 then
      for i = 0 to len(st.then_body) - 1
        if _lang_lazy_contains_yield(st.then_body[i]) then return true end if
      end for
    end if
    if typeof(st.elifs) == "array" and len(st.elifs) > 0 then
      for i = 0 to len(st.elifs) - 1
        branch = st.elifs[i][1]
        if len(branch) > 0 then
          for j = 0 to len(branch) - 1
            if _lang_lazy_contains_yield(branch[j]) then return true end if
          end for
        end if
      end for
    end if
    if typeof(st.else_body) == "array" and len(st.else_body) > 0 then
      for i = 0 to len(st.else_body) - 1
        if _lang_lazy_contains_yield(st.else_body[i]) then return true end if
      end for
    end if
    return false
  end if
  if kind == "Switch" then
    if typeof(st.cases) == "array" and len(st.cases) > 0 then
      for i = 0 to len(st.cases) - 1
        body = st.cases[i].body
        if len(body) > 0 then
          for j = 0 to len(body) - 1
            if _lang_lazy_contains_yield(body[j]) then return true end if
          end for
        end if
      end for
    end if
    if typeof(st.default_body) == "array" and len(st.default_body) > 0 then
      for i = 0 to len(st.default_body) - 1
        if _lang_lazy_contains_yield(st.default_body[i]) then return true end if
      end for
    end if
    return false
  end if
  body = try(st.body)
  if typeof(body) == "array" and len(body) > 0 then
    for i = 0 to len(body) - 1
      if _lang_lazy_contains_yield(body[i]) then return true end if
    end for
  end if
  return false
end function

/// Parse or represent lang lazy collect names in the MiniLang front end.
/// @internal
function _lang_lazy_collect_names(state, body)
  if typeof(body) != "array" or len(body) <= 0 then return state end if
  for i = 0 to len(body) - 1
    st = body[i]
    kind = t.ast_kind(st)
    if kind == "GlobalDecl" then
      if len(st.names) > 0 then
        for j = 0 to len(st.names) - 1
          state.globals_declared = _lang_add_unique(state.globals_declared, st.names[j])
        end for
      end if
      continue
    end if
    if kind == "Assign" or kind == "ConstDecl" or kind == "SynchronizedDecl" then
      state.persistent = _lang_add_unique(state.persistent, st.name)
    else if kind == "For" or kind == "ForEach" then
      state.persistent = _lang_add_unique(state.persistent, st.var)
    else if kind == "FunctionDef" then
      state.persistent = _lang_add_unique(state.persistent, st.name)
      continue
    end if
    if kind == "If" then
      state = _lang_lazy_collect_names(state, st.then_body)
      if len(st.elifs) > 0 then
        for j = 0 to len(st.elifs) - 1
          state = _lang_lazy_collect_names(state, st.elifs[j][1])
        end for
      end if
      state = _lang_lazy_collect_names(state, st.else_body)
    else if kind == "Switch" then
      if len(st.cases) > 0 then
        for j = 0 to len(st.cases) - 1
          state = _lang_lazy_collect_names(state, st.cases[j].body)
        end for
      end if
      state = _lang_lazy_collect_names(state, st.default_body)
    else
      nested = try(st.body)
      if typeof(nested) == "array" then state = _lang_lazy_collect_names(state, nested) end if
    end if
  end for
  return state
end function

/// Parse or represent lang lazy compile seq in the MiniLang front end.
/// @internal
function _lang_lazy_compile_seq(state, body, cont, break_target, continue_target)
  current = cont
  if typeof(body) != "array" or len(body) <= 0 then return [state, current] end if
  for reverse_i = 0 to len(body) - 1
    st = body[len(body) - reverse_i - 1]
    kind = t.ast_kind(st)
    if kind == "Yield" then
      generated_file = "__ml_generated__"
      reserved = _lang_lazy_reserve(state)
      state = reserved[0]
      block = reserved[1]
      value = try(st.expr)
      if typeof(value) == "void" or value == 0 then value = t.ast_leaf_new("VoidLit", 0, 0, generated_file) end if
      if typeof(state.fn.return_type) == "string" then
        value = TypeGuard("TypeGuard", value, state.fn.return_type, state.fn.return_optional, 0, generated_file)
      end if
      state.blocks[block] = [Assign("Assign", state.state_name, t.ast_leaf_new("Num", current, 0, generated_file), 0, false, 0, generated_file), Return("Return", value, 0, generated_file)]
      current = block
      continue
    end if
    if kind == "Return" then
      _lang_fail("iterator functions use yield and cannot return a value")
      return [state, current]
    end if
    if kind == "Break" then
      if st.count != 1 or typeof(break_target) != "int" or break_target < 0 then
        _lang_fail("lazy iterators only support break for the innermost loop")
        return [state, current]
      end if
      reserved = _lang_lazy_reserve(state)
      state = reserved[0]
      block = reserved[1]
      state.blocks[block] = _lang_lazy_jump(state, break_target, st)
      current = block
      continue
    end if
    if kind == "Continue" then
      if typeof(continue_target) != "int" or continue_target < 0 then
        _lang_fail("continue outside a lazy-iterator loop")
        return [state, current]
      end if
      reserved = _lang_lazy_reserve(state)
      state = reserved[0]
      block = reserved[1]
      state.blocks[block] = _lang_lazy_jump(state, continue_target, st)
      current = block
      continue
    end if
    if kind == "If" then
      compiled = _lang_lazy_compile_seq(state, st.then_body, current, break_target, continue_target)
      state = compiled[0]
      then_entry = compiled[1]
      compiled = _lang_lazy_compile_seq(state, st.else_body, current, break_target, continue_target)
      state = compiled[0]
      else_entry = compiled[1]
      elif_entries = []
      if len(st.elifs) > 0 then
        for i = 0 to len(st.elifs) - 1
          compiled = _lang_lazy_compile_seq(state, st.elifs[i][1], current, break_target, continue_target)
          state = compiled[0]
          elif_entries = elif_entries + [[st.elifs[i][0], compiled[1]]]
        end for
      end if
      branch_elifs = []
      if len(elif_entries) > 0 then
        for i = 0 to len(elif_entries) - 1
          branch_elifs = branch_elifs + [[elif_entries[i][0], _lang_lazy_jump(state, elif_entries[i][1], st)]]
        end for
      end if
      reserved = _lang_lazy_reserve(state)
      state = reserved[0]
      branch = reserved[1]
      state.blocks[branch] = [If("If", st.cond, _lang_lazy_jump(state, then_entry, st), branch_elifs, _lang_lazy_jump(state, else_entry, st), 0, "__ml_generated__")]
      current = branch
      continue
    end if
    if kind == "While" or kind == "DoWhile" then
      reserved = _lang_lazy_reserve(state)
      state = reserved[0]
      cond_block = reserved[1]
      compiled = _lang_lazy_compile_seq(state, st.body, cond_block, current, cond_block)
      state = compiled[0]
      body_entry = compiled[1]
      state.blocks[cond_block] = [If("If", st.cond, _lang_lazy_jump(state, body_entry, st), [], _lang_lazy_jump(state, current, st), 0, "__ml_generated__")]
      if kind == "DoWhile" then current = body_entry else current = cond_block end if
      continue
    end if
    if kind == "For" then
      generated_file = "__ml_generated__"
      end_name = _lang_fresh("lazy_for_end")
      step_name = _lang_fresh("lazy_for_step")
      state.persistent = _lang_add_unique(state.persistent, st.var)
      state.persistent = _lang_add_unique(state.persistent, end_name)
      state.persistent = _lang_add_unique(state.persistent, step_name)
      reserved = _lang_lazy_reserve(state)
      state = reserved[0]
      cond_block = reserved[1]
      reserved = _lang_lazy_reserve(state)
      state = reserved[0]
      inc_block = reserved[1]
      compiled = _lang_lazy_compile_seq(state, st.body, inc_block, current, inc_block)
      state = compiled[0]
      body_entry = compiled[1]
      positive = t.ast_bin_new(t.ast_leaf_new("Var", step_name, 0, generated_file), ">", t.ast_leaf_new("Num", 0, 0, generated_file), 0, generated_file)
      within_up = t.ast_bin_new(t.ast_leaf_new("Var", st.var, 0, generated_file), "<=", t.ast_leaf_new("Var", end_name, 0, generated_file), 0, generated_file)
      within_down = t.ast_bin_new(t.ast_leaf_new("Var", st.var, 0, generated_file), ">=", t.ast_leaf_new("Var", end_name, 0, generated_file), 0, generated_file)
      up = t.ast_bin_new(positive, "and", within_up, 0, generated_file)
      down = t.ast_bin_new(Unary("Unary", "not", positive, 0, generated_file), "and", within_down, 0, generated_file)
      condition = t.ast_bin_new(up, "or", down, 0, generated_file)
      state.blocks[cond_block] = [If("If", condition, _lang_lazy_jump(state, body_entry, st), [], _lang_lazy_jump(state, current, st), 0, generated_file)]
      increment = t.ast_bin_new(t.ast_leaf_new("Var", st.var, 0, generated_file), "+", t.ast_leaf_new("Var", step_name, 0, generated_file), 0, generated_file)
      state.blocks[inc_block] = [Assign("Assign", st.var, increment, 0, false, 0, generated_file)] + _lang_lazy_jump(state, cond_block, st)
      reserved = _lang_lazy_reserve(state)
      state = reserved[0]
      init_block = reserved[1]
      choose_step_cond = t.ast_bin_new(t.ast_leaf_new("Var", st.var, 0, generated_file), "<=", t.ast_leaf_new("Var", end_name, 0, generated_file), 0, generated_file)
      choose_step = If("If", choose_step_cond, [Assign("Assign", step_name, t.ast_leaf_new("Num", 1, 0, generated_file), 0, false, 0, generated_file)], [], [Assign("Assign", step_name, t.ast_leaf_new("Num", -1, 0, generated_file), 0, false, 0, generated_file)], 0, generated_file)
      state.blocks[init_block] = [Assign("Assign", st.var, st.start, 0, false, 0, generated_file), Assign("Assign", end_name, st.end_expr, 0, false, 0, generated_file), choose_step] + _lang_lazy_jump(state, cond_block, st)
      current = init_block
      continue
    end if
    if kind == "ForEach" then
      generated_file = "__ml_generated__"
      seq_name = _lang_fresh("lazy_each_seq")
      index_name = _lang_fresh("lazy_each_index")
      state.persistent = _lang_add_unique(state.persistent, st.var)
      state.persistent = _lang_add_unique(state.persistent, seq_name)
      state.persistent = _lang_add_unique(state.persistent, index_name)
      reserved = _lang_lazy_reserve(state)
      state = reserved[0]
      cond_block = reserved[1]
      reserved = _lang_lazy_reserve(state)
      state = reserved[0]
      inc_block = reserved[1]
      compiled = _lang_lazy_compile_seq(state, st.body, inc_block, current, inc_block)
      state = compiled[0]
      body_entry = compiled[1]
      reserved = _lang_lazy_reserve(state)
      state = reserved[0]
      load_block = reserved[1]
      load_value = Index("Index", t.ast_leaf_new("Var", seq_name, 0, generated_file), t.ast_leaf_new("Var", index_name, 0, generated_file), 0, generated_file)
      state.blocks[load_block] = [Assign("Assign", st.var, load_value, 0, false, 0, generated_file)] + _lang_lazy_jump(state, body_entry, st)
      len_call = Call("Call", t.ast_leaf_new("Var", "len", 0, generated_file), [t.ast_leaf_new("Var", seq_name, 0, generated_file)], [], 0, generated_file)
      condition = t.ast_bin_new(t.ast_leaf_new("Var", index_name, 0, generated_file), "<", len_call, 0, generated_file)
      state.blocks[cond_block] = [If("If", condition, _lang_lazy_jump(state, load_block, st), [], _lang_lazy_jump(state, current, st), 0, generated_file)]
      increment = t.ast_bin_new(t.ast_leaf_new("Var", index_name, 0, generated_file), "+", t.ast_leaf_new("Num", 1, 0, generated_file), 0, generated_file)
      state.blocks[inc_block] = [Assign("Assign", index_name, increment, 0, false, 0, generated_file)] + _lang_lazy_jump(state, cond_block, st)
      reserved = _lang_lazy_reserve(state)
      state = reserved[0]
      init_block = reserved[1]
      state.blocks[init_block] = [Assign("Assign", seq_name, st.iterable, 0, false, 0, generated_file), Assign("Assign", index_name, t.ast_leaf_new("Num", 0, 0, generated_file), 0, false, 0, generated_file)] + _lang_lazy_jump(state, cond_block, st)
      current = init_block
      continue
    end if
    if (kind == "Switch" or kind == "SynchronizedBlock") and _lang_lazy_contains_yield(st) then
      _lang_fail("yield inside match/switch or synchronized is not supported by lazy iterators")
      return [state, current]
    end if
    if kind == "Defer" then
      _lang_fail("defer is not supported inside a lazy iterator")
      return [state, current]
    end if
    simple = st
    if kind == "ConstDecl" then simple = Assign("Assign", st.name, st.expr, 0, false, 0, "__ml_generated__") end if
    reserved = _lang_lazy_reserve(state)
    state = reserved[0]
    block = reserved[1]
    state.blocks[block] = [simple] + _lang_lazy_jump(state, current, st)
    current = block
  end for
  return [state, current]
end function

/// Parse or represent lang lower lazy iterator in the MiniLang front end.
/// @internal
function _lang_lower_lazy_iterator(fn)
  if fn.is_async then _lang_fail("A function cannot be both async and iterator") return fn end if
  state_name = _lang_fresh("lazy_state")
  next_name = _lang_fresh("lazy_next")
  state = LazyIteratorState(fn, state_name, [], [state_name], [])
  state = _lang_lazy_collect_names(state, fn.body)
  reserved = _lang_lazy_reserve(state)
  state = reserved[0]
  done = reserved[1]
  generated_file = "__ml_generated__"
  state.blocks[done] = [Return("Return", t.ast_leaf_new("VoidLit", 0, 0, generated_file), 0, generated_file)]
  compiled = _lang_lazy_compile_seq(state, fn.body, done, -1, -1)
  state = compiled[0]
  entry = compiled[1]
  cases = []
  if len(state.blocks) > 0 then
    for i = 0 to len(state.blocks) - 1
      cases = cases + [SwitchCase("SwitchCase", "values", [t.ast_leaf_new("Num", i, 0, generated_file)], 0, 0, state.blocks[i], 0, generated_file)]
    end for
  end if
  dispatch = Switch("Switch", t.ast_leaf_new("Var", state_name, 0, generated_file), cases, [Return("Return", t.ast_leaf_new("VoidLit", 0, 0, generated_file), 0, generated_file)], 0, generated_file)
  next_fn = _new_function_node(next_name, [], [While("While", t.ast_leaf_new("Bool", true, 0, generated_file), [dispatch], 0, generated_file)], false, false, false, [], [], [], -1, 0, false, false, false, t.ast_pos(fn), t.ast_filename(fn))
  initializers = []
  names = _lang_sort_strings(state.persistent)
  if len(names) > 0 then
    for i = 0 to len(names) - 1
      name = names[i]
      if name == state_name or _contains(fn.params, name) or _contains(state.globals_declared, name) then continue end if
      initializers = initializers + [Assign("Assign", name, _lang_void(fn), 0, false, t.ast_pos(fn), t.ast_filename(fn))]
    end for
  end if
  initializers = initializers + [Assign("Assign", state_name, _lang_num(entry, fn), 0, false, t.ast_pos(fn), t.ast_filename(fn))]
  fn.body = initializers + [next_fn, Return("Return", _lang_var(next_name, fn), t.ast_pos(fn), t.ast_filename(fn))]
  fn.return_type = 0
  fn.return_optional = false
  fn.is_iterator = false
  return fn
end function

/// Parse or represent lang lower async in the MiniLang front end.
/// @internal
function _lang_lower_async(fn)
  /// Current language needs async pool used by this routine.
  /// @internal
  global _language_needs_async_pool, _language_async_pool_name
  impl_name = _lang_fresh("async_impl")
  entry_name = _lang_fresh("async_entry")
  arg_name = _lang_fresh("async_args")
  _language_needs_async_pool = true
  // The wrapper has already packed a variadic tail, so the implementation ABI
  // is fixed even when the public declaration was variadic.
  impl = _new_function_node(impl_name, fn.params, fn.body, false, false, false, fn.param_types, fn.param_optional, [], -1, fn.return_type, fn.return_optional, false, false, t.ast_pos(fn), t.ast_filename(fn))
  forwarded = []
  if len(fn.params) > 0 then
    for i = 0 to len(fn.params) - 1
      forwarded = forwarded + [Index("Index", _lang_var(arg_name, fn), _lang_num(i, fn), t.ast_pos(fn), "__ml_generated__")]
    end for
  end if
  entry_call = Call("Call", _lang_var(impl_name, fn), forwarded, [], t.ast_pos(fn), "__ml_generated__")
  entry = _new_function_node(entry_name, [arg_name], [Return("Return", entry_call, t.ast_pos(fn), "__ml_generated__")], false, false, false, [], [], [], -1, 0, false, false, false, t.ast_pos(fn), t.ast_filename(fn))
  packed_items = []
  if len(fn.params) > 0 then
    for i = 0 to len(fn.params) - 1
      packed_items = packed_items + [_lang_var(fn.params[i], fn)]
    end for
  end if
  packed = ArrayLit("ArrayLit", packed_items, false, t.ast_pos(fn), "__ml_generated__")
  submit_member = Member("Member", _lang_var(_language_async_pool_name, fn), "Submit", t.ast_pos(fn), "__ml_generated__")
  submit_call = Call("Call", submit_member, [_lang_var(entry_name, fn), packed], [], t.ast_pos(fn), "__ml_generated__")
  wrapper_body = [Return("Return", submit_call, t.ast_pos(fn), "__ml_generated__")]
  // The public async function returns a job handle. Its declared return type
  // still describes the value produced by await, not the wrapper itself.
  wrapper = _new_function_node(fn.name, fn.params, wrapper_body, fn.is_static, false, false, fn.param_types, fn.param_optional, fn.param_defaults, fn.variadic_index, 0, false, false, false, t.ast_pos(fn), t.ast_filename(fn))
  return [impl, entry, wrapper]
end function

/// Parse or represent lang await helper in the MiniLang front end.
/// @internal
function _lang_await_helper()
  /// Current language await pos used by this routine.
  /// @internal
  global _language_await_pos, _language_await_file
  node = _new_function_node("__ml_await", ["value"], [], false, false, false, [], [], [], -1, 0, false, false, false, _language_await_pos, _language_await_file)
  value = _lang_var("value", node)
  cond = t.ast_bin_new(_lang_call("typeof", [value], node), "==", t.ast_leaf_new("Str", "thread", 0, "__ml_generated__"), 0, "__ml_generated__")
  is_job = IsType("IsType", value, "std.concurrent.thread_pool.ThreadPoolJob", false, 0, "__ml_generated__")
  join_call = ExprStmt("ExprStmt", Call("Call", Member("Member", value, "Join", 0, "__ml_generated__"), [], [], 0, "__ml_generated__"), 0, "__ml_generated__")
  result_call = Call("Call", Member("Member", value, "Result", 0, "__ml_generated__"), [], [], 0, "__ml_generated__")
  wait_job = ExprStmt("ExprStmt", Call("Call", Member("Member", value, "Wait", 0, "__ml_generated__"), [], [], 0, "__ml_generated__"), 0, "__ml_generated__")
  job_result = Call("Call", Member("Member", value, "GetResult", 0, "__ml_generated__"), [], [], 0, "__ml_generated__")
  node.body = [If("If", cond, [join_call, Return("Return", result_call, 0, "__ml_generated__")], [], [], 0, "__ml_generated__"), If("If", is_job, [wait_job, Return("Return", job_result, 0, "__ml_generated__")], [], [], 0, "__ml_generated__"), Return("Return", value, 0, "__ml_generated__")]
  return node
end function

/// Parse or represent lang select helper in the MiniLang front end.
/// @internal
function _lang_select_helper()
  /// Current language select pos used by this routine.
  /// @internal
  global _language_select_pos, _language_select_file
  node = _new_function_node("__ml_select", ["handles"], [], false, false, false, [], [], [], -1, 0, false, false, false, _language_select_pos, _language_select_file)
  handles = _lang_var("handles", node)
  idx = _lang_var("__ml_select_i", node)
  handle = _lang_var("__ml_select_handle", node)
  valid = t.ast_bin_new(_lang_call("typeof", [handles], node), "==", t.ast_leaf_new("Str", "array", 0, "__ml_generated__"), 0, "__ml_generated__")
  nonempty = t.ast_bin_new(_lang_call("len", [handles], node), ">", _lang_num(0, node), 0, "__ml_generated__")
  both = t.ast_bin_new(valid, "and", nonempty, 0, "__ml_generated__")
  invalid = Unary("Unary", "not", both, 0, "__ml_generated__")
  assign_handle = Assign("Assign", "__ml_select_handle", Index("Index", handles, idx, 0, "__ml_generated__"), 0, false, 0, "__ml_generated__")
  is_thread = t.ast_bin_new(_lang_call("typeof", [handle], node), "==", t.ast_leaf_new("Str", "thread", 0, "__ml_generated__"), 0, "__ml_generated__")
  is_job = IsType("IsType", handle, "std.concurrent.thread_pool.ThreadPoolJob", false, 0, "__ml_generated__")
  valid_handle = t.ast_bin_new(is_thread, "or", is_job, 0, "__ml_generated__")
  invalid_handle = Unary("Unary", "not", valid_handle, 0, "__ml_generated__")
  alive_call = Call("Call", Member("Member", handle, "IsAlive", 0, "__ml_generated__"), [], [], 0, "__ml_generated__")
  completed_thread = t.ast_bin_new(is_thread, "and", Unary("Unary", "not", alive_call, 0, "__ml_generated__"), 0, "__ml_generated__")
  done_call = Call("Call", Member("Member", handle, "IsDone", 0, "__ml_generated__"), [], [], 0, "__ml_generated__")
  completed_job = t.ast_bin_new(is_job, "and", done_call, 0, "__ml_generated__")
  completed = t.ast_bin_new(completed_thread, "or", completed_job, 0, "__ml_generated__")
  check_loop = For("For", "__ml_select_i", _lang_num(0, node), t.ast_bin_new(_lang_call("len", [handles], node), "-", _lang_num(1, node), 0, "__ml_generated__"), [assign_handle, If("If", invalid_handle, [Return("Return", idx, 0, "__ml_generated__")], [], [], 0, "__ml_generated__"), If("If", completed, [Return("Return", idx, 0, "__ml_generated__")], [], [], 0, "__ml_generated__")], 0, "__ml_generated__")
  sleep_call = ExprStmt("ExprStmt", _lang_call("threadSleep", [_lang_num(1, node)], node), 0, "__ml_generated__")
  wait_loop = While("While", t.ast_leaf_new("Bool", true, 0, "__ml_generated__"), [check_loop, sleep_call], 0, "__ml_generated__")
  node.body = [If("If", invalid, [Return("Return", _lang_num(-1, node), 0, "__ml_generated__")], [], [], 0, "__ml_generated__"), wait_loop, Return("Return", _lang_num(-1, node), 0, "__ml_generated__")]
  return node
end function

/// Parse or represent lang lower stmt in the MiniLang front end.
/// @internal
function _lang_lower_stmt(st, function_depth)
  kind = t.ast_kind(st)
  prelude = []
  if kind == "NamespaceDef" then
    st.body = _lang_lower_block(st.body, function_depth)
  else if kind == "FunctionDef" then
    st = _lang_apply_contracts(st)
    if typeof(st.param_defaults) == "array" and len(st.param_defaults) > 0 then
      for i = 0 to len(st.param_defaults) - 1
        if typeof(st.param_defaults[i]) != "void" then
          lowered_default = _lang_lower_expr(st.param_defaults[i], prelude)
          st.param_defaults[i] = lowered_default[0]
          prelude = lowered_default[1]
        end if
      end for
    end if
    st.body = _lang_lower_block(st.body, function_depth + 1)
    if st.is_iterator then
      if st.is_iterator == 2 then st = _lang_lower_lazy_iterator(st) else st = _lang_lower_iterator(st) end if
    end if
    if st.is_async then
      if function_depth > 0 then _lang_fail("async functions must be declared at module or namespace scope") return [st] end if
      return prelude + _lang_lower_async(st)
    end if
  else if kind == "StructDef" then
    if typeof(st.methods) == "array" and len(st.methods) > 0 then
      for i = 0 to len(st.methods) - 1
        method = _lang_apply_contracts(st.methods[i])
        if typeof(method.param_defaults) == "array" and len(method.param_defaults) > 0 then
          for j = 0 to len(method.param_defaults) - 1
            if typeof(method.param_defaults[j]) != "void" then
              lowered_default = _lang_lower_expr(method.param_defaults[j], prelude)
              method.param_defaults[j] = lowered_default[0]
              prelude = lowered_default[1]
            end if
          end for
        end if
        method.body = _lang_lower_block(method.body, function_depth + 1)
        if method.is_iterator then
          if method.is_iterator == 2 then method = _lang_lower_lazy_iterator(method) else method = _lang_lower_iterator(method) end if
        end if
        st.methods[i] = method
      end for
    end if
  else if kind == "If" then
    lowered = _lang_lower_expr(st.cond, prelude)
    st.cond = lowered[0]
    prelude = lowered[1]
    st.then_body = _lang_lower_block(st.then_body, function_depth)
    if len(st.elifs) > 0 then
      for i = 0 to len(st.elifs) - 1
        pair = st.elifs[i]
        lowered = _lang_lower_expr(pair[0], prelude)
        pair[0] = lowered[0]
        prelude = lowered[1]
        pair[1] = _lang_lower_block(pair[1], function_depth)
        st.elifs[i] = pair
      end for
    end if
    st.else_body = _lang_lower_block(st.else_body, function_depth)
  else if kind == "While" or kind == "DoWhile" then
    lowered = _lang_lower_expr(st.cond, prelude)
    st.cond = lowered[0]
    prelude = lowered[1]
    st.body = _lang_lower_block(st.body, function_depth)
  else if kind == "For" then
    lowered = _lang_lower_expr(st.start, prelude)
    st.start = lowered[0]
    lowered2 = _lang_lower_expr(st.end_expr, lowered[1])
    st.end_expr = lowered2[0]
    prelude = lowered2[1]
    st.body = _lang_lower_block(st.body, function_depth)
  else if kind == "ForEach" then
    lowered = _lang_lower_expr(st.iterable, prelude)
    st.iterable = lowered[0]
    prelude = lowered[1]
    st.body = _lang_lower_block(st.body, function_depth)
  else if kind == "SynchronizedBlock" then
    lowered = _lang_lower_expr(st.lock, prelude)
    st.lock = lowered[0]
    prelude = lowered[1]
    st.body = _lang_lower_block(st.body, function_depth)
  else if kind == "Switch" then
    lowered = _lang_lower_expr(st.expr, prelude)
    st.expr = lowered[0]
    prelude = lowered[1]
    if len(st.cases) > 0 then
      for i = 0 to len(st.cases) - 1
        cs = st.cases[i]
        if len(cs.values) > 0 then
          for j = 0 to len(cs.values) - 1
            lowered = _lang_lower_expr(cs.values[j], prelude)
            cs.values[j] = lowered[0]
            prelude = lowered[1]
          end for
        end if
        if typeof(cs.range_start) != "void" and cs.range_start != 0 then
          lowered = _lang_lower_expr(cs.range_start, prelude)
          cs.range_start = lowered[0]
          prelude = lowered[1]
          lowered = _lang_lower_expr(cs.range_end, prelude)
          cs.range_end = lowered[0]
          prelude = lowered[1]
        end if
        cs.body = _lang_lower_block(cs.body, function_depth)
        st.cases[i] = cs
      end for
    end if
    st.default_body = _lang_lower_block(st.default_body, function_depth)
  else
    if kind == "SetMember" then
      lowered = _lang_lower_expr(st.obj, prelude)
      st.obj = lowered[0]
      prelude = lowered[1]
    end if
    if kind == "Assign" or kind == "SynchronizedDecl" or kind == "ConstDecl" or kind == "Print" or kind == "ExprStmt" or kind == "Return" or kind == "Yield" or kind == "Defer" or kind == "SetMember" or kind == "SetIndex" then
      expr_value = st.expr
      if typeof(expr_value) != "void" and expr_value != 0 then
        lowered = _lang_lower_expr(expr_value, prelude)
        st.expr = lowered[0]
        prelude = lowered[1]
      end if
    end if
    if kind == "SetIndex" then
      lowered = _lang_lower_expr(st.target, prelude)
      st.target = lowered[0]
      lowered2 = _lang_lower_expr(st.index, lowered[1])
      st.index = lowered2[0]
      prelude = lowered2[1]
    end if
  end if
  return prelude + [st]
end function

/// Parse or represent lang lower block in the MiniLang front end.
/// @internal
function _lang_lower_block(body, function_depth)
  if typeof(body) != "array" or len(body) <= 0 then return [] end if
  chunks = []
  tail = []
  for i = 0 to len(body) - 1
    items = _lang_lower_stmt(body[i], function_depth)
    if len(items) > 0 then
      for j = 0 to len(items) - 1
        app = _chunked_push(chunks, tail, items[j], 64)
        chunks = app[0]
        tail = app[1]
      end for
    end if
  end for
  return _chunked_finish(chunks, tail)
end function

/// Track language interfaces compiler state.
_language_interfaces = []
/// Track language structs compiler state.
_language_structs = []

/// Parse or represent lang collect contracts in the MiniLang front end.
/// @internal
function _lang_collect_contracts(body, prefix)
  /// Current language interfaces used by this routine.
  /// @internal
  global _language_interfaces, _language_structs
  if typeof(body) != "array" or len(body) <= 0 then return end if
  for i = 0 to len(body) - 1
    st = body[i]
    kind = t.ast_kind(st)
    if kind == "NamespaceDef" then
      _lang_collect_contracts(st.body, prefix + st.name + ".")
    else if kind == "InterfaceDef" then
      _language_interfaces = _language_interfaces + [[prefix + st.name, st]]
    else if kind == "StructDef" then
      _language_structs = _language_structs + [[prefix + st.name, prefix, st]]
    end if
  end for
end function

/// Parse or represent lang find interface in the MiniLang front end.
/// @internal
function _lang_find_interface(raw_name, prefix)
  if len(_language_interfaces) <= 0 then return void end if
  local_name = prefix + raw_name
  unique = void
  for i = 0 to len(_language_interfaces) - 1
    item = _language_interfaces[i]
    if item[0] == local_name or item[0] == raw_name then return item[1] end if
    full = item[0]
    simple = full
    last_dot = s.lastIndexOf(full, ".")
    if typeof(last_dot) == "int" and last_dot >= 0 then simple = s.substr(full, last_dot + 1, len(full) - last_dot - 1) end if
    if simple == raw_name then
      if typeof(unique) != "void" then return void end if
      unique = item[1]
    end if
  end for
  return unique
end function

/// Parse or represent lang interface signature matches in the MiniLang front end.
/// @internal
function _lang_interface_signature_matches(required, actual)
  if try(actual.is_static) == true then return false end if
  if len(actual.params) != len(required.params) or actual.variadic_index != required.variadic_index then return false end if
  count = len(required.params)
  if count > 0 then
    for i = 0 to count - 1
      required_type = void
      actual_type = void
      required_optional = false
      actual_optional = false
      if typeof(required.param_types) == "array" and i < len(required.param_types) then required_type = required.param_types[i] end if
      if typeof(actual.param_types) == "array" and i < len(actual.param_types) then actual_type = actual.param_types[i] end if
      if typeof(required.param_optional) == "array" and i < len(required.param_optional) then required_optional = required.param_optional[i] end if
      if typeof(actual.param_optional) == "array" and i < len(actual.param_optional) then actual_optional = actual.param_optional[i] end if
      if required_type != actual_type or required_optional != actual_optional then return false end if
    end for
  end if
  if try(required.return_type) != try(actual.return_type) then return false end if
  if try(required.return_optional) != try(actual.return_optional) then return false end if
  return true
end function

/// Parse or represent lang validate interfaces in the MiniLang front end.
/// @internal
function _lang_validate_interfaces(program)
  /// Current language interfaces used by this routine.
  /// @internal
  global _language_interfaces, _language_structs
  _language_interfaces = []
  _language_structs = []
  _lang_collect_contracts(program, "")
  if len(_language_structs) <= 0 then return "" end if
  for i = 0 to len(_language_structs) - 1
    item = _language_structs[i]
    struct_name = item[0]
    prefix = item[1]
    st = item[2]
    if typeof(st.interfaces) != "array" or len(st.interfaces) <= 0 then continue end if
    for j = 0 to len(st.interfaces) - 1
      raw_name = st.interfaces[j]
      iface = _lang_find_interface(raw_name, prefix)
      if typeof(iface) == "void" then return "Unknown interface '" + raw_name + "' implemented by " + struct_name end if
      if len(iface.methods) <= 0 then continue end if
      for k = 0 to len(iface.methods) - 1
        required = iface.methods[k]
        actual = void
        if len(st.methods) > 0 then
          for m = 0 to len(st.methods) - 1
            if st.methods[m].name == required.name then actual = st.methods[m] break end if
          end for
        end if
        if typeof(actual) == "void" then return "Struct " + struct_name + " does not implement " + raw_name + "." + required.name end if
        if _lang_interface_signature_matches(required, actual) == false then
          return "Method " + struct_name + "." + actual.name + " has an incompatible interface signature"
        end if
      end for
    end for
  end for
  return ""
end function

/// Parse or represent lang remove interfaces in the MiniLang front end.
/// @internal
function _lang_remove_interfaces(body)
  if typeof(body) != "array" or len(body) <= 0 then return [] end if
  result_items = []
  for i = 0 to len(body) - 1
    st = body[i]
    if t.ast_kind(st) == "InterfaceDef" then continue end if
    if t.ast_kind(st) == "NamespaceDef" then st.body = _lang_remove_interfaces(st.body) end if
    result_items = result_items + [st]
  end for
  return result_items
end function

/// Parse or represent prepare language features in the MiniLang front end.
/// @param program Value supplied for `program`.
function prepare_language_features(program)
  /// Current language serial used by this routine.
  /// @internal
  global _language_serial, _language_needs_await, _language_needs_select, _language_needs_async_pool, _language_async_pool_name, _language_await_pos, _language_await_file, _language_select_pos, _language_select_file, _language_failure
  _language_serial = 0
  _language_needs_await = false
  _language_needs_select = false
  _language_needs_async_pool = false
  _language_await_pos = 0
  _language_await_file = ""
  _language_select_pos = 0
  _language_select_file = ""
  _language_failure = ""
  validation = _lang_validate_interfaces(program)
  if validation != "" then return error(1600, validation) end if
  lowered = _lang_lower_block(program, 0)
  if _language_failure != "" then return error(1600, _language_failure) end if
  lowered = _lang_remove_interfaces(lowered)
  helpers = []
  if _language_needs_await then helpers = helpers + [_lang_await_helper()] end if
  if _language_needs_select then helpers = helpers + [_lang_select_helper()] end if
  if _language_needs_async_pool then
    // The pool initializer is generated infrastructure. A neutral source
    // position avoids attributing its machine code to a user's await line and
    // keeps the Python and self-hosted debug tables byte-identical.
    generated_file = "__ml_generated__"
    std_var = t.ast_leaf_new("Var", "std", 0, generated_file)
    std_member = Member("Member", std_var, "concurrent", 0, generated_file)
    concurrent_member = Member("Member", std_member, "thread_pool", 0, generated_file)
    pool_type = Member("Member", concurrent_member, "ThreadPool", 0, generated_file)
    pool_new = Member("Member", pool_type, "new", 0, generated_file)
    pool_count = t.ast_leaf_new("Num", 4, 0, generated_file)
    pool_init = Assign("Assign", _language_async_pool_name, Call("Call", pool_new, [pool_count], [], 0, generated_file), 0, false, 0, generated_file)
    helpers = [pool_init] + helpers
  end if
  return helpers + lowered
end function

/// Returns parse program.
/// @param source Source value to process.
/// @param filename Value supplied for `filename`.
function parse_program(source, filename)
  toks = tokenize(source)
  if typeof(toks) == "struct" and typeof(try(toks.message)) == "string" then
    toks.filename = filename
    return toks
  end if
  _reset(toks, source, filename, false, 50)
  stmts_chunks = []
  stmts_tail = []
  _skip_stmt_seps()
  while _tok_kind_id(_peek()) != TK_EOF
    st = _parse_stmt()
    if _has_error() then return _last_error end if
    app = _chunked_push(stmts_chunks, stmts_tail, st, 128)
    stmts_chunks = app[0]
    stmts_tail = app[1]
    if _func_depth == 0 and st.node_kind != "NamespaceDecl" then
      _seen_nonpackage_toplevel_stmt = true
    end if
    _skip_stmt_seps()
  end while
  return _chunked_finish(stmts_chunks, stmts_tail)
end function

/// Returns parse program keepgoing.
/// @param source Source value to process.
/// @param filename Value supplied for `filename`.
/// @param max_errors Value supplied for `max_errors`.
function parse_program_keepgoing(source, filename, max_errors)
  toks = tokenize(source)
  if typeof(toks) == "struct" and typeof(try(toks.message)) == "string" then
    toks.filename = filename
    return ParseKeepResult([], [toks])
  end if

  limit = max_errors
  if typeof(limit) != "int" or limit <= 0 then
    limit = 50
  end if

  _reset(toks, source, filename, true, limit)

  stmts_chunks = []
  stmts_tail = []
  _skip_stmt_seps()
  while _tok_kind_id(_peek()) != TK_EOF
    st = _parse_stmt_recover([], 0)
    if st != 0 then
      app = _chunked_push(stmts_chunks, stmts_tail, st, 128)
      stmts_chunks = app[0]
      stmts_tail = app[1]
      if _func_depth == 0 and st.node_kind != "NamespaceDecl" then
        _seen_nonpackage_toplevel_stmt = true
      end if
    else
      if len(_errors) >= _max_errors then
        break
      end if
    end if
    _skip_stmt_seps()
  end while

  if _has_error() then
    _record_error(_last_error)
    _clear_error()
  end if

  return ParseKeepResult(_chunked_finish(stmts_chunks, stmts_tail), _errors)
end function
