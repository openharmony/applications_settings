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

import picker from '@ohos.file.picker';
import fileIo from '@ohos.file.fs';
import util from '@ohos.util';
import { BusinessError } from '@kit.BasicServicesKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import VpnConfig from './model/VpnConfig';
import VpnConstant from './model/VpnConstant';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';

/* instrument ignore file */
const MODULE_TAG: string = 'custom_component:';
const IS_PC: boolean = DeviceUtil.isDevicePc();

@Extend(Text)
function textPrimaryStyle() {
  .fontColor($r('sys.color.font_primary'))
  .fontSize($r('sys.float.Body_L'))
  .fontFamily('HarmonyHeiTi')
  .fontWeight(FontWeight.Medium)
  .textAlign(TextAlign.Start)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .maxLines(1)
}

@Extend(Text)
function textSecondaryStyle() {
  .fontColor($r('sys.color.font_secondary'))
  .fontSize($r('sys.float.Body_M'))
  .fontFamily('HarmonyHeiTi')
  .fontWeight(FontWeight.Regular)
}

@Extend(Row)
function heightAndRadiusStyle() {
  .height(IS_PC ? $r('app.float.height_48') : $r('app.float.height_56'))
  .borderRadius(IS_PC ? $r('sys.float.corner_radius_level8') :
  $r('sys.float.corner_radius_level10'))
}

@Component
export struct TextWithInput {
  title: Resource | string = '';
  textInputId: string = '';
  inputType: number | undefined = undefined;
  inputPlaceholder: Resource | string = '';
  maxLength: number = VpnConstant.INPUT_MAX_LENGTH;
  @Prop inputText: string = '';
  @State fontColor: ResourceColor = $r('sys.color.font_secondary');
  onChange: (value: string) => void = () => {};
  isLtr: boolean = LanguageUtils.isLtrDirection();

  build() {
    Row() {
      Text(this.title)
        .textPrimaryStyle()
        .constraintSize({ maxWidth: '70%' })
        .direction(this.isLtr ? Direction.Ltr : Direction.Rtl)
      TextInput({ placeholder: this.inputPlaceholder, text: this.inputText })
        .type(this.inputType == VpnConstant.INPUT_TYPE_PWD ? InputType.Password : InputType.Normal)
        .maxLength(this.maxLength)
        .fontColor(this.fontColor)
        .placeholderFont({ size: $r('sys.float.Body_M'), weight: FontWeight.Regular, family: 'HarmonyHeiTi' })
        .fontSize($r('sys.float.Body_M'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.End)
        .backgroundColor(Color.Transparent)
        .maxLines(1)
        .height('100%')
        .layoutWeight(1)
        .padding({ left: 0, right: 0 })
        .direction(this.isLtr ? Direction.Ltr : Direction.Rtl)
        .id(this.textInputId)
        .onChange((value: string) => {
          this.checkInputValid(value);
          this.onChange(value);
        })
    }
    .padding({
      left: 12,
      right: 12
    })
    .width('100%')
    .heightAndRadiusStyle()
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }

  private checkInputValid(value: string): void {
    let isValueValid: boolean = true;
    if (this.inputType == VpnConstant.INPUT_TYPE_IP) {
      let regex: RegExp =
        /^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
      isValueValid = regex.test(value);
    }
    if (this.inputType == VpnConstant.INPUT_TYPE_PORT) {
      let regex: RegExp =
        /^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$/;
      isValueValid = regex.test(value);
    }
    this.fontColor =
      isValueValid ? $r('sys.color.font_secondary') : $r('sys.color.warning');
  }
}

@Component
export struct Selector {
  onSelectedChange: Function = (id: number) => {
  };
  @Prop sheetTitles: string[] = [];
  @Prop selectedId: number = 0;
  @State isBindSheetShow: boolean = false;
  @State bgColor: ResourceColor = Color.Transparent;
  title: string | Resource = '';
  selectorTextId: string = '';
  type: number = 0;
  selectDialogController: CustomDialogController | undefined = undefined;
  isLtr: boolean = LanguageUtils.isLtrDirection();

