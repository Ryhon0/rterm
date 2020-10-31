module mainwindow;
import widgets.term;
import widgets.tab;
import profile;
import widgets.dialogs.aboutrtermdialog;
import widgets.dialogs.settingsdialog;
import widgets.dialogs.shortcutsdialog;

import std.conv;
import std.process;
import std.stdio;
import gio.Application : GioApplication = Application;
import gtk.Application;
import gtk.ApplicationWindow;
import gtk.AccelGroup;
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
import vte.Terminal;
import gdk.RGBA;
import gdk.Screen;
import gdk.Visual;
import gdk.Event;
import gdk.Keymap;
import gobject.Signals;
import gobject.ObjectG;
import gtk.CssProvider;
import gtk.MenuButton;
import gtk.Menu;
import gtk.MenuItem;
import cairo.Context;
import gtk.Settings;
import gtk.EventControllerKey;
import gobject.Signals;
import gtk.AccelGroup;
import gtk.PopoverMenu;
import gtk.ModelButton;
import gtk.ListBox;
import gtk.ListBoxRow;
import gtk.Dialog;
import gdk.Keysyms;
import rtsettings;
import widgets.profilelistrow;
import widgets.dialogs.newterminaldialog;

class MainWindow : ApplicationWindow
{
    Stack mainStack;
    Notebook terminalNotebook;
    AccelGroup accelGroup;

