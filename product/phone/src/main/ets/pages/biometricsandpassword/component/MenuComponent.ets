/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { CommonModifier } from '@kit.ArkUI';
import {
  FOCUS_BOX_PADDING_METRICS,
  PADDING_0,
  PADDING_8
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { AccessibilityLevelType } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EntryType, MenuEntry, ObservedMenuEntry } from './MenuEntry';

/* instrument ignore file */
const TAG: string = 'MenuComponent: ';

const MAX_LINES_10: number = 10;
const BACKGROUND_COLOR = 'rgba(10, 89, 247, 0.1)'

/**
 * 通用menu模板
 */
@Component
export struct MenuComponent {
  @ObjectLink @Watch('onUpdate') entryMenus: ObservedMenuEntry;

  build() {
    if (this.entryMenus.visible) {
      Column() {
        if (this.entryMenus?.showHeader) {
          List() {
            ListItem() {
              Row() {
                Text(this.entryMenus?.headerText)
                  .headerTitleTextStyle()
              }
              .width('100%')
              .constraintSize({
                minHeight: '36vp',
              })
              .padding({
                top: '0vp',
                bottom: '0vp',
                left: $r('sys.float.ohos_id_default_padding_start'),
                right: $r('sys.float.ohos_id_default_padding_end'),
              })
              .alignItems(VerticalAlign.Bottom)
              .justifyContent(FlexAlign.Start)
            }
          }
          .headerListStyle()
        }

        List() {
          ForEach(this.entryMenus?.menus, (menu: MenuEntry, index: number) => {
            ListItem() {
              if (menu?.menuType === EntryType.TEXT) {
                TextComponent({
                  menu: menu,
                  index: index,
                })
              } else if (menu?.menuType === EntryType.SWITCH) {
                SwitchComponent({
                  menu: menu,
                  index: index,
                })
              } else if (menu?.menuType === EntryType.ENTRY) {
                EntryComponent({
                  menu: menu,
                  index: index,
                })
              } else if (menu?.menuType === EntryType.MULTI_ENTRY) {
                if (FontScaleUtils.isExtraLargeFontMode()) {
                  MultiLargeEntryComponent({
                    menu: menu,
                    index: index,
                  })
                } else {
                  MultiEntryComponent({
                    menu: menu,
                    index: index,
                  })
                }
              } else if (menu?.menuType === EntryType.IDENTIFY_ENTRY) {
                FgIdTextComponent({
                  menu: menu,
                  index: index,
                })
              } else if (menu?.menuType === EntryType.UNDER_IDENTIFY_ENTRY) {
                FgUnderIdTextComponent({
                  menu: menu,
                  index: index,
                })
              }
            }
          }, (menu: MenuEntry) => {
            return JSON.stringify(menu);
          })
        }
        .listStyle()
      }
      .width('100%')
      .margin({
        bottom: $r('app.float.wh_value_12'),
      })
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  onUpdate(): void {
    LogUtil.info(`${TAG} onUpdate`);
  }
}

@Component
export struct FigMenuComponent {
  @ObjectLink @Watch('onUpdate') entryMenus: ObservedMenuEntry;
  scroller: Scroller = new Scroller();

  build() {
    if (this.entryMenus.visible) {
      Scroll(this.scroller) {
        Column() {
          if (this.entryMenus?.showHeader) {
            List() {
              ListItem() {
                Row() {
                  Text(this.entryMenus?.headerText)
                    .headerTitleTextStyle()
                }
                .width('100%')
                .constraintSize({
                  minHeight: '36vp',
                })
                .padding({
                  top: '0vp',
                  bottom: '0vp',
                  left: $r('sys.float.ohos_id_default_padding_start'),
                  right: $r('sys.float.ohos_id_default_padding_end'),
                })
                .alignItems(VerticalAlign.Bottom)
                .justifyContent(FlexAlign.Start)
              }
            }
            .headerListStyle()
          }

          List() {
            ForEach(this.entryMenus?.menus, (menu: MenuEntry, index: number) => {
              ListItem() {
                FgUnderIdTextComponent({
                  menu: menu,
                  index: index,
                })
              }
            }, (menu: MenuEntry) => {
              return JSON.stringify(menu);
            })
          }
          .listStyle()
        }
        .width('100%')
        .margin({
          bottom: $r('app.float.wh_value_12'),
        })
      }
      .scrollBar(BarState.Off)
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  onUpdate(): void {
    LogUtil.info(`${TAG} onUpdate`);
  }
}

@Component
export struct FgIdMenuComponent {
  @ObjectLink @Watch('onUpdate') entryMenus: ObservedMenuEntry;
  build() {
    if (this.entryMenus.visible) {
      Column() {
        List() {
          ForEach(this.entryMenus?.menus, (menu: MenuEntry, index: number) => {
            ListItem() {
              FgIdTextComponent({
                menu: menu,
                index: index,
              })
            }
          })
        }.fgIdListStyle()
      }
      .width('100%')
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  onUpdate(): void {
    LogUtil.info(`${TAG} onUpdate`);
  }
}

@Component
struct SwitchComponent {
  @ObjectLink menu?: MenuEntry;
  index: number = -1;
  throttleFlag: boolean = true;
  throttleDelay: number = 10;
  throttleTimerId: number = 0;

  aboutToDisappear(): void {
    if (this.throttleTimerId !== 0) {
      clearTimeout(this.throttleTimerId);
    }
  }

  private onTouchInterceptInner(): void {
    if (this.throttleFlag) {
      this.throttleFlag = false;

      if (this.menu?.touchInterceptCallback) {
        this.menu?.touchInterceptCallback();
      }
      this.throttleTimerId = setTimeout(() => {
        this.throttleFlag = true;
        this.throttleTimerId = 0;
      }, this.throttleDelay)
    }
  }

  @Builder
  toggleContent() {
    Toggle({ type: ToggleType.Switch, isOn: this.menu?.state })
      .width($r('app.float.wh_value_36'))
      .height($r('app.float.wh_value_20'))
      .onChange((isOn: boolean) => {
        if (this.menu?.onSwitchChanged) {
          this.menu?.onSwitchChanged(isOn, this.index);
        }
      })
      .margin({
        top: $r('app.float.margin_0'),
        bottom: $r('app.float.margin_0'),
      })
      .hoverEffect(HoverEffect.None)
      .enabled(this.menu?.enabled as boolean)
      .onTouchIntercept((event : TouchEvent) => {
        if (this.menu?.isNeedTouchIntercept) {
          this.onTouchInterceptInner();
          return HitTestMode.None;
        }
        return HitTestMode.Default;
      })
  }

  @Styles
  switchMenu() {
    .width('100%')
    .padding({
      left: $r('app.float.padding_12'),
      right: $r('app.float.padding_12')
    })
    .constraintSize({
      minHeight: this.menu?.subTitle ? $r('app.float.wh_value_64') : $r('app.float.wh_value_48')
    })
    .accessibilityDescription(this.getAccessibilityDescription())
    .onClick(() => {
      if (this.menu?.onMenuClick) {
        this.menu?.onMenuClick(this.index);
      }
    })
  }

  build() {
    Row() {
      Row() {
        if (FontScaleUtils.getFontScaleSize() < FontScaleUtils.EXTRA_LARGE_FONT_1) {
          Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
            Column() {
              Text(this.menu?.title)
                .primarySwitchText(this.menu?.enabled as boolean)
              if (this.menu?.subTitle) {
                Text(this.menu?.subTitle)
                  .secondarySwitchText(this.menu?.enabled as boolean)
              }
            }

            Column() {
              this.toggleContent();
            }
            .flexGrow(1)
            .alignItems(HorizontalAlign.End);
          }
          .width('100%')
        } else {
          Column() {
            Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween,
              alignItems: ItemAlign.Center }) {
              Text(this.menu?.title)
                .primarySwitchText(this.menu?.enabled as boolean)
              Column() {
                this.toggleContent();
              }
              .flexGrow(1)
              .alignItems(HorizontalAlign.End);
            }

            if (this.menu?.subTitle) {
              Row() {
                Text(this.menu?.subTitle)
                  .secondarySwitchText(this.menu?.enabled as boolean)
              }
              .width('100%')
            }
          }
        }
      }
      .align(Alignment.Center)
      .padding({
        top: this.menu?.subTitle ? $r('app.float.wh_value_10') : $r('app.float.wh_value_13'),
        bottom: this.menu?.subTitle ? $r('app.float.distance_11') : $r('app.float.wh_value_14')
      })
      .width('100%')
    }
    .switchMenu()
    .focusable(this.menu?.enabled)
  }

  private getAccessibilityDescription(): string {
    if (!this.menu?.onMenuClick) {
      return ' ';
    }
    return '';
  }
}

@Component
struct TextComponent {
  menu?: MenuEntry;
  index: number = -1;

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Column() {
          Text(this.menu?.title)
            .fontColor(this.menu?.style?.fontColor ? this.menu.style.fontColor : $r('sys.color.ohos_id_color_text_primary'))
            .fontSize(this.menu?.style?.fontSize ? this.menu.style.fontSize : $r('sys.float.ohos_id_text_size_body1'))
            .fontWeight(this.menu?.style?.fontWeight ? this.menu.style.fontWeight : FontWeight.Medium)
        }
        .padding({ top: FontScaleUtils.getCurrentPadding(), bottom: FontScaleUtils.getCurrentPadding() })
        .alignItems(HorizontalAlign.Start);
      }
      .flexStyle()
      .hoverEffect(HoverEffect.Highlight)
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
      .onClick(() => {
        if (this.menu?.onMenuClick) {
          this.menu?.onMenuClick(this.index);
        }
      })
      .focusBox({
        margin: FOCUS_BOX_PADDING_METRICS
      })
    }
    .padding({
      left: $r('app.float.padding_4'),
      right: $r('app.float.padding_4'),
      top: $r('app.float.margin_0'),
      bottom: $r('app.float.margin_0')
    })
  }
}

