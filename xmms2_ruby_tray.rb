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
#$icon.file = "/usr/share/pixmaps/xmms2-white-on-black.svg" # should be there!
$icon.file = "/usr/share/pixmaps/xmms2-128.png" # Another option

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

class Gtk::MenuItem
	def set_callback(meth, args = [])
		args.unshift(meth)

		signal_connect("activate") do
		  `xmms2 #{meth}`
			false
		end
	end
end

menu = Gtk::Menu.new

			[
				[Gtk::Stock::MEDIA_PLAY, :play],
				[Gtk::Stock::MEDIA_PAUSE, :pause],
				[Gtk::Stock::MEDIA_STOP, :stop]
			].each do |(stock, meth)|
				item = Gtk::ImageMenuItem.new(stock)
				item.set_callback(meth)

				menu.append(item)
			end

			menu.append(Gtk::SeparatorMenuItem.new)

			item = Gtk::ImageMenuItem.new("Shuffle")
			item.set_callback("shuffle")

			menu.append(item)

			item = Gtk::ImageMenuItem.new(Gtk::Stock::CLEAR)
			item.set_callback("clear")

			menu.append(item)

			menu.append(Gtk::SeparatorMenuItem.new)

			item = Gtk::ImageMenuItem.new(Gtk::Stock::ABOUT)
			item.signal_connect("activate") do
				props = {
					"name" => PROGRAM_NAME,
					"version" => CLIENT_VERSION.to_s + " " + RELEASE,
					"copyright" => "(c) 2006 Tilman Sauerbeck (Good Code) / (!$?) 2006-2010 David Richards (Bad Code)",
					"logo" => Gdk::Pixbuf.new("/usr/share/pixmaps/xmms2-128.png")
				}

				Gtk::AboutDialog.show(nil, props)
				false
			end

			menu.append(item)

			item = Gtk::ImageMenuItem.new(Gtk::Stock::QUIT)
			item.signal_connect("activate") do
				Gtk.main_quit
				
			end

			menu.append(item)

			menu.append(Gtk::SeparatorMenuItem.new)

			[
				[Gtk::Stock::MEDIA_PREVIOUS, :prev],
				[Gtk::Stock::MEDIA_NEXT, :NEXT]
			].each do |(stock, meth)|
				item = Gtk::ImageMenuItem.new(stock)
				item.set_callback(meth)

				menu.append(item)
			end

menu.show_all

$info_window_open = "no"
def set_info_window(state)
if state == "closed"
 $w.destroy
 $info_window_open = "no"
else
 info_window
end

end

def handle_info_window
if $info_window_open == "yes"
 $w.destroy
 $info_window_open = "no"
else
 info_window
end
end

def update_label(label)
sleep 0.2
label.text = `xmms2 info`

end

def info_window

$w = Gtk::Window.new
$w.set_default_size 1000, 600
$w.set_window_position Gtk::Window::POS_CENTER
$w.decorated = false
$w.set_border_width 10
vbox = Gtk::VBox.new

hbox = Gtk::HBox.new
vbox.add hbox
label = Gtk::Label.new ""
hbox.add label   

update_label(label)
      
hbox2 = Gtk::HBox.new
vbox.add hbox2
 
button = Gtk::Button.new "Previous"
button.signal_connect("button_press_event") { `xmms2 prev`; update_label(label); false}
hbox2.add button

button = Gtk::Button.new "Play"
button.signal_connect("button_press_event") { `xmms2 toggle_play`; update_label(label); false}
hbox2.add button

button = Gtk::Button.new "Next"
button.signal_connect("button_press_event") { `xmms2 next`; update_label(label); false}
hbox2.add button

button = Gtk::Button.new "X"
button.signal_connect("button_press_event") { set_info_window("closed"); false}
hbox2.add button

$w.add vbox
$w.signal_connect('focus-out-event') {|w, e| set_info_window("closed");}
$w.set_skip_taskbar_hint true
$w.show_all
$info_window_open = "yes"
end

$icon.signal_connect("button_press_event") do |widget, event|
  if (event.button == 1)
    handle_info_window
  end	
end

$icon.signal_connect("button_press_event") do |widget, event|
  if (event.button == 3)
    menu.popup(nil, nil, event.button, event.time) { |menu, x, y, pushin| $icon.position_menu(menu); }
  end	
end

# loopy
Gtk.main
