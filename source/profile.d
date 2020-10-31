module profile;

import gdk.RGBA;
import std.stdio;

/**
Information about a terminal
*/
class Profile
{
    /** Profile name */
    string name = "Default";
    /** Default terminal font color*/
    Color foreground;
    /** Terminal color palette
        0-7 - Regular colors
        8-15 - Bold colors
        16- 231 -  6x6x6 color cube
        232 - 256 - 24 grayscale colors
        null = default color */
    Color[] palette;
    /** GTK CSS*/
    string CSS;
    /** Path to the executable*/
    string executable;
    /** Path to start in*/
    string path;
    /** List of enviroment variables in the following format NAME=value */
    string[] envVars;
    /** If true, terminal closes itself, when the child process ends */
    bool closeWhenProcessEnds = true;
}

/** Workaround for not being able to deserialize Gdk.RGBA */
class Color
{
    double R, G, B, A;

    /** Converts Gdk.RGBA to Profile.Color */
    static Color fromGdk(RGBA rgba)
    {
        if(!rgba) return null; 
        auto c = new Color();
        c.R = rgba.red;
        c.G = rgba.green;
        c.B = rgba.blue;
        c.A = rgba.alpha;  
        return c;
    }

    /** Converts Profile.Color to Gdk.RGBA */
    RGBA toGdk()
    {
        return new RGBA(R,G,B,A);
    }

}

/** Converts Profile.Color[] to Gdk.RGBA[] */
RGBA[] colorArrayToGdkArray(Color[] c)
{
    if(!c) return null;

    RGBA[] array;
    array.length = c.length;
    for(int i = 0; i<c.length; i++)
    {
        array[i] = c[i].toGdk();
    }

    return array;
}