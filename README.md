# NShiftUI para iOS

Runtime de Server-Driven UI em SwiftUI. O `NShiftRainbowCompiler` interpreta a AST do Rainbow, resolve plugins e eventos registrados pelo aplicativo e produz os modelos que o `NShiftView` renderiza. A gramática e a AST pertencem ao [RainbowParser-iOS](https://github.com/NShiftUI-OSS/RainbowParser-iOS).

## Instalação

A [versão 1.0.0](https://github.com/NShiftUI-OSS/NShiftUI-iOS/releases/tag/v1.0.0) requer Swift 6.3, iOS 15+ e macOS 14+ para desenvolvimento com SwiftPM. O runtime fixa a versão `1.0.0` do RainbowParser-iOS.

```swift
.package(
    url: "https://github.com/NShiftUI-OSS/NShiftUI-iOS.git",
    exact: "1.0.0"
)
```

Adicione o produto `NShiftUI` ao target do app e use `import NShiftUI`. O aplicativo registra seus plugins e eventos em assemblies e inicializa o SDK por `NShiftConfig.shared.startup(hostContainer:assemblies:)`.

- [Aplicação de demonstração](https://github.com/NShiftUI-OSS/NShiftUI-Demo)
- [Documentação pública](https://nshiftui-oss.github.io/NShiftUI-Landing/)
- [Arquitetura e API](Docs/Harness/INDEX.md)

## Desenvolvimento

```bash
swift build
swift test --no-parallel
```

O workflow manual **Release** recebe uma branch e uma versão SemVer, executa testes e build, publica a tag e cria a GitHub Release. O SwiftPM instala o código pela tag.

## Licença

[MIT](LICENSE).
