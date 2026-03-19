package mlc.constants

// tagged values
const TAG_PTR = 0
const TAG_INT = 1
const TAG_BOOL = 2
const TAG_VOID = 3
const TAG_ENUM = 4

// heap object ids
const OBJ_FREE = 0
const OBJ_STRING = 1
const OBJ_ARRAY = 2
const OBJ_FUNCTION = 3
const OBJ_FLOAT = 4
const OBJ_STRUCT = 5
const OBJ_STRUCTTYPE = 6
const OBJ_BUILTIN = 7
const OBJ_ENV = 8
const OBJ_BOX = 9
const OBJ_BYTES = 10

// gc header
const GC_HEADER_SIZE = 24
const GC_OFF_BLOCK_SIZE = -24
const GC_OFF_MARK = -16
const GC_OFF_REFCOUNT = -16
const GC_OFF_NEXT_FREE = -8

// runtime buffers
const WIDEBUF_SIZE = 8096
const INBUF_SIZE = 4096

// builtin struct ids
const ERROR_STRUCT_ID = 0xE0000001
const CALLSTAT_STRUCT_ID = 0xE0000002

// runtime error codes
const ERR_EXTERN_CONVERSION = 1001
const ERR_EXTERN_RET_WSTR_CONVERSION = 1002
const ERR_CALL_NOT_CALLABLE = 1100
const ERR_METHOD_NOT_FOUND = 1101
const ERR_VOID_OP = 1200
const ERR_INDEX_OOB = 1300
const ERR_INDEX_TYPE = 1301
const ERR_INDEX_TARGET_TYPE = 1302
const ERR_STRINGIFY_UNSUPPORTED = 1303
const ERR_PRINT_UNSUPPORTED = 1304
const ERR_MEMBER_TARGET_TYPE = 1305
const ERR_MEMBER_NOT_FOUND = 1306
const ERR_ARRAY_INIT_SIZE = 1307
const ERR_MODULE_INIT_CYCLE = 1400
