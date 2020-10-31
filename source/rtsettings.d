module rtsettings;
import profile;
import std.process;
import std.file;
import yajl;

/** Contains user settings and profiles */
static class RTSettings
{
    static this()
    {
        loadConfig();
    }

    /** Settings describing RTerm behaviour */
    static Settings userSettings;

    /** Default terminal profile*/
    static Profile defaultProfile;

    /** Custom terminal profiles*/
    static Profile[] customProfiles;
}

/** Contains settings */
class Settings
{
    /** If true, when RTerm launches, a new default terminal is automatically created */
    bool startWithNewTerminal = true;

    /** Closes RTerm when all tabs are closed */
    bool closeWhenNoTerminals = true;
}

/** Loads config file and profiles */
void loadConfig()
{
    if(!exists(getConfigPath())) mkdirRecurse(getConfigPath());

    string settingsPath = getConfigPath() ~ "/settings.json";
    if(exists(settingsPath))
    {
        auto json = readText(settingsPath);
        RTSettings.userSettings = decode!Settings(json);
    }
    else RTSettings.userSettings = new Settings();

    /* TODO:    Default profile can be customized by distibutions
                e.g. Gentoo 'branding' useflag will make the background CSS purple
                Default profile template will be stored in /usr/share/rterm/default.json
                If no default.json file is found in the config directory, it will be copied
    */
    string defaultPath = getConfigPath() ~ "/default.json";
    if(exists(defaultPath))
    {
        auto json = readText(defaultPath);
        RTSettings.defaultProfile = decode!Profile(json);
    }
    else RTSettings.defaultProfile = new Profile();

    auto profilePath = getConfigPath() ~ "/profiles";
    if(!exists(profilePath)) mkdir(profilePath);
    auto profileFiles = dirEntries(profilePath,"*.json",SpanMode.shallow);
    RTSettings.customProfiles = [];
    foreach (prof; profileFiles)
    {
        Profile p = decode!Profile(readText(prof));
        RTSettings.customProfiles ~= p;
    }
}

string getConfigPath()
{
    version(linux) return environment.get("XDG_CONFIG_HOME", environment.get("HOME") ~ "/.config") ~ "/rterm";
    // TODO: Config paths for OSX and Windows
    else version(OSX) return "";
    else version(Windows) return "";
    else return "";
}

/** Saves settings to a config file */
void saveSettings()
{
    auto json = encode(RTSettings.userSettings);
    write(getConfigPath() ~ "/settings.json", json);
}

/** Saves profiles to a config file */
void saveProfiles()
{
    auto defaultJSON = encode(RTSettings.defaultProfile);
    write(getConfigPath() ~ "/default.json", defaultJSON);

    // TODO: Save custom profiles
}