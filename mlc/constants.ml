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

// Shared tagged-value, heap-object and Windows/Linux x64 ABI constants.
//! Provides the mlc constants package.

package mlc.constants

/// Tagged values.
const TAG_PTR = 0
/// Track tag int.
const TAG_INT = 1
/// Track tag bool.
const TAG_BOOL = 2
/// Track tag void.
const TAG_VOID = 3
/// Track tag enum.
const TAG_ENUM = 4
/// Track tag float.
const TAG_FLOAT = 5

/// Heap object ids.
const OBJ_FREE = 0
/// Track obj string.
const OBJ_STRING = 1
/// Track obj array.
const OBJ_ARRAY = 2
/// Track obj function.
const OBJ_FUNCTION = 3
/// Track obj float.
const OBJ_FLOAT = 4
/// Track obj struct.
const OBJ_STRUCT = 5
/// Track obj structtype.
const OBJ_STRUCTTYPE = 6
/// Track obj builtin.
const OBJ_BUILTIN = 7
/// Track obj env.
const OBJ_ENV = 8
/// Track obj box.
const OBJ_BOX = 9
/// Track obj bytes.
const OBJ_BYTES = 10
/// Track obj closure.
const OBJ_CLOSURE = 11
/// Track obj env local.
const OBJ_ENV_LOCAL = 12
/// Track obj array imm.
const OBJ_ARRAY_IMM = 13
/// Track obj thread.
const OBJ_THREAD = 14

/// Gc header.
const GC_HEADER_SIZE = 8
/// Track gc off block size.
const GC_OFF_BLOCK_SIZE = -8
/// Track gc off mark.
const GC_OFF_MARK = 0
/// Track gc off refcount.
const GC_OFF_REFCOUNT = GC_OFF_MARK
/// Track gc off next free.
const GC_OFF_NEXT_FREE = 8
/// Track gc block free bit.
const GC_BLOCK_FREE_BIT = 0x1
/// Track gc block flags mask.
const GC_BLOCK_FLAGS_MASK = 0x7
/// Track gc block size mask.
const GC_BLOCK_SIZE_MASK = ~GC_BLOCK_FLAGS_MASK

/// Runtime buffers.
const WIDEBUF_SIZE = 8096
/// Track inbuf size.
const INBUF_SIZE = 4096

/// Builtin struct ids.
const ERROR_STRUCT_ID = 0xE0000001
/// Track callstat struct id.
const CALLSTAT_STRUCT_ID = 0xE0000002

/// Runtime error codes.
const ERR_EXTERN_CONVERSION = 1001
/// Track err extern ret wstr conversion.
const ERR_EXTERN_RET_WSTR_CONVERSION = 1002
/// Track err call not callable.
const ERR_CALL_NOT_CALLABLE = 1100
/// Track err method not found.
const ERR_METHOD_NOT_FOUND = 1101
/// Track err void op.
const ERR_VOID_OP = 1200
/// Track err index oob.
const ERR_INDEX_OOB = 1300
/// Track err index type.
const ERR_INDEX_TYPE = 1301
/// Track err index target type.
const ERR_INDEX_TARGET_TYPE = 1302
/// Track err stringify unsupported.
const ERR_STRINGIFY_UNSUPPORTED = 1303
/// Track err print unsupported.
const ERR_PRINT_UNSUPPORTED = 1304
/// Track err member target type.
const ERR_MEMBER_TARGET_TYPE = 1305
/// Track err member not found.
const ERR_MEMBER_NOT_FOUND = 1306
/// Track err array init size.
const ERR_ARRAY_INIT_SIZE = 1307
/// Track err type guard.
const ERR_TYPE_GUARD = 1308
/// Track err module init cycle.
const ERR_MODULE_INIT_CYCLE = 1400
/// Track err synchronized value.
const ERR_SYNCHRONIZED_VALUE = 1500
