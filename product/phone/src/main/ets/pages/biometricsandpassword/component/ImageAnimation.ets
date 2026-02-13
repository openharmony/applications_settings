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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import AccessibilityUtil from '../module/privacyPassword/common/utils/AccessibilityUtil';
/* instrument ignore file */
import { LoadFileUtil } from './LoadFileUtil';

@Component
export default struct ImageAnimatorComponent {
  @Prop index: number;
  @State images: ImageFrameInfo[] = [];
  COMPONENT_WIDTH = 240;
  COMPONENT_HEIGHT = 240;
  COMPONENT_MARGIN = 428;
  COMPONENT_DURATION = 800; //图片更换时间
  COMPONENT_ITERATIONS = -1; // 是否循环播放
  COMPONENT_COLUMN_SPACE = 10;
  PAGE_WIDTH = '100%'; // 屏幕宽度
  PAGE_HEIGHT = '100%'; // 屏幕高度
  IMAGES_NAME: string[] = [
    '001', '002', '003', '004', '005', '006', '007', '008', '009', '010',
    '011', '012', '013', '014', '015', '016', '017', '018', '019', '020',
    '021', '022', '023', '024', '025', '026', '027', '028', '029', '030'
  ];
  FINGERPRINT_ANIM_RES_PATH: string[] = [
    '/sys_prod/resource/fpthemes/theme1/res/preview/',
    '/sys_prod/resource/fpthemes/theme2/res/preview/',
    '/sys_prod/resource/fpthemes/theme3/res/preview/',
    '/sys_prod/resource/fpthemes/theme4/res/preview/'
  ];
  FINGERPRINT_ANIM_PNG: string = '.png';
  FINGERPRINT_ANIM_JPG: string = '.jpg';

  aboutToAppear(): void {
    LogUtil.info(`fgloadresourse, ${this.index}`);
    this.loadImageResoure();
  }

  async loadImageResoure(): Promise<void> {
    try {
      let imageType: string = this.index == 0 ? this.FINGERPRINT_ANIM_JPG : this.FINGERPRINT_ANIM_PNG;
      let imageData: ImageFrameInfo[] = [];
      if (AppStorage.get<ImageFrameInfo[]>('imageData' + this.index) === undefined ||
        AppStorage.get<ImageFrameInfo[]>('imageData' + this.index) === null) {
        for (let imageName of this.IMAGES_NAME) {
          let src = await LoadFileUtil.loadImageFromDisk(this.FINGERPRINT_ANIM_RES_PATH[this.index] + imageName + imageType) ?? '';
          let imageFrameInfo: ImageFrameInfo = {
            src: src
          };
          imageData.push(imageFrameInfo);
        }
        AppStorage.setOrCreate('imageData' + this.index, imageData);
        LogUtil.info(`fgloadresourse, storage`);
      } else {
        imageData = AppStorage.get('imageData' + this.index) as ImageFrameInfo[];
        LogUtil.info(`fgloadresourse, read`);
      }
      this.images = imageData;
    } catch (err) {
      AppStorage.setOrCreate('imageData' + this.index, undefined);
    }
  }

  build() {
    Column({ space: this.COMPONENT_COLUMN_SPACE }) {
      ImageAnimator()
        .images(this.images)
        .duration(this.COMPONENT_DURATION)
        .state(AnimationStatus.Running)
        .reverse(false)
        .fixedSize(true)
        .fillMode(FillMode.None)
        .iterations(this.COMPONENT_ITERATIONS)
        .width(this.COMPONENT_WIDTH)
        .height(this.COMPONENT_HEIGHT)
        .margin({ top: this.COMPONENT_MARGIN })
        .draggable(false)
    }.width(this.PAGE_WIDTH).height(this.PAGE_HEIGHT)
  }
}