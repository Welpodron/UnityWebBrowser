// UnityWebBrowser (UWB)
// Copyright (c) 2021-2024 Voltstro-Studios
// 
// This project is under the MIT license. See the LICENSE.md file for more details.

using System;
using UnityWebBrowser.Engine.Cef.Shared.Browser;
using VoltstroStudios.UnityWebBrowser.Engine.Shared.Core;
using Xilium.CefGlue;

namespace UnityWebBrowser.Engine.Cef.SubProcess;

public static class Program
{
    public static int Main(string[] args)
    {
        //Setup CEF
        CefRuntime.Load();

        LaunchArgumentsParser argumentsParser = new();
        int subProcessExitCode = 0;
        argumentsParser.Run(args, launchArguments =>
        {
// ReSharper disable once RedundantAssignment
            string[] argv = args;

            //Set up CEF args and the CEF app
            CefMainArgs cefMainArgs = new CefMainArgs(argv);
            UwbCefApp cefApp = new UwbCefApp(launchArguments);

            //Run our sub-processes
            subProcessExitCode = CefRuntime.ExecuteProcess(cefMainArgs, cefApp, IntPtr.Zero);
        });

        return subProcessExitCode;
    }
}