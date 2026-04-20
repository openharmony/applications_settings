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

/**
 * 将自定义的函数绑定到组件上，解决arkts对@Builder装饰器的限制，使得组件中可使用外部@Builder，从而实现动态加载
 *
 * @param component 组件
 * @param builder
 * @returns builder
 */
export function bindBuilder2Comp(component: any, builder: Function): Function {
  if (!component || !builder) {
    return builder;
  }
  return builder.bind(component);
}