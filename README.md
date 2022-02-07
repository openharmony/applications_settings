# Settings<a name="EN-US_TOPIC_0000001103554544"></a>

-   [Introduction](#section11660541593)
    -   [Architecture](#section48896451454)

-   [Directory Structure](#section161941989596)
-   [Repositories Involved](#section1371113476307)

## Introduction<a name="section11660541593"></a>
The Settings is a system application prebuilt in OpenHarmony. It provides a human-machine interactions entry for users to set system configs like settings system time, lightness of screen and etc.

### Architecture<a name="section48896451454"></a>

![](figures/en-us_image_0000001153225717.png)

## Directory Structure<a name="section161941989596"></a>

```
/applications/standard/settings
├── entry             # main entry module
│   └── src
│       ├── main
│           ├── ets               # ets module
│               ├── default
│                   ├── common    # common code and utils
│                   ├── model     # data management and logic control
│                   ├── pages     # code of view components
│                   ├── res       # some image resources
│                   ├── resources # other resources
│                   ├── app.ets   # main process
│           ├── resources         # resources configs
│               ├── base          # default language, image resources, font size and colors
│               ├── en_AS.element # English resources
│               ├── rawfile       # local configs
│               ├── zh_CN.element # Chinese resources
│           └── config.json       # global configs
├── signature              # Certificate files
├── LICENSE                # Copyright license file
```

## Repositories Involved<a name="section1371113476307"></a>

System apps

**applications\_settings**

