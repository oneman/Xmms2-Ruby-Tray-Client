#!/usr/bin/env ruby

# xmms2 ruby systray client
# drr 2010
#
# license gpl3 / give me some money 

PROGRAM_NAME = "xmms2 ruby systray client"
CLIENT_VERSION = 0.666 
RELEASE = "INTERNAL"

require 'gtk2'
require 'RNotify'

# rnotify, it was really simple to install wasnt it??
if !Notify.init(PROGRAM_NAME)
puts "failed, really its easy to install i mean come on right?? :P"
Kernel.exit
end

$icon = Gtk::StatusIcon.new

# change to suit style
$icon.file = "/usr/share/pixmaps/xmms2-white-on-black.svg" # should be there!
#$icon.file = "/usr/share/pixmaps/xmms2-128.png" # Another option

$icon.tooltip = PROGRAM_NAME + " VERSION " + CLIENT_VERSION.to_s + " RELEASE " + RELEASE


# song change notification stuff / icon tooltip
xmms2_info = ""
old_xmms2_info = ""
show_notification = false
timeout = Gtk::timeout_add(5000) { 
xmms2_info = `xmms2 current`
$icon.tooltip = xmms2_info.chop
xmms2_info = "Unknown Song" if xmms2_info.length < 5
if xmms2_info != old_xmms2_info && show_notification
 notification = Notify::Notification.new("#{xmms2_info}\n",nil,nil,nil)
 #notification.timeout = 2000
 notification.show
end
old_xmms2_info = "#{xmms2_info}"
show_notification = true
}










# loopy
Gtk.main
