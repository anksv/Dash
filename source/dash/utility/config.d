/**
 * Defines the static class Config, which handles all configuration options.
 */
module dash.utility.config;
import dash.utility.resources, dash.utility.output, dash.utility.data;

import std.datetime;

/**
 * The global instance of config.
 */
private Config configInst;
/// ditto
const(Config) config() @property
{
    return configInst;
}

/**
 * Static class which handles the configuration options and YAML interactions.
 */
struct Config
{
public:
    @rename( "Logging" ) @optional
    LoggerSettings logging;
    @rename( "Display" ) @optional
    DisplaySettings display;
    @rename( "Graphics" ) @optional
    GraphicsSettings graphics;
    @rename( "UserInterface" ) @optional
    UserInterfaceSettings userInterface;
    @rename( "Editor" ) @optional
    EditorSettings editor;

    static struct LoggerSettings
    {
        @rename( "FilePath" ) @optional
        string filePath = null;
        @rename( "Debug" ) @optional
        Verbosities debug_ = Verbosities( Verbosity.Debug, Verbosity.Debug );
        @rename( "Release" ) @optional
        Verbosities release = Verbosities( Verbosity.Off, Verbosity.High );

        static struct Verbosities
        {
            @rename( "OutputVerbosity" ) @optional @byName
            Verbosity outputVerbosity = Verbosity.Low;
            @rename( "LoggingVerbosity" ) @optional @byName
            Verbosity loggingVerbosity = Verbosity.Debug;
        }
    }

    static struct DisplaySettings
    {
        @rename( "Fullscreen" )
        bool fullscreen;
        @rename( "Height" ) @optional
        uint height = 1920;
        @rename( "Width" ) @optional
        uint width = 720;
    }

    static struct GraphicsSettings
    {
        @rename( "BackfaceCulling" ) @optional
        bool backfaceCulling = true;
        @rename( "VSync" ) @optional
        bool vsync = false;
    }

    static struct UserInterfaceSettings
    {
        @rename( "FilePath" ) @optional
        string filePath = null;
    }

    static struct EditorSettings
    {
        @rename( "Port" ) @optional
        ushort port = 8080;
        @rename( "Route" ) @optional
        string route = "ws";
    }

static:
    @ignore
    private Resource resource = Resource( "" );

    void initialize()
    {
        auto res = deserializeFileByName!Config( Resources.ConfigFile );
        configInst = res[ 0 ];
        resource = res[ 1 ];
    }

    void refresh()
    {
        if( resource.needsRefresh )
        {
            configInst = deserializeFile!Config( resource );
        }
    }
}

/**
 * TODO
 */
T constructConv( T )( ref Node node ) if( is( T == enum ) )
{
    if( node.isScalar )
    {
        return node.get!string.to!T;
    }
    else
    {
        throw new Exception( "Enum must be represented as a scalar." );
    }
}

version( unittest )
{
    import std.string;
    /// The string to store test yaml content in.
    string testYML = q{---
Config:
    Input:
        Forward:
            Keyboard: W
        Backward:
            Keyboard: S
        Jump:
            Keyboard: Space
    Config:
        Logging:
            FilePath: "dash.log"
            Debug:
                OutputVerbosity: !Verbosity Debug
                LoggingVerbosity: !Verbosity Debug
            Release:
                OutputVerbosity: !Verbosity Medium
                LoggingVerbosity: !Verbosity Medium
        Display:
            Fullscreen: false
            Height: 720
            Width: 1280
        Graphics:
            BackfaceCulling: true
            VSync: false
        Physics:
            Gravity: !Vector3 0.0 -10.0 0.0
        UserInterface:
            FilePath: "uitest.html"
            Scale: !Vector2 1.0 1.0
    };
}