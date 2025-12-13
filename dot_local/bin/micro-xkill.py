#!/usr/bin/python -B

'''
	workaround to https://code.google.com/p/chromium/issues/detail?id=59491
		"Gtk: context menu does not render properly and leaves an uncloseable gray box"

	may also be usable for other situations, but see disclaimer

	THIS IS A DESPERATE HACK WRITTEN WITH MINIMAL X-SERVER KNOWLEDGE.
	USE AT YOUR OWN RISK / SAVE YOUR WORK.

	- - - - -

	Copyright (c) 2012 Mats Ahlgren , http://www.interplexing.com/code/micro-xkill.py
	standard MIT license:

	Permission is hereby granted, free of charge, to any person obtaining
	a copy of this software and associated documentation files (the
	"Software"), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject to
	the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
	LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
	OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
	WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
'''

import sys
import re
from itertools import *
from subprocess import Popen,PIPE

try:
	import Xlib.display
except ImportError:
	print 'Error: Please install the python Xlib package through your package manager.'
	sys.exit(1)

def clickForWindowId():
	'''
		Uses xwininfo to turn the cursor into a crosshairs, letting the user click on a
		window; the output is parsed and the window's X id is extracted as an integer.
	'''
	print '''
Your mouse cursor has become a crosshairs.
Please click on the offending popup window to kill it.

THE WINDOW YOU CLICK ON WILL BE DESTROYED. ONLY CLICK ON THE OFFENDING *POPUP* WINDOW.
Other related(?) windows or applications or the window manager may misbehave.

If you accidentally started this script and wish to ABORT, hit ctrl-C.'''
	try:
		output = Popen(['xwininfo'], stdout=PIPE).communicate()[0]
	except Exception as ex:
		print 'Error occurred while attempting to call xwininfo. Please make sure xwininfo is installed.'
		raise ex
	
	try:
		idHexString = re.compile(r'id: (0x[0-9a-f]+)').findall(output)[0]
		xid = int(idHexString, 16)
	except Exception as ex:
		print 'Error parsing output of xwininfo.'
		raise ex

	return xid

def getWindowFromId(xid):
	'''
		Input: window's X id, as integer
		Output: corresponding Xlib.display.Window object
		
		note: uses shortcut; assumes relevant window's parent is root window
	'''
	def iterTree(win):
		return chain.from_iterable([[win]] + [iterTree(w) for w in win.query_tree().children])

	root = Xlib.display.Display().screen().root
	for w in iterTree(root):
		if w.id==xid:
			return w

def clickToDestroyEvilPopup():
	xid = clickForWindowId()
	badWindow = getWindowFromId(xid)
	
	try:
		#badWindow.unmap_sub_windows()	# right order? not sure if necessary
		#badWindow.unmap()				# right order? not sure if necessary
		badWindow.destroy()
		badWindow.query_tree()  # .destroy() doesn't seem to work without this...
	except Xlib.error.BadWindow as ex:
		print '\nWindow successfully destroyed?'

clickToDestroyEvilPopup()
