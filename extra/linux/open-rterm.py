import os

from gi.repository import Nautilus, GObject

class OpenRTerm(GObject.GObject, Nautilus.MenuProvider):
    def __init__(self):
        pass

    def menu_activate_cb(self, menu, file):
        try:
            path = file.get_location().get_path()
            os.system("PWD=\"%s\" rterm & pid=&!" % path)
        except AttributeError: # it is a list of elements
            dir_list = [f.get_location().get_path() for f in file if f.is_directory()]
            for d in dir_list:
                os.system("PWD=\"%s\" rterm & pid=&!" % d)

    def define_menu_helper(self, name, window, file):
        item = Nautilus.MenuItem(name="RTermOpen::" + name,
                                 label="Open RTerm",
                                 tip="Opens RTerm in this directory", icon="terminal")
        item.connect('activate', self.menu_activate_cb, file)
        return item,

    def get_background_items(self, window, file):
        return self.define_menu_helper("Background", window, file)

    def get_file_items(self, window, file):
        return self.define_menu_helper("File", window, file)