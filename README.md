> [!WARNING]
> Use `--recursive` flag when git cloning this repository

## Install in Unity

1. Setup [VoltstroUPM](https://github.com/Voltstro/VoltstroUPM#setup)
2. Define the additional scopes `org.nuget` and `com.cysharp.unitask` with VoltstroUPM
3. Install the required packages!
    - UnityWebBrowser
4. Install an engine:
    - E.G.: UnityWebBrowser CEF Engine with Windows natives

## Additional resources

- [setup article](https://projects.voltstro.dev/UnityWebBrowser/articles/user/setup/)
- [developer guide article](https://projects.voltstro.dev/UnityWebBrowser/articles/dev/dev-guide/)
- [UWB's project site](https://projects.voltstro.dev/UnityWebBrowser/articles/)
- [CEF](https://bitbucket.org/chromiumembedded/cef/src/master/) - Underlying web engine.
- [CefGlue](https://gitlab.com/xiliumhq/chromiumembedded/cefglue) - C# wrapper.
- [CefUnitySample](https://github.com/aleab/cef-unity-sample) - CEF directly in Unity. Has crashing problems tho.
- [unity_browser](https://github.com/tunerok/unity_browser) - (Orginally by Vitaly Chashin) CEF working in Unity using IPC, but the project is in a messy state.
- [ChromiumGtk](https://github.com/lunixo/ChromiumGtk) - Linux stuff with CEF
