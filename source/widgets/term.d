module widgets.term;

import profile;

import std.conv;
import std.process;
import std.stdio;
import gtk.VBox;
import gtk.Widget;
import gtk.Application;
import gtk.Notebook;
import gtk.Viewport;
import gdk.RGBA;
import vte.Terminal;
import gtk.AccelGroup;
import gtk.Menu;
import gtk.MenuItem;
import gdk.Event;
import gdk.Keysyms;
import widgets.tab;

class Term : Viewport
{
    AccelGroup accelGroup;
    Terminal term;
    Notebook notebook;
    
    this(Profile prof, Notebook nb)
    {
        super(null, null);

        notebook = nb;
        term = new Terminal();
        term.setClearBackground(false);
        // Set fg to null if no foreground color is set
        RGBA fg = prof.foreground is null ? null : prof.foreground.toGdk();
        RGBA[] palette = colorArrayToGdkArray(prof.palette);
        term.setColors(fg, null, palette);
        accelGroup = new AccelGroup();
        term.addEvents(GdkEventMask.SCROLL_MASK);

        // Menu and shortcuts
        uint keyval;
        GdkModifierType keymod;

        Menu termMenu = new Menu();
        MenuItem copy = new MenuItem(delegate(MenuItem m)
        {
            term.copyClipboardFormat(VteFormat.TEXT);
        }, "Copy");
        accelGroup.acceleratorParse("<Control><Shift>C", keyval, keymod);
        copy.addAccelerator("activate", accelGroup, keyval, keymod, AccelFlags.VISIBLE);
        termMenu.append(copy);

        MenuItem copyHTML = new MenuItem(delegate(MenuItem m)
        {
            term.copyClipboardFormat(VteFormat.HTML);
        }, "Copy as HTML");
        accelGroup.acceleratorParse("<Control><Alt><Shift>C", keyval, keymod);
        copyHTML.addAccelerator("activate", accelGroup, keyval, keymod, AccelFlags.VISIBLE);
        termMenu.append(copyHTML);

        MenuItem paste = new MenuItem(delegate(MenuItem m)
        {
            term.pasteClipboard();
        }, "Paste");
        accelGroup.acceleratorParse("<Control><Shift>V", keyval, keymod);
        paste.addAccelerator("activate", accelGroup, keyval, keymod, AccelFlags.VISIBLE);
        termMenu.append(paste);

        MenuItem zoomin = new MenuItem(delegate(MenuItem m)
        {
            term.setFontScale(term.getFontScale() * 1.2);
        }, "Zoom in");
        accelGroup.acceleratorParse("<Control>KP_Add", keyval, keymod);
        zoomin.addAccelerator("activate", accelGroup, keyval, keymod, AccelFlags.VISIBLE);
        // ScrollUp doesn't work as a keyval for some reason
        //zoomin.addAccelerator("activate", accelGroup, Keysyms.GDK_ScrollUp, keymod, AccelFlags.VISIBLE);
        termMenu.append(zoomin);

        MenuItem zoomout = new MenuItem(delegate(MenuItem m)
        {
            term.setFontScale(term.getFontScale() * .8333);
        }, "Zoom out");
        accelGroup.acceleratorParse("<Control>KP_Subtract", keyval, keymod);
        zoomout.addAccelerator("activate", accelGroup, keyval, keymod, AccelFlags.VISIBLE);
        // ScrollUp doesn't work as a keyval for some reason
        //zoomout.addAccelerator("activate", accelGroup, Keysyms.GDK_ScrollDown, keymod, AccelFlags.VISIBLE);
        termMenu.append(zoomout);

        termMenu.showAll();

        // Right click menu
        addOnButtonPress(delegate(Event e, Widget w)
        {
            if(e.button().button == 3)
            {
                termMenu.popup(null, this, null, null, 0, 0);
                return true;
            }
            return false;
        });

        // Executable
        string exec;
        if(prof.executable == "" || prof is null) exec = environment.get("SHELL", "/usr/bin/sh");
        else exec = prof.executable;

        // Enviroment variables
        string[] env = prof.envVars;
        if(!env) env = [];  // If null, create empty array
        env ~= "TERM_PROGRAM=rterm";   // Append terminal name

        string path = prof.path;
        if(!path) path = environment.get("PWD", ".");

        // Create child process
        int pid = 0;
        term.spawnSync(
            VtePtyFlags.DEFAULT,
            path,           // Start directory
            [exec],         // Command
            env ,           // EnvVars
            GSpawnFlags.DEFAULT,
            null, null, pid, null);
        
        term.addOnEof(delegate(Terminal t)
        {
            if(prof.closeWhenProcessEnds)
                destroy();
        });

        auto nameChanged = delegate(Terminal t)
        {
            Tab tab = cast(Tab)notebook.getTabLabel(this);
            tab.setName(term.getWindowTitle());
        };
        term.addOnWindowTitleChanged(nameChanged);

        add(term);
        showAll();
    }
}