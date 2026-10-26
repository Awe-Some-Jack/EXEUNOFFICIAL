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

    private static final String OS_NAME = System.getProperty("os.name", "").toLowerCase();
    private static final String OS_ARCH = System.getProperty("os.arch", "").toLowerCase();

    public static final boolean IS_WINDOWS = OS_NAME.contains("win");
    public static final boolean IS_MAC = OS_NAME.contains("mac") || OS_NAME.contains("darwin");
    public static final boolean IS_LINUX = OS_NAME.contains("nux") || OS_NAME.contains("nix") || OS_NAME.contains("aix");

    public static final boolean IS_ARM64 = OS_ARCH.contains("aarch64") || OS_ARCH.contains("arm64");

    public static File getDefaultInstallDirectory() {
        String home = System.getProperty("user.home");
        String base;
        if (IS_WINDOWS) {
            base = System.getenv("LOCALAPPDATA");
            if (base == null || base.isEmpty()) {
                base = home + File.separator + "AppData" + File.separator + "Local";
            }
        } else if (IS_MAC) {
            base = home + File.separator + "Library" + File.separator + "Application Support";
        } else {
            base = System.getenv("XDG_DATA_HOME");
            if (base == null || base.isEmpty()) {
                base = home + File.separator + ".local" + File.separator + "share";
            }
        }
        return new File(base + File.separator + "EXEUNOFFICIAL" + File.separator + "sonicexeunofficial");
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
        File dir = getInstallDirectory();
        if (IS_WINDOWS) {
            return new File(dir, "SonicExe.exe");
        }
        File[] candidates = {
            new File(dir, "SonicExe"),
            new File(dir, "SonicExe.app/Contents/MacOS/SonicExe"),
            new File(dir, "SonicExe.sh")
        };
        for (File candidate : candidates) {
            if (candidate.isFile()) {
                return candidate;
            }
        }
        return candidates[IS_MAC ? 1 : 0];
    }

    private static void markExecutables(File dir) {
        if (IS_WINDOWS) return;
        for (String rel : new String[] {"SonicExe", "SonicExe.sh", "SonicExe.app/Contents/MacOS/SonicExe"}) {
            File f = new File(dir, rel);
            if (f.isFile()) {
                f.setExecutable(true, false);
            }
        }
    }

    public static void closeGameIfRunning() {
        try {
            String exeName = getGameExecutable().getName();
            ProcessBuilder pb = IS_WINDOWS
                ? new ProcessBuilder("taskkill", "/F", "/IM", exeName)
                : new ProcessBuilder("pkill", "-x", exeName);
            Process process = pb.start();
            process.waitFor();
        } catch (Exception ignored) {}
    }

    private static String pickDownloadUrl(String jsonResponse) {
        Matcher matcher = Pattern.compile("\"browser_download_url\"\\s*:\\s*\"([^\"]+)\"").matcher(jsonResponse);
        String fallbackUrl = "";
        String bestMatchUrl = "";

        while (matcher.find()) {
            String url = matcher.group(1);
            String filename = url.substring(url.lastIndexOf('/') + 1).toLowerCase();

            if (fallbackUrl.isEmpty()) {
                fallbackUrl = url;
            }

            if (!filename.endsWith(".zip")) {
                continue;
            }

            if (IS_WINDOWS) {
                if (filename.endsWith("-win.zip") || filename.endsWith("-windows.zip") || filename.contains("win")) {
                    bestMatchUrl = url;
                    break;
                }
            } else if (IS_MAC) {
                if (IS_ARM64) {
                    if (filename.endsWith("-mac-arm64.zip") || filename.endsWith("-mac-silicon.zip") || filename.endsWith("-mac-m1.zip")) {
                        bestMatchUrl = url;
                        break;
                    }
                } else {
                    if (filename.endsWith("-mac-intel.zip") || filename.endsWith("-mac-x64.zip")) {
                        bestMatchUrl = url;
                        break;
                    }
                }

                if (filename.endsWith("-mac.zip")) {
                    bestMatchUrl = url;
                    break;
                }
            } else if (IS_LINUX) {
                if (filename.endsWith("-linux.zip")) {
                    bestMatchUrl = url;
                    break;
                }
            }
        }

        return bestMatchUrl.isEmpty() ? fallbackUrl : bestMatchUrl;
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

            String downloadUrl = pickDownloadUrl(jsonResponse);

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
                    markExecutables(targetDir);

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