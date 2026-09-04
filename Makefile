TARGET := iphone:clang:latest:14.0
ARCHS := arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := CraftRiseMod

CraftRiseMod_FILES := Tweak.xm
CraftRiseMod_CFLAGS := -fno-objc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk
