module widgets.tab;
import mainwindow;
import widgets.dialogs.changetitledialog;

import std.stdio;
import gio.Application : GioApplication = Application;
import gtk.Application;
import gtk.ApplicationWindow;
import gtk.VBox;
import gtk.HBox;
import gtk.Main;
import gtk.Builder;
import gtk.Window;
import gtk.Widget;
import gtk.Viewport;
import gtk.Notebook;
import gtk.Stack;
import gtk.Button;
import gtk.Label;
import gtk.Image;
import gtk.Adjustment;
import gdk.Event;
import gdk.Keymap;
import gtk.EventBox;
import gtk.Dialog;
import gtk.PopoverMenu;
import gobject.Signals;
import gobject.ObjectG;
import gtk.MenuItem;
import gtk.Menu;
import profile;
import widgets.term;

class Tab : EventBox {
    Notebook parentNotebook;
    Widget childWidget;
    MainWindow mainWindow;
    Label label;
    PopoverMenu popoverMenu;
    string title = null;

    this(MainWindow window, Notebook notebook, Widget child)
    {
        mainWindow = window;
        parentNotebook = notebook;
        childWidget = child;

        super();
        HBox hb = new HBox(false, 5);
        hb.setMarginLeft(7);
        hb.setMarginRight(7);
        hb.setMarginTop(2);
        hb.setMarginBottom(2);
        add(hb);

        auto removeTerm = (Button b = null)
        {
            parentNotebook.remove(childWidget);
            closeTab();
        };

        // Destroy itself, if child gets destroyed
        childWidget.addOnDestroy(delegate(Widget w)
        {
            parentNotebook.remove(w);
            removeTerm();
        });

        // Tab label
        label = new Label("Tab");
        hb.add(label);

        // Close tab button
        Button b = new Button("window-close", GtkIconSize.SMALL_TOOLBAR);
        b.setRelief(GtkReliefStyle.NONE );
        b.getStyleContext().addClass("circular");
        b.getStyleContext().addClass("titlebutton");
        b.setValign(GtkAlign.CENTER);
        b.setHalign(GtkAlign.CENTER);
        b.addOnClicked(removeTerm);
        hb.add(b);

        
        addEvents(GdkEventMask.BUTTON3_MOTION_MASK);
        addEvents(GdkEventMask.BUTTON2_MOTION_MASK);
        addEvents(GdkEventMask.SCROLL_MASK);

        // Right click menu
        Menu menu = new Menu();
        MenuItem newDefaultTerm = new MenuItem(delegate(MenuItem m)
        {
            Window w = cast(Window)this.getToplevel();
            ChangeTitleDialog dialog = new ChangeTitleDialog(w, label.getText());

            dialog.addOnResponse(delegate(int response, Dialog d)
            {
                if(response ==  ResponseType.OK)
                    setTitle(dialog.entry.getText());

                dialog.destroy();
            });
        }, "Rename");
        menu.append(newDefaultTerm);
        MenuItem newProfileTerm = new MenuItem(delegate(MenuItem m)
        {
            closeTab();
        }, "Close");
        menu.append(newProfileTerm);
        menu.showAll();     

        addOnButtonPress(delegate(Event e, Widget w)
        {
            switch(e.button().button)
            {
                // Close window
                // Mouse 3 (Middle button)
                case 2:
                {
                    closeTab();
                    return true;
                }

                // Right click menu
                case 3:
                {
                    menu.popup(null, this, null, null, 0, 0);
                    return true;
                }

                default:
                    return false;
            }
        });

        // Scroll to change tabs
        addOnScroll(delegate(Event e, Widget w)
        {
            GdkEventScroll *ev = e.scroll();
            switch(ev.direction)
            {
                // Next tab
                // Scroll up
                case GdkScrollDirection.UP:
                case GdkScrollDirection.RIGHT:
                {
                    window.nextTab();
                    return true;
                }

                // Previous tab
                // Scroll down
                case GdkScrollDirection.DOWN:
                case GdkScrollDirection.LEFT:
                {
                    window.previousTab();
                    return true;
                }

                // No shortcut
                default:
                    return false;
            }
        });

        Term term = (cast(Term)childWidget);
        setTitleProcess(term.term.getWindowTitle());

        HBox.showAll();
        showAll();
    }

    void closeTab()
    {
        childWidget.destroy();
    }

    void setTitleProcess(string t)
    {
        if(!title)
            label.setText(t);
        else label.setText(title);
    }
    
    void setTitle(string t)
    {
        if(t == "") t = null;
        title = t;
        Term term = (cast(Term)childWidget);
        setTitleProcess(term.term.getWindowTitle());
    }
}