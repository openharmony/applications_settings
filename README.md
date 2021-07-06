# Settings<a name="EN-US_TOPIC_0000001103421572"></a>

-   [Introduction](#section11660541593)
    -   [Architecture](#section48896451454)

-   [Directory Structure](#section161941989596)
-   [Repositories Involved](#section1371113476307)

## Introduction<a name="section11660541593"></a>

Settings is a system app preinstalled in OpenHarmony to provide an interactive UI for users to set system attributes, such as the system time and screen brightness.

### Architecture<a name="section48896451454"></a>

![](figures/en-us_image_0000001153225717.png)

## Directory Structure<a name="section161941989596"></a>

```
/applications/standard/settings
├── figures                # Architecture figures
├── entry                  # Main entry module code
│    ├── src
│      ├── main
│        └── js            # JavaScript code
│        └── resources     # Resources
│        └── config.json   # Global configuration files
├── signature              # Certificate files
├── LICENSE                # License files
```

## Repositories Involved<a name="section1371113476307"></a>

System apps

**applications\_settings**

