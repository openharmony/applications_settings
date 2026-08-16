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
import { dataShare } from '@kit.ArkData';
import {
  CompCtrlParam,
  ComponentControl
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ItemDetailType,
  ItemResultType, ItemType,
  SettingIconType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysAuxiliaryEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { PADDING_0 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import { SettingToggleState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ZoomGestureLottieComponent, ZoomGestureSummaryComponent } from '../view/ZoomGestureBuilderComponent';
import { PageUrl } from '../../../pages/PageUrl';
import {
  CLICK_SWITCH_OFF,
  CLICK_SWITCH_ON,
  SCREEN_MAGNIFICATION,
  MAGNIFICATION_TYPES_ARRAY,
  DEFAULT_TEXT_STYLE
} from '../constant/Constants';
import { ZoomGestureSwitchController } from './ZoomGestureSwitchController';
import { AccessibilityImageSizeAdjust } from '../utils/AccessibilityImageSizeAdjust';
import { ScreenMagnificationTypeController } from './ScreenMagnificationTypeController';

@Builder
function zoomGestureImageGroupBuilder($$: Params): void {
  ZoomGestureLottieComponent({ params: $$ as Object as PushParam });
}

@Builder
function zoomGestureSummaryGroupBuilder(param: object): void {
  ZoomGestureSummaryComponent();
}

/**
 * 放大手势页面控制器
 *
 * @since 2024-08-18
 */
export class ZoomGesturePageController implements ComponentControl {
  private compId: string = '';
  private tag: string = 'ZoomGesturePageController : ';
  private settingPageModel?: SettingPageModel;
  private accessibilityImageSizeAdjust: AccessibilityImageSizeAdjust = new AccessibilityImageSizeAdjust();

  private addImageGroup(): void {
    let item: SettingGroupModel = {
      id: 'zoomGesture_image_group',
      type: GroupType.GROUP_TYPE_CUSTOM,
      builder: wrapBuilder(zoomGestureImageGroupBuilder),
    };
    this.settingPageModel?.groups?.push(item);
  }

  private addZoomFunctionGroup(): void {
    let item: SettingGroupModel = {
      id: 'zoomGesture_switch_group',
      type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
      compControl: new ZoomGestureShortcutController(),
      layout: {
        margin: {
          top: PADDING_0,
        }
      }
    };
    this.settingPageModel?.groups?.push(item);
  }

  private addSummaryGroup(): void {
    let item: SettingGroupModel = {
      id: 'zoomGesture_content_group',
      type: GroupType.GROUP_TYPE_CUSTOM,
      builder: wrapBuilder(zoomGestureSummaryGroupBuilder),
    };
    this.settingPageModel?.groups?.push(item);
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    LogUtil.info(`${this.tag} init ${this.compId}`);
    if (compParam) {
      this.settingPageModel = compParam.component as SettingPageModel;
    }
    AppStorage.setOrCreate<number>('AccessibilityImageSize', this.accessibilityImageSizeAdjust.imageResourceRadius);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(
      HiSysAuxiliaryEventGroup.ENTER_ZOOM_GESTURE_FUNCTIONS, 'pageUrl: ' + PageUrl.ACCESSIBILITY_ZOOM_GESTURE_PAGE_URL);
    this.addImageGroup();
    this.addZoomFunctionGroup();
    this.addSummaryGroup();
  }

  destroy(): void {
    LogUtil.info(`${this.tag} on destroy`);
  }
}

/**
 * 放大功能页面懒加载部分控制器
 *
 * @since 2025-04-28
 */
export class ZoomGestureShortcutController implements ComponentControl {
  private compId: string = '';
  private tag: string = 'ZoomGestureShortcutController : ';
  private dataSource?: OrderedDataSource;
  protected dataHelper?: dataShare.DataShareHelper;
  private zoomFunctionMainSwitch: boolean = false;
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${this.tag} toggleModel is invalid`);
      return;
    }
    LogUtil.info(`${this.tag} toggleState ${toggleState.state}`);
    this.zoomFunctionMainSwitch = toggleState.state;
    this.hideZoomTypeItem();
    if (this.zoomFunctionMainSwitch) {
      this.addZoomTypeItem();
    }
  };

  private initMenus(): void {
    this.addZoomFunctionItem();
    if (this.zoomFunctionMainSwitch) {
      this.addZoomTypeItem();
    }
  }

  private addZoomFunctionItem(): void {
    this.dataSource?.pushData({
      id: 'single_zoom_gesture_switch',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.zoom_gesture'),
        style: DEFAULT_TEXT_STYLE
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: this.zoomFunctionMainSwitch },
      },
      compControl: new ZoomGestureSwitchController(),
    });
  }

  private addZoomTypeItem(): void {
    let screenMagnificationController = new ScreenMagnificationTypeController();
    this.dataSource?.pushData({
      id: 'zoom_type_select',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.zoom_zone_text'),
        style: DEFAULT_TEXT_STYLE
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_MENU,
        icon: $r('app.media.arrow_triangle_down_fill'),
        iconType: SettingIconType.ICON_TYPE_TIP,
        menu: {
          items: MAGNIFICATION_TYPES_ARRAY,
          selectIcon: $r('app.media.ic_selected_ok'),
          onSelected: (index) => {
            ScreenMagnificationTypeController.updateTouchScreenType(index);
          },
        },
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: '',
          style: DEFAULT_TEXT_STYLE
        },
      },
      compControl: screenMagnificationController,
    })
  }

  private hideZoomTypeItem(): void {
    LogUtil.info(`hide zoomFunction shortcut item ${this.compId}`);
    this.dataSource?.removeData({
      id: 'zoom_type_select',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.zoom_zone_text'),
        style: DEFAULT_TEXT_STYLE
      },
    });
  }

  private initState(): void {
    this.zoomFunctionMainSwitch = SettingsDataUtils.getSecureValue(SCREEN_MAGNIFICATION,
      CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    LogUtil.info(`${this.tag} zoomFunctionMainSwitch ${this.zoomFunctionMainSwitch}`);
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    this.dataSource = (compParam.dataSource) as OrderedDataSource;
    this.initState();
    this.initMenus();
    EventBus.getInstance().on(`${this.compId}.single_zoom_gesture_switch.toggle`, this.toggleStateChangeEventCallback);
  }

  destroy(): void {
    LogUtil.info(`${this.tag} on destroy`);
    EventBus.getInstance().detach(`${this.compId}.single_zoom_gesture_switch.toggle`,
      this.toggleStateChangeEventCallback);
  }
}