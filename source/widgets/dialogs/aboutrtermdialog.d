module widgets.dialogs.aboutrtermdialog;

import std.compiler;
import std.conv;
import gtk.AboutDialog;
import gtk.Window;
import gtk.Entry;
import gtk.Button;
import gdk.Pixbuf;
import gtk.Application;
import gtk.Window;

class AboutRTermDialog : AboutDialog
{
    this(Application app)
    {
        super();

        setApplication(app);
        setLogoIconName("terminal");
        setProgramName("RTerm");
        setTitle("About RTerm");

        setAuthors(["Ryhon"]);
        setArtists(["Ryhon"]);
        setWebsite("https://github.com/Ryhon0/rterm");
        setCopyright("Copyright © 2020, Ryhon");
        setLicenseType(GtkLicense.GPL_3_0);
        setVersion(name ~ " v" ~ to!string(version_major) ~ "." ~ to!string(version_minor));

        addActionWidget(new Button(StockID.OK), ResponseType.OK);
    }
}