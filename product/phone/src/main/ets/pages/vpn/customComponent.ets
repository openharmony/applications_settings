/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import deviceInfo from '@ohos.deviceInfo';
import fileIo from '@ohos.file.fs';
import picker from '@ohos.file.picker';
import util from '@ohos.util';
import { BusinessError } from '@ohos.base';
import { SelectDialog } from '@ohos.arkui.advanced.Dialog';
import VpnConfig, { OpenVpnConfig } from '../../model/vpnImpl/VpnConfig';
import { VpnTypeModel } from '../../model/vpnImpl/VpnTypeModel';
import VpnConstant from '../../model/vpnImpl/VpnConstant';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';

export const SELECTER_VPNTYPE: number = 1;
export const SELECTER_OVPN_PROTOCOL: number = 2;
export const SELECTER_OVPN_AUTH: number = 3;
export const SELECTER_CERT: number = 4;
export const deviceTypeInfo = deviceInfo.deviceType;

export const INPUT_TYPE_IP: number = 1;
export const INPUT_TYPE_PORT: number = 2;
export const INPUT_TYPE_PWD: number = 3;

const MODULE_TAG: string = 'setting_vpn:custom_component:';

@Component
export struct TextWithInput {
  title: Resource | string = '';
  inputType: number | undefined = undefined;
  inputPlaceholder: Resource | string = '';
  maxLength: number = VpnConstant.INPUT_MAX_LENGTH;
  @Prop inputText: string = '';
  @State fontColor: ResourceColor = $r('app.color.font_color_182431');
  onChange: (value: string) => void = () => {};

  build() {
    Column() {
      Text(this.title)
        .fontSize($r('app.float.font_16'))
        .fontColor($r('app.color.font_color_182431'))
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Start)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Start)
        .padding({ left: 8 })
        .margin({ top: 10 });
      TextInput({ placeholder: this.inputPlaceholder, text: this.inputText }).onChange((value: string) => {
        if (this.inputType === INPUT_TYPE_IP) {
          if (VpnConstant.REGEX_IP.test(value)) {
            this.fontColor = $r('app.color.font_color_182431');
          } else {
            this.fontColor = $r('sys.color.ohos_id_color_warning');
          }
        }
        if (this.inputType === INPUT_TYPE_PORT) {
          if (VpnConstant.REGEX_PORT.test(value)) {
            this.fontColor = $r('app.color.font_color_182431');
          } else {
            this.fontColor = $r('sys.color.ohos_id_color_warning');
          }
        }
        this.onChange(value);
      }).padding({ left: 5 })
        .fontSize($r('app.float.font_16'))
        .type(this.inputType === INPUT_TYPE_PWD ? InputType.Password : InputType.Normal)
        .backgroundColor('#00000000')
        .showUnderline(true)
        .height(45)
        .margin({ top: 5 })
        .fontColor(this.fontColor)
        .maxLength(this.maxLength);
      if (this.inputType === INPUT_TYPE_PWD) {
        Divider()
          .color($r('sys.color.ohos_id_color_list_separator'))
      }
    }.alignItems(HorizontalAlign.Start)
  }
}

@Component
export struct Selector {
  @Link vpnConfig: VpnConfig;
  @Prop sheetTitles: string[] = [];
  @Prop sheetInfos: SheetInfo[] = [];
  @Prop certSelectedId: number;
  title: string | Resource = '';
  type: number = 0;
  selectDialogController: CustomDialogController | undefined = undefined;