@Component
struct EntryComponent {
  @Prop menu: MenuEntry;
  index: number = -1;

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Column() {
          Text(this.menu?.title)
            .fontColor(this.menu?.style?.fontColor ? this.menu.style.fontColor : $r('sys.color.ohos_id_color_text_primary'))
            .fontSize(this.menu?.style?.fontSize ? this.menu.style.fontSize : $r('sys.float.ohos_id_text_size_body1'))
            .fontWeight(this.menu?.style?.fontWeight ? this.menu.style.fontWeight : FontWeight.Medium)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(MAX_LINES_10);
        }
        .padding({
          top: FontScaleUtils.getCurrentTopPadding(),
          bottom: FontScaleUtils.getCurrentTopPadding()
        })
        .flexGrow(1)
        .alignItems(HorizontalAlign.Start);

        Image($r('app.media.ic_settings_arrow'))
          .size({
            width: '12vp',
            height: '24vp',
          })
          .margin({
            start: PADDING_8,
            top: PADDING_0,
            bottom: PADDING_0,
          })
          .draggable(false)
          .matchTextDirection(true);
      }
      .flexStyle()
      .hoverEffect(HoverEffect.Highlight)
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
      .focusBox({
        margin: FOCUS_BOX_PADDING_METRICS
      })
      .onClick(() => {
        if (this.menu?.onMenuClick) {
          this.menu?.onMenuClick(this.index);
        }
      })
    }.padding({
      left: $r('app.float.padding_4'),
      right: $r('app.float.padding_4'),
      top: $r('app.float.margin_0'),
      bottom: $r('app.float.margin_0')
    })
  }
}

