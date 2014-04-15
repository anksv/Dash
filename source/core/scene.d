/**
 * This module defines the Scene class, TODO
 * 
 */
module core.scene;
import core, components, graphics, utility;

import std.path;

/**
 * TODO
 */
shared final class Scene
{
private:
    GameObject root;
    
package:
    GameObject[uint] objectById;
    uint[string] idByName;

public:
    /// The camera to render with.
    Camera camera;

    this()
    {
        root = new shared GameObject;
        root.name = "[scene]";
    }

    /**
     * Load all objects inside the specified folder in FilePath.Objects.
     * 
     * Params:
     *  objectPath =            The folder location inside of /Objects to look for objects in.
     */
    final void loadObjects( string objectPath = "" )
    {
        string[shared GameObject] parents;
        string[][shared GameObject] children;

        foreach( yml; loadYamlDocuments( buildNormalizedPath( FilePath.Resources.Objects, objectPath ) ) )
        {
            // Create the object
            root.addChild( GameObject.createFromYaml( yml, parents, children ) );
        }
        
        // Make sure the child graph is complete.
        foreach( object, parentName; parents )
            this[ parentName ].addChild( object );
        foreach( object, childNames; children )
            foreach( child; childNames )
                object.addChild( this[ child ] );
    }

    /**
     * Remove all objects from the collection.
     */
    final void clear()
    {
        root = new shared GameObject;
    }

    /**
    * TODO
    */
    final void update()
    {
        root.update();
    }

    /**
    * TODO
    */
    final void draw()
    {
        root.draw();
    }

    /**
    * TODO
    */
    final shared(GameObject) opIndex( string name )
    {
        shared GameObject[] objs;

        objs ~= root;

        while( objs.length )
        {
            auto curObj = objs[ 0 ];
            objs = objs[ 1..$ ];

            if( curObj.name == name )
                return curObj;
            else
                foreach( obj; curObj.children )
                    objs ~= obj;
        }

        return null;
    }

    /**
    * TODO
    */
    final shared(GameObject) opIndex( uint index )
    {
        shared GameObject[] objs;

        objs ~= root;

        while( objs.length )
        {
            auto curObj = objs[ 0 ];
            objs = objs[ 1..$ ];

            if( curObj.id == index )
                return curObj;
            else
                foreach( obj; curObj.children )
                    objs ~= obj;
        }

        return null;
    }

    /**
    * TODO
    */
    final @property shared(GameObject[]) objects()
    {
        shared GameObject[] objs, toReturn;

        objs ~= root;

        while( objs.length )
        {
            auto temp = objs[ 0 ];
            objs = objs[ 1..$ ];
            toReturn ~= temp.children;
            objs ~= temp.children;
        }

        return toReturn;
    }
}