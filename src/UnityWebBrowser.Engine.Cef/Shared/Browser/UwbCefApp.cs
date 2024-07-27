// UnityWebBrowser (UWB)
// Copyright (c) 2021-2022 Voltstro-Studios
// 
// This project is under the MIT license. See the LICENSE.md file for more details.

using VoltstroStudios.UnityWebBrowser.Engine.Shared.Core;
using Xilium.CefGlue;

namespace UnityWebBrowser.Engine.Cef.Shared.Browser;

/// <summary>
///     <see cref="CefApp" /> for CefBrowserProcess
/// </summary>
public class UwbCefApp : CefApp
{
    private readonly bool mediaStreamingEnabled;
    private readonly bool noProxyServer;
    private readonly bool remoteDebugging;
    private readonly string[] remoteDebuggingOrigins;

    private UwbCefBrowserProcessHandler browserProcessHandler;

    public UwbCefApp(LaunchArguments launchArguments)
    {
        mediaStreamingEnabled = launchArguments.WebRtc;
        noProxyServer = !launchArguments.ProxyEnabled;
        remoteDebugging = launchArguments.RemoteDebugging != 0;
        remoteDebuggingOrigins = launchArguments.RemoteDebuggingAllowedOrigins;
    }

    protected override void OnBeforeCommandLineProcessing(string processType, CefCommandLine commandLine)
    {
        if (noProxyServer && !commandLine.HasSwitch("--no-proxy-server"))
            commandLine.AppendSwitch("--no-proxy-server");

        if (mediaStreamingEnabled && !commandLine.HasSwitch("--enable-media-stream"))
            commandLine.AppendSwitch("--enable-media-stream");

        if (remoteDebugging && !commandLine.HasSwitch("--remote-allow-origins"))
            commandLine.AppendSwitch("--remote-allow-origins", string.Join(',', remoteDebuggingOrigins));
    }

    protected override CefBrowserProcessHandler GetBrowserProcessHandler()
    {
        browserProcessHandler = new UwbCefBrowserProcessHandler();
        return browserProcessHandler;
    }

    protected override CefRenderProcessHandler GetRenderProcessHandler()
    {
        return new UwbCefRenderProcessHandler();
    }

    protected override void Dispose(bool disposing)
    {
        browserProcessHandler.Dispose();
        base.Dispose(disposing);
    }
}