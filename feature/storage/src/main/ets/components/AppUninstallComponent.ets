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

/* instrument ignore file */
import { LengthMetrics, LoadingDialog } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AppEntry } from '@ohos/settings.application/src/main/ets/AppModel';
import { AppCloneBadgeComponent } from '@ohos/settings.application/src/main/ets/components/AppCloneBadgeComponent';
import { SettingIconStyle, } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PADDING_16, PADDING_2, PADDING_6, } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { AppManager } from '@ohos/settings.application/src/main/ets/util/AppManager';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { UninstallResult } from '@ohos/settings.application/src/main/ets/model/UninstallResult';
import { AppEntryStorage } from '../constant/StorageConstant';
import { StorageSizeUtil } from '../utils/StorageSizeUtil';

const TAG: string = 'AppUninstallComponent';
const SELECT_UNINSTALL_APP_EVENT: string = 'change_chose_app_uninstall';
const MAX_STACK_IMAGE_SIZE: number = 3;

@Component
export struct AppUninstallComponent {
  iconStyle: SettingIconStyle = this.getIconStyle();
  private uninstallAppDialogController: CustomDialogController | undefined = undefined;
  @State private appList: AppEntry[] = [];
  private selectUninstallAppCallback = (selectedAppList: AppEntryStorage[]) => {
    this.appList = selectedAppList as AppEntry[];
    LogUtil.info(`${TAG} update select uninstall app length: ${this.appList?.length}`);
  };

  aboutToAppear(): void {
    EventBus.getInstance().on(SELECT_UNINSTALL_APP_EVENT, this.selectUninstallAppCallback);
  }

  aboutToDisappear(): void {
    EventBus.getInstance().detach(SELECT_UNINSTALL_APP_EVENT, this.selectUninstallAppCallback);
  }

  build() {
    Column() {
      Button({ type: ButtonType.Normal }) {
        Text(this.appList?.length <= 0 ? $r('app.string.uninstall') :
        ResourceUtil.getPluralStringValueSync($r('app.plural.delete_apps_selected'), this.appList.length))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.ohos_id_color_warning'))
          .constraintSize({
            minHeight: 21,
          })
          .margin({
            top: $r('sys.float.padding_level5'),
            bottom: $r('sys.float.padding_level5'),
            left: $r('sys.float.padding_level8'),
            right: $r('sys.float.padding_level8'),
          })
          .maxLines(2)
          .ellipsisMode(EllipsisMode.END)
          .textOverflow({overflow: TextOverflow.Ellipsis})
      }
      .onClick(() => {
        this.openUninstallAppDialog();
      })
      .borderRadius($r('sys.float.corner_radius_level10'))
      .enabled(this.appList.length > 0)
      .width('100%')
      .backgroundColor($r('sys.color.comp_background_tertiary'))
    }
    .justifyContent(FlexAlign.End)
    .padding({
      bottom: $r('sys.float.padding_level10'),
      top: $r('sys.float.padding_level10'),
      left: $r('sys.float.padding_level10'),
      right: $r('sys.float.padding_level10'),
    })
  }

  @Builder
  BulkUninstallDialogBuilder(list: AppEntry[]) {
    Column() {
      if (list?.length === 1) {
        AppCloneBadgeComponent({
          iconStyle:{
            border: { width: '0px', color: '#00000000', radius: 0 },
            borderRadius: 0,
            width: 64,
            height: 64,
            mirrored: false,
            interpolation: ImageInterpolation.Medium,
            draggable: false
          } as SettingIconStyle,
          entry: list[0],
          isNeedEndPadding: false,
          iconSize: 64,
          bundleName: list[0]?.name
        })

        Text($r('app.string.is_delete_app', list[0]?.label))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Bold)
          .fontSize($r('sys.float.Title_S'))
          .maxFontScale(2)
          .fontColor($r('sys.color.font_primary'))
          .wordBreak(WordBreak.BREAK_WORD)
          .margin({ top: LengthMetrics.vp(16) })
      } else {
        Stack({ alignContent: Alignment.End }) {
          ForEach(this.getShowIconApps(list), (item: AppEntry, index: number) => {
            AppCloneBadgeComponent({
              iconStyle:{
                border: { width: '0px', color: '#00000000', radius: 0 },
                borderRadius: 0,
                width: 64,
                height: 64,
                mirrored: false,
                interpolation: ImageInterpolation.Medium,
                draggable: false
              } as SettingIconStyle,
              entry: list[index],
              isNeedEndPadding: false,
              iconSize: 64,
              bundleName: list[index]?.name
            })
              .zIndex(list?.length - index)
              .rotate({
                x: 0,
                y: 0,
                z: 1,
                centerX: '50%',
                centerY: '50%',
                angle: 10 * index
              })
          })
        }

        Text(ResourceUtil.getPluralStringValueSync($r('app.plural.is_delete_apps_number'), list?.length))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Bold)
          .fontSize($r('sys.float.Title_S'))
          .maxFontScale(2)
          .fontColor($r('sys.color.font_primary'))
          .wordBreak(WordBreak.BREAK_WORD)
          .margin({ top: LengthMetrics.vp(16) })
      }

