import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.file.Files;
import java.util.prefs.Preferences;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import javafx.concurrent.Task;

public class InstallManager {

    private static final Preferences prefs = Preferences.userNodeForPackage(InstallManager.class);
    private static File customInstallDir = null;

    public interface InstallCallback {
        void onProgress(double progress, double downloadedMb, double totalMb);
        void onCompleted();
        void onError(String message);
    }

    public static class ReleaseInfo {
        public String tagName;
        public String downloadUrl;

        public ReleaseInfo(String tagName, String downloadUrl) {
            this.tagName = tagName;
            this.downloadUrl = downloadUrl;
        }
    }

    public static File getDefaultInstallDirectory() {
        String localAppData = System.getenv("LOCALAPPDATA");
        if (localAppData == null || localAppData.isEmpty()) {
            localAppData = System.getProperty("user.home") + File.separator + "AppData" + File.separator + "Local";
        }
        return new File(localAppData + File.separator + "EXEUNOFFICIAL" + File.separator + "sonicexeunofficial");
    }

    public static File getInstallDirectory() {
        if (customInstallDir != null) {
            return customInstallDir;
        }
        String savedPath = prefs.get("install_path", null);
        if (savedPath != null) {
            customInstallDir = new File(savedPath);
            return customInstallDir;
        }
        return getDefaultInstallDirectory();
    }

    public static void setInstallDirectory(File baseDir) {
        if (baseDir != null) {
            File safeDir;
            if (baseDir.getName().equalsIgnoreCase("sonicexeunofficial")) {
                safeDir = baseDir;
            } else {
                safeDir = new File(baseDir, "sonicexeunofficial");
            }
            customInstallDir = safeDir;
            prefs.put("install_path", safeDir.getAbsolutePath());
        }
    }

    public static void resetToDefaultDirectory() {
        customInstallDir = null;
        prefs.remove("install_path");
    }

    public static File getGameExecutable() {
        return new File(getInstallDirectory(), "SonicExe.exe");
    }

    public static void closeGameIfRunning() {
        try {
            String exeName = getGameExecutable().getName();
            ProcessBuilder pb = new ProcessBuilder("taskkill", "/F", "/IM", exeName);
            Process process = pb.start();
            process.waitFor();
        } catch (Exception ignored) {}
    }

    public static File getVersionFile() {
        return new File(getInstallDirectory(), "version.json");
    }

    public static String getLocalVersion() {
        File verFile = getVersionFile();
        if (verFile.exists()) {
            try {
                String content = Files.readString(verFile.toPath());
                Pattern pattern = Pattern.compile("\"version\"\\s*:\\s*\"([^\"]+)\"");
                Matcher matcher = pattern.matcher(content);
                if (matcher.find()) {
                    return matcher.group(1);
                }
            } catch (Exception ignored) {}
        }
        return "0.0.0";
    }

    public static void saveLocalVersion(String version) {
        File targetDir = getInstallDirectory();
        if (!targetDir.exists()) targetDir.mkdirs();
        File verFile = getVersionFile();
        try {
            String json = "{\n  \"version\": \"" + version + "\"\n}";
            Files.writeString(verFile.toPath(), json);
        } catch (Exception e) {
            System.out.println("Error saving local version: " + e.getMessage());
        }
    }