	this(Application application)
	{
        auto newTerm = (Button b = null)
        {
            Profile p = RTSettings.defaultProfile;
            this.addTermTab(p);
        };

		super(application);

        setTitle("rterm");
        setDefaultSize(800,600);
        setGravity(GdkGravity.CENTER);
        makeTransparentBackground(this);
        accelGroup = new AccelGroup();
        addAccelGroup(accelGroup);

        // Enable dark GTK theme
        getSettings().setProperty("gtk-application-prefer-dark-theme", true);

        // Main stack
        mainStack = new Stack();
        mainStack.setTransitionType(GtkStackTransitionType.OVER_LEFT_RIGHT);
        add(mainStack);

        mainStack.getStyleContext().addClass("rterm-window");
        CssProvider transparentBack = new CssProvider();
        makeTransparentBackground(mainStack);
        transparentBack.loadFromData("
        .rterm-window
        {
            background: rgba(0,0,0,0.5);
        }
        ");
        mainStack.getStyleContext().addProvider(transparentBack, 100);

        // Shortcuts
        uint keyval;
        GdkModifierType keymod;

        // No tabs open message
        VBox nvb = new VBox(false, 5);
        mainStack.add(nvb);
        nvb.setHalign(GtkAlign.CENTER);
        nvb.setValign(GtkAlign.CENTER);
        Label ntl = new Label("There are no terminals open");
        nvb.add(ntl);

        // Profile list
        ListBox lb = new ListBox();
        lb.setSelectionMode(GtkSelectionMode.SINGLE);
        nvb.add(lb);

        // Default profile
        auto defaultRow = new ProfileListRow(RTSettings.defaultProfile, true);
        accelGroup.acceleratorParse("<Control>N", keyval, keymod);
        defaultRow.addAccelerator("activate", accelGroup, keyval, keymod, AccelFlags.VISIBLE);
        lb.add(defaultRow);
        defaultRow.setSelectable(true);

        // Custom profiles
        foreach(profile; RTSettings.customProfiles)
        {
            auto row = new ProfileListRow(profile);
            lb.add(row);
            row.setSelectable(true);
        }

        // Create terminal
        lb.addOnRowActivated(delegate(ListBoxRow lbr, ListBox lb)
        {
            if(!lbr) return;

            ProfileListRow row = cast(ProfileListRow)lbr;
            addTermTab(row.profile);
            lb.selectRow(null);
        });
        
        // Notebook
        terminalNotebook = new Notebook();  
        terminalNotebook.setScrollable(true);
        mainStack.add(terminalNotebook);
        showAll();

        // No padding on notebook tabs
        CssProvider notebookTabPadding = new CssProvider();
        /* CSS style for when we have tabs in the header
        notebookTabPadding.loadFromData("
        header.top, notebook
        {
            border: none;
            background-color: transparent;
        }
        notebook > stack
        {
            
        }
        tab
        {
            padding: 5px;
            margin: 0px;
        }
        ");
        */
        notebookTabPadding.loadFromData("
        tab
        {
            padding: 5px;
            margin: 0px;
        }
        ");
        terminalNotebook.getStyleContext().addProvider(notebookTabPadding, 1000);
        
        // Menu buttons and shortcuts
        {
            HBox buttons = new HBox(false,0);
            terminalNotebook.setActionWidget(buttons, GtkPackType.END);

            // New terminal button
            Button b = new Button();
            b.add(new Image(StockID.ADD, GtkIconSize.SMALL_TOOLBAR));
            b.getStyleContext().addClass("titlebutton");
            b.setRelief(GtkReliefStyle.HALF);
            b.showAll();
            b.addOnClicked(newTerm);
            buttons.add(b);

            Menu termMenu = new Menu();
            MenuItem newDefaultTerm = new MenuItem(delegate(MenuItem m)
            {
                newTerm();
            }, "New default terminal");
            accelGroup.acceleratorParse("<Control>N", keyval, keymod);
            newDefaultTerm.addAccelerator("activate", accelGroup, keyval, keymod, AccelFlags.VISIBLE);
            termMenu.append(newDefaultTerm);
            MenuItem newProfileTerm = new MenuItem(delegate(MenuItem m)
            {
                NewTerminalDialog terminalDialog = new NewTerminalDialog(this);
                terminalDialog.showAll();
                terminalDialog.addOnResponse(delegate(int i, Dialog d)
                {
                    terminalDialog.destroy();
                    auto dial = cast(NewTerminalDialog)d;
                    if(dial !is null && terminalDialog.selectedProfile !is null)
                        addTermTab(terminalDialog.selectedProfile);
                });
            }, "New terminal");
            accelGroup.acceleratorParse("<Control><Shift>N", keyval, keymod);
            newProfileTerm.addAccelerator("activate", accelGroup, keyval, keymod, AccelFlags.VISIBLE);
            termMenu.append(newProfileTerm);
            termMenu.showAll();

            // New terminal right click menu
            b.addOnButtonPress(delegate(Event e, Widget w)
            {
                if(e.button().button == 3)
                {
                    termMenu.popup(null, b, null, null, 0, 0);
                    return true;
                }
                return false;
            });
            

            // Menu button
            MenuButton menu = new MenuButton();
            menu.add(new Image(StockID.PREFERENCES, GtkIconSize.SMALL_TOOLBAR));
            
            menu.getStyleContext().addClass("titlebutton");
            menu.setRelief(GtkReliefStyle.HALF);
            Menu m = new Menu();

            // Settings
            auto sett = new MenuItem(delegate(MenuItem menuitem)
                {
                    SettingsDialog settings = new SettingsDialog(this);
                    settings.show();
                }, "Settings");
            m.append(sett);

            // Shortcuts
            auto shortcut = new MenuItem(delegate(MenuItem menuitem)
                {
                    ShortcutsDialog shortcuts = new ShortcutsDialog(this);
                    shortcuts.show();
                }, "Shortcuts");
            m.append(shortcut);

            // About
            auto about = new MenuItem(delegate(MenuItem menuitem)
                {
                    AboutRTermDialog about = new AboutRTermDialog(application);
                    about.show();
                }, "About");
            m.append(about);

            // Close current terminal
            auto close = new MenuItem(delegate(MenuItem menuitem)
                {
                    closeTab();
                }, "Close");
            accelGroup.acceleratorParse("<Control>W", keyval, keymod);
            close.addAccelerator("activate", accelGroup, keyval, keymod, AccelFlags.VISIBLE);
            m.append(close);

            // Next tab
            auto next = new MenuItem(delegate(MenuItem menuitem)
                {
                    nextTab();
                }, "Next tab");
            // For some reason <Control><Shift>Tab doesn't work :/
            //accelGroup.acceleratorParse("<Control><Shift>Tab", keyval, keymod);
            //next.addAccelerator("activate", accelGroup, keyval, keymod, AccelFlags.VISIBLE);
            accelGroup.acceleratorParse("<Control><Shift>Right", keyval, keymod);
            next.addAccelerator("activate", accelGroup, keyval, keymod, AccelFlags.VISIBLE);
            m.append(next);

            // Previous tab
            auto prev = new MenuItem(delegate(MenuItem menuitem)
                {
                    previousTab();
                }, "Previous tab");
            accelGroup.acceleratorParse("<Control><Shift>Left", keyval, keymod);
            prev.addAccelerator("activate", accelGroup, keyval, keymod, AccelFlags.VISIBLE);
            m.append(prev);
            
            m.showAll();
            menu.setPopup(m);
            application.setMenubar(menu.getMenuModel());
            buttons.add(menu);
            buttons.showAll();
        }

        this.present();

        /** Create a terminal on start if RTSettings.startWithNewTerminal is set to true */
        if(RTSettings.userSettings.startWithNewTerminal)
        {
            mainStack.setTransitionType(GtkStackTransitionType.NONE);
            addTermTab(RTSettings.defaultProfile);
            mainStack.setVisibleChild(terminalNotebook);
            mainStack.setTransitionType(GtkStackTransitionType.OVER_LEFT_RIGHT);
        }

        showAll();
	}

    /**
    Sets the background color of a widget
    */
    void makeTransparentBackground(Widget w)
    {
        w.setAppPaintable(true);
        w.addOnDraw(delegate(Context c, Widget w)
        {
            c.setSourceRgba(0,0,0,0);
            c.setOperator(cairo_operator_t.SOURCE);
            c.paint();
            c.setOperator(cairo_operator_t.OVER);
            return false;
        });
        Screen screen = w.getScreen();
        Visual visual = screen.getRgbaVisual();
        if(visual !is null && screen.isComposited())
            w.setVisual(visual);
        else
            w.setVisual(screen.getSystemVisual());
    }

    /**
    Adds a terminal based on the provided profile to the notebook 
    */
    void addTermTab(Profile p)
    {
        Term t = new Term(p, terminalNotebook);
        addAccelGroup(t.accelGroup);
        t.addOnDestroy(delegate(Widget w) => checkStack());

        Tab tab = new Tab(this, terminalNotebook, t);

        terminalNotebook.appendPageMenu(t, tab, tab);
        terminalNotebook.setTabDetachable(t, true);
        terminalNotebook.setTabReorderable(t, true);
        tab.label.setText("Terminal " ~ to!string(terminalNotebook.pageNum(t)+1));

        // CSS
        makeTransparentBackground(t);
        t.getStyleContext().addClass("rterm-term");
        CssProvider defaultcss = new CssProvider();
        defaultcss.loadFromData("
        .rterm-term
        {
            background: rgba(0,0,0,0.75);
        }
        ");
        t.getStyleContext().addProvider(defaultcss, 100);
        // Custom CSS
        if(p.CSS)
        {
            CssProvider css = new CssProvider();
            css.loadFromData(p.CSS);
            tab.getStyleContext().addProvider(css, 801);
            t.getStyleContext().addProvider(css, 801);
        }
        
        terminalNotebook.showAll();
        terminalNotebook.setCurrentPage(t);
        t.grabFocus();
        t.grabDefault();

        checkStack();
    }

    /**
    Checks if the terminal notebook has any children
    if doesn't  - sets the visible stack child to "No terminals open" page or close RTerm
    if does     - sets the visible stack child to the notebook

    Ran every time a new tab is added or a tab is destroyed
    */
    void checkStack()
    {
        Widget child;

        if(terminalNotebook.getChildren() is null || terminalNotebook.getChildren().length == 0)
        {
            /** Closes RTerm if RTSettings.closeWhenNoTerminals is set to true
                and if there are no terminals open */
            if(RTSettings.userSettings.closeWhenNoTerminals) close();
            else child = mainStack.children[0];
        }
        else child = terminalNotebook;
        
        mainStack.setVisibleChild(child);
        checkFocus();
    }

    void checkFocus()
    {
        if(terminalNotebook.getChildren() is null || terminalNotebook.getChildren().length == 0) return;

        int page = terminalNotebook.getCurrentPage();
        Term t = cast(Term)terminalNotebook.getNthPage(page);
        t.term.grabFocus();
    }

    /**
    Changes the current tab to one on the right from current
    or first if the current tab is the last
    */
    void nextTab()
    {
        if(terminalNotebook.getChildren() is null) return;
        int pages = terminalNotebook.getChildren().length;
        int current = terminalNotebook.getCurrentPage();

        int newPage = (current + 1) % pages;
        terminalNotebook.setCurrentPage(newPage);
    }

    /**
    Changes the current tab to one on the left from current
    or last if the current tab is the first tab
    */
    void previousTab()
    {
        if(terminalNotebook.getChildren() is null) return;
        int pages = terminalNotebook.getChildren().length;
        int current = terminalNotebook.getCurrentPage();

        int newPage = current - 1;
        if(newPage == -1 ) newPage = pages - 1;
        terminalNotebook.setCurrentPage(newPage);
    }

    /**
    Closes the current active tab
    */
    void closeTab()
    {
        if(terminalNotebook.getChildren() is null) return;
        int pages = terminalNotebook.getChildren().length;
        if(pages == 0) return;

        int current = terminalNotebook.getCurrentPage();
        Widget term = terminalNotebook.getNthPage(current);
        Widget tab = terminalNotebook.getTabLabel(term);

        term.destroy();
        tab.destroy();
    }
}