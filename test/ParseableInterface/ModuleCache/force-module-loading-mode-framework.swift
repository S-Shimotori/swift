// RUN: %empty-directory(%t)

// 1. Not finding things is okay.
// RUN: env SWIFT_FORCE_MODULE_LOADING=prefer-parseable not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s 2>&1 | %FileCheck -check-prefix=NO-SUCH-MODULE %s
// RUN: env SWIFT_FORCE_MODULE_LOADING=prefer-serialized not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s 2>&1 | %FileCheck -check-prefix=NO-SUCH-MODULE %s
// RUN: env SWIFT_FORCE_MODULE_LOADING=only-parseable not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s 2>&1 | %FileCheck -check-prefix=NO-SUCH-MODULE %s
// RUN: env SWIFT_FORCE_MODULE_LOADING=only-serialized not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s 2>&1 | %FileCheck -check-prefix=NO-SUCH-MODULE %s
// (default)
// RUN: not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s 2>&1 | %FileCheck -check-prefix=NO-SUCH-MODULE %s

// 2. Only interface is present.
// RUN: %empty-directory(%t/Lib.framework/Modules/Lib.swiftmodule)
// RUN: cp %S/Inputs/force-module-loading-mode/Lib.swiftinterface %t/Lib.framework/Modules/Lib.swiftmodule/%target-cpu.swiftinterface
// RUN: env SWIFT_FORCE_MODULE_LOADING=prefer-parseable not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=FROM-INTERFACE %s
// RUN: env SWIFT_FORCE_MODULE_LOADING=prefer-serialized not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=FROM-INTERFACE %s
// RUN: env SWIFT_FORCE_MODULE_LOADING=only-parseable not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=FROM-INTERFACE %s
// RUN: env SWIFT_FORCE_MODULE_LOADING=only-serialized not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=NO-SUCH-MODULE %s
// (default)
// RUN: not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP -F %t %s 2>&1 | %FileCheck -check-prefix=FROM-INTERFACE %s

// 3. Only module is present.
// RUN: %empty-directory(%t/Lib.framework/Modules/Lib.swiftmodule)
// RUN: sed -e 's/FromInterface/FromSerialized/g' %S/Inputs/force-module-loading-mode/Lib.swiftinterface | %target-swift-frontend -parse-stdlib -module-cache-path %t/MCP -emit-module-path %t/Lib.framework/Modules/Lib.swiftmodule/%target-swiftmodule-name - -module-name Lib
// RUN: env SWIFT_FORCE_MODULE_LOADING=prefer-parseable not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=FROM-SERIALIZED %s
// RUN: env SWIFT_FORCE_MODULE_LOADING=prefer-serialized not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=FROM-SERIALIZED %s
// RUN: env SWIFT_FORCE_MODULE_LOADING=only-parseable not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=NO-SUCH-MODULE %s
// RUN: env SWIFT_FORCE_MODULE_LOADING=only-serialized not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=FROM-SERIALIZED %s
// (default)
// RUN: not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP -F %t %s 2>&1 | %FileCheck -check-prefix=FROM-SERIALIZED %s

// 4. Both are present.
// RUN: cp %S/Inputs/force-module-loading-mode/Lib.swiftinterface %t/Lib.framework/Modules/Lib.swiftmodule/%target-cpu.swiftinterface
// RUN: env SWIFT_FORCE_MODULE_LOADING=prefer-parseable not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=FROM-INTERFACE %s
// RUN: %empty-directory(%t/MCP)
// RUN: env SWIFT_FORCE_MODULE_LOADING=prefer-serialized not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=FROM-SERIALIZED %s
// RUN: %empty-directory(%t/MCP)
// RUN: env SWIFT_FORCE_MODULE_LOADING=only-parseable not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=FROM-INTERFACE %s
// RUN: %empty-directory(%t/MCP)
// RUN: env SWIFT_FORCE_MODULE_LOADING=only-serialized not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=FROM-SERIALIZED %s
// RUN: %empty-directory(%t/MCP)
// (default)
// RUN: not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP -F %t %s 2>&1 | %FileCheck -check-prefix=FROM-SERIALIZED %s
// RUN: %empty-directory(%t/MCP)