@Component
struct MultiLargeEntryComponent {
  @Prop menu: MenuEntry;
  index: number = -1;

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
  }

  build() {
    Column() {
      Column() {
        Column() {
          Text(this.menu?.title)
            .fontColor(this.menu?.style?.fontColor ? this.menu.style.fontColor : $r('sys.color.ohos_id_color_text_primary'))
            .fontSize(this.menu?.style?.fontSize ? this.menu.style.fontSize : $r('sys.float.ohos_id_text_size_body1'))
            .fontWeight(this.menu?.style?.fontWeight ? this.menu.style.fontWeight : FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .wordBreak(WordBreak.BREAK_WORD)
            .width('90%')
        }
        .width('100%')
        .padding({ top: FontScaleUtils.getCurrentPadding(),
          left: $r('app.float.padding_8'),
          right: $r('app.float.padding_8')
        })
        .alignItems(HorizontalAlign.Start);
        Row() {
          Text(this.menu?.subTitle)
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
            .width('90%')
            .textAlign(TextAlign.Start)
          Image($r('app.media.ic_settings_arrow'))
            .size({
              width: '12vp',
              height: '24vp',
            })
            .margin({
              start: PADDING_8,
              top: PADDING_0,
              bottom: PADDING_0,
            })
            .draggable(false)
            .matchTextDirection(true);
        }
        .padding({
          bottom: FontScaleUtils.getCurrentPadding(),
          left: $r('app.float.padding_8'),
          right: $r('app.float.padding_8'),
        })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .width('100%')
      }
      .hoverEffect(HoverEffect.Highlight)
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
      .onClick(() => {
        if (this.menu?.onMenuClick) {
          this.menu?.onMenuClick(this.index);
        }
      })
      .focusBox({
        margin: FOCUS_BOX_PADDING_METRICS
      })
    }
    .margin({
      left: $r('app.float.padding_4'),
      right: $r('app.float.padding_4'),
    })
  }
}

