# Android ######################################################################
#
# ENV Vars
#
export MY_ANDROID_HOME="/Users/${USER}/Library/Android"
export MY_ANDROID_SDK_HOME=${MY_ANDROID_HOME}/sdk
# export ANDROID_NDK_HOME=${ANDROID_SDK_HOME}/ndk/21.1.6352462
#
# Platform Tools
addpath ${MY_ANDROID_SDK_HOME}/platform-tools
addpath ${MY_ANDROID_SDK_HOME}/emulator
#
# Logcat #######################################################################
#
# https://developer.android.com/studio/command-line/logcat
# Log Levels
#
# V: Verbose (lowest priority)
# D: Debug
# I: Info
# W: Warning
# E: Error
# F: Fatal
# S: Silent (highest priority, on which nothing is ever printed)
#
# Control log output format
# Log messages contain a number of metadata fields, in addition to the tag and
# priority. You can modify the output format for messages so that they display
# a specific metadata field. To do so, you use the -v option and specify one of
# the supported output formats listed below.

# brief: Display priority, tag, and PID of the process issuing the message.
# long: Display all metadata fields and separate messages with blank lines.
# process: Display PID only.
# raw: Display the raw log message with no other metadata fields.
# tag: Display the priority and tag only.
# thread: A legacy format that shows priority, PID, and TID of the thread
#   issuing the message.
# threadtime (default): Display the date, invocation time, priority, tag, PID, and
#   TID of the thread issuing the message.
# time: Display the date, invocation time, priority, tag, and PID of the process
#   issuing the message.
# When starting logcat, you can specify the output format you want by using the -v option:
# [adb] logcat [-v <format>]
#
# Default warn
alias logcat="adb logcat \*:W"
alias logcat_v="adb logcat \*:V"
alias logcat_d="adb logcat \*:D"
alias logcat_i="adb logcat \*:I"
alias logcat_w="adb logcat \*:W"
alias logcat_e="adb logcat \*:E"
alias logcat_f="adb logcat \*:F"

# Utils ########################################################################

function adb_list() {
  adb shell "pm list packages -f" | grep -v system
}

function adb_uninstall() {
  echo "# Pipe output to a shell"
  adb shell "pm list packages -f" | grep -v system | cut -f 2 -d "=" | awk '{print "adb uninstall "$0}'
}
