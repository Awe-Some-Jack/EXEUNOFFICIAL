import java.io.File;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.prefs.Preferences;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javafx.scene.text.Text;
import javafx.scene.text.TextFlow;

public class LanguageManager {

    private static Map<String, String> translations = new HashMap<>();
    private static List<String> availableLanguages = new ArrayList<>();
    private static String currentLangCode = "eng_US";

    private static final Preferences prefs = Preferences.userNodeForPackage(LanguageManager.class);

    public static void scanAvailableLanguages() {
        availableLanguages.clear();
        File dir = new File("media/langs");
        if (dir.exists() && dir.isDirectory()) {
            File[] files = dir.listFiles((d, name) -> name.toLowerCase().endsWith(".json"));
            if (files != null) {
                for (File file : files) {
                    String name = file.getName().replace(".json", "");
                    availableLanguages.add(name);
                }
            }
        }
        if (availableLanguages.isEmpty()) {
            availableLanguages.add("eng_US");
        }
    }

    public static List<String> getAvailableLanguages() {
        if (availableLanguages.isEmpty()) {
            scanAvailableLanguages();
        }
        return availableLanguages;
    }

    public static String getCurrentLangCode() {
        return currentLangCode;
    }

    public static String getSavedLanguage() {
        return prefs.get("saved_lang", "eng_US");
    }

    public static String getLanguageDisplayName(String langCode) {
        File file = new File("media/langs/" + langCode + ".json");
        if (file.exists()) {
            try {
                String content = Files.readString(file.toPath());
                Pattern pattern = Pattern.compile("\"id\"\\s*:\\s*\"([^\"]+)\"");
                Matcher matcher = pattern.matcher(content);
                if (matcher.find()) {
                    return matcher.group(1);
                }
            } catch (Exception ignored) {}
        }
        return langCode.toUpperCase();
    }

    public static void loadLanguage(String langCode) {
        currentLangCode = langCode;
        prefs.put("saved_lang", langCode);
        translations.clear();

        File file = new File("media/langs/" + langCode + ".json");
        if (!file.exists()) {
            System.out.println("Lang not founded: " + file.getAbsolutePath());
            return;
        }

        try {
            String content = Files.readString(file.toPath());
            parseJson(content);
        } catch (Exception e) {
            System.out.println("Error loading language " + langCode + ": " + e.getMessage());
        }
    }

    private static void parseJson(String json) {
        json = json.trim();
        if (json.startsWith("{") && json.endsWith("}")) {
            json = json.substring(1, json.length() - 1);
            String[] lines = json.split("\",");

            for (String line : lines) {
                String[] parts = line.split("\":");
                if (parts.length >= 2) {
                    String key = parts[0].replace("\"", "").trim();
                    String value = parts[1].replace("\"", "").replace("}", "").trim();
                    translations.put(key, value);
                }
            }
        }
    }

    public static String get(String key) {
        return translations.getOrDefault(key, "[" + key + "]");
    }

    public static TextFlow parseFormattedText(String key) {
        String rawText = get(key);
        TextFlow textFlow = new TextFlow();

        Pattern pattern = Pattern.compile("(?<red><red>(.*?)</red>)|(?<bold><b>(.*?)</b>)|(?<text>[^<]+)");
        Matcher matcher = pattern.matcher(rawText);

        while (matcher.find()) {
            Text textNode = new Text();

            if (matcher.group("red") != null) {
                textNode.setText(matcher.group(2));
                textNode.getStyleClass().add("text-red");
            } else if (matcher.group("bold") != null) {
                textNode.setText(matcher.group(4));
                textNode.getStyleClass().add("text-bold");
            } else if (matcher.group("text") != null) {
                textNode.setText(matcher.group("text"));
                textNode.getStyleClass().add("about-text");
            }

            textFlow.getChildren().add(textNode);
        }

        return textFlow;
    }
}