  build() {
    Row() {
      Text(this.title)
        .fontSize($r('app.float.font_16'))
        .fontColor($r('app.color.font_color_182431'))
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Start)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Start)
      Blank()
      Text(this.sheetTitles?.length > 0 ?
          this.sheetTitles[this.getSelectIndex(this.vpnConfig, this.type)] : '')
        .padding({ right: 4 })
      Image($r('app.media.ic_settings_arrow'))
        .width($r('app.float.wh_value_12'))
        .height($r('app.float.wh_value_24'))
        .fillColor($r('sys.color.ohos_id_color_primary'))
        .opacity($r('app.float.opacity_0_2'))
    }
    .borderRadius($r('app.float.radius_16'))
    .backgroundColor('#ffffff')
    .width('100%')
    .height($r('app.float.wh_value_56'))
    .borderRadius($r('app.float.radius_16'))
    .padding({ left: 8, right: 8 })
    .onClick(() => {
      this.showSelectDialog();
    })
  }

  getSelectIndex(vpnConfig: VpnConfig, selecter: number): number {
    if (selecter === SELECTER_VPNTYPE) {
      return VpnTypeModel.getInstance().getSupportVpnTypes().indexOf(vpnConfig.vpnType);
    } else if (selecter === SELECTER_OVPN_PROTOCOL) {
      let openvpn : OpenVpnConfig = vpnConfig as OpenVpnConfig;
      return openvpn.ovpnProtocol;
    } else if (selecter === SELECTER_OVPN_AUTH) {
      let openvpn : OpenVpnConfig = vpnConfig as OpenVpnConfig;
      return openvpn.ovpnAuthType;
    } else if (selecter === SELECTER_CERT){
      return this.certSelectedId;
    } else {
      return 0;
    }
  }

  showSelectDialog() {
    this.selectDialogController = new CustomDialogController({
      builder: SelectDialog({
        title: this.title,
        selectedIndex: this.getSelectIndex(this.vpnConfig, this.type),
        confirm: {
          value: $r('app.string.cancel'),
          action: () => {
            this.selectDialogController?.close();
          },
        },
        radioContent: this.sheetInfos
      }),
      autoCancel: true,
      alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
      offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 })
    });
    this.selectDialogController?.open();
  }
}

@Component
export struct SelectFile {
  title: ResourceStr = '';
  @Prop vpnConfig: VpnConfig;
  @State fileName: string | undefined = undefined;
  realFilePath: string | undefined = undefined;
  callback?: (result: string[]) => void;

  build() {
    Row() {
      Text(this.title)
        .fontSize($r('app.float.font_16'))
        .fontColor($r('app.color.font_color_182431'))
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Start)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Start)
      Blank()
      Text(this.fileName ?? $r('app.string.vpn_edit_ovpn_click_select'))
        .padding({ right: 4 })
      Image($r('sys.media.ohos_ic_public_arrow_right')).width($r('app.float.wh_value_12'))
        .height($r('app.float.wh_value_24'))
        .fillColor($r('sys.color.ohos_id_color_primary'))
        .opacity($r('app.float.opacity_0_2'))
    }
    .borderRadius($r('app.float.radius_16'))
    .backgroundColor('#ffffff')
    .width('100%')
    .height($r('app.float.wh_value_56'))
    .borderRadius($r('app.float.radius_16'))
    .padding({ left: 8, right: 8 })
    .onClick(() => {
      this.pickFile((result: string[]) => {
        if (result) {
          this.fileName = result[0];
          this.callback!(result);
        }
      })
    })
  }

  pickFile(callback: (result: string[]) => void): void {
    try {
      let selectOption = new picker.DocumentSelectOptions();
      let documentPicker = new picker.DocumentViewPicker();
      documentPicker.select(selectOption).then((result: Array<string>) => {
        if (result.length > 0) {
          let uri = result[0];
          let fileName = uri.substring(uri.lastIndexOf('/') + 1);
          let file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
          let fileStat = fileIo.statSync(file.fd);
          let buf = new ArrayBuffer(fileStat.size);
          fileIo.readSync(file.fd, buf);
          fileIo.close(file.fd)
          let unit8 = new Uint8Array(buf);
          let content = new util.TextDecoder().decodeWithStream(unit8);
          callback([fileName, content]);
        }
      }).catch((err: BusinessError) => {
        LogUtil.error(MODULE_TAG + 'DocumentViewPicker select failed with err: ' + JSON.stringify(err));
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      LogUtil.error(MODULE_TAG + 'DocumentViewPicker failed with err: ' + JSON.stringify(err));
    }
  }
}
