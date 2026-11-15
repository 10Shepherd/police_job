lib.locale()

-- standalone only, permissions use ACE groups
Bridge = require(("bridge.standalone.%s"):format(lib.context))