// 5. Both are present but the module is invalid.
// RUN: rm %t/Lib.framework/Modules/Lib.swiftmodule/%target-swiftmodule-name && touch %t/Lib.framework/Modules/Lib.swiftmodule/%target-swiftmodule-name
// RUN: env SWIFT_FORCE_MODULE_LOADING=prefer-parseable not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=FROM-INTERFACE %s
// RUN: %empty-directory(%t/MCP)
// RUN: env SWIFT_FORCE_MODULE_LOADING=prefer-serialized not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=FROM-INTERFACE %s
// RUN: %empty-directory(%t/MCP)
// RUN: env SWIFT_FORCE_MODULE_LOADING=only-parseable not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=FROM-INTERFACE %s
// RUN: %empty-directory(%t/MCP)
// RUN: env SWIFT_FORCE_MODULE_LOADING=only-serialized not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=BAD-MODULE %s
// RUN: %empty-directory(%t/MCP)
// (default)
// RUN: not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP -F %t %s 2>&1 | %FileCheck -check-prefix=FROM-INTERFACE %s
// RUN: %empty-directory(%t/MCP)

// 6. Both are present but the module can't be opened.
// RUN: chmod a-r %t/Lib.framework/Modules/Lib.swiftmodule/%target-swiftmodule-name
// RUN: env SWIFT_FORCE_MODULE_LOADING=prefer-parseable not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=FROM-INTERFACE %s
// RUN: %empty-directory(%t/MCP)
// RUN: env SWIFT_FORCE_MODULE_LOADING=prefer-serialized not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=NO-SUCH-MODULE %s
// RUN: %empty-directory(%t/MCP)
// RUN: env SWIFT_FORCE_MODULE_LOADING=only-parseable not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=FROM-INTERFACE %s
// RUN: %empty-directory(%t/MCP)
// RUN: env SWIFT_FORCE_MODULE_LOADING=only-serialized not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=NO-SUCH-MODULE %s
// RUN: %empty-directory(%t/MCP)
// (default)
// RUN: not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP -F %t %s 2>&1 | %FileCheck -check-prefix=NO-SUCH-MODULE %s
// RUN: %empty-directory(%t/MCP)

// 7. Both are present but for the wrong architecture.
// RUN: %empty-directory(%t/Lib.framework/Modules/Lib.swiftmodule)
// RUN: touch %t/Lib.framework/Modules/Lib.swiftmodule/garbage.swiftmodule
// RUN: touch %t/Lib.framework/Modules/Lib.swiftmodule/garbage.swiftinterface
// RUN: env SWIFT_FORCE_MODULE_LOADING=prefer-parseable not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=WRONG-ARCH -DARCH=%module-target-triple %s
// RUN: env SWIFT_FORCE_MODULE_LOADING=prefer-serialized not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=WRONG-ARCH -DARCH=%module-target-triple %s
// RUN: env SWIFT_FORCE_MODULE_LOADING=only-parseable not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=NO-SUCH-MODULE %s
// RUN: env SWIFT_FORCE_MODULE_LOADING=only-serialized not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=WRONG-ARCH -DARCH=%module-target-triple %s
// (default)
// RUN: not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP -F %t %s 2>&1 | %FileCheck -check-prefix=WRONG-ARCH -DARCH=%module-target-triple %s

// 8. Only the interface is present but for the wrong architecture.
// (Diagnostics for the module only are tested elsewhere.)
// FIXME: We should improve this to not just say NO-SUCH-MODULE.
// RUN: rm %t/Lib.framework/Modules/Lib.swiftmodule/garbage.swiftmodule
// RUN: env SWIFT_FORCE_MODULE_LOADING=prefer-parseable not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=NO-SUCH-MODULE %s
// RUN: env SWIFT_FORCE_MODULE_LOADING=prefer-serialized not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=NO-SUCH-MODULE %s
// RUN: env SWIFT_FORCE_MODULE_LOADING=only-parseable not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=NO-SUCH-MODULE %s
// RUN: env SWIFT_FORCE_MODULE_LOADING=only-serialized not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP %s -F %t 2>&1 | %FileCheck -check-prefix=NO-SUCH-MODULE %s
// (default)
// RUN: not %target-swift-frontend -typecheck -parse-stdlib -module-cache-path %t/MCP -F %t %s 2>&1 | %FileCheck -check-prefix=NO-SUCH-MODULE %s

import Lib
// NO-SUCH-MODULE: [[@LINE-1]]:8: error: no such module 'Lib'
// BAD-MODULE: [[@LINE-2]]:8: error: malformed module file: {{.*}}Lib.swiftmodule
// WRONG-ARCH: [[@LINE-3]]:8: error: could not find module 'Lib' for target '[[ARCH]]'; found: garbage

struct X {}
let _: X = Lib.testValue
// FROM-INTERFACE: [[@LINE-1]]:16: error: cannot convert value of type 'FromInterface' to specified type 'X'
// FROM-SERIALIZED: [[@LINE-2]]:16: error: cannot convert value of type 'FromSerialized' to specified type 'X'
