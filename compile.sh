#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/user/depot_tools:/home/user/depot_tools


cd src
gn gen out/Release --args='is_debug = false symbol_level = 0 enable_nacl = true remove_webcore_debug_symbols = true enable_linux_installer = true enable_ac3_eac3_audio_demuxing = true enable_google_now = false enable_hevc_demuxing = true enable_hotwording = false enable_iterator_debugging = false enable_mse_mpeg2ts_stream_parser = true enable_nacl = true exclude_unwind_tables = true ffmpeg_branding = "Chrome" is_component_build = false proprietary_codecs = true remove_webcore_debug_symbols = true symbol_level = 0 target_cpu = "x64" enable_hangout_services_extension = true enable_webrtc = true enable_widevine = true rtc_use_h264 = true rtc_use_lto = true use_openh264 = true chrome_pgo_phase = 0 full_wpo_on_official = false is_official_build = false'

ninja -C out/Release chrome
export IGNORE_DEPS_CHANGES=1
ninja -C out/Release  "chrome/installer/linux:beta_deb"


