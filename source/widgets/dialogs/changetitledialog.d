module widgets.dialogs.changetitledialog;

import gtk.Dialog;
import gtk.Window;
import gtk.Entry;
import gtk.Button;

/** Dialog used to change tab's name*/
class ChangeTitleDialog : Dialog
{
    Entry entry;

    this(Window w, string name)
    {
        super("Change title", w, GtkDialogFlags.MODAL, [StockID.CANCEL, StockID.OK], [ResponseType.NO, ResponseType.OK]);
        setResizable(false);

        entry = new Entry(name);
        getContentArea().add(entry);
        entry.grabFocus();
        entry.setActivatesDefault(true);
        entry.addOnActivate(delegate(Entry e)
        {
            response(ResponseType.OK);
        });

        showAll();
    }
}