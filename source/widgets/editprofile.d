module widgets.editprofile;

import gtk.VBox;
import gtk.CheckButton;
import gtk.Entry;
import gtk.EditableIF;
import gsv.SourceView;
import gtk.Label;
import profile;
import gtk.ScrolledWindow;

class EditProfile : VBox
{
    Profile profile;
    this(Profile p)
    {
        super(false, 5);

        profile = p;

        CheckButton closeWhenEnds = new CheckButton("Close when process ends",
        delegate(CheckButton cb)
        {
            p.closeWhenProcessEnds = cb.getActive();    
        });
        closeWhenEnds.setActive(p.closeWhenProcessEnds);
        add(closeWhenEnds);

        Entry shell = new Entry();
        shell.setPlaceholderText("Shell or executable. Leave empty for default shell");
        shell.setText(p.executable);
        shell.addOnChanged(delegate(EditableIF eif)
        {
            p.executable = shell.getText();
        });
        add(shell);

        Entry path = new Entry();
        path.setPlaceholderText("Start directory. Leave empty for current");
        path.setText(p.path);
        path.addOnChanged(delegate(EditableIF eif)
        {
            p.path = path.getText();
        });
        add(path);

        // SourceView seems to be increasing the loading times
        // Edit dub.json and remove "CSSEdit" fron "-versions=" ind dflags to disable
        add(new Label("CSS"));
        version(CSSEdit)
        {
            import gsv.SourceLanguageManager;
            import gsv.SourceLanguage;

            SourceView css = new SourceView();
            css.setSizeRequest(-1, 200);
            css.setShowLineNumbers(true);
            css.setMonospace(true);
            css.getBuffer.setText(p.CSS);
            css.getBuffer().addOnChanged(delegate(TextBuffer)
            {
                p.CSS = css.getBuffer().getText();
            });
            ScrolledWindow sw = new ScrolledWindow();
            sw.setSizeRequest(-1, 200);
            sw.add(css);
            add(sw);

            SourceLanguageManager slm = new SourceLanguageManager();
		    SourceLanguage cssLang = slm.getLanguage("css");
		    if ( cssLang !is null )
		    {
		    	css.getBuffer().setLanguage(cssLang);
		    	css.getBuffer().setHighlightSyntax(true);
		    }
        }
        else
        {
            import gtk.TextView;
        
            TextView css = new TextView();
            css.setSizeRequest(-1, 200);
            css.setMonospace(true);
            //css.setPlaceholderText(".rterm-term { ... }");
            css.getBuffer.setText(p.CSS);
            css.getBuffer().addOnChanged(delegate(TextBuffer)
            {
                p.CSS = css.getBuffer().getText();
            });
            ScrolledWindow sw = new ScrolledWindow();
            sw.setSizeRequest(-1, 200);
            sw.add(css);
            add(sw);
        }      
    }
}