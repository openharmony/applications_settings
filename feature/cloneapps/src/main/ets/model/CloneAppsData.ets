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

import bundle from '@ohos.bundle.bundleManager';
import bundleResourceManager from '@ohos.bundle.bundleResourceManager';
// import hdsDrawable from '@hms.hds.hdsDrawable';
import image from '@ohos.multimedia.image';
import {
  ComparableSettingItemModel,
  SettingDialogModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingContentModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { LayeredDrawableDescriptor } from '@ohos.arkui.drawableDescriptor';
import { ThemeManager } from '@ohos/settings.application';

const TAG: string = 'AppCloneData : ';

export class AppCloneData {
  public bundleName: string = '';
  public cloneAppNum: number = 0;
  public maxCloneAppNum: number = 0;
  public label: string = '';
  public icon?: ResourceStr | PixelMap;
  public static readonly defaultSize: number = 48;

  init(bundleInfo: bundle.BundleInfo): void {
    this.bundleName = bundleInfo.name;
    this.maxCloneAppNum = bundleInfo?.appInfo?.multiAppMode?.maxCount;
  }
  /**
   * 加载并hds处理指定应用的label和图标
   */
  async loadLabelAndIcon(): Promise<void> {
    let defaultLabel: string = this.bundleName;
    let defaultIcon: ResourceStr | PixelMap = this.getDefaultIcon();
    let bundleFlags = bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_LABEL |
    bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_DRAWABLE_DESCRIPTOR;
    try {
      let bundleResourceInfo:bundleResourceManager.BundleResourceInfo | undefined =
        await bundleResourceManager.getBundleResourceInfo(this.bundleName, bundleFlags,0);

      if (!bundleResourceInfo) {
        this.label = defaultLabel;
        this.icon = defaultIcon;
        LogUtil.error(`${TAG} loadLabelAndIcon fail, name: ${this.label }`);
        return;
      }
      let hasBorder: boolean = !ThemeManager.getInstance().checkIsOnlineIcon();
      let mask = this.getMask();
      if (mask) {
        this.icon = this.getCustomHdsIcon(this.bundleName, bundleResourceInfo.drawableDescriptor,
          AppCloneData.defaultSize, mask, hasBorder) ?? defaultIcon;
        mask.release();
      }

      if (!this.icon) {
        LogUtil.error(`${TAG} get icon invalid`);
        this.icon = defaultIcon;
      }
      this.label = bundleResourceInfo?.label;
      if (!this.label) {
        LogUtil.error(`${TAG} get label invalid`);
        this.label = defaultLabel;
      }
    } catch (error) {
      LogUtil.error(`${TAG} getBundleResourceInfo error, errmsg: ${error?.message}`);
    }
  }

  private getDefaultIcon(): ResourceStr {
    return $r('sys.media.ohos_app_icon');
  }

  /**
   * 获取Hds裁剪所需的蒙层
   */
  public getMask(): PixelMap | undefined {
    try {
      let settingsDrawableDescriptor: LayeredDrawableDescriptor =
        bundleResourceManager.getBundleResourceInfo('com.ohos.settings',
          bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_DRAWABLE_DESCRIPTOR)
          .drawableDescriptor as LayeredDrawableDescriptor;
      return settingsDrawableDescriptor.getMask().getPixelMap();
    } catch (error) {
      LogUtil.error(`${TAG} getMask error, errmsg: ${error?.message}`);
    }
    return;
  }

  /**
   * 获取hds处理的icon
   *
   * @param bundleName 应用包名
   * @param drawDesc 要处理的图标描述符
   * @param size 处理后图标输出大小
   * @param mask hds根据该mask进行图标裁剪
   * @param hasBorder 处理图标是否带描边
   * @return 裁剪处理后的图标
   */
  public getCustomHdsIcon(bundleName: string, drawDesc: DrawableDescriptor, size: number, mask: PixelMap,
    hasBorder: boolean): PixelMap | undefined {
    let result: PixelMap | undefined;
    let fixBundleName = bundleName;
    if (drawDesc instanceof LayeredDrawableDescriptor) {
      try {
        // result = hdsDrawable.getHdsLayeredIcon(fixBundleName, drawDesc, size, hasBorder);
      } catch (error) {
        LogUtil.error(`${TAG} getHdsLayeredIcon code is ${error?.code}, message is ${error?.message}`);
      }
    } else {
      let pixelMap: PixelMap = drawDesc.getPixelMap();
      try {
        // result = hdsDrawable.getHdsIcon(fixBundleName, pixelMap, size, mask, hasBorder);
      } catch (error) {
        LogUtil.error(`${TAG} getHdsIcon code is ${error?.code}, message is ${error?.message}`);
      }
      pixelMap.release();
    }
    if (result) {
      try {
        let imageInfo: image.ImageInfo = result.getImageInfoSync();
        LogUtil.info(`${TAG} getCustomHdsIcon name: ${bundleName}, pixelMap size {${imageInfo.size.width}, ${imageInfo.size.height}}`);
      } catch {
        LogUtil.error(`${TAG} getCustomHdsIcon name: ${bundleName}, get imageInfo failed`);
      }
    } else {
      LogUtil.error(`${TAG} getCustomHdsIcon name: ${bundleName}, get pixelMap failed, it's empty.`);
    }
    return result;
  }
}

export class CloneAppBriefInfo {
  public bundleName: string = '';
  public label?: string = '';
  public index: number = 0;
  public icon?: ResourceStr | PixelMap;
}

export interface CloneAppItemHeaderModel extends SettingContentModel {
  icon?: ResourceStr | PixelMap;
  label?: string;
}

export interface CloneAppItemModel extends ComparableSettingItemModel {
  label?: string;
  appIndex?: number;
  bundleName?: string;
  dialog?: SettingDialogModel;
}