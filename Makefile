include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MessageFile
MessageFile_OBJCC_FILES = /mnt/d/codes/messagefile/Tweak.xm
MessageFile_FRAMEWORKS = UIKit Foundation CydiaSubstrate
MessageFile_PRIVATE_FRAMEWORKS = ChatKit
LDFLAGS = -Wl,-segalign,0x4000

export ARCHS = armv7 arm64
MessageFile_ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/tweak.mk
