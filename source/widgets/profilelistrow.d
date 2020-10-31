module widgets.profilelistrow;


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
import profile;
import widgets.editprofile;

class ProfileListRow : ListBoxRow
{
    Profile profile;
    EditProfile edit;
    this(Profile p, EditProfile ep, bool isDefault = false)
    {
        edit = ep;
        this(p, isDefault);
    }

    this(Profile p, bool isDefault = false)
    {
        super();
        
        profile = p;
        
        setSizeRequest(-1, 50);
        add(new Label(p.name));
    }
}