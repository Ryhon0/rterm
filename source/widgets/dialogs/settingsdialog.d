module widgets.dialogs.settingsdialog;

import gtk.Dialog;
import gtk.Window;
import gtk.Entry;
import gtk.Button;
import gtk.ScrolledWindow;
import gtk.VBox;
import gtk.HBox;
import gtk.CheckButton;
import rtsettings;
import gtk.Viewport;
import gtk.Stack;
import gtk.ListBox;
import gtk.Label;
import gtk.ListBoxRow;
import gtk.Separator;
import widgets.editprofile;
import profile;
import widgets.profilelistrow;

/** Dialog with settings*/
class SettingsDialog : Dialog
{
    this(Window w)
    {
        super("Settings", w, GtkDialogFlags.MODAL, [StockID.OK, StockID.SAVE], [ResponseType.NONE, ResponseType.OK]);

        addOnResponse(delegate(int i, Dialog d)
        {
            if(i == ResponseType.OK)
            {
                saveSettings();
                saveProfiles();
            }
            destroy();
        });
        setDefaultSize(600, 400);

        ScrolledWindow sw = new ScrolledWindow();
        sw.setVexpand(true);
        sw.setPolicy(GtkPolicyType.NEVER, GtkPolicyType.AUTOMATIC);
        sw.setValign(GtkAlign.FILL);
        getContentArea().add(sw);
        VBox vb = new VBox(false, 5);
        vb.setVexpand(false);
        vb.setValign(GtkAlign.START);
        vb.setMarginLeft(10);
        vb.setMarginRight(10);
        vb.setMarginTop(5);
        sw.addWithViewport(vb);
        
        // Create a terminal on start
        CheckButton termOnStart = new CheckButton("Create a terminal on start",
        delegate(CheckButton cb)
        {
            RTSettings.userSettings.startWithNewTerminal = cb.getActive();
        });
        termOnStart.setActive(RTSettings.userSettings.startWithNewTerminal);
        vb.add(termOnStart);

        // Close when no terminals open
        CheckButton closeNoTerm = new CheckButton("Close when no terminals left",
        delegate(CheckButton cb)
        {
            RTSettings.userSettings.closeWhenNoTerminals = cb.getActive();
        });
        closeNoTerm.setActive(RTSettings.userSettings.closeWhenNoTerminals);
        vb.add(closeNoTerm);
        
        // Profiles
        vb.add(new Label("Profiles"));
        HBox hb = new HBox(false, 0);
        vb.add(hb);
        ListBox lb = new ListBox();
        lb.setSelectionMode(GtkSelectionMode.BROWSE);
        hb.add(lb);
        Stack profilesStack = new Stack();
        profilesStack.setTransitionType(GtkStackTransitionType.SLIDE_UP_DOWN);
        hb.add(profilesStack);

        // Default profile
        EditProfile editDefault = new EditProfile(RTSettings.defaultProfile);
        profilesStack.add(editDefault);
        auto defaultRow = new ProfileListRow(RTSettings.defaultProfile, editDefault, true);
        lb.add(defaultRow);
        lb.selectRow(defaultRow);

        // Custom profiles
        foreach(profile; RTSettings.customProfiles)
        {
            EditProfile edit = new EditProfile(profile);
            profilesStack.add(edit);
            auto row = new ProfileListRow(profile, edit);
            lb.add(row);
        }

        // Switch to stack child
        lb.addOnRowSelected(delegate(ListBoxRow lbr, ListBox lb)
        {
            ProfileListRow row = cast(ProfileListRow)lbr;
            profilesStack.setVisibleChild(row.edit);
        }); 

        showAll();
    }
}