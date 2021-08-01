# Tun editor

## Example

本项目配备 example 以用于插件调试，也可以基本查看框架提供的基本接口。

### 运行命令

```bash
cd example
flutter run
```

## 集成方式

直接根据目录的相对路径作为依赖引入即可，打开 `pubspec.yaml` 文件

```yaml
dependencies:
  flutter:
    sdk: flutter
  tun_editor:
    path: ../tun_editor   # 假设插件与你的项目是同级的
```

## 开放接口

接口原则上直接参考 [flutter-quill](https://github.com/singerdmx/flutter-quill) ，

部分可能进行了空安全类型优化，具体以源码注释为准即可，特定的接口都会有适当注释说明，

参考源码即可。
