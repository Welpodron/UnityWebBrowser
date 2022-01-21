#if UNITY_EDITOR

using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEngine;

namespace UnityWebBrowser.Editor.EngineManagement
{
    /// <summary>
    ///     Manages UWB engines
    /// </summary>
    public static class BrowserEngineManager
    {
        internal static List<BrowserEngine> Engines { get; } = new();

        /// <summary>
        ///     Adds a <see cref="BrowserEngine" />.
        ///     <para>This must be called every assembly reload!</para>
        /// </summary>
        /// <param name="engine">The <see cref="BrowserEngine" /> you want to add</param>
        public static void AddEngine(BrowserEngine engine)
        {
            if (!CheckIfAppExists(engine))
            {
                Debug.LogError($"{engine.EngineName} is setup incorrectly!");
                return;
            }

            Engines.Add(engine);
        }

        /// <summary>
        ///     Gets a <see cref="BrowserEngine" /> by its <see cref="BrowserEngine.EngineAppFile" />
        /// </summary>
        /// <param name="engineAppName"></param>
        /// <returns></returns>
        public static BrowserEngine GetEngine(string engineAppName)
        {
            return Engines.FirstOrDefault(x => x.EngineAppFile == engineAppName);
        }

        private static bool CheckIfAppExists(BrowserEngine engine)
        {
            foreach (KeyValuePair<BuildTarget, string> files in engine.BuildFiles)
            {
                string path = Path.GetFullPath(files.Value);
                string engineFile;
                if (files.Key == BuildTarget.StandaloneWindows || files.Key == BuildTarget.StandaloneWindows64)
                    engineFile = $"{engine.EngineAppFile}.exe";
                else
                    engineFile = engine.EngineAppFile;

                if (File.Exists($"{path}{engineFile}"))
                    continue;

                Debug.LogError($"{files.Key} target is missing {engine.EngineAppFile}!");
                return false;
            }

            return true;
        }

        [PostProcessBuild(1)]
        private static void CopyFilesOnBuild(BuildTarget target, string pathToBuiltProject)
        {
            Debug.Log("Copying browser engine files...");

            if (Engines.Count == 0)
            {
                Debug.LogWarning("No browser engines to copy!");
                return;
            }

            //Get full dir
            pathToBuiltProject = Path.GetDirectoryName(pathToBuiltProject);

            //We need to get the built project's plugins folder
            string buildPluginsDir = Path.GetFullPath($"{pathToBuiltProject}/{Application.productName}_Data/UWB/");

            //Make sure it exists
            if (!Directory.Exists(buildPluginsDir))
                Directory.CreateDirectory(buildPluginsDir);

            //Go trough all installed engines
            foreach (BrowserEngine engine in Engines)
            {
                //Check if the engine has our build target
                if (!engine.BuildFiles.ContainsKey(target))
                    continue;

                //Get the location where we are copying all the files
                string buildFilesDir = Path.GetFullPath(engine.BuildFiles[target]);
                string buildFilesParent = Directory.GetParent(buildFilesDir)?.Name;

                //Get all files that aren't Unity .meta files
                string[] files = Directory.EnumerateFiles(buildFilesDir, "*.*", SearchOption.AllDirectories)
                    .Where(fileType => !fileType.EndsWith(".meta"))
                    .ToArray();
                int size = files.Length;

                //Now to copy all the files.
                //We need to keep the structure of the process
                for (int i = 0; i < size; i++)
                {
                    string file = files[i];
                    string destFileName = Path.GetFileName(file);
                    EditorUtility.DisplayProgressBar("Copying Browser Engine Files",
                        $"Copying {destFileName}", i / size);

                    string parentDirectory = "";
                    if (Directory.GetParent(file)?.Name != buildFilesParent)
                    {
                        parentDirectory = $"{Directory.GetParent(file)?.Name}/";

                        if (!Directory.Exists($"{buildPluginsDir}{parentDirectory}"))
                            Directory.CreateDirectory($"{buildPluginsDir}{parentDirectory}");
                    }

                    //Copy the file
                    File.Copy(file, $"{buildPluginsDir}{parentDirectory}{destFileName}", true);
                }

                EditorUtility.ClearProgressBar();
            }

            Debug.Log("Done!");
        }
    }
}

#endif