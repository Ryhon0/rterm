module main;

import mainwindow;

import std.stdio;
import vte.Terminal;
import gtk.Window;
import gio.Application : GioApplication = Application;
import gtk.Application;
import std.process;

int main(string[] args)
{
	auto application = new Application("ga.ryhon.rterm", GApplicationFlags.FLAGS_NONE);

	application.addOnActivate(delegate void(GioApplication app) 
	{
		MainWindow window = new MainWindow(application);
		window.setApplication(application);
		window.showAll();

		/* TODO: 	Depending on user settings or args:
					When rterm is launched and another process already has a window
					- Open a new tab in a that window
					- Open a new window
		/* 
			auto windows = application.getWindows();

			// If another window is already open
			if(windows)
			{
				
			}
			else
			{
				
			}
		*/
	});

	// TODO: Add handle commandline arguments
	return application.run(args);
}   