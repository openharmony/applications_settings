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
import { ObservedData, UiExtensionViewModel } from '@ohos/settings.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { ExitAbnormallyComponent } from '@ohos/settings.common/src/main/ets/viewmodel/ExitAbnormallyComponent';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { PageStartReason } from '@ohos/settings.common/src/main/ets/data/types';
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ExternalMenuPreloadManager } from '@ohos/settings.common/src/main/ets/externalmenu/ExternalMenuPreloadManager'
import promptAction from '@ohos.promptAction';
import I18n from '@ohos.i18n';
import LightWeightMap from '@ohos.util.LightWeightMap';

const TAG: string = 'AodSettingsPage:';
const BUNDLE_NAME: string = 'com.ohos.sceneboard';
const ABILITY_NAME: string = 'AodSettingsAbility';

enum Intent {
  OPEN_TIME_PICKER_DIALOG = 'open_aod_time_picker_dialog',
  UPDATE_SCHEDULED_SHOW_TIME = 'update_aod_scheduled_show_time',
  SHOW_TOAST = 'show_aod_toast',
  RETURN_PREVIOUS_PAGE = 'return_to_previous_page',
}

interface Action {
  executeAction: (data: Object) => void;
}

@Builder
export function AodSettingsLoader($$: Params): void {
  AodSettings({ params: $$ as Object as PushParam });
}

@Component
struct AodSettings {
  @State observedData: ObservedData = new ObservedData();
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  @Consume('pathInfos') pathStack: NavPathStack;
  private intentMap: LightWeightMap<Intent, Action> = new LightWeightMap();
  private proxy?: UIExtensionProxy;
  private controller?: CustomDialogController;
  @StorageProp('navigationMode') @Watch('onNavigationModeChange') navigationMode: NavigationMode = NavigationMode.Stack;
  private hideBackButton: boolean = false;
  public params: Nullable<PushParam> = undefined;

  recoverController: CustomDialogController = new CustomDialogController({
    builder: ExitAbnormallyComponent(),
  });

  public onNavigationModeChange(): void {
    if (this.params?.startReason === PageStartReason.FROM_SEARCH) {
      this.hideBackButton = this.navigationMode === NavigationMode.Split;
      this.proxy?.send({ 'hideBackButton': this.hideBackButton });
    }
  }

