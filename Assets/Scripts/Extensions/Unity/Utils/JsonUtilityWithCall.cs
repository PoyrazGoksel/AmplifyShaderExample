using System;
using System.IO;
using System.Text;
using UnityEngine;

namespace Extensions.Unity.Utils
{
    public static class JsonUtilityWithCall
    {
        public static T FromJson<T>(string dataString) where T : IJsonCallBackReceiver
        {
            T t = JsonUtility.FromJson<T>(dataString);
            t.OnAfterDeserialize();
            return t;
        }

        public static string ToJson<T>(T t, bool prettyPrint = false) where T : IJsonCallBackReceiver
        {
            t.OnBeforeSerialize();
            return JsonUtility.ToJson(t, prettyPrint);
        }

        /// <summary>
        /// Causes naming error!
        /// </summary>
        /// <param name="saveData"></param>
        /// <param name="path"></param>
        public static void WriteToEnd(string saveData, string path) => WriteToEnd(saveData, path, false, null);
        public static void WriteToEnd(string saveData, string path, bool append) => WriteToEnd(saveData, path, append, null);
        public static void WriteToEnd(string saveData, string path, Encoding encoding) => WriteToEnd(saveData, path, false, encoding);

        public static void WriteToEnd(string saveData, string path, bool append, Encoding encoding)
        {
            StreamWriter streamWriter;

            if (encoding == null)
            {
                streamWriter = new StreamWriter(path, append);
            }
            else
            {
                streamWriter = new StreamWriter(path, append, encoding);
            }

            streamWriter.Write(saveData);
            streamWriter.Flush();
            streamWriter.Close();
        }

        public static string ReadToEnd(string path)
        {
            StreamReader streamReader = new StreamReader(path);
            string streamString = streamReader.ReadToEnd();
            streamReader.Close();
            return streamString;
        }
        
        public static string ReadToEndSafe(string path)
        {
            try
            {
                using (StreamReader streamReader = new StreamReader(path))
                {
                    return streamReader.ReadToEnd();
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"Failed to read from {path}: {ex.Message}");
                return string.Empty; // or throw, depending on your error handling strategy
            }
        }

        public static void WriteToEndSafe(string saveData, string path, bool append, Encoding encoding)
        {
            try
            {
                using (StreamWriter streamWriter = encoding == null ? new StreamWriter(path, append) : new StreamWriter(path, append, encoding))
                {
                    streamWriter.Write(saveData);
                    streamWriter.Flush();
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"Failed to write to {path}: {ex.Message}");
                // Handle the exception (e.g., rethrow, log, etc.)
            }
        }

    }

    public interface IJsonCallBackReceiver
    {
        void OnBeforeSerialize();
        void OnAfterDeserialize();
    }
}