    public static ReleaseInfo fetchLatestRelease(String repoOwner, String repoName) throws Exception {
        String apiUrl = "https://api.github.com/repos/" + repoOwner + "/" + repoName + "/releases/latest";
        URL url = new URL(apiUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("User-Agent", "Mozilla/5.0");
        conn.setRequestProperty("Accept", "application/vnd.github.v3+json");

        if (conn.getResponseCode() == 200) {
            InputStream is = conn.getInputStream();
            String jsonResponse = new String(is.readAllBytes());
            conn.disconnect();

            Pattern tagPattern = Pattern.compile("\"tag_name\"\\s*:\\s*\"([^\"]+)\"");
            Matcher tagMatcher = tagPattern.matcher(jsonResponse);
            String tagName = tagMatcher.find() ? tagMatcher.group(1) : "";

            Pattern urlPattern = Pattern.compile("\"browser_download_url\"\\s*:\\s*\"([^\"]+)\"");
            Matcher urlMatcher = urlPattern.matcher(jsonResponse);
            String downloadUrl = urlMatcher.find() ? urlMatcher.group(1) : "";

            if (!tagName.isEmpty() && !downloadUrl.isEmpty()) {
                return new ReleaseInfo(tagName, downloadUrl);
            }
        }
        conn.disconnect();
        throw new Exception("Error obtaining Github repo information..");
    }

    public static void downloadAndInstall(String downloadUrl, String newVersion, InstallCallback callback) {
        Task<Void> task = new Task<>() {
            @Override
            protected Void call() throws Exception {
                closeGameIfRunning();

                File targetDir = getInstallDirectory();
                if (!targetDir.exists()) {
                    targetDir.mkdirs();
                }

                File tempZip = new File(targetDir, "download_temp.zip");

                HttpURLConnection httpConn = openConnectionWithRedirects(downloadUrl);
                int responseCode = httpConn.getResponseCode();

                if (responseCode == HttpURLConnection.HTTP_OK) {
                    long contentLength = httpConn.getContentLengthLong();
                    InputStream inputStream = new BufferedInputStream(httpConn.getInputStream());
                    FileOutputStream outputStream = new FileOutputStream(tempZip);

                    byte[] buffer = new byte[8192];
                    int bytesRead;
                    long totalBytesRead = 0;

                    while ((bytesRead = inputStream.read(buffer)) != -1) {
                        outputStream.write(buffer, 0, bytesRead);
                        totalBytesRead += bytesRead;

                        double currentMb = totalBytesRead / (1024.0 * 1024.0);
                        double totalMb = contentLength > 0 ? contentLength / (1024.0 * 1024.0) : 0;
                        double progress = contentLength > 0 ? (double) totalBytesRead / contentLength : -1;

                        updateProgress(totalBytesRead, contentLength);
                        
                        javafx.application.Platform.runLater(() -> 
                            callback.onProgress(progress, currentMb, totalMb)
                        );
                    }

                    outputStream.close();
                    inputStream.close();
                    httpConn.disconnect();

                    cleanDirectoryExceptTempZip(targetDir, tempZip);
                    unzip(tempZip, targetDir);

                    if (tempZip.exists()) {
                        tempZip.delete();
                    }

                    saveLocalVersion(newVersion);

                } else {
                    throw new Exception("Error HTTP Server: " + responseCode);
                }
                return null;
            }
        };

        task.setOnSucceeded(e -> callback.onCompleted());
        task.setOnFailed(e -> callback.onError(task.getException() != null ? task.getException().getMessage() : "Unknow err"));

        Thread thread = new Thread(task);
        thread.setDaemon(true);
        thread.start();
    }

    private static HttpURLConnection openConnectionWithRedirects(String urlString) throws Exception {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestProperty("User-Agent", "Mozilla/5.0");
        conn.setInstanceFollowRedirects(true);

        int status = conn.getResponseCode();
        if (status == HttpURLConnection.HTTP_MOVED_TEMP 
            || status == HttpURLConnection.HTTP_MOVED_PERM 
            || status == HttpURLConnection.HTTP_SEE_OTHER) {

            String newUrl = conn.getHeaderField("Location");
            conn.disconnect();
            return openConnectionWithRedirects(newUrl);
        }
        return conn;
    }

    private static void cleanDirectoryExceptTempZip(File dir, File tempZip) {
        if (dir.exists() && dir.isDirectory()) {
            File[] files = dir.listFiles();
            if (files != null) {
                for (File f : files) {
                    if (f.getAbsolutePath().equals(tempZip.getAbsolutePath())) {
                        continue;
                    }
                    deleteRecursive(f);
                }
            }
        }
    }

    private static void deleteRecursive(File file) {
        if (file.isDirectory()) {
            File[] children = file.listFiles();
            if (children != null) {
                for (File child : children) {
                    deleteRecursive(child);
                }
            }
        }
        file.delete();
    }

    private static void unzip(File zipFile, File destDir) throws Exception {
        try (ZipInputStream zipIn = new ZipInputStream(new BufferedInputStream(new java.io.FileInputStream(zipFile)))) {
            ZipEntry entry = zipIn.getNextEntry();

            while (entry != null) {
                File filePath = new File(destDir, entry.getName());
                if (!entry.isDirectory()) {
                    File parentDir = filePath.getParentFile();
                    if (!parentDir.exists()) {
                        parentDir.mkdirs();
                    }
                    try (FileOutputStream fos = new FileOutputStream(filePath)) {
                        byte[] bytes = new byte[8192];
                        int read;
                        while ((read = zipIn.read(bytes)) != -1) {
                            fos.write(bytes, 0, read);
                        }
                    }
                } else {
                    filePath.mkdirs();
                }
                zipIn.closeEntry();
                entry = zipIn.getNextEntry();
            }
        }
    }
}