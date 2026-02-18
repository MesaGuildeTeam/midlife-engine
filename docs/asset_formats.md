# Asset Formats
When you want to create certain scenes, it is easier to use tools that organize
data for these scenes. We will create tools for this, but to organize the data,
we will use json to organize the data, but we will have a sub-extension for 
files using these types to avoid confusing the json files together.

One *hypothetical* example would be generic data being stored as a `.gen.json`
file. In this case, a file could be called `genericData.gen.json`. The file is
still JSON, but it is organized in 

# Scenes
Scenes are reccomended to use the extension `.scene.json`, and will have data
stored as the following

```json
{
    "scene": [
        {
            "type": NodeType,
            "name": String,
            "params": Dynamic,
            "children": []
        }
    ]
}
```

# Signed Distance Fields
Because these meshes can get compicated due to their recursive structure, they
are possible to organize in .json files too. SDF models are recommended to use
the extension `.sdf.json` and be stored as follows:

```json
{
    "root": {
        "type": SDFType,
        "params": Dynamic,
        "children": []
    }
}
```

> **Warning:**
>
> only use the children parameter if the sdf type is a form of additive booleans 

# Spritesheets
These are just an array of rectangles. These are not a big issue for storing data. These will be stored as a `.ss.csv`
```csv
TopLeftX,TopLeftY,BottomRightX,BottomRightY
```