  build() {
    NavDestination() {
      UIExtensionComponent({
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME,
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'hideBackButton': this.hideBackButton,
          'reconnect': this.observedData.reconnect,
        },
      })
        .defaultFocus(true)
        .width('100%')
        .height('100%')
        .onRemoteReady((proxy) => {
          LogUtil.info(`${TAG} UIExtensionComponent onRemoteReady`);
          this.proxy = proxy;
        })
        .onError((error) => {
          LogUtil.info(`${TAG} UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
          this.viewModel.refreshing(error, this.recoverController, BUNDLE_NAME, ABILITY_NAME);
        })
        .onTerminated(()=>{})
        .onReceive((data) => {
          LogUtil.info(`${TAG} UIExtensionComponent onReceive`);
          this.intentMap.get(data['intent'] as Intent)?.executeAction(data['data']);
        });
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .width('100%')
    .height('100%')
    .onShown(() => {
      LogUtil.info(`${TAG} NavDestination onShown`);
    })
    .onHidden(() => {
      LogUtil.info(`${TAG} NavDestination onHidden`);
    });
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.viewModel.listening(this.recoverController);
    this.intentMap.set(Intent.SHOW_TOAST, { executeAction: this.showToast });
    this.intentMap.set(Intent.OPEN_TIME_PICKER_DIALOG, { executeAction: this.openTimePickerDialog });
    this.intentMap.set(Intent.RETURN_PREVIOUS_PAGE, { executeAction: this.returnPreviousPage });
    if (this.params?.startReason === PageStartReason.FROM_SEARCH && this.navigationMode === NavigationMode.Split) {
      // 设置中搜索跳转时，若设置分栏，则隐藏返回按钮
      this.hideBackButton = true;
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.viewModel.destroyListening();
    try {
      ExternalMenuPreloadManager.getInstance().preloadUIExtensionAbility(ABILITY_NAME, getContext());
    } catch (err) {
      LogUtil.showInfo(TAG, `preload AodSettingsAbility failed. err: ${err?.code} ${err?.message}`);
    }
  }

  private returnPreviousPage: (data: Object) => void = () => {
    LogUtil.info(`${TAG} Return To Previous Page`);
    this.pathStack.pop();
  }

  private showToast: (data: Object) => void = (data) => {
    LogUtil.info(`${TAG} Show AOD Toast`);
    promptAction?.showToast({ message: data.toString() });
  }

  private openTimePickerDialog: (data: Object) => void = (data) => {
    LogUtil.info(`${TAG} Open AOD Time Picker Dialog`);
    let initialData = data as AodDialogData;
    let finalData = new AodDialogData();
    finalData.type = initialData.type;
    let finalTime = new Date(initialData.time ?? 0);

    this.controller = new CustomDialogController({
      builder: AodTimePickerDialog({
        data: data,
        handleCancelClick: () => {
          this.controller?.close();
          this.controller = undefined;
        },
        handleConfirmClick: () => {
          this.controller?.close();
          this.controller = undefined;
          if (finalTime.toString() !== initialData.time) {
            finalData.time = finalTime.toString();
            this.proxy?.send({ 'intent': Intent.UPDATE_SCHEDULED_SHOW_TIME, 'data': finalData });
          }
        },
        handleDateChange: (value: TimePickerResult) => {
          finalTime.setHours(value.hour ?? 0);
          finalTime.setMinutes(value.minute ?? 0);
        }
      }),
      gridCount: DeviceUtil.isDevicePhone() ? 4 : undefined,
      alignment: DeviceUtil.isDevicePhone() ? DialogAlignment.Bottom : undefined,
    });
    this.controller?.open();
  }
}

@CustomDialog
struct AodTimePickerDialog {
  controller?: CustomDialogController;
  private data: AodDialogData = new AodDialogData();
  private handleConfirmClick?: (event: ClickEvent) => void;
  private handleCancelClick?: (event: ClickEvent) => void;
  private handleDateChange?: (value: TimePickerResult) => void;

  build() {
    Column() {
      Text(this.data.titleText)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.ohos_id_text_size_dialog_tittle'))// 20.0fp
        .fontColor($r('sys.color.ohos_id_color_text_primary'));

      TimePicker({ selected: new Date(this.data.time ?? 0) })
        .useMilitaryTime(I18n.System.is24HourClock())
        .backgroundColor(Color.Transparent)
        .width('100%')
        .margin({
          top: $r('sys.float.ohos_id_default_padding_top'), // 24.0vp
          bottom: $r('sys.float.ohos_id_default_padding_top') // 24.0vp
        })
        .onChange(this.handleDateChange);

      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Button(this.data.buttonCancelText ?? '')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.ohos_id_text_size_button1'))// 16.0fp
          .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
          .backgroundColor(Color.Transparent)
          .width('100%')
          .onClick(this.handleCancelClick);

        Divider()
          .vertical(true)
          .strokeWidth(1)
          .margin({
            left: $r('sys.float.ohos_id_elements_margin_horizontal_m'), // 8.0vp
            right: $r('sys.float.ohos_id_elements_margin_horizontal_m') // 8.0vp
          })
          .height(24);

        Button(this.data.buttonConfirmText ?? '')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.ohos_id_text_size_button1'))// 16.0fp
          .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
          .backgroundColor(Color.Transparent)
          .width('100%')
          .onClick(this.handleConfirmClick);
      }
      .width('100%');
    }
    .padding($r('sys.float.ohos_id_max_padding_start')) // 24vp
    .width('100%');
  }
}

class AodDialogData {
  public type?: string;
  public time?: string;
  public titleText?: string;
  public buttonConfirmText?: string;
  public buttonCancelText?: string;
}
