# RenderLib

面向 Unity URP 的常用效果封装，供业务项目快速复用。

Unity 2022.3 LTS · URP 14 · MIT · 持续完善中

<img src="docs/images/demo-stylized.gif" alt="Demo_Stylized 场景，溶解动画" width="800">

RenderLib 是一套可直接用在生产场景里的 URP 效果合集：物体效果挂到材质上即可，全屏后处理通过 Renderer Feature 接入，再用 Volume 调参。

公共逻辑放在 `_Core`；每个效果对应一份 Shader 和一份演示材质。效果仍在扩充，下表中尚未完成的条目暂未合入。

## 如何复用

- 物体效果：在材质上把 Shader 设为对应的 `RenderLib/...` 路径（例如 `RenderLib/Shading/ToonLit`）。
- 后处理：在 `Assets/Settings/URP-RenderLib_Renderer.asset` 上添加对应 Renderer Feature，再用 Volume 控制（`RenderLib/Pixelation`、`RenderLib/OutlinePost`、`RenderLib/Vignette`、`RenderLib/Underwater`）。
- 打开 `Assets/Scenes/Gallery.unity` 或任一 `Demo_*` 场景即可查看打包示例。

## 预览

### Demo_Shading

<img src="docs/images/demo-shading.png" alt="Demo_Shading 场景" width="800">

### Demo_VFX

<img src="docs/images/demo-vfx.gif" alt="Demo_VFX 场景" width="800">

### Demo_PostProcess

<img src="docs/images/demo-postprocess.png" alt="Demo_PostProcess 像素化" width="800">

## 效果一览

| 名称 | Shader | 分类 | 状态 |
| --- | --- | --- | --- |
| 无光照 | Unlit | 光照 | 已完成 |
| Lambert 漫反射 | Lambert | 光照 | 已完成 |
| 卡通光照 | ToonLit | 光照 | 已完成 |
| 卡通描边 | ToonOutline | 光照 | 已完成 |
| MatCap | MatCap | 光照 | 已完成 |
| 次表面散射 | SSS | 光照 | 已完成 |
| 溶解 | Dissolve | 风格化 | 已完成 |
| 方向溶解 | DissolveDir | 风格化 | 已完成 |
| 反转外壳描边 | OutlineHull | 风格化 | 已完成 |
| 全息 | Hologram | 风格化 | 已完成 |
| 边缘光 | RimLight | 风格化 | 已完成 |
| 故障 | Glitch | 风格化 | 已完成 |
| UV 扭曲 | UVDistort | 风格化 | 已完成 |
| 三平面投影 | Triplanar | 风格化 | 已完成 |
| 视差 | Parallax | 风格化 | 已完成 |
| 序列帧 | Flipbook | 风格化 | 已完成 |
| 叠加粒子 | ParticleAdd | 特效 | 已完成 |
| 透明粒子 | ParticleAlpha | 特效 | 已完成 |
| 软粒子 | SoftParticle | 特效 | 已完成 |
| 能量护盾 | Shield | 特效 | 已完成 |
| 顶点动画 | VertexAnim | 特效 | 已完成 |
| FlowMap | FlowMap | 特效 | 已完成 |
| 极坐标 UV | Polar | 特效 | 已完成 |
| 程序化天空 | ProceduralSky | 环境 | 已完成 |
| 水面 | Water | 环境 | 已完成 |
| 水下 | Underwater | 环境 | 已完成 |
| 地形混合 | TerrainBlend | 环境 | 已完成 |
| 草 | Grass | 环境 | 待完成 |
| 雪 | Snow | 环境 | 待完成 |
| 像素化 | Pixelation | 后处理 | 已完成 |
| 后处理描边 | OutlinePost | 后处理 | 已完成 |
| 暗角 | Vignette | 后处理 | 已完成 |
| 调色 | ColorGrade | 后处理 | 待完成 |
| 色差 | Chromatic | 后处理 | 待完成 |
| 胶片颗粒 | FilmGrain | 后处理 | 待完成 |
| 圆角 UI | UIRounded | UI | 待完成 |
| UI 渐变 | UIGradient | UI | 待完成 |

## 打开工程

1. 克隆 `https://github.com/sophia-y-labs/RenderLib.git`
2. 用 Unity **2022.3 LTS**（URP 14）打开工程。
3. 运行 `Assets/Scenes/Gallery.unity`。
4. 分类演示场景：`Demo_Shading`、`Demo_Stylized`、`Demo_VFX`、`Demo_Environment`、`Demo_PostProcess`（均在 `Assets/Scenes/`）。

## 目录

`Assets/_Core` 放公共 HLSL。`Assets/Shaders` 按分类存放效果。`Assets/Scenes` 包含 Gallery 以及每个已完成分类对应的演示场景。

## 许可

MIT，见 [LICENSE](LICENSE)。