      Text($r('app.string.after_delete'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .wordBreak(WordBreak.BREAK_WORD)
        .margin({ top: LengthMetrics.vp(16) })
    }
    .width('100%')
  }

  private getShowIconApps(list: AppEntry[]): AppEntry[] {
    let apps: AppEntry[] = [];
    if (!list) {
      return apps;
    }
    let maxIndex: number = Math.min(list.length, MAX_STACK_IMAGE_SIZE);
    for (let i = 0; i < maxIndex; i++) {
      apps.push(list[i]);
    }
    return apps;
  }

  private openUninstallAppDialog(): void {
    LogUtil.info(`${TAG} onUninstallAppDialog`);
    this.uninstallAppDialogController = new CustomDialogController({
      builder: CustomContentDialog({
        contentBuilder: () => {
          this.BulkUninstallDialogBuilder(this.appList);
        },
        buttons: [{
          value: $r('app.string.dialog_cancel'),
          action: () => {
            this.uninstallAppDialogController?.close();
          }
        },
          {
            value: $r('app.string.app_info_uninstall'),
            action: () => {
              LogUtil.info(`${TAG} onDialogConfirm`);
              this.uninstallAppDialogController?.close();
              this.uninstallApp(this.appList);
            },
            fontColor: $r('sys.color.ohos_id_color_warning')
          }]
      }),
      autoCancel: false,
      alignment: DialogAlignment.Center,
    });
    this.uninstallAppDialogController.open();
  }

  private async uninstallApp(uninstallList: AppEntry[]): Promise<void> {
    let dialogController = new CustomDialogController({
      builder: LoadingDialog({
        content: $r('app.string.deleting'),
      })
    });
    try {
      dialogController.open();
      let uninstallFailedApps: AppEntry[] = [];
      let allAppSize: number = 0;
      LogUtil.info(`${TAG} uninstall start `)
      for (let i = 0; i < uninstallList.length; i++) {
        let item = uninstallList[i];
        let result: UninstallResult = await AppManager.getInstance().uninstallApp(item?.name ?? '', item?.appIndex ?? 0);
        LogUtil.info(`${TAG} uninstall ${item?.name} result:${result.isSuccess}`);
        if (result.isSuccess) {
          allAppSize += Number(item?.totalSize);
        } else {
          uninstallFailedApps.push(item);
        }
      }
      dialogController.close();
      LogUtil.info(`${TAG} uninstall completed`);
      this.appList = uninstallFailedApps;
      LogUtil.info(`${TAG} ShowToastOptions`);
      const options: promptAction.ShowToastOptions = {
        message: $r('app.string.freed_memory_apps_number', String(StorageSizeUtil.formatDataIntl(allAppSize, 0, true))),
        duration: 2000,
      };
      try {
        promptAction.showToast(options);
      } catch (error) {
        LogUtil.error(`${TAG} showToast error code is ${error?.code}, message is ${error?.message}`);
      }
    } catch (error) {
      LogUtil.error(`${TAG} uninstallApp List error: ${error?.message}`)
    }
  }

  private getIconStyle(): SettingIconStyle {
    // 接入了HDS之后，图标不需要主动做描边处理
    let style: SettingIconStyle = {
      border: { width: '0px', color: '#00000000', radius: 0 },
      borderRadius: 0,
      width: 64,
      height: 64,
      mirrored: false,
      interpolation: ImageInterpolation.Medium
    };
    return style;
  }
}

@Extend(Image)
function iconStyle(style: SettingIconStyle) {
  .width(style.width)
  .height(style.height)
  .objectFit(style.objectFit)
  .borderRadius(style.borderRadius || $r('sys.float.corner_radius_level6'))
  .draggable(style.draggable)
  .interpolation(style.interpolation)
  .edgeAntialiasing(style.edgeAntialiasing)
  .border(style.border)
  .clip(style.clip)
  .syncLoad(true)
  .matchTextDirection(style.mirrored)
  .accessibilityText(style?.accessibilityText)
  .accessibilityLevel(style?.accessibilityLevel)
}