@Component
struct MultiEntryComponent {
  @Prop menu: MenuEntry;
  index: number = -1;

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Column() {
          Text(this.menu?.title)
            .fontColor(this.menu?.style?.fontColor ? this.menu.style.fontColor : $r('sys.color.ohos_id_color_text_primary'))
            .fontSize(this.menu?.style?.fontSize ? this.menu.style.fontSize : $r('sys.float.ohos_id_text_size_body1'))
            .fontWeight(this.menu?.style?.fontWeight ? this.menu.style.fontWeight : FontWeight.Medium)
        }
        .flexGrow(1)
        .alignItems(HorizontalAlign.Start);

        Text(this.menu?.subTitle)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))

        Image($r('app.media.ic_settings_arrow'))
          .size({
            width: '12vp',
            height: '24vp',
          })
          .margin({
            start: PADDING_8,
            top: PADDING_0,
            bottom: PADDING_0,
          })
          .draggable(false)
          .matchTextDirection(true);
      }
      .flexStyle()
      .hoverEffect(HoverEffect.Highlight)
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
      .onClick(() => {
        if (this.menu?.onMenuClick) {
          this.menu?.onMenuClick(this.index);
        }
      })
      .focusBox({
        margin: FOCUS_BOX_PADDING_METRICS
      })
    }.padding({
      left: $r('app.float.padding_4'),
      right: $r('app.float.padding_4'),
      top: $r('app.float.margin_0'),
      bottom: $r('app.float.margin_0')
    })
  }
}

class ClickModifier extends CommonModifier {
  private index: number = -1;
  private onMenuClick?: (index: number) => void;

  constructor(index: number, onMenuClick?: (index: number) => void) {
    super();
    this.index = index;
    this.onMenuClick = onMenuClick;
  }

  applyNormalAttribute(instance: CommonAttribute): void {
    if (this.onMenuClick) {
      instance.onClick(() => {
        if (this.onMenuClick) {
          this.onMenuClick(this.index);
        }
      });
    }
  }
}

@Component
struct FgIdTextComponent {
  @Prop menu?: MenuEntry;
  index: number = -1;
  clickModifier: ClickModifier = new ClickModifier(this.index, this.menu?.onMenuClick);

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.interactive_click'))
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Column() {
          Text(this.menu?.title)
            .fontColor(this.menu?.style?.fontColor ? this.menu.style.fontColor : $r('sys.color.font_primary'))
            .fontSize(this.menu?.style?.fontSize ? this.menu.style.fontSize : $r('sys.float.ohos_id_text_size_body1'))
            .fontWeight(this.menu?.style?.fontWeight ? this.menu.style.fontWeight : FontWeight.Medium)
            .padding({
              left: $r('sys.float.padding_level6'),
              right: $r('sys.float.padding_level6'),
            })
            .accessibilityLevel(AccessibilityLevelType.NO)
        }
        .padding({
          top: FontScaleUtils.getCurrentTopPadding(),
          bottom: FontScaleUtils.getCurrentTopPadding()
        })
        .alignItems(HorizontalAlign.Start);
      }
      .borderRadius($r('sys.float.corner_radius_level8'))
      .fgIdFlexStyle()
      .hoverEffect(HoverEffect.Highlight)
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
      .accessibilityText(this.menu?.title)
      .accessibilityLevel(AccessibilityLevelType.YES)
      .backgroundColor(this.menu?.isTouch ? BACKGROUND_COLOR : Color.Transparent)
      .attributeModifier(this.clickModifier)
    }
  }
}

