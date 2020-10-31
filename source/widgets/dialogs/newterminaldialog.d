module widgets.dialogs.newterminaldialog;

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

class NewTerminalDialog : Dialog
{
    Profile selectedProfile;
    this(Window w)
    {
        super("New terminal", w, GtkDialogFlags.MODAL, [StockID.CANCEL], [ResponseType.CANCEL]);
        setSizeRequest(300, 600);

        ScrolledWindow sw = new ScrolledWindow();
        getContentArea().add(sw);
        sw.setVexpand(true);

        // Profile list
        ListBox lb = new ListBox();
        lb.setSelectionMode(GtkSelectionMode.SINGLE);
        sw.add(lb);

        // Default profile
        auto defaultRow = new ProfileListRow(RTSettings.defaultProfile, true);
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
            selectedProfile = row.profile;
            response(ResponseType.CANCEL);
        });
    }
}