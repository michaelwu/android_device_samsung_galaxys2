#!/bin/sh

# Copyright (C) 2010 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

DEVICE=galaxys2
COMMON=c1-common
MANUFACTURER=samsung

DEVICE_BUILD_ID=`adb shell cat /system/build.prop | grep ro.build.display.id | sed -e 's/ro.build.display.id=//' | tr -d '\r'`
case "$DEVICE_BUILD_ID" in
"GINGERBREAD.UHKG7")
  FIRMWARE=UHKG7 ;;
"GINGERBREAD.XWKE2")
  FIRMWARE=XWKE2 ;;
*)
  echo Warning, your device has unknown firmware $DEVICE_BUILD_ID >&2
  FIRMWARE=unknown ;;
esac

BASE_PROPRIETARY_COMMON_DIR=vendor/$MANUFACTURER/$COMMON/proprietary
PROPRIETARY_DEVICE_DIR=../../../vendor/$MANUFACTURER/$DEVICE/proprietary
PROPRIETARY_COMMON_DIR=../../../$BASE_PROPRIETARY_COMMON_DIR

mkdir -p $PROPRIETARY_DEVICE_DIR

for NAME in audio cameradat egl firmware hw keychars wifi
do
    mkdir -p $PROPRIETARY_COMMON_DIR/$NAME
done

# galaxys2


# c1-common
(cat << EOF) | sed s/__DEVICE__/$DEVICE/g | sed s/__MANUFACTURER__/$MANUFACTURER/g > ../../../vendor/$MANUFACTURER/$DEVICE/$DEVICE-vendor-blobs.mk
# Copyright (C) 2010 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Prebuilt libraries that are needed to build open-source libraries
PRODUCT_COPY_FILES := \\

# All the blobs necessary for galaxys2 devices
PRODUCT_COPY_FILES += \\

EOF

COMMON_BLOBS_LIST=../../../vendor/$MANUFACTURER/$COMMON/c1-vendor-blobs.mk

(cat << EOF) | sed s/__COMMON__/$COMMON/g | sed s/__MANUFACTURER__/$MANUFACTURER/g > $COMMON_BLOBS_LIST
# Copyright (C) 2010 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Prebuilt libraries that are needed to build open-source libraries
PRODUCT_COPY_FILES := \\
    vendor/__MANUFACTURER__/__COMMON__/proprietary/libcamera.so:obj/lib/libcamera.so \\
    vendor/__MANUFACTURER__/__COMMON__/proprietary/libril.so:obj/lib/libril.so \\
    vendor/__MANUFACTURER__/__COMMON__/proprietary/libsecril-client.so:obj/lib/libsecril-client.so \\
    vendor/__MANUFACTURER__/__COMMON__/proprietary/audio/libaudio.so:obj/lib/libaudio.so \\
    vendor/__MANUFACTURER__/__COMMON__/proprietary/audio/libmediayamahaservice.so:obj/lib/libmediayamahaservice.so \\
    vendor/__MANUFACTURER__/__COMMON__/proprietary/audio/libaudiopolicy.so:obj/lib/libaudiopolicy.so

# All the blobs necessary for galaxys2 devices
PRODUCT_COPY_FILES += \\
EOF

# copy_files
# pulls a list of files from the device and adds the files to the list of blobs
#
# $1 = list of files
# $2 = directory path on device
# $3 = directory name in $PROPRIETARY_COMMON_DIR
copy_files()
{
    for NAME in $1
    do
        echo Pulling $NAME
        adb pull /$2/$NAME $PROPRIETARY_COMMON_DIR/$3/$NAME
        echo $BASE_PROPRIETARY_COMMON_DIR/$3/$NAME:$2/$NAME \\\\ >> $COMMON_BLOBS_LIST
    done
}

COMMON_LIBS="
	libActionShot.so
	libakm.so
	libarccamera.so
	libcamera_client.so
	libcameraservice.so
	libcamera.so
	libcaps.so
	libEGL.so
	libexif.so
	libfimc.so
	libfimg.so
	libGLESv1_CM.so
	libGLESv2.so
	libMali.so
	libOpenSLES.so
	libPanoraMax3.so
	libril.so
	libs5pjpeg.so
	libseccameraadaptor.so
	libseccamera.so
	libsecril-client.so
	libsec-ril.so
	libtvoutcec.so
	libtvoutddc.so
	libtvoutedid.so
	lib_tvoutengine.so
	libtvoutfimc.so
	libtvoutfimg.so
	libtvouthdmi.so
	libtvout_jni.so
	libtvoutservice.so
	libtvout.so
	"
if [ $FIRMWARE != "UHKG7" ]
then
    COMMON_LIBS="$COMMON_LIBS libsecjpegencoder.so"
fi
copy_files "$COMMON_LIBS" "system/lib" ""

COMMON_BINS="
	rild
	tvoutserver
	"
if [ $FIRMWARE != "UHKG7" ] 
then
COMMON_BINS="$COMMON_BINS BCM4330B1_002.001.003.0043.0077.hcd"
else
COMMON_BINS="$COMMON_BINS BCM4330B1_002.001.003.0221.0265.hcd"
fi
copy_files "$COMMON_BINS" "system/bin" ""

if [ $FIRMWARE != "UHKG7" ] 
then
COMMON_CAMERADATA="
	datapattern_420sp.yuv
	datapattern_front_420sp.yuv
	"
fi
copy_files "$COMMON_CAMERADATA" "system/cameradata" "cameradata"

COMMON_EGL="
	libEGL_mali.so
	libGLES_android.so
	libGLESv1_CM_mali.so
	libGLESv2_mali.so
	"
copy_files "$COMMON_EGL" "system/lib/egl" "egl"

COMMON_FIRMWARE="
	qt602240.fw
	"
copy_files "$COMMON_FIRMWARE" "system/etc/firmware" "firmware"
copy_files "mfc_fw.bin" "vendor/firmware" "firmware"

COMMON_HW="
	acoustics.default.so
	alsa.default.so
	copybit.GT-I9100.so
	gps.GT-I9100.so
	gralloc.default.so
	gralloc.GT-I9100.so
	lights.GT-I9100.so
	overlay.GT-I9100.so
	sensors.GT-I9100.so
	"
copy_files "$COMMON_HW" "system/lib/hw" "hw"

COMMON_KEYCHARS="
	Broadcom_Bluetooth_HID.kcm.bin
	qwerty2.kcm.bin
	qwerty.kcm.bin
	sec_key.kcm.bin
	sec_touchkey.kcm.bin
	"
copy_files "$COMMON_KEYCHARS" "system/usr/keychars" "keychars"

COMMON_WIFI="
	bcm4330_mfg.bin
	bcm4330_sta.bin
	"
copy_files "$COMMON_WIFI" "system/etc/wifi" "wifi"

COMMON_AUDIO="
	libasound.so
	libaudio.so
	libaudioeffect_jni.so
	libaudiohw_op.so
	libaudiohw_sf.so
	libaudiopolicy.so
	liblvvefs.so
	libmediayamaha.so
	libmediayamaha_jni.so
	libmediayamahaservice.so
	libmediayamaha_tuning_jni.so
	libsamsungAcousticeq.so
	lib_Samsung_Acoustic_Module_Llite.so
	lib_Samsung_Resampler.so
	libsamsungSoundbooster.so
	lib_Samsung_Sound_Booster.so
	libsoundalive.so
	libSR_AudioIn.so
	libyamahasrc.so
	"
copy_files "$COMMON_AUDIO" "system/lib" "audio"

./setup-makefiles.sh