@Component
struct FgUnderIdTextComponent {
  @Prop menu?: MenuEntry;
  index: number = -1;
  clickModifier: ClickModifier = new ClickModifier(this.index, this.menu?.onMenuClick);

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.interactive_click'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Column() {
          Text(this.menu?.title)
            .fontColor(this.menu?.style?.fontColor ? this.menu.style.fontColor : $r('sys.color.font_primary'))
            .fontSize(this.menu?.style?.fontSize ? this.menu.style.fontSize : $r('sys.float.ohos_id_text_size_body1'))
            .fontWeight(this.menu?.style?.fontWeight ? this.menu.style.fontWeight : FontWeight.Medium)
            .accessibilityLevel(AccessibilityLevelType.NO)
        }
        .alignItems(HorizontalAlign.Start)
        .padding({
          top: FontScaleUtils.getCurrentTopPadding(),
          bottom: FontScaleUtils.getCurrentTopPadding()
        });
      }
      .flexStyle()
      .hoverEffect(HoverEffect.Highlight)
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
      .backgroundColor(this.menu?.isTouch ? BACKGROUND_COLOR : Color.Transparent)
      .accessibilityText(this.menu?.title)
      .accessibilityLevel(AccessibilityLevelType.YES)
      .attributeModifier(this.clickModifier)
    }
    .padding({
      left: $r('app.float.padding_4'),
      right: $r('app.float.padding_4'),
      top: $r('app.float.margin_0'),
      bottom: $r('app.float.margin_0')
    })
  }
}

/**
 * 默认header文本样式
 */
@Extend(Text)
function headerTitleTextStyle() {
  .fontColor($r('sys.color.ohos_id_color_text_secondary'))
  .font({
    size: $r('sys.float.ohos_id_text_size_sub_title3'),
    weight: FontWeight.Medium,
  })
  .margin({
    top: '7.5vp',
    bottom: '9.5vp',
  })
  .accessibilityDescription($r('app.string.title'))
}

@Extend(List)
function headerListStyle() {
  .clip(false)
}

@Extend(List)
function listStyle() {
  .divider({
    strokeWidth: $r('app.float.wh_value_0_5'),
    color: $r('sys.color.ohos_id_color_list_separator'),
    startMargin: $r('sys.float.ohos_id_default_padding_start'),
    endMargin: $r('sys.float.ohos_id_default_padding_end'),
  })
  .padding({
    top: $r('app.float.wh_value_4'),
    bottom: $r('app.float.wh_value_4'),
  })
  .backgroundColor($r('sys.color.comp_background_list_card'))
  .borderRadius($r('sys.float.corner_radius_level10'))
  .scrollBar(BarState.Off)
  .align(Alignment.TopStart)
  .edgeEffect(EdgeEffect.Spring)
  .alignSelf(ItemAlign.Start)
  .clip(true)
}

@Extend(Flex)
function flexStyle() {
  .width('100%')
  .constraintSize({
    minHeight: $r('app.float.wh_value_48'),
  })
  .padding({
    left: $r('app.float.padding_8'),
    right: $r('app.float.padding_8'),
  })
}

@Extend(List)
function fgIdListStyle() {
  .divider({
    strokeWidth: $r('app.float.wh_value_0_5'),
    color: $r('sys.color.comp_divider'),
    startMargin: $r('sys.float.margin_left'),
    endMargin: $r('sys.float.margin_right'),
  })
  .scrollBar(BarState.Off)
  .align(Alignment.TopStart)
  .edgeEffect(EdgeEffect.Spring)
  .alignSelf(ItemAlign.Start)
  .clip(true)
}

@Extend(Flex)
function fgIdFlexStyle() {
  .width('100%')
  .constraintSize({
    minHeight: $r('app.float.wh_value_48'),
  })
  .margin({
    left: $r('sys.float.padding_level6'),
    right: $r('sys.float.padding_level6'),
  })
}

@Extend(Text)
function primarySwitchText(isEnabled: boolean) {
  .fontSize($r('sys.float.Body_L'))
  .fontWeight(FontWeight.Medium)
  .fontColor($r('sys.color.font_primary'))
  .width('80%')
  .align(Alignment.Start)
  .opacity(isEnabled ? $r('app.float.opacity_1') : $r('sys.float.ohos_id_alpha_disabled'))
}

@Extend(Text)
function secondarySwitchText(isEnabled: boolean) {
  .fontSize($r('sys.float.Body_M'))
  .fontWeight(FontWeight.Regular)
  .fontColor($r('sys.color.font_secondary'))
  .width('80%')
  .align(Alignment.Start)
  .opacity(isEnabled ? $r('app.float.opacity_1') : $r('sys.float.ohos_id_alpha_disabled'))
  .margin({
    top: $r('app.float.length_2')
  })
}