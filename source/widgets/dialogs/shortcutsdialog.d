module widgets.dialogs.shortcutsdialog;

import std.stdio;
import std.typecons;
import gtk.Dialog;
import gtk.Window;
import gtk.VBox;
import gtk.HBox;
import gtk.ShortcutLabel;
import gtk.Label;

/** Windows containging all keyboard shortcuts*/
class ShortcutsDialog : Dialog
{
    this(Window w)
    {
        super("Shortcuts", w, GtkDialogFlags.MODAL, [StockID.OK], [ResponseType.OK]);

        VBox vb = new VBox(false, 5);

        auto shortcuts =
        [
            tuple("<Control>N", "New default terminal"),
            tuple("<Control><Shift>N", "New terminal"),
            tuple("<Control><Shift>Right", "Next terminal"),
            tuple("<Control><Shift>Left", "Previous terminal"),
            tuple("<Control>W", "Close current terminal"),
            tuple("<Control>Plus", "Bigger font size"),
            tuple("<Control>Minus", "Smaller font size"),
            tuple("<Control><Shift>C", "Copy text"),
            tuple("<Control><Shift><Alt>C", "Copy text as HTML"),
            tuple("<Control><Shift>C", "Paste text")
        ];

        foreach (shortcut; shortcuts)
        {
            vb.add(new Shortcut(shortcut[0], shortcut[1]));
        }

        addOnResponse(delegate(int i, Dialog d)
        {
            destroy();
        });

        getContentArea.add(vb);
        vb.showAll();
        showAll();
    }
}

class Shortcut : HBox
{
    this(string accel, string text)
    {
        super(true, 0);

        add(new ShortcutLabel(accel));
        add(new Label(text));
        showAll();
    }
}