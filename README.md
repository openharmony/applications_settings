# Settings<a name="EN-US_TOPIC_0000001103554544"></a>

-   [Introduction](#section11660541593)
    -   [Architecture](#section48896451454)

-   [Directory Structure](#section161941989596)
-   [Repositories Involved](#section1371113476307)

## Introduction<a name="section11660541593"></a>
The Settings application is a preinstalled system app in OpenHarmony, providing users with essential configuration features including homepage search, WLAN, Bluetooth, and mobile network settings, multi-device collaboration, home screen and personalization, notification and status bar controls, display and brightness adjustment, sound and vibration management, application settings, biometric recognition and password setup, battery and storage management, system configurations, about device information, and developer options.
### Architecture<a name="section48896451454"></a>

![](figures/en-us_image_0000001153225717.png)

## Directory Structure<a name="section161941989596"></a>

```
/applications/standard/settings
├─ product
│  └─ phone
│     └─ src
│        └─ main
│           ├─ ets
│              ├─ Application  # ETS logic and application lifecycle management
│              ├─ MainAbility  # Directory for Ability and ExtentionAbility
│              ├─ pages        # Directory for page components
│              ├─ Setting      # Directory for setting items
│              ├─ stub         # Directory for settings service stubs
│              ├─ utils        # Directory for public utilities
│           ├─ resources       # Directory for resource files
├─ native                      # Directory for kernel-native related code
├─ feature                     # Directory for feature module business logic
├─ common                      # Directory for common utilities
├─ LICENSE                     # License file
├─ signature                   # Directory for certificate files                  
```

## Repositories Involved<a name="section1371113476307"></a>

[**Setings**](https://gitcode.com/openharmony/applications_settings)
[**SetingsData**](https://gitcode.com/openharmony/applications_settings_data)