  build() {
    Row() {
      Row() {
        Text(this.title)
          .textPrimaryStyle()
        Blank(16)
        Text(this.sheetTitles?.length > 0 ? this.sheetTitles[this.selectedId] : '')
          .id(this.selectorTextId)
          .textSecondaryStyle()
          .padding({ right: 4 })
          .textAlign(TextAlign.Start)
          .direction(this.isLtr ? Direction.Ltr : Direction.Rtl)
        Image($r('app.media.ic_settings_arrow'))
          .width($r('app.float.wh_value_12'))
          .height($r('app.float.wh_value_24'))
          .fillColor($r('sys.color.icon_primary'))
          .opacity($r('app.float.opacity_0_2'))
          .matchTextDirection(true)
          .draggable(false)
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .width('calc(100% - 8vp)')
      .height('calc(100% - 8vp)')
      .padding({ left: 12, right: 12 })
      .backgroundColor(this.bgColor)
      .borderRadius($r('sys.float.corner_radius_level8'))
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .heightAndRadiusStyle()
    .width('100%')
    .onClick(() => {
      this.isBindSheetShow = true;
    })
    .onHover((isHover?: boolean) => {
      this.onHoverEvent(isHover);
    })
    .onTouch((event?: TouchEvent) => {
      this.onTouchEvent(event);
    })
    .onMouse((event?: MouseEvent): void => {
      this.onMouseEvent(event);
    })
    .bindSheet(this.isBindSheetShow, this.SelectorBindSheet(), {
      height: SheetSize.FIT_CONTENT,
      preferType: SheetType.CENTER,
      showClose: true,
      dragBar: false,
      title: { title: this.title },
      onWillDisappear: () => {
        this.isBindSheetShow = false
      },
    })
  }

  @Builder
  SelectorBindSheet() {
    Column() {
      List() {
        ForEach(this.sheetTitles, (title: string, sheetId: number) => {
          ListItem() {
            SelectorListItem({
              title: title,
              sheetId: sheetId,
              isHead: sheetId === 0,
              isTail: sheetId === this.sheetTitles.length - 1,
              isSelected: this.selectedId === sheetId,
              onSelectedChange: (id: number) => {
                this.selectedId = id;
                this.isBindSheetShow = false;
                // callback
                this.onSelectedChange(id);
              }
            })
          }
        });
      }
      .align(Alignment.Top)
      .borderRadius(IS_PC ? $r('sys.float.corner_radius_level8') :
      $r('sys.float.corner_radius_level10'))
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .divider({
        strokeWidth: $r('app.float.divider_stroke_width'),
        startMargin: '12vp',
        endMargin: '12vp',
        color: $r('sys.color.comp_divider'),
      })
    }
    .padding({ top: 8, left: 16, right: 16 })
    .width('100%')
    .height('100%')
  }

  private onHoverEvent(isHover?: boolean): void {
    if (isHover) {
      this.bgColor = $r('sys.color.interactive_hover');
    } else {
      this.bgColor = Color.Transparent;
    }
  }

  private onTouchEvent(event?: TouchEvent): void {
    if (event && event.type === TouchType.Down) {
      this.bgColor = $r('sys.color.interactive_pressed');
    }
    if (event && event.type === TouchType.Up) {
      this.bgColor = Color.Transparent;
    }
  }

  private onMouseEvent(event?: MouseEvent): void {
    if (event && event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.bgColor = $r('sys.color.interactive_pressed');
    } else if (event && event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.bgColor = Color.Transparent;
    }
  }
}

@Component
export struct SelectorListItem {
  onSelectedChange: Function = (id: number) => {
  };
  @State bgColor: ResourceColor = Color.Transparent;
  title: string = '';
  sheetId: number = 0;
  isSelected: boolean = false;
  isHead = false;
  isTail = false;
  isLtr: boolean = LanguageUtils.isLtrDirection();

  build() {
    Row() {
      Row() {
        Text(this.title)
          .textPrimaryStyle()
          .layoutWeight(1)
          .textAlign(TextAlign.Start)
          .direction(this.isLtr ? Direction.Ltr : Direction.Rtl)
        Checkbox()
          .select(true)
          .shape(CheckBoxShape.CIRCLE)
          .visibility(this.isSelected ? Visibility.Visible : Visibility.Hidden)
          .onChange((value: boolean) => {
            this.onSelectedChange(this.sheetId);
          })
      }
      .width('calc(100% - 8vp)')
      .height(this.isHead && this.isTail ? 'calc(100% - 8vp)' :
        this.isHead || this.isTail ? 'calc(100% - 4vp)' : '100%')
      .backgroundColor(this.bgColor)
      .borderRadius(IS_PC ? $r('sys.float.corner_radius_level8') :
      $r('sys.float.corner_radius_level8'))
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .padding({
        left: 12,
        right: 12
      })
    }
    .alignItems(this.isHead && !this.isTail ? VerticalAlign.Bottom :
      this.isTail && !this.isHead ? VerticalAlign.Top : VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .height(IS_PC ? $r('app.float.height_40') : $r('app.float.height_48'))
    .width('100%')
    .layoutWeight(1)
    .borderRadius(IS_PC ? $r('sys.float.corner_radius_level8') :
    $r('sys.float.corner_radius_level10'))
    .onHover((isHover?: boolean) => {
      this.onHoverEvent(isHover);
    })
    .onTouch((event?: TouchEvent) => {
      this.onTouchEvent(event);
    })
    .onMouse((event?: MouseEvent): void => {
      this.onMouseEvent(event);
    })
    .onClick(() => {
      this.onSelectedChange(this.sheetId);
    })
  }

  private onHoverEvent(isHover?: boolean): void {
    if (isHover) {
      this.bgColor = $r('sys.color.interactive_hover');
    } else {
      this.bgColor = Color.Transparent;
    }
  }

  private onTouchEvent(event?: TouchEvent): void {
    if (event && event.type === TouchType.Down) {
      this.bgColor = $r('sys.color.interactive_pressed');
    }
    if (event && event.type === TouchType.Up) {
      this.bgColor = Color.Transparent;
    }
  }

  private onMouseEvent(event?: MouseEvent): void {
    if (event && event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.bgColor = $r('sys.color.interactive_pressed');
    } else if (event && event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.bgColor = Color.Transparent;
    }
  }
}

@Component
export struct SelectFile {
  title: ResourceStr = '';
  @Prop vpnConfig: VpnConfig;
  @State fileName: string | undefined = undefined;
  realFilePath: string | undefined = undefined;
  callback?: (result: string[]) => void;
  isLtr: boolean = LanguageUtils.isLtrDirection();

  build() {
    Row() {
      Text(this.title)
        .textPrimaryStyle()
        .padding({ left: 8 })
        .textAlign(TextAlign.Start)
        .direction(this.isLtr ? Direction.Ltr : Direction.Rtl)
      Blank()
      Text(this.fileName ?? $r('app.string.vpn_edit_ovpn_click_select'))
        .textSecondaryStyle()
        .padding({ right: 4 })
        .textAlign(TextAlign.Start)
        .direction(this.isLtr ? Direction.Ltr : Direction.Rtl)
      Image($r('app.media.ic_settings_arrow'))
        .width($r('app.float.wh_value_12'))
        .height($r('app.float.wh_value_24'))
        .fillColor($r('sys.color.icon_primary'))
        .opacity($r('app.float.opacity_0_2'))
        .matchTextDirection(true)
        .draggable(false)
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('100%')
    .heightAndRadiusStyle()
    .padding({ left: 8, right: 8 })
    .onClick(() => {
      this.pickFile((result: string[]) => {
        if (result) {
          this.fileName = result[0];
          if (this.callback) {
            this.callback(result);
          }
        }
      })
    })
  }

  pickFile(callback: (result: string[]) => void): void {
    let selectOption = new picker.DocumentSelectOptions();
    let documentPicker = new picker.DocumentViewPicker();
    documentPicker.select(selectOption).then((result: Array<string>) => {
      if (result.length > 0) {
        let uri = result[0];
        let fileName = uri.substring(uri.lastIndexOf('/') + 1);
        let file: fileIo.File | undefined = undefined;
        try {
          file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
          let fileStat = fileIo.statSync(file.fd);
          let buf = new ArrayBuffer(fileStat.size);
          fileIo.readSync(file.fd, buf);
          let unit8 = new Uint8Array(buf);
          let content = new util.TextDecoder().decodeWithStream(unit8);
          callback([fileName, content]);
        } catch (error) {
          let err: BusinessError = error as BusinessError;
          LogUtil.error(`${MODULE_TAG} DocumentViewPicker failed with err: ${err}`);
        } finally {
          try {
            file && fileIo.closeSync(file);
          } catch (err) {
            LogUtil.error(`${MODULE_TAG} fs.closeSync catch code:${err?.code} message:${err?.message}`);
          }
        }
      }
    }).catch((err: BusinessError) => {
      LogUtil.error(`${MODULE_TAG} DocumentViewPicker select failed with err: ${err}`);
    });
